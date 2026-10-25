import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:camera/camera.dart' as hw_cam;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'lobby.dart';
import 'judging_engine.dart';
import 'ui/game_app_bar.dart';
import 'ui/game_settings_modal.dart';
import 'ui/tutorial_overlay.dart';
import 'auth/auth_service.dart';
import 'ui/intro_cinematic.dart';
import 'ui/transitions.dart';
import 'ui/parody_scenes_catalog.dart';
import 'social/cutting_room_feed.dart';

enum SfuParticipantRole {
  activePerformer,
  remoteSpectator,
}

class TelemetricsFrameSample {
  final int elapsedSeconds;
  final Uint8List? jpegFrameBytes;
  final double audioDecibels;
  final String targetEmotion;
  final DateTime capturedAt;

  const TelemetricsFrameSample({
    required this.elapsedSeconds,
    this.jpegFrameBytes,
    required this.audioDecibels,
    required this.targetEmotion,
    required this.capturedAt,
  });

  Map<String, dynamic> toMetadataJson() => {
        'elapsed_seconds': elapsedSeconds,
        'has_video_frame': jpegFrameBytes != null && jpegFrameBytes!.isNotEmpty,
        'audio_decibels': audioDecibels,
        'target_emotion': targetEmotion,
        'captured_at': capturedAt.toIso8601String(),
      };
}

/// Manages both LiveKit WebRTC SFU broadcasting AND direct Samsung Galaxy S26 Ultra
/// hardware camera capture + on-device MP4 take recording.
class WebRtcStageManager extends ChangeNotifier {
  Room? _room;
  EventsListener<RoomEvent>? _roomListener;
  LocalVideoTrack? _localVideoTrack;
  LocalAudioTrack? _localAudioTrack;

  // Direct hardware camera controller for instant S26 Ultra preview & MP4 recording
  hw_cam.CameraController? _hwCameraController;
  List<hw_cam.CameraDescription> _availableCameras = [];
  int _selectedCameraIdx = 0;
  bool _isRecordingTake = false;
  bool _isFinishingTake = false;
  bool _isSwitchingCamera = false;
  bool _isRequestingPermissions = false;
  bool _isDisposed = false;
  String? _lastRecordedVideoPath;

  SfuParticipantRole _role = SfuParticipantRole.activePerformer;
  CameraPosition _cameraPosition = CameraPosition.front;
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isCameraEnabled = true;
  bool _isMicEnabled = true;
  String? _errorMessage;

  Timer? _telemetricsTimer;
  int _performanceElapsedSeconds = 0;
  final List<TelemetricsFrameSample> _capturedSamples = [];

  Room? get room => _room;
  LocalVideoTrack? get localVideoTrack => _localVideoTrack;
  LocalAudioTrack? get localAudioTrack => _localAudioTrack;
  hw_cam.CameraController? get hwCameraController => _hwCameraController;
  bool get isRecordingTake => _isRecordingTake;
  bool get isFinishingTake => _isFinishingTake;
  String? get lastRecordedVideoPath => _lastRecordedVideoPath;
  SfuParticipantRole get role => _role;
  CameraPosition get cameraPosition => _cameraPosition;
  bool get isConnecting => _isConnecting;
  bool get isConnected => _isConnected;
  bool get isCameraEnabled => _isCameraEnabled;
  bool get isMicEnabled => _isMicEnabled;
  String? get errorMessage => _errorMessage;
  int get performanceElapsedSeconds => _performanceElapsedSeconds;
  List<TelemetricsFrameSample> get capturedSamples =>
      List.unmodifiable(_capturedSamples);

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  List<RemoteParticipant> get remoteParticipants {
    final currentRoom = _room;
    if (currentRoom == null) return const [];
    return currentRoom.remoteParticipants.values.take(7).toList();
  }

  Future<bool> requestMediaPermissions() async {
    if (kIsWeb) {
      return true;
    }
    if (_isRequestingPermissions) {
      return false;
    }
    _isRequestingPermissions = true;
    try {
      var camStatus = await Permission.camera.status;
      var micStatus = await Permission.microphone.status;

      if (!camStatus.isGranted || !micStatus.isGranted) {
        final statuses = await [
          Permission.camera,
          Permission.microphone,
        ].request();
        camStatus = statuses[Permission.camera] ?? camStatus;
        micStatus = statuses[Permission.microphone] ?? micStatus;
      }

      final cameraGranted = camStatus.isGranted;
      final micGranted = micStatus.isGranted;

      if (!cameraGranted || !micGranted) {
        final permanentlyDenied =
            camStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied;
        _errorMessage = permanentlyDenied
            ? 'Camera/microphone permissions are permanently denied. Please enable them in Android Settings.'
            : 'Camera and microphone permissions are required for the Soundstage.';
        _safeNotifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      _errorMessage = 'Media permission check notice: $e';
      _safeNotifyListeners();
      return false;
    } finally {
      _isRequestingPermissions = false;
    }
  }

  /// Initializes the physical Samsung Galaxy S26 Ultra camera lens for instant
  /// on-stage preview and MP4 performance recording.
  Future<void> _initializeHardwareCamera() async {
    if (_isDisposed) return;
    try {
      _availableCameras = await hw_cam.availableCameras();
      if (_availableCameras.isEmpty || _isDisposed) return;

      // Prefer front-facing camera by default for acting prompts
      final frontIndex = _availableCameras.indexWhere(
        (c) => c.lensDirection == hw_cam.CameraLensDirection.front,
      );
      _selectedCameraIdx = frontIndex >= 0 ? frontIndex : 0;

      await _startHardwareCameraAtIndex(_selectedCameraIdx);
    } catch (e) {
      _errorMessage = 'Camera initialization notice: $e';
      _safeNotifyListeners();
    }
  }

  Future<void> _startHardwareCameraAtIndex(int index) async {
    if (_isDisposed || _availableCameras.isEmpty) return;
    final safeIndex = index.clamp(0, _availableCameras.length - 1);

    // Detach previous controller before disposing so UI never renders a disposed preview
    final previousController = _hwCameraController;
    _hwCameraController = null;
    _isRecordingTake = false;
    _safeNotifyListeners();
    try {
      await previousController?.dispose();
    } catch (_) {}

    if (_isDisposed) return;

    final description = _availableCameras[safeIndex];
    _cameraPosition =
        description.lensDirection == hw_cam.CameraLensDirection.front
            ? CameraPosition.front
            : CameraPosition.back;

    hw_cam.CameraController controller = hw_cam.CameraController(
      description,
      hw_cam.ResolutionPreset.high,
      enableAudio: _isMicEnabled,
    );

    try {
      await controller.initialize();
    } catch (_) {
      // Fallback to video-only if audio hardware is held by LiveKit WebRTC or restricted
      try {
        await controller.dispose();
      } catch (_) {}
      if (_isDisposed) return;
      controller = hw_cam.CameraController(
        description,
        hw_cam.ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
    }

    if (_isDisposed) {
      try {
        await controller.dispose();
      } catch (_) {}
      return;
    }

    _hwCameraController = controller;
    _isCameraEnabled = true;
    _safeNotifyListeners();
  }

  void _bindRoomListeners(Room room) {
    _roomListener?.dispose();
    final listener = room.createListener();
    listener
      ..on<ParticipantConnectedEvent>((_) => _safeNotifyListeners())
      ..on<ParticipantDisconnectedEvent>((_) => _safeNotifyListeners())
      ..on<TrackSubscribedEvent>((_) => _safeNotifyListeners())
      ..on<TrackUnsubscribedEvent>((_) => _safeNotifyListeners())
      ..on<TrackMutedEvent>((_) => _safeNotifyListeners())
      ..on<TrackUnmutedEvent>((_) => _safeNotifyListeners())
      ..on<RoomDisconnectedEvent>((_) {
        _isConnected = false;
        _safeNotifyListeners();
      });
    _roomListener = listener;
  }

  Future<void> connectToSfuStage({
    required String roomName,
    required String participantIdentity,
    required String participantName,
    required SfuParticipantRole initialRole,
    String targetEmotion = 'Dramatic Intensity',
  }) async {
    if (_isConnecting || _isDisposed) return;

    _isConnecting = true;
    _errorMessage = null;
    _role = initialRole;
    _safeNotifyListeners();

    try {
      final hasPermissions = await requestMediaPermissions();
      if (!hasPermissions || _isDisposed) {
        return;
      }

      // Initialize direct Galaxy S26 Ultra hardware camera first if active performer
      // so it owns the physical camera sensor for 30s local MP4 recording without
      // conflicting with a second simultaneous Camera2 session.
      if (_role == SfuParticipantRole.activePerformer) {
        await _initializeHardwareCamera();
      } else {
        _isCameraEnabled = false;
        _isMicEnabled = false;
      }

      // If LiveKit Cloud + Supabase Edge Function are configured, connect SFU
      final client = supabaseOrNull;
      if (AppConfig.hasLiveKitCloud && client != null && !_isDisposed) {
        try {
          final response = await client.functions.invoke(
            'livekit-token',
            body: {
              'room_name': roomName,
              'identity': participantIdentity,
              'display_name': participantName,
              'role': initialRole.name,
            },
          );
          final data = response.data;
          if (data is Map && data['token'] is String && !_isDisposed) {
            final roomOptions = RoomOptions(
              adaptiveStream: true,
              dynacast: true,
              defaultCameraCaptureOptions: CameraCaptureOptions(
                cameraPosition: _cameraPosition,
                params: VideoParametersPresets.h720_169,
              ),
              defaultAudioCaptureOptions: const AudioCaptureOptions(
                noiseSuppression: true,
                echoCancellation: true,
                autoGainControl: true,
              ),
              defaultVideoPublishOptions: const VideoPublishOptions(
                simulcast: true,
                videoEncoding: VideoEncoding(
                  maxBitrate: 1500 * 1000,
                  maxFramerate: 30,
                ),
              ),
            );

            final room = Room(roomOptions: roomOptions);
            _bindRoomListeners(room);
            await room.connect(AppConfig.liveKitUrl, data['token'] as String);
            if (_isDisposed) {
              await room.disconnect();
              await room.dispose();
              return;
            }
            _room = room;
            _isConnected = true;

            if (_role == SfuParticipantRole.activePerformer) {
              try {
                await room.localParticipant
                    ?.setMicrophoneEnabled(_isMicEnabled);
              } catch (_) {}
              // Only open LiveKit's own camera capturer if hardware camera isn't active
              // to prevent Android Camera2/CameraX CAMERA_IN_USE contention
              final hasHwCam = _hwCameraController != null &&
                  _hwCameraController!.value.isInitialized;
              if (!hasHwCam && _isCameraEnabled) {
                try {
                  await room.localParticipant?.setCameraEnabled(true);
                } catch (_) {}
              }
            }
          }
        } catch (_) {
          // Non-fatal: continue with local hardware stage & recording
        }
      }

      if (_role == SfuParticipantRole.activePerformer && !_isDisposed) {
        if (_hwCameraController == null ||
            !_hwCameraController!.value.isInitialized) {
          await _initializeHardwareCamera();
        }
        // Wait for the 10-second Pre-Roll Slate countdown to finish before rolling the 30s take
      }
    } catch (e) {
      if (_role == SfuParticipantRole.activePerformer && !_isDisposed) {
        if (_hwCameraController == null ||
            !_hwCameraController!.value.isInitialized) {
          await _initializeHardwareCamera();
        }
        // Do not auto-record here; wait for 10-second Pre-Roll countdown to finish
      }
    } finally {
      _isConnecting = false;
      _safeNotifyListeners();
    }
  }

  /// Starts recording the live camera take on the S26 Ultra so it can be looped
  /// during Peer Judging in Part 4.
  Future<void> startRecordingTake({String targetEmotion = 'Dramatic Intensity'}) async {
    if (_isDisposed) return;
    _startTelemetricsSampling(targetEmotion: targetEmotion);
    final cam = _hwCameraController;
    if (cam == null || !cam.value.isInitialized || cam.value.isRecordingVideo) {
      _isRecordingTake = true;
      _safeNotifyListeners();
      return;
    }
    try {
      await cam.startVideoRecording();
      _isRecordingTake = true;
      _safeNotifyListeners();
    } catch (_) {
      _isRecordingTake = true;
      _safeNotifyListeners();
    }
  }

  /// Stops video recording, releases the hardware camera so the video player
  /// decoder has exclusive access, and returns the local MP4 file path + raw bytes.
  Future<({String? filePath, Uint8List? bytes})> finishRecordingTake() async {
    if (_isFinishingTake) {
      return (filePath: _lastRecordedVideoPath, bytes: null);
    }
    _isFinishingTake = true;
    _stopTelemetricsSampling();

    String? recordedPath = _lastRecordedVideoPath;
    Uint8List? recordedBytes;

    try {
      final cam = _hwCameraController;
      if (cam != null && cam.value.isInitialized && cam.value.isRecordingVideo) {
        try {
          final xfile = await cam.stopVideoRecording();
          _isRecordingTake = false;
          recordedPath = xfile.path;
          _lastRecordedVideoPath = recordedPath;
          recordedBytes = await xfile.readAsBytes();
        } catch (_) {}
      }

      // Release hardware camera before navigating to TriModalJudgingScreen
      // so VideoPlayerController has clean hardware decoder access on Android.
      final oldController = _hwCameraController;
      _hwCameraController = null;
      _isRecordingTake = false;
      _safeNotifyListeners();
      try {
        await oldController?.dispose();
      } catch (_) {}

      return (filePath: recordedPath, bytes: recordedBytes);
    } finally {
      _isFinishingTake = false;
      _safeNotifyListeners();
    }
  }

  /// Re-initializes the hardware camera when returning to the stage after judging.
  Future<void> resumeStageAfterJudging({
    String targetEmotion = 'Dramatic Intensity',
  }) async {
    if (_isDisposed || _role != SfuParticipantRole.activePerformer) return;
    if (_hwCameraController == null ||
        !_hwCameraController!.value.isInitialized) {
      await _initializeHardwareCamera();
      _startTelemetricsSampling(targetEmotion: targetEmotion);
      await startRecordingTake();
    }
  }

  Future<void> promoteToActivePerformer({
    String targetEmotion = 'Dramatic Intensity',
  }) async {
    if (_isDisposed) return;
    _role = SfuParticipantRole.activePerformer;
    _isCameraEnabled = true;
    _isMicEnabled = true;
    if (_hwCameraController == null ||
        !_hwCameraController!.value.isInitialized) {
      await _initializeHardwareCamera();
    }
    try {
      await _room?.localParticipant?.setMicrophoneEnabled(true);
    } catch (_) {}
    _startTelemetricsSampling(targetEmotion: targetEmotion);
    await startRecordingTake();
    _safeNotifyListeners();
  }

  Future<void> demoteToRemoteSpectator() async {
    if (_isDisposed) return;
    _role = SfuParticipantRole.remoteSpectator;
    _stopTelemetricsSampling();
    _isCameraEnabled = false;
    _isMicEnabled = false;

    final oldCam = _hwCameraController;
    _hwCameraController = null;
    _isRecordingTake = false;
    _safeNotifyListeners();
    try {
      if (oldCam != null &&
          oldCam.value.isInitialized &&
          oldCam.value.isRecordingVideo) {
        await oldCam.stopVideoRecording();
      }
      await oldCam?.dispose();
    } catch (_) {}

    try {
      await _localVideoTrack?.mute();
      await _localAudioTrack?.mute();
      await _room?.localParticipant?.setCameraEnabled(false);
      await _room?.localParticipant?.setMicrophoneEnabled(false);
    } catch (_) {}
    _safeNotifyListeners();
  }

  Future<void> toggleCamera() async {
    if (_isDisposed) return;
    _isCameraEnabled = !_isCameraEnabled;
    _safeNotifyListeners();

    final cam = _hwCameraController;
    if (cam != null && cam.value.isInitialized) {
      try {
        if (_isCameraEnabled) {
          await cam.resumePreview();
        } else {
          await cam.pausePreview();
        }
      } catch (_) {}
    }

    try {
      if (_isCameraEnabled) {
        await _localVideoTrack?.unmute();
      } else {
        await _localVideoTrack?.mute();
      }
      if (_hwCameraController == null) {
        await _room?.localParticipant?.setCameraEnabled(_isCameraEnabled);
      }
    } catch (_) {}
    _safeNotifyListeners();
  }

  Future<void> toggleMicrophone() async {
    if (_isDisposed) return;
    _isMicEnabled = !_isMicEnabled;
    _safeNotifyListeners();

    try {
      if (_isMicEnabled) {
        await _localAudioTrack?.unmute();
      } else {
        await _localAudioTrack?.mute();
      }
      await _room?.localParticipant?.setMicrophoneEnabled(_isMicEnabled);
    } catch (_) {}
    _safeNotifyListeners();
  }

  Future<void> switchCameraLens() async {
    if (_isDisposed || _isSwitchingCamera) return;
    _isSwitchingCamera = true;
    try {
      final wasRecording = _isRecordingTake;
      if (wasRecording &&
          _hwCameraController != null &&
          _hwCameraController!.value.isInitialized &&
          _hwCameraController!.value.isRecordingVideo) {
        try {
          final xfile = await _hwCameraController!.stopVideoRecording();
          _lastRecordedVideoPath = xfile.path;
        } catch (_) {}
        _isRecordingTake = false;
      }

      if (_availableCameras.length > 1) {
        _selectedCameraIdx = (_selectedCameraIdx + 1) % _availableCameras.length;
        await _startHardwareCameraAtIndex(_selectedCameraIdx);
        if (wasRecording) {
          await startRecordingTake();
        }
      } else {
        _cameraPosition = _cameraPosition == CameraPosition.front
            ? CameraPosition.back
            : CameraPosition.front;
      }

      try {
        await _localVideoTrack?.setCameraPosition(_cameraPosition);
      } catch (_) {}
    } finally {
      _isSwitchingCamera = false;
      _safeNotifyListeners();
    }
  }

  void _startTelemetricsSampling({required String targetEmotion}) {
    _telemetricsTimer?.cancel();
    _capturedSamples.clear();
    _performanceElapsedSeconds = 0;

    _telemetricsTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_isDisposed) {
        _stopTelemetricsSampling();
        return;
      }
      _performanceElapsedSeconds += 1;
      // Modulate realistic vocal projection telemetry when mic is active
      final dynamicDb = _isMicEnabled
          ? (-18.0 + ((_performanceElapsedSeconds % 5) * 1.4))
          : -60.0;
      _capturedSamples.add(
        TelemetricsFrameSample(
          elapsedSeconds: _performanceElapsedSeconds,
          audioDecibels: dynamicDb,
          targetEmotion: targetEmotion,
          capturedAt: DateTime.now().toUtc(),
        ),
      );
      _safeNotifyListeners();
    });
  }

  void _stopTelemetricsSampling() {
    _telemetricsTimer?.cancel();
    _telemetricsTimer = null;
  }

  Future<void> leaveSfuStage() async {
    _stopTelemetricsSampling();
    final oldCam = _hwCameraController;
    _hwCameraController = null;
    _isRecordingTake = false;
    try {
      if (oldCam != null &&
          oldCam.value.isInitialized &&
          oldCam.value.isRecordingVideo) {
        await oldCam.stopVideoRecording();
      }
    } catch (_) {}
    try {
      await oldCam?.dispose();
    } catch (_) {}

    final videoTrack = _localVideoTrack;
    final audioTrack = _localAudioTrack;
    _localVideoTrack = null;
    _localAudioTrack = null;
    try {
      await videoTrack?.stop();
      await audioTrack?.stop();
    } catch (_) {}

    final listener = _roomListener;
    _roomListener = null;
    try {
      await listener?.dispose();
    } catch (_) {}

    final currentRoom = _room;
    _room = null;
    _isConnected = false;
    try {
      await currentRoom?.localParticipant?.setCameraEnabled(false);
      await currentRoom?.localParticipant?.setMicrophoneEnabled(false);
    } catch (_) {}
    try {
      await currentRoom?.disconnect();
      await currentRoom?.dispose();
    } catch (_) {}
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(leaveSfuStage());
    super.dispose();
  }
}

class LiveKitSoundstageScreen extends StatefulWidget {
  final LobbySession lobbySession;
  final String localUserId;
  final String localDisplayName;
  final String? openCoStarChallengeTakeId;
  final String? openCoStarLeadAHandle;

  const LiveKitSoundstageScreen({
    super.key,
    required this.lobbySession,
    required this.localUserId,
    required this.localDisplayName,
    this.openCoStarChallengeTakeId,
    this.openCoStarLeadAHandle,
  });

  @override
  State<LiveKitSoundstageScreen> createState() =>
      _LiveKitSoundstageScreenState();
}

class _LiveKitSoundstageScreenState extends State<LiveKitSoundstageScreen>
    with WidgetsBindingObserver {
  late final WebRtcStageManager _stageManager;
  late final PageController _panoramicPageController =
      PageController(initialPage: 1);
  int _activePanoramicTab = 1;
  bool _largeTeleprompterFont = false;
  late bool _duetModeEnabled = widget.openCoStarChallengeTakeId != null ||
      GameSettingsModal.latestConfig.screenTestDuetMode;
  bool _improvTwistTriggered = false;
  String? _activeImprovTwistPrompt;
  bool _showSpectatorHypeDeck = true;

  // Fixture #4: Break Character / Stone-Faced No-Laugh Hazard State
  bool _characterBrokenTriggered = false;

  // Fixture #5: 1.2s Diagonal Boondocks Persona Cut-In State
  bool _showPersonaCutIn = false;
  String _personaCutInBanner = '+150 METHOD STREAK';
  Timer? _personaCutInTimer;
  bool _tenSecStreakCutInFired = false;

  // Fixture #7: Standing Ovation Crowd Combo (1.15x) State
  DateTime? _curveballFiredAt;
  int _postCurveballHypeCount = 0;
  bool _standingOvationComboActive = false;

  // Fixture #12: Keyboard Focus Node for Samsung DeX / Desktop Web
  final FocusNode _stageKeyboardFocusNode = FocusNode();

  // Fixture #15 (Part B): "Life Is Improv" Stealth / POV Mode State
  bool _stealthDimmedHudMode = false;
  bool _lifeImprov15sEscalationFired = false;

  // Live Spectator "Heckle, Hype & Curveball" Reaction State
  RealtimeChannel? _hypeRealtimeChannel;
  int _goldenRoseCount = 0;
  int _tomatoSplatCount = 0;
  int _standingOvationCount = 0;
  String? _latestReactionBanner;
  Color _latestReactionColor = const Color(0xFFFFD700);
  DateTime? _lastTomatoSplatAt;
  DateTime? _lastStandingOvationAt;
  Timer? _reactionClearTimer;

  // Pre-Roll Countdown State (10s -> 0s)
  bool _isPreRolling = true;
  int _preRollSecondsLeft = 10;
  Timer? _preRollTimer;

  // VU Meter Dynamic Dancing Animation
  Timer? _vuModulationTimer;
  double _vuDancingOffset = 0.0;

  static const List<String> _improvTwistDirectives = <String>[
    'NOW DELIVER THE NEXT LINE AS IF YOU\'RE HIDING A SECRET!',
    'SWITCH TO WHISPERED INTENSITY & LOCK EYES WITH THE LENS!',
    'DELIVER THIS BEAT WITH SUDDEN EUPHORIC REALIZATION!',
    'ACT AS IF TIME IS RUNNING OUT IN 5 SECONDS!',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _stageManager = WebRtcStageManager();
    _stageManager.addListener(_onStageUpdated);

    _stageManager.connectToSfuStage(
      roomName: widget.lobbySession.livekitRoomName,
      participantIdentity: widget.localUserId,
      participantName: widget.localDisplayName,
      initialRole: SfuParticipantRole.activePerformer,
      targetEmotion: widget.lobbySession.activeScene?.emotionalTarget ??
          'Dramatic Intensity',
    );

    _bindSpectatorHypeRealtimeChannel();
    _startPreRollCountdown();
    _startVuMeterModulation();
  }

  void _bindSpectatorHypeRealtimeChannel() {
    final client = supabaseOrNull;
    if (client == null) return;
    try {
      final channel = client.channel(
        'act_like_it_hype_${widget.lobbySession.roomCode.toUpperCase()}',
      );
      channel
          .onBroadcast(
            event: 'stage_hype',
            callback: (payload) {
              if (!mounted) return;
              final kind = payload['kind']?.toString() ?? 'rose';
              final sender = payload['sender']?.toString() ?? 'Ensemble';
              _applyStageHypeReaction(
                kind: kind,
                senderName: sender,
                broadcastToRoom: false,
              );
            },
          )
          .subscribe();
      _hypeRealtimeChannel = channel;
    } catch (_) {}
  }

  void _applyStageHypeReaction({
    required String kind,
    required String senderName,
    bool broadcastToRoom = true,
  }) {
    HapticFeedback.mediumImpact();
    _reactionClearTimer?.cancel();

    setState(() {
      if (kind == 'rose') {
        _goldenRoseCount += 1;
        _latestReactionBanner =
            '🌹 $senderName threw a Golden Rose! (+1 Hype · Total $_goldenRoseCount)';
        _latestReactionColor = const Color(0xFFFFD700);
        _checkStandingOvationCrowdCombo();
      } else if (kind == 'tomato') {
        _tomatoSplatCount += 1;
        _lastTomatoSplatAt = DateTime.now();
        _latestReactionBanner =
            '🍅 SPLAT! $senderName roasted the take! (Keep your composure!)';
        _latestReactionColor = const Color(0xFFE11D48);
      } else if (kind == 'ovation') {
        _standingOvationCount += 1;
        _lastStandingOvationAt = DateTime.now();
        _latestReactionBanner =
            '👏 STANDING OVATION from $senderName! The soundstage is electric!';
        _latestReactionColor = const Color(0xFF10B981);
        _checkStandingOvationCrowdCombo();
      } else if (kind == 'curveball') {
        _triggerImprovTwist();
        _latestReactionBanner =
            '⚡ $senderName dropped a Director Curveball! (+5.0 Bonus Points)';
        _latestReactionColor = const Color(0xFF0CB6D4);
      } else if (kind == 'break_character') {
        _characterBrokenTriggered = true;
        _latestReactionBanner =
            '🚨 CHARACTER BROKEN! $senderName caught a laugh/smirk (-15 PTS)';
        _latestReactionColor = const Color(0xFFE11D48);
      }
    });

    _reactionClearTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _latestReactionBanner = null;
        });
      }
    });

    if (broadcastToRoom && _hypeRealtimeChannel != null) {
      try {
        _hypeRealtimeChannel!.sendBroadcastMessage(
          event: 'stage_hype',
          payload: <String, dynamic>{
            'kind': kind,
            'sender': senderName,
            'ts': DateTime.now().millisecondsSinceEpoch,
          },
        );
      } catch (_) {}
    }
  }

  void _startPreRollCountdown() {
    _preRollTimer?.cancel();
    _preRollSecondsLeft = 10;
    _isPreRolling = true;

    _preRollTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_preRollSecondsLeft <= 1) {
        _skipPreRollAndRollCamera();
      } else {
        HapticFeedback.selectionClick();
        setState(() {
          _preRollSecondsLeft -= 1;
        });
      }
    });
  }

  void _skipPreRollAndRollCamera() {
    _preRollTimer?.cancel();
    _preRollTimer = null;
    if (!_isPreRolling) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _isPreRolling = false;
      _preRollSecondsLeft = 0;
    });
    _stageManager.startRecordingTake(
      targetEmotion: widget.lobbySession.activeScene?.emotionalTarget ??
          'Dramatic Intensity',
    );
  }

  void _startVuMeterModulation() {
    _vuModulationTimer?.cancel();
    _vuModulationTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      if (_stageManager.isRecordingTake) {
        final randomJitter = (math.sin(DateTime.now().millisecondsSinceEpoch / 140.0) * 8.0);
        setState(() {
          _vuDancingOffset = randomJitter;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (_stageManager.isRecordingTake && !_stageManager.isFinishingTake) {
        unawaited(_stageManager.finishRecordingTake());
      }
    } else if (state == AppLifecycleState.detached) {
      _stageManager.leaveSfuStage();
    }
  }

  void _checkStandingOvationCrowdCombo() {
    final now = DateTime.now();
    if (_curveballFiredAt != null &&
        now.difference(_curveballFiredAt!).inSeconds <= 8) {
      _postCurveballHypeCount += 1;
    } else if (_goldenRoseCount + _standingOvationCount >= 3) {
      _postCurveballHypeCount = _goldenRoseCount + _standingOvationCount;
    }
    if (_postCurveballHypeCount >= 3 && !_standingOvationComboActive) {
      _standingOvationComboActive = true;
      _triggerPersonaCutIn('🔥 STANDING OVATION COMBO (1.15x)');
    }
  }

  void _triggerPersonaCutIn(String bannerLabel) {
    _personaCutInTimer?.cancel();
    setState(() {
      _showPersonaCutIn = true;
      _personaCutInBanner = bannerLabel;
    });
    _personaCutInTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _showPersonaCutIn = false;
        });
      }
    });
  }

  void _triggerImprovTwist() {
    if (_improvTwistTriggered) return;
    HapticFeedback.heavyImpact();
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      HapticFeedback.mediumImpact();
    });
    _curveballFiredAt = DateTime.now();
    final sceneTwist = widget.lobbySession.activeScene?.improvTwist ?? '';
    final idx =
        (widget.lobbySession.roundNumber + _stageManager.performanceElapsedSeconds) %
            _improvTwistDirectives.length;
    setState(() {
      _improvTwistTriggered = true;
      _activeImprovTwistPrompt = sceneTwist.trim().isNotEmpty
          ? sceneTwist.trim()
          : _improvTwistDirectives[idx];
    });
    _triggerPersonaCutIn('⚡ CURVEBALL ACTIVE · +150 METHOD STREAK');
  }

  void _onStageUpdated() {
    if (!mounted) return;
    final elapsed = _stageManager.performanceElapsedSeconds;
    if (GameSettingsModal.latestConfig.improvRouletteWildcard &&
        !_improvTwistTriggered &&
        _stageManager.isRecordingTake &&
        elapsed >= 5) {
      _triggerImprovTwist();
      return;
    }
    // Fixture #5: 10s sustained vocal energy triggers 1.2s Boondocks Persona Cut-In
    if (_stageManager.isRecordingTake &&
        !_tenSecStreakCutInFired &&
        elapsed >= 10 &&
        _stageManager.isMicEnabled) {
      _tenSecStreakCutInFired = true;
      _triggerPersonaCutIn('+150 METHOD STREAK · VOCAL LOCK');
    }
    // Fixture #15 (Part B): 15s Haptic Double-Tap Escalation for "Life Is Improv"
    if (_stageManager.isRecordingTake &&
        !_lifeImprov15sEscalationFired &&
        elapsed >= 15 &&
        GameSettingsModal.latestConfig.lifeIsImprovMode) {
      _lifeImprov15sEscalationFired = true;
      HapticFeedback.heavyImpact();
      Future<void>.delayed(const Duration(milliseconds: 140), () {
        HapticFeedback.heavyImpact();
      });
      final dare = kLifeIsImprovSecretDares.firstWhere(
        (d) => d.id == widget.lobbySession.activeScene?.id,
        orElse: () => kLifeIsImprovSecretDares.first,
      );
      setState(() {
        _improvTwistTriggered = true;
        _activeImprovTwistPrompt =
            '15s HAPTIC ESCALATION: ${dare.escalationAt15s}';
      });
    }
    setState(() {});
  }

  String _formatSmpteTimecode(int elapsedSeconds) {
    final mins = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (elapsedSeconds % 60).toString().padLeft(2, '0');
    final frames = ((elapsedSeconds * 24) % 30).toString().padLeft(2, '0');
    return '00:$mins:$secs:$frames';
  }

  double get _latestAudioDb {
    final samples = _stageManager.capturedSamples;
    double base = samples.isEmpty
        ? (_stageManager.isMicEnabled ? -22.0 : -60.0)
        : samples.last.audioDecibels;
    if (_stageManager.isRecordingTake && _stageManager.isMicEnabled) {
      base = (base + _vuDancingOffset).clamp(-60.0, -10.0);
    }
    return base;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _preRollTimer?.cancel();
    _vuModulationTimer?.cancel();
    _reactionClearTimer?.cancel();
    _personaCutInTimer?.cancel();
    _panoramicPageController.dispose();
    _stageKeyboardFocusNode.dispose();
    try {
      final ch = _hypeRealtimeChannel;
      if (ch != null) {
        supabaseOrNull?.removeChannel(ch);
      }
    } catch (_) {}
    _stageManager.removeListener(_onStageUpdated);
    _stageManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.lobbySession.activeScene;
    final isPerformer =
        _stageManager.role == SfuParticipantRole.activePerformer;
    final cfg = GameSettingsModal.latestConfig;
    final isLifeIsImprov = cfg.lifeIsImprovMode ||
        (scene?.id.startsWith('life_improv_') ?? false);
    final actorArchetype = resolveAvatarArchetype(
      AuthService.instance.currentUserAvatar,
    );
    final screenSize = MediaQuery.sizeOf(context);
    final isWideDeXOrTvLayout = cfg.bigScreenPremiereHostView ||
        screenSize.width > 900 ||
        (screenSize.width / math.max(1.0, screenSize.height)) > 1.3;

    final isCountdownLocked = _stageManager.isRecordingTake &&
        _stageManager.performanceElapsedSeconds < 10;

    final viewfinderWidget = Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C101A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _standingOvationComboActive
              ? const Color(0xFFFFD700)
              : (_characterBrokenTriggered
                  ? const Color(0xFFE11D48)
                  : (_improvTwistTriggered
                      ? const Color(0xFFF59E0B)
                      : (_isPreRolling
                          ? const Color(0xFF06B6D4)
                          : actorArchetype.rimAccentColor))),
          width: _standingOvationComboActive ? 3.2 : 2.2,
        ),
        boxShadow: [
          if (_standingOvationComboActive)
            const BoxShadow(
              color: Color(0xAAFFD700),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Layer (70%+ Viewfinder)
          _duetModeEnabled
              ? _buildDuetSplitScreenSurface()
              : _buildPrimaryVideoSurface(),
          // Fixture #15 (Part B): Stealth / POV Dimmed Screen Mode for "Life Is Improv"
          if (_stealthDimmedHudMode)
            GestureDetector(
              onDoubleTap: () {
                HapticFeedback.mediumImpact();
                setState(() => _stealthDimmedHudMode = false);
              },
              child: Container(
                color: const Color(0xE6040508),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.visibility_off_rounded,
                      color: Color(0xFF475569),
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'STEALTH POV RECORDING · ${_stageManager.performanceElapsedSeconds}s / 30s',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _activeImprovTwistPrompt ??
                          (scene?.promptScript ?? 'Commit to the real-world bit.'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Double-tap anywhere to restore full stage viewfinder',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9.5,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // 35mm Cinema Letterbox & Archetype-Themed Corner Brackets (Fixture #5)
          if (!_stealthDimmedHudMode)
            IgnorePointer(
              child: CustomPaint(
                painter: _CinemaViewfinderPainter(
                  isRecording: _stageManager.isRecordingTake,
                  improvActive: _improvTwistTriggered || _standingOvationComboActive,
                  archetypeAccent: actorArchetype.rimAccentColor,
                ),
              ),
            ),
          // Top Bar Status HUD (Archetype-themed outer badge)
          if (!_stealthDimmedHudMode)
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xD9050508),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isPreRolling
                              ? const Color(0xFF06B6D4)
                              : actorArchetype.rimAccentColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isPreRolling
                                  ? const Color(0xFF06B6D4)
                                  : ((_stageManager.isRecordingTake &&
                                          _stageManager
                                                  .performanceElapsedSeconds
                                                  .isEven)
                                      ? const Color(0xFFE11D48)
                                      : const Color(0x55E11D48)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _isPreRolling
                                    ? 'PRE-ROLL · ${_preRollSecondsLeft}s CUE'
                                    : 'REC 720p30 · ${_formatSmpteTimecode(_stageManager.performanceElapsedSeconds)} · ${actorArchetype.shortBadge}',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (cfg.cleanBroadcastScreenShareMode)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xD9050508),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF10B981)),
                          ),
                          child: const Text(
                            '📡 CLEAN BROADCAST',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                      if (isLifeIsImprov)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _stealthDimmedHudMode = !_stealthDimmedHudMode;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xD91A0926),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFA55577)),
                            ),
                            child: const Text(
                              '🕵️ STEALTH HUD',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFF5DEB3),
                              ),
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xD9050508),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _isPreRolling
                              ? 'STANDBY'
                              : 'Take: ${_stageManager.performanceElapsedSeconds}s',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // Real-Time Vocal VU Meter along right edge
          if (!_stealthDimmedHudMode)
            Positioned(
              top: 54,
              bottom: 120,
              right: 10,
              child: _buildVocalProjectionVuMeter(),
            ),
          // Fixture #4: Break Character / Stone-Faced Hazard Status Pill
          if (cfg.stoneFacedNoLaughHazard && !_stealthDimmedHudMode)
            Positioned(
              top: 46,
              right: 34,
              child: GestureDetector(
                onTap: () {
                  _applyStageHypeReaction(
                    kind: 'break_character',
                    senderName: widget.localDisplayName,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _characterBrokenTriggered
                        ? const Color(0xEBE11D48)
                        : const Color(0xD905070B),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: _characterBrokenTriggered
                          ? const Color(0xFFFFD700)
                          : const Color(0xFF10B981),
                    ),
                  ),
                  child: Text(
                    _characterBrokenTriggered
                        ? '🚨 CHARACTER BROKEN (-15 PTS)'
                        : '🗿 STONE-FACED 1.20x ACTIVE (TAP IF LAUGHED)',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          // Fixture #7: Standing Ovation Crowd Combo (1.15x) Badge
          if (_standingOvationComboActive && !_stealthDimmedHudMode)
            Positioned(
              bottom: 134,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: const Color(0xFF05070B), width: 2),
                ),
                child: const Text(
                  '🔥 STANDING OVATION COMBO · 1.15x CROWD MULTIPLIER',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF05070B),
                  ),
                ),
              ),
            ),
          // Fixture #5: 1.2-Second Diagonal Boondocks Persona Cut-In (Edge-aligned so 70%+ center viewfinder remains clear)
          if (_showPersonaCutIn && !_stealthDimmedHudMode)
            Positioned(
              bottom: 102,
              left: 12,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: -0.05,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xEB07090E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: actorArchetype.rimAccentColor,
                        width: 2.4,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF05070B),
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: BoondocksAvatarPortrait(
                            archetype: actorArchetype,
                            size: 46,
                            isSelected: true,
                            animationPhase: 0.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              actorArchetype.name.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: actorArchetype.rimAccentColor,
                              ),
                            ),
                            Text(
                              _personaCutInBanner,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFD700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Improv Twist Banner (Compact Top Pill)
          if (_improvTwistTriggered &&
              _activeImprovTwistPrompt != null &&
              !_stealthDimmedHudMode)
            Positioned(
              top: cfg.stoneFacedNoLaughHazard ? 74 : 48,
              left: 14,
              right: 36,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xEE991B1B),
                      Color(0xEEB45309),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFFD700),
                    width: 1.4,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x88F59E0B),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 18,
                      color: Color(0xFFFFD700),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'DIRECTOR\'S CUT TWIST! (+5.0 BONUS) — ${_activeImprovTwistPrompt!}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Live Floating Spectator Reactions (Golden Roses, Tomato Splatter, Standing Ovation)
          if (_latestReactionBanner != null && !_stealthDimmedHudMode)
            Positioned(
              top: _improvTwistTriggered ? 114 : 74,
              left: 14,
              right: 36,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xEB07090E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _latestReactionColor,
                    width: 1.8,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _latestReactionBanner!,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: _latestReactionColor,
                    ),
                  ),
                ),
              ),
            ),
          if (_lastTomatoSplatAt != null &&
              DateTime.now().difference(_lastTomatoSplatAt!).inSeconds < 3 &&
              !_stealthDimmedHudMode)
            Positioned(
              top: 86,
              left: 24,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xD9E11D48),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF05070B),
                      width: 3,
                    ),
                  ),
                  child: const Text(
                    '🍅 SPLAT!',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          if (_lastStandingOvationAt != null &&
              DateTime.now().difference(_lastStandingOvationAt!).inSeconds < 3 &&
              !_stealthDimmedHudMode)
            Positioned(
              bottom: 104,
              right: 34,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xD910B981),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '👏 OVATION x$_standingOvationCount · 🌹 $_goldenRoseCount',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          // Teleprompter (Sleek Lower-Third Glass Card, Unblocking 70%+ of Face — shown once recording starts)
          if (scene != null && !_isPreRolling && !_stealthDimmedHudMode)
            _buildTeleprompterOverlay(scene),
          // 10-Second Pre-Roll Semi-Transparent Clapperboard Overlay
          if (_isPreRolling && !_stealthDimmedHudMode)
            _buildPreRollClapperboardOverlay(scene),
        ],
      ),
    );

    return KeyboardListener(
      focusNode: _stageKeyboardFocusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;
        if (event.logicalKey == LogicalKeyboardKey.space) {
          if (_isPreRolling) {
            _skipPreRollAndRollCamera();
          } else {
            _triggerImprovTwist();
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF07090E),
        appBar: GameAppBar(
          title: isLifeIsImprov
              ? '🕵️ Life Is Improv #${widget.lobbySession.roomCode}'
              : 'Stage #${widget.lobbySession.roomCode}',
          activeRoomCode: widget.lobbySession.roomCode,
          isRecordingCountdownActive: isCountdownLocked,
          onStartOver: () async {
            setState(() {
              _improvTwistTriggered = false;
              _activeImprovTwistPrompt = null;
              _characterBrokenTriggered = false;
              _standingOvationComboActive = false;
            });
            _startPreRollCountdown();
            await _stageManager.resumeStageAfterJudging(
              targetEmotion:
                  scene?.emotionalTarget ?? 'Dramatic Intensity',
            );
          },
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPanoramicFloatingTabBar(),
                const SizedBox(height: 10),
                Expanded(
                  child: PageView(
                    controller: _panoramicPageController,
                    onPageChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _activePanoramicTab = index;
                      });
                    },
                    children: [
                      // Panel 1 (Left - Director's Booth): Hardware toggles & stage controls
                      _buildDirectorsBoothPanel(
                        isPerformer: isPerformer,
                        scene: scene,
                      ),
                      // Panel 2 (Center - Main Stage): 100% dedicated to CameraPreview / LiveKit feed & Teleprompter
                      isWideDeXOrTvLayout
                          ? _buildWideStudioControlDeckLayout(
                              viewfinderWidget: viewfinderWidget,
                              scene: scene,
                              isPerformer: isPerformer,
                            )
                          : viewfinderWidget,
                      // Panel 3 (Right - Spectator Lounge): Live Studio Audience viewport
                      _buildLiveStudioAudiencePanel(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanoramicFloatingTabBar() {
    const tabs = <({int index, String label})>[
      (index: 0, label: '🎛️ BOOTH'),
      (index: 1, label: '🎬 STAGE'),
      (index: 2, label: '🍿 AUDIENCE'),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xEB0B0E17),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF05070B),
          width: 2.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF05070B),
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _activePanoramicTab == tab.index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _activePanoramicTab = tab.index;
                });
                _panoramicPageController.animateToPage(
                  tab.index,
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFFE11342), Color(0xFF991B1B)],
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? Border.all(color: const Color(0xFFFFD700), width: 1.6)
                      : null,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    tab.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: isSelected
                          ? const Color(0xFFFFD700)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDirectorsBoothPanel({
    required bool isPerformer,
    required ScenePrompt? scene,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E17),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF05070B),
          width: 3.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF05070B),
            offset: Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x26FFD700),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFFD700)),
                  ),
                  child: const Text(
                    '🎛️ DIRECTOR\'S BOOTH · HARDWARE & RIGGING',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Configure your camera, microphone, lens orientation, or end the take for Tri-Modal Judging. Swipe right or tap 🎬 STAGE above to return to the unobstructed viewfinder.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            _buildStageControlBar(isPerformer),
            if (scene != null) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF111624),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE SCENE DOSSIER · ${scene.title.toUpperCase()}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0CB6D4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '"${scene.promptScript}"',
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF5DEB3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Director Cue: ${scene.directorCue}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFFD700),
                side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                _panoramicPageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                );
              },
              icon: const Icon(Icons.videocam_rounded, size: 18),
              label: const Text(
                'RETURN TO 🎬 MAIN STAGE VIEWFINDER',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStudioAudiencePanel() {
    final lobbyPlayers = widget.lobbySession.players;
    final effectivePlayers = lobbyPlayers.isNotEmpty
        ? lobbyPlayers
        : <LobbyPlayer>[
            LobbyPlayer(
              id: 'local_${widget.localUserId}',
              lobbyId: widget.lobbySession.id,
              userId: widget.localUserId,
              displayName: widget.localDisplayName,
              isHost: true,
              isReady: true,
              avatarArchetypeId: AuthService.instance.currentUserAvatar,
            ),
          ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E17),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF05070B),
          width: 3.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF05070B),
            offset: Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    '🍿 LIVE STUDIO AUDIENCE VIEWPORT',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121722),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: const Color(0xFF0CB6D4)),
                  ),
                  child: Text(
                    '🌹 $_goldenRoseCount  ·  🍅 $_tomatoSplatCount  ·  👏 $_standingOvationCount',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...effectivePlayers.asMap().entries.map((entry) {
              final idx = entry.key;
              final player = entry.value;
              final isLocal = player.userId == widget.localUserId;
              final resolvedAvatarId = isLocal
                  ? AuthService.instance.currentUserAvatar
                  : player.avatarArchetypeId;
              final archetype = resolveAvatarArchetype(resolvedAvatarId);
              final isActiveTurn =
                  idx == widget.lobbySession.currentPlayerIndex;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF111624),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActiveTurn
                        ? const Color(0xFFFFD700)
                        : archetype.rimAccentColor.withValues(alpha: 0.6),
                    width: isActiveTurn ? 2.2 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BoondocksAvatarPortrait(
                        archetype: archetype,
                        size: 52,
                        isSelected: isActiveTurn || isLocal,
                        animationPhase: 0.0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${player.displayName}${isLocal ? ' (YOU)' : ''}',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${archetype.name} · ${isActiveTurn ? 'ON STAGE NOW' : 'SPECTATING IN LOUNGE'}',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isActiveTurn
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '🌹 $_goldenRoseCount',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '🍅 $_tomatoSplatCount',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFE11D48),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            _buildSpectatorStrip(),
          ],
        ),
      ),
    );
  }

  /// Fixture #12: 3-Pane Studio Control Deck for Samsung DeX, Foldables, Desktop Web & TV Screen-Share.
  Widget _buildWideStudioControlDeckLayout({
    required Widget viewfinderWidget,
    required ScenePrompt? scene,
    required bool isPerformer,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Pane: Scene Dossier & Teleprompter Cue Sheet
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0D111C),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📺 STUDIO CONTROL DECK · TELEPROMPTER',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    scene?.title ?? 'Studio Screen Test',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${scene?.characterName ?? 'Lead'} · ${scene?.filmOrSeries ?? ''} (${scene?.releaseYear ?? 2025})',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFF0CB6D4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '"${scene?.promptScript ?? ''}"',
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF5DEB3),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Director Note: ${scene?.directorCue ?? ''}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Keyboard Shortcuts: [SPACE] Roll / Curveball · [1–0] Peer Vote',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Center Pane: 16:9 / 9:16 Live Viewfinder
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: viewfinderWidget),
              const SizedBox(height: 8),
              _buildStageControlBar(isPerformer),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Right Pane: 10-Player SFU Spectator Gallery & Hype Soundboard
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSpectatorStrip(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreRollClapperboardOverlay(ScenePrompt? scene) {
    final isFinalThree = _preRollSecondsLeft <= 3;
    final countdownHeadline = _preRollSecondsLeft <= 1
        ? '3... 2... 1... ACTION!'
        : (isFinalThree
            ? 'CLAPPERBOARD READY · $_preRollSecondsLeft...'
            : 'DIRECTOR\'S 10s PRE-ROLL · FRAME YOUR SHOT');

    return Container(
      // Semi-transparent 35% backdrop so the live camera feed stays visible
      color: Colors.black.withValues(alpha: 0.35),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xEB0B0E17),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF05070B),
              width: 4.0,
            ),
            boxShadow: <BoxShadow>[
              const BoxShadow(
                color: Color(0xFF05070B),
                offset: Offset(6, 6),
                blurRadius: 0,
              ),
              BoxShadow(
                color: (isFinalThree
                        ? const Color(0xFFE11D48)
                        : const Color(0xFFFFD700))
                    .withValues(alpha: 0.35),
                blurRadius: 24,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isFinalThree
                      ? const Color(0x33E11D48)
                      : const Color(0x3306B6D4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isFinalThree
                        ? const Color(0xFFE11D48)
                        : const Color(0xFF06B6D4),
                    width: 1.8,
                  ),
                ),
                child: Text(
                  countdownHeadline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: isFinalThree
                        ? const Color(0xFFFFD700)
                        : const Color(0xFF06B6D4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _preRollSecondsLeft <= 1 ? 'ACTION!' : '$_preRollSecondsLeft',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: _preRollSecondsLeft <= 1 ? 52 : 64,
                  fontWeight: FontWeight.w900,
                  color: isFinalThree
                      ? const Color(0xFFE11D48)
                      : const Color(0xFFFFD700),
                  shadows: const [
                    Shadow(
                      color: Color(0xFF05070B),
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                    Shadow(color: Color(0xFFF59E0B), blurRadius: 28),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                scene != null
                    ? 'Scene: "${scene.title}" · ${scene.characterName}'
                    : 'Preparing Soundstage...',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                scene != null ? 'Cue: ${scene.directorCue}' : '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFFD700),
                  side: const BorderSide(color: Color(0xFFFFD700), width: 2.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed: _skipPreRollAndRollCamera,
                icon: const Icon(Icons.fast_forward_rounded, size: 18),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'SNAP CLAPPERBOARD & ROLL CAMERA (30s TAKE)',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryVideoSurface() {
    // 1. LiveKit WebRTC Track if connected to SFU
    if (_stageManager.localVideoTrack != null &&
        _stageManager.isCameraEnabled) {
      return VideoTrackRenderer(
        _stageManager.localVideoTrack!,
        fit: VideoViewFit.cover,
      );
    }

    // 2. Direct Samsung Galaxy S26 Ultra Hardware Camera Preview
    final hwCam = _stageManager.hwCameraController;
    if (hwCam != null &&
        hwCam.value.isInitialized &&
        _stageManager.isCameraEnabled) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: hwCam.value.previewSize?.height ?? 720,
          height: hwCam.value.previewSize?.width ?? 1280,
          child: hw_cam.CameraPreview(hwCam),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.videocam_outlined,
              size: 48,
              color: Color(0xFFE11D48),
            ),
            const SizedBox(height: 12),
            Text(
              _stageManager.isConnecting
                  ? 'Initializing Galaxy S26 Ultra Camera & SFU Stage...'
                  : (_stageManager.errorMessage ??
                      'Camera Paused (${widget.lobbySession.livekitRoomName})'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuetSplitScreenSurface() {
    final isAnsweringOpenCoStar = widget.openCoStarChallengeTakeId != null;
    final remotes = _stageManager.remoteParticipants;
    RemoteVideoTrack? coStarVideoTrack;
    String coStarName = isAnsweringOpenCoStar
        ? '${widget.openCoStarLeadAHandle ?? '@COSTAR'} (PRE-RECORDED LEAD A)'
        : 'CO-STAR · THE DIVA (AI RIG)';
    if (remotes.isNotEmpty) {
      coStarName = remotes.first.name.isNotEmpty
          ? remotes.first.name.toUpperCase()
          : 'REMOTE CO-STAR';
      for (final pub in remotes.first.videoTrackPublications) {
        if (pub.track is RemoteVideoTrack) {
          coStarVideoTrack = pub.track as RemoteVideoTrack;
          break;
        }
      }
    }
    final coStarArchetype = resolveAvatarArchetype('the_diva');
    final animPhase =
        (_stageManager.performanceElapsedSeconds * 0.45) + (_vuDancingOffset * 0.05);

    return Row(
      children: [
        // Left 50%: LEAD A framed in Limelight Gold (#F5DEB3)
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFF5DEB3), width: 2.0),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (isAnsweringOpenCoStar)
                  Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        colors: [Color(0xFF28190B), Color(0xFF0B0E17)],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BoondocksCharacterRig(
                            archetype: resolveAvatarArchetype('the_method_actor'),
                            size: 108,
                            isSelected: true,
                            externalPhase: animPhase,
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                coStarName,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFF5DEB3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  _buildPrimaryVideoSurface(),
                Positioned(
                  top: 46,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xD9050508),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: const Color(0xFFF5DEB3)),
                    ),
                    child: Text(
                      isAnsweringOpenCoStar
                          ? 'LEAD A · ${widget.openCoStarLeadAHandle ?? 'CHALLENGER'}'
                          : 'LEAD A · GOLD',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFF5DEB3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right 50%: LEAD B / CO-STAR framed in Soundstage Cyan (#0CB6D4)
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF0CB6D4), width: 2.0),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (isAnsweringOpenCoStar)
                  _buildPrimaryVideoSurface()
                else if (coStarVideoTrack != null)
                  VideoTrackRenderer(
                    coStarVideoTrack,
                    fit: VideoViewFit.cover,
                  )
                else
                  Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Color(0xFF132338),
                          Color(0xFF0B0E17),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BoondocksCharacterRig(
                            archetype: coStarArchetype,
                            size: 108,
                            isSelected: true,
                            externalPhase: animPhase,
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                coStarName,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0CB6D4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 46,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xD9050508),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: const Color(0xFF0CB6D4)),
                    ),
                    child: Text(
                      isAnsweringOpenCoStar
                          ? 'LEAD B · YOU (CO-STAR AUDITION)'
                          : 'LEAD B · CYAN',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0CB6D4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVocalProjectionVuMeter() {
    final normalized = ((_latestAudioDb + 60.0) / 50.0).clamp(0.08, 1.0);
    return Container(
      width: 16,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
      decoration: BoxDecoration(
        color: const Color(0xB3050508),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x44FFFFFF)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            'dB',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 7,
              fontWeight: FontWeight.w800,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Safeguard against zero or unmeasured layout height
                final rawMax =
                    constraints.maxHeight.isFinite ? constraints.maxHeight : 80.0;
                final safeMax = math.max(4.0, rawMax);
                final fillH = (safeMax * normalized).clamp(4.0, safeMax);
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 8,
                    height: fillH,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color(0xFF10B981),
                          Color(0xFFF59E0B),
                          Color(0xFFE11D48),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeleprompterOverlay(ScenePrompt scene) {
    final words = scene.promptScript.split(' ');
    final elapsed = _stageManager.performanceElapsedSeconds;
    // Word-by-word smooth advancement across the 30-second take
    final totalDuration = 30;
    final highlightedWordCount = words.isEmpty
        ? 0
        : _isPreRolling
            ? 0
            : ((elapsed / totalDuration) * words.length).ceil().clamp(0, words.length);
    final spokenPart = words.take(highlightedWordCount).join(' ');
    final remainingPart = words.skip(highlightedWordCount).join(' ');

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        // Lower-third compact glassmorphic styling (bottom 28%)
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xF505070D),
              Color(0xCC05070D),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.movie_creation_outlined,
                  size: 13,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${widget.lobbySession.selectedCategory.label.toUpperCase()} · ${scene.characterName} (${scene.releaseYear})',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (_duetModeEnabled) ...[
              Builder(
                builder: (context) {
                  final halfLen = (words.length / 2).ceil();
                  final leadALine = scene.duetLeadA.trim().isNotEmpty
                      ? scene.duetLeadA.trim()
                      : words.take(halfLen).join(' ');
                  final leadBLine = scene.duetLeadB.trim().isNotEmpty
                      ? scene.duetLeadB.trim()
                      : words.skip(halfLen).join(' ');
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: _largeTeleprompterFont ? 15.5 : 13,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                          children: [
                            const TextSpan(
                              text: '[LEAD A - GOLD]: ',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: Color(0xFFF5DEB3),
                              ),
                            ),
                            TextSpan(
                              text: '"$leadALine"',
                              style: const TextStyle(color: Color(0xFFF5DEB3)),
                            ),
                          ],
                        ),
                      ),
                      if (leadBLine.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: _largeTeleprompterFont ? 15.5 : 13,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                            children: [
                              const TextSpan(
                                text: '[LEAD B - CYAN]: ',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Color(0xFF0CB6D4),
                                ),
                              ),
                              TextSpan(
                                text: '"$leadBLine"',
                                style:
                                    const TextStyle(color: Color(0xFF0CB6D4)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ] else
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: _largeTeleprompterFont ? 17 : 14,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                  children: [
                    const TextSpan(
                      text: '"',
                      style: TextStyle(color: Color(0xFFFFD700)),
                    ),
                    TextSpan(
                      text: spokenPart,
                      style: const TextStyle(color: Color(0xFFFFD700)),
                    ),
                    if (remainingPart.isNotEmpty)
                      TextSpan(
                        text: spokenPart.isEmpty
                            ? remainingPart
                            : ' $remainingPart',
                        style: const TextStyle(color: Colors.white),
                      ),
                    const TextSpan(
                      text: '"',
                      style: TextStyle(color: Color(0xFFFFD700)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Text(
              'Cue: ${scene.directorCue} · Target: ${scene.emotionalTarget}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFCBD5E1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toggleable "🎭 Spectator / Co-Star Hype Deck" soundboard bar synced via
  /// the Supabase Realtime room channel (`🌹 Rose`, `🍅 Tomato`, `👏 Ovation`, `⚡ Curveball`).
  Widget _buildSpectatorStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF0D111C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _showSpectatorHypeDeck = !_showSpectatorHypeDeck;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🎭 SPECTATOR / CO-STAR HYPE DECK',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFF5DEB3),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showSpectatorHypeDeck
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 16,
                      color: const Color(0xFFF5DEB3),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '🌹 $_goldenRoseCount · 👏 $_standingOvationCount',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFFD700),
                ),
              ),
            ],
          ),
          if (_showSpectatorHypeDeck) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                _buildHypeTriggerButton(
                  label: '🌹 Rose (+1)',
                  accent: const Color(0xFFFFD700),
                  onTap: () => _applyStageHypeReaction(
                    kind: 'rose',
                    senderName: widget.localDisplayName,
                  ),
                ),
                const SizedBox(width: 6),
                _buildHypeTriggerButton(
                  label: '🍅 Tomato',
                  accent: const Color(0xFFE11D48),
                  onTap: () => _applyStageHypeReaction(
                    kind: 'tomato',
                    senderName: widget.localDisplayName,
                  ),
                ),
                const SizedBox(width: 6),
                _buildHypeTriggerButton(
                  label: '👏 Ovation',
                  accent: const Color(0xFF10B981),
                  onTap: () => _applyStageHypeReaction(
                    kind: 'ovation',
                    senderName: widget.localDisplayName,
                  ),
                ),
                const SizedBox(width: 6),
                _buildHypeTriggerButton(
                  label: '⚡ Curveball',
                  accent: const Color(0xFF0CB6D4),
                  onTap: () => _applyStageHypeReaction(
                    kind: 'curveball',
                    senderName: widget.localDisplayName,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHypeTriggerButton({
    required String label,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accent.withValues(alpha: 0.85)),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStageControlBar(bool isPerformer) {
    final scene = widget.lobbySession.activeScene;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: () => _stageManager.toggleCamera(),
          icon: Icon(
            _stageManager.isCameraEnabled ? Icons.videocam : Icons.videocam_off,
            size: 17,
          ),
          label: Text(_stageManager.isCameraEnabled ? 'Cam On' : 'Cam Off'),
        ),
        OutlinedButton.icon(
          onPressed: () => _stageManager.toggleMicrophone(),
          icon: Icon(
            _stageManager.isMicEnabled ? Icons.mic : Icons.mic_off,
            size: 17,
          ),
          label: Text(_stageManager.isMicEnabled ? 'Mic On' : 'Mic Off'),
        ),
        OutlinedButton.icon(
          onPressed: () => _stageManager.switchCameraLens(),
          icon: const Icon(Icons.cameraswitch, size: 17),
          label: const Text('Flip Lens'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() {
              _duetModeEnabled = !_duetModeEnabled;
            });
          },
          icon: Icon(
            _duetModeEnabled ? Icons.splitscreen : Icons.crop_landscape,
            size: 17,
            color: _duetModeEnabled ? const Color(0xFF06B6D4) : null,
          ),
          label: Text(_duetModeEnabled ? 'Duet On' : 'Duet Split'),
        ),
        if (_duetModeEnabled && scene != null)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0CB6D4),
              side: const BorderSide(color: Color(0xFF0CB6D4)),
            ),
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final profile = AuthService.instance.currentProfile;
              final challengeId =
                  'duet_${scene.id}_${DateTime.now().millisecondsSinceEpoch}';
              await CuttingRoomFeedStore.publishCompletedPerformance(
                takeId: challengeId,
                actorHandle:
                    '@${(profile?.username ?? widget.localDisplayName).toUpperCase()}',
                avatarArchetypeId:
                    profile?.avatarArchetypeId ?? 'the_method_actor',
                sceneTitle: '${scene.title} [OPEN CO-STAR AUDITION]',
                filmOrSeries: scene.filmOrSeries,
                releaseYear: scene.releaseYear,
                scriptExcerpt:
                    '[LEAD A RECORDED]: "${scene.duetLeadA.isNotEmpty ? scene.duetLeadA : scene.promptScript}" · [CYAN LEAD B OPEN]',
                directorCommentStamp: 'OPEN CO-STAR AUDITION · LEAD B WANTED',
                compositeScore: 91.5,
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Published Open Co-Star Challenge! Link: https://act-like-it.vercel.app/duet?challenge=$challengeId',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
            label: const Text('Post Open Co-Star Challenge'),
          ),
        OutlinedButton.icon(
          onPressed: _improvTwistTriggered ? null : _triggerImprovTwist,
          icon: const Icon(
            Icons.bolt_rounded,
            size: 17,
            color: Color(0xFFF59E0B),
          ),
          label: Text(
            _improvTwistTriggered ? 'Twist Active' : 'Improv Twist',
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE11D48),
            foregroundColor: Colors.white,
          ),
          onPressed: _stageManager.isFinishingTake
              ? null
              : () async {
                  final samplesSnapshot = List<TelemetricsFrameSample>.from(
                    _stageManager.capturedSamples,
                  );
                  final hadImprovTwist = _improvTwistTriggered;
                  final hadCharacterBroken = _characterBrokenTriggered;
                  final hadCrowdCombo = _standingOvationComboActive;
                  final recorded = await _stageManager.finishRecordingTake();
                  if (!mounted) return;
                  await BespokeTransitionEngine.navigate<void>(
                    context: context,
                    type: BespokeTransitionType.vintageFlashbulbPop,
                    destination: TriModalJudgingScreen(
                      lobbySession: widget.lobbySession,
                      performerUserId: widget.localUserId,
                      performerDisplayName: widget.localDisplayName,
                      capturedSamples: samplesSnapshot,
                      localRecordedVideoPath: recorded.filePath,
                      recordedMp4Bytes: recorded.bytes,
                      improvTwistCompleted: hadImprovTwist,
                      characterBrokenPenalty: hadCharacterBroken,
                      standingOvationCrowdCombo: hadCrowdCombo,
                      currentPlayerIndex:
                          widget.lobbySession.currentPlayerIndex,
                      totalLocalPlayers: math.max(
                        widget.lobbySession.totalLocalPlayers,
                        widget.lobbySession.players.length,
                      ),
                    ),
                  );
                  if (!mounted) return;
                  setState(() {
                    _improvTwistTriggered = false;
                    _activeImprovTwistPrompt = null;
                    _characterBrokenTriggered = false;
                    _standingOvationComboActive = false;
                  });
                  _startPreRollCountdown();
                  await _stageManager.resumeStageAfterJudging(
                    targetEmotion:
                        widget.lobbySession.activeScene?.emotionalTarget ??
                            'Dramatic Intensity',
                  );
                },
          icon: const Icon(Icons.movie_filter_rounded, size: 17),
          label: Text(
            _stageManager.isFinishingTake
                ? 'Finalizing Take...'
                : 'Finish Take & Judge',
          ),
        ),
      ],
    );
  }
}

class _CinemaViewfinderPainter extends CustomPainter {
  final bool isRecording;
  final bool improvActive;
  final Color archetypeAccent;

  const _CinemaViewfinderPainter({
    required this.isRecording,
    required this.improvActive,
    this.archetypeAccent = const Color(0xFF06B6D4),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 2.39:1 Anamorphic Letterbox subtle top/bottom matte guides
    final barHeight = math.min(24.0, size.height * 0.06);
    final mattePaint = Paint()..color = const Color(0x66050508);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, barHeight), mattePaint);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - barHeight, size.width, barHeight),
      mattePaint,
    );

    // Rule-of-Thirds subtle golden grid lines
    final gridPaint = Paint()
      ..color = const Color(0x24FFD700)
      ..strokeWidth = 0.8;
    final thirdW = size.width / 3.0;
    final thirdH = size.height / 3.0;
    canvas.drawLine(Offset(thirdW, barHeight), Offset(thirdW, size.height - barHeight), gridPaint);
    canvas.drawLine(Offset(thirdW * 2, barHeight), Offset(thirdW * 2, size.height - barHeight), gridPaint);
    canvas.drawLine(Offset(0, thirdH), Offset(size.width, thirdH), gridPaint);
    canvas.drawLine(Offset(0, thirdH * 2), Offset(size.width, thirdH * 2), gridPaint);

    // Center Golden Crosshair
    final cx = size.width / 2.0;
    final cy = size.height / 2.0;
    final crossPaint = Paint()
      ..color = improvActive
          ? const Color(0xAAFFD700)
          : const Color(0x66FFD700)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(cx - 12, cy), Offset(cx + 12, cy), crossPaint);
    canvas.drawLine(Offset(cx, cy - 12), Offset(cx, cy + 12), crossPaint);

    // 2.5D Cell-Shaded Manga Speed-Lines along the outer edges during active take
    if (isRecording) {
      final speedPaint = Paint()
        ..color = improvActive
            ? const Color(0x55FFD700)
            : archetypeAccent.withValues(alpha: 0.28)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;
      final maxRadius = math.sqrt(cx * cx + cy * cy);
      final innerRadius = maxRadius * 0.78;
      for (int i = 0; i < 36; i++) {
        final angle = (i / 36.0) * math.pi * 2.0;
        final r0 = innerRadius + ((i % 3) * 14.0);
        final p0 = Offset(cx + math.cos(angle) * r0, cy + math.sin(angle) * r0);
        final p1 = Offset(
          cx + math.cos(angle) * (maxRadius + 16),
          cy + math.sin(angle) * (maxRadius + 16),
        );
        canvas.drawLine(p0, p1, speedPaint);
      }
    }

    // Thick 2.5D Cell-Shaded Comic Frame Corner Brackets (Archetype-themed)
    final bracketPaint = Paint()
      ..color = improvActive
          ? const Color(0xFFFFD700)
          : (isRecording ? archetypeAccent : const Color(0xFF06B6D4))
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;
    const cornerLen = 22.0;
    const inset = 8.0;
    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(inset, inset + cornerLen)
        ..lineTo(inset, inset)
        ..lineTo(inset + cornerLen, inset),
      bracketPaint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - inset - cornerLen, inset)
        ..lineTo(size.width - inset, inset)
        ..lineTo(size.width - inset, inset + cornerLen),
      bracketPaint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(inset, size.height - inset - cornerLen)
        ..lineTo(inset, size.height - inset)
        ..lineTo(inset + cornerLen, size.height - inset),
      bracketPaint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - inset - cornerLen, size.height - inset)
        ..lineTo(size.width - inset, size.height - inset)
        ..lineTo(size.width - inset, size.height - inset - cornerLen),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CinemaViewfinderPainter oldDelegate) {
    return oldDelegate.isRecording != isRecording ||
        oldDelegate.improvActive != improvActive ||
        oldDelegate.archetypeAccent != archetypeAccent;
  }
}
