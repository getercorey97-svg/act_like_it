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
import 'main.dart';
import 'lobby.dart';
import 'judging_engine.dart';
import 'ui/game_app_bar.dart';
import 'ui/game_settings_modal.dart';
import 'ui/tutorial_overlay.dart';
import 'auth/auth_service.dart';
import 'ui/intro_cinematic.dart';
import 'ui/transitions.dart';

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

  const LiveKitSoundstageScreen({
    super.key,
    required this.lobbySession,
    required this.localUserId,
    required this.localDisplayName,
  });

  @override
  State<LiveKitSoundstageScreen> createState() =>
      _LiveKitSoundstageScreenState();
}

class _LiveKitSoundstageScreenState extends State<LiveKitSoundstageScreen>
    with WidgetsBindingObserver {
  late final WebRtcStageManager _stageManager;
  bool _largeTeleprompterFont = false;
  bool _duetModeEnabled = GameSettingsModal.latestConfig.screenTestDuetMode;
  bool _improvTwistTriggered = false;
  String? _activeImprovTwistPrompt;

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

    _startPreRollCountdown();
    _startVuMeterModulation();
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

  void _triggerImprovTwist() {
    if (_improvTwistTriggered) return;
    HapticFeedback.heavyImpact();
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      HapticFeedback.mediumImpact();
    });
    final idx =
        (widget.lobbySession.roundNumber + _stageManager.performanceElapsedSeconds) %
            _improvTwistDirectives.length;
    setState(() {
      _improvTwistTriggered = true;
      _activeImprovTwistPrompt = _improvTwistDirectives[idx];
    });
  }

  void _onStageUpdated() {
    if (!mounted) return;
    if (GameSettingsModal.latestConfig.improvRouletteWildcard &&
        !_improvTwistTriggered &&
        _stageManager.isRecordingTake &&
        _stageManager.performanceElapsedSeconds >= 5) {
      _triggerImprovTwist();
      return;
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
    _stageManager.removeListener(_onStageUpdated);
    _stageManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.lobbySession.activeScene;
    final isPerformer =
        _stageManager.role == SfuParticipantRole.activePerformer;

    final isCountdownLocked = _stageManager.isRecordingTake &&
        _stageManager.performanceElapsedSeconds < 10;

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      appBar: GameAppBar(
        title: 'Stage #${widget.lobbySession.roomCode}',
        activeRoomCode: widget.lobbySession.roomCode,
        isRecordingCountdownActive: isCountdownLocked,
        onStartOver: () async {
          setState(() {
            _improvTwistTriggered = false;
            _activeImprovTwistPrompt = null;
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
              Expanded(
                flex: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C101A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _improvTwistTriggered
                          ? const Color(0xFFF59E0B)
                          : (_isPreRolling
                              ? const Color(0xFF06B6D4)
                              : const Color(0xFFE11D48)),
                      width: 2.0,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Camera Layer (70%+ Viewfinder)
                      _duetModeEnabled
                          ? _buildDuetSplitScreenSurface()
                          : _buildPrimaryVideoSurface(),
                      // 35mm Cinema Letterbox & Subtle Grid
                      IgnorePointer(
                        child: CustomPaint(
                          painter: _CinemaViewfinderPainter(
                            isRecording: _stageManager.isRecordingTake,
                            improvActive: _improvTwistTriggered,
                          ),
                        ),
                      ),
                      // Top Bar Status HUD (Single unified status)
                      Positioned(
                        top: 10,
                        left: 12,
                        right: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
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
                                      : const Color(0xFFE11D48),
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
                                  Text(
                                    _isPreRolling
                                        ? 'PRE-ROLL · ${_preRollSecondsLeft}s CUE'
                                        : 'REC 720p30 · ${_formatSmpteTimecode(_stageManager.performanceElapsedSeconds)}',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
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
                                    : 'Take: ${_stageManager.performanceElapsedSeconds}s (Frames: ${_stageManager.performanceElapsedSeconds * 30})',
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
                      ),
                      // Real-Time Vocal VU Meter along right edge
                      Positioned(
                        top: 54,
                        bottom: 120,
                        right: 10,
                        child: _buildVocalProjectionVuMeter(),
                      ),
                      // Improv Twist Banner (Compact Top Pill)
                      if (_improvTwistTriggered &&
                          _activeImprovTwistPrompt != null)
                        Positioned(
                          top: 48,
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
                      // Teleprompter (Sleek Lower-Third Glass Card, Unblocking 70%+ of Face)
                      if (scene != null) _buildTeleprompterOverlay(scene),
                      // 10-Second Pre-Roll Translucent Clapperboard Overlay
                      if (_isPreRolling) _buildPreRollClapperboardOverlay(scene),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildSpectatorStrip(),
              const SizedBox(height: 10),
              _buildStageControlBar(isPerformer),
            ],
          ),
        ),
      ),
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
      color: const Color(0xD905070D),
      padding: const EdgeInsets.all(24),
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
                label: const Text(
                  'SNAP CLAPPERBOARD & ROLL CAMERA (30s TAKE)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
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
    final remotes = _stageManager.remoteParticipants;
    RemoteVideoTrack? coStarVideoTrack;
    String coStarName = 'CO-STAR (LOCAL PIP)';
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

    return Row(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildPrimaryVideoSurface(),
              Positioned(
                bottom: 96,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xCC050508),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0x99FFD700)),
                  ),
                  child: const Text(
                    'LEAD ACTOR',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(width: 2, color: const Color(0xFFFFD700)),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (coStarVideoTrack != null)
                VideoTrackRenderer(
                  coStarVideoTrack,
                  fit: VideoViewFit.cover,
                )
              else
                Container(
                  color: const Color(0xFF0B0E17),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people_alt_rounded,
                          size: 34,
                          color: Color(0xFF06B6D4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          coStarName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF06B6D4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '50/50 Cinema Split Active',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                bottom: 96,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xCC050508),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0x9906B6D4)),
                  ),
                  child: Text(
                    coStarName,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF06B6D4),
                    ),
                  ),
                ),
              ),
            ],
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      text: spokenPart.isEmpty ? remainingPart : ' $remainingPart',
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

  Widget _buildSpectatorStrip() {
    final remotes = _stageManager.remoteParticipants;
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF101420),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sensors, size: 18, color: Color(0xFF10B981)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              remotes.isEmpty
                  ? 'S26 Ultra Stage Active · Recording MP4 Take for Peer & AI Judging'
                  : 'Connected Remote Peers (${remotes.length}/7)',
              style: const TextStyle(fontSize: 11.5, color: Color(0xFFCBD5E1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageControlBar(bool isPerformer) {
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
                    ),
                  );
                  if (!mounted) return;
                  setState(() {
                    _improvTwistTriggered = false;
                    _activeImprovTwistPrompt = null;
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

  const _CinemaViewfinderPainter({
    required this.isRecording,
    required this.improvActive,
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
            : const Color(0x40E11D48)
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

    // Thick 2.5D Cell-Shaded Comic Frame Corner Brackets
    final bracketPaint = Paint()
      ..color = improvActive
          ? const Color(0xFFFFD700)
          : (isRecording ? const Color(0xFFE11D48) : const Color(0xFF06B6D4))
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
        oldDelegate.improvActive != improvActive;
  }
}
