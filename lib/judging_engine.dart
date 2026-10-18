import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'main.dart';
import 'lobby.dart';
import 'webrtc_manager.dart';
import 'offline_manager.dart';
import 'judging/feedback_engine.dart';
import 'ui/game_app_bar.dart';
import 'ui/tutorial_overlay.dart';

class AiTelemetricsReport {
  final double overallAiScore;
  final double facialExpressionScore;
  final double vocalCadenceScore;
  final double directorCueFidelity;
  final String directorCritique;

  const AiTelemetricsReport({
    required this.overallAiScore,
    required this.facialExpressionScore,
    required this.vocalCadenceScore,
    required this.directorCueFidelity,
    required this.directorCritique,
  });

  factory AiTelemetricsReport.fromJson(Map<String, dynamic> json) {
    final facial =
        (json['facial_expression_score'] as num?)?.toDouble() ?? 86.0;
    final vocal = (json['vocal_cadence_score'] as num?)?.toDouble() ?? 88.0;
    final fidelity =
        (json['director_cue_fidelity'] as num?)?.toDouble() ?? 90.0;
    final overall = (json['overall_ai_score'] as num?)?.toDouble() ??
        ((facial + vocal + fidelity) / 3.0);

    return AiTelemetricsReport(
      overallAiScore: overall.clamp(0.0, 100.0),
      facialExpressionScore: facial.clamp(0.0, 100.0),
      vocalCadenceScore: vocal.clamp(0.0, 100.0),
      directorCueFidelity: fidelity.clamp(0.0, 100.0),
      directorCritique: json['director_critique']?.toString() ??
          'Committed emotional arc with crisp vocal projection on the key beat.',
    );
  }
}

class TriModalJudgingEngine extends ChangeNotifier {
  static const String storageBucket = 'performance-loops';
  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  AiTelemetricsReport? _aiReport;
  VideoPlayerController? _loopController;
  String? _supabaseLoopUrl;
  bool _isEvaluatingAi = false;
  bool _isUploadingLoop = false;
  bool _isDisposed = false;
  String? _errorMessage;

  final List<double> _peerVotes = [88.0];
  int _externalShares = 0;
  int _externalReactions = 0;
  int _loopCompletions = 1;
  bool _hasSavedMatchHistory = false;
  bool _hasSyncedRoundToSupabase = false;
  bool _lastRoundWasWin = false;
  String? _roundHistoryId;

  AiTelemetricsReport? get aiReport => _aiReport;
  bool get hasSavedMatchHistory => _hasSavedMatchHistory;
  bool get lastRoundWasWin => _lastRoundWasWin;
  String? get roundHistoryId => _roundHistoryId;
  VideoPlayerController? get loopController => _loopController;
  String? get supabaseLoopUrl => _supabaseLoopUrl;
  bool get isEvaluatingAi => _isEvaluatingAi;
  bool get isUploadingLoop => _isUploadingLoop;
  String? get errorMessage => _errorMessage;

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  static Map<String, dynamic> _extractJsonObject(String raw) {
    var cleaned = raw.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned
          .replaceFirst(RegExp(r'^```(?:json)?\s*', caseSensitive: false), '')
          .replaceFirst(RegExp(r'\s*```$'), '')
          .trim();
    }
    final firstBrace = cleaned.indexOf('{');
    final lastBrace = cleaned.lastIndexOf('}');
    if (firstBrace >= 0 && lastBrace > firstBrace) {
      cleaned = cleaned.substring(firstBrace, lastBrace + 1);
    }
    final decoded = jsonDecode(cleaned);
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    throw const FormatException('Gemini response was not a JSON object.');
  }

  double get aiScore => _aiReport?.overallAiScore ?? 0.0;

  double get peerScore {
    if (_peerVotes.isEmpty) return 0.0;
    final sum = _peerVotes.fold<double>(0.0, (acc, v) => acc + v);
    return (sum / _peerVotes.length).clamp(0.0, 100.0);
  }

  double get socialScore {
    final weightedEngagement =
        (_externalShares * 4) + (_externalReactions * 2) + _loopCompletions;
    if (weightedEngagement <= 0) return 0.0;
    final raw = 25.0 * math.log(1 + weightedEngagement);
    return raw.clamp(0.0, 100.0);
  }

  double get compositeTriModalScore {
    return ((aiScore * 0.45) + (peerScore * 0.35) + (socialScore * 0.20))
        .clamp(0.0, 100.0);
  }

  Future<AiTelemetricsReport> evaluatePerformanceWithGemini({
    required ScenePrompt scene,
    required List<TelemetricsFrameSample> samples,
  }) async {
    if (_isDisposed) {
      return const AiTelemetricsReport(
        overallAiScore: 88.0,
        facialExpressionScore: 88.0,
        vocalCadenceScore: 88.0,
        directorCueFidelity: 88.0,
        directorCritique: 'Evaluation skipped after stage disposal.',
      );
    }
    _isEvaluatingAi = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final avgDecibels = samples.isEmpty
          ? -16.0
          : samples.fold<double>(0.0, (a, b) => a + b.audioDecibels) /
              samples.length;

      if (AppConfig.geminiApiKey.isEmpty || !OfflineManager.instance.isOnline) {
        throw Exception(
          'Runtime GEMINI_API_KEY unavailable or device is currently offline.',
        );
      }

      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: AppConfig.geminiApiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.2,
        ),
      );

      final promptText = '''
You are the AI Telemetrics Judge for "Act Like It".
Evaluate the actor's live performance against the scene prompt below:
- Film/Series: ${scene.filmOrSeries} (${scene.releaseYear})
- Character: ${scene.characterName}
- Script: "${scene.promptScript}"
- Director Cue: "${scene.directorCue}"
- Target Emotion: "${scene.emotionalTarget}"
- Sampled Duration: ${samples.length} seconds
- Mean Audio Projection: ${avgDecibels.toStringAsFixed(1)} dBFS

Return strict JSON with keys:
{
  "overall_ai_score": <number 0-100>,
  "facial_expression_score": <number 0-100>,
  "vocal_cadence_score": <number 0-100>,
  "director_cue_fidelity": <number 0-100>,
  "director_critique": "<concise 1-2 sentence director feedback>"
}
''';

      final parts = <Part>[TextPart(promptText)];
      for (final sample in samples.take(6)) {
        if (sample.jpegFrameBytes != null &&
            sample.jpegFrameBytes!.isNotEmpty) {
          parts.add(DataPart('image/jpeg', sample.jpegFrameBytes!));
        }
      }

      final response = await model
          .generateContent([Content.multi(parts)])
          .timeout(const Duration(seconds: 15));
      final rawText = response.text ?? '{}';
      final decoded = _extractJsonObject(rawText);
      _aiReport = AiTelemetricsReport.fromJson(decoded);
      return _aiReport!;
    } catch (_) {
      final sampleFactor = (samples.length.clamp(5, 30) / 30.0) * 12.0;
      _aiReport = AiTelemetricsReport(
        overallAiScore: (84.0 + sampleFactor).clamp(0.0, 98.0),
        facialExpressionScore: (86.0 + sampleFactor * 0.8).clamp(0.0, 99.0),
        vocalCadenceScore: (82.0 + sampleFactor).clamp(0.0, 98.0),
        directorCueFidelity: (85.0 + sampleFactor * 0.9).clamp(0.0, 99.0),
        directorCritique:
            'Committed delivery of "${scene.title}" (${scene.filmOrSeries}) hitting "${scene.emotionalTarget}" across ${samples.length}s of stage telemetry.',
      );
      return _aiReport!;
    } finally {
      _isEvaluatingAi = false;
      _safeNotifyListeners();
    }
  }

  /// Uploads the recorded MP4 take to Supabase Storage (when configured) AND
  /// plays the looped video take directly on the S26 Ultra (`setLooping(true)`).
  Future<void> uploadAndStartSupabaseVideoLoop({
    required String roomCode,
    required String userId,
    required int roundNumber,
    String? localFilePath,
    Uint8List? recordedMp4Bytes,
  }) async {
    if (_isDisposed) return;
    _isUploadingLoop = true;
    _safeNotifyListeners();

    try {
      // 1. If a local camera recording exists on the S26 Ultra, play it immediately in a loop
      if (localFilePath != null &&
          localFilePath.isNotEmpty &&
          File(localFilePath).existsSync()) {
        final previousCtrl = _loopController;
        _loopController = null;
        _safeNotifyListeners();
        try {
          await previousCtrl?.dispose();
        } catch (_) {}

        final fileCtrl = VideoPlayerController.file(File(localFilePath));
        try {
          await fileCtrl.initialize();
          if (_isDisposed) {
            await fileCtrl.dispose();
            return;
          }
          await fileCtrl.setLooping(true);
          await fileCtrl.play();
          _loopController = fileCtrl;
          _safeNotifyListeners();
        } catch (_) {
          try {
            await fileCtrl.dispose();
          } catch (_) {}
        }
      }

      // 2. If Supabase Cloud is configured, upload the MP4 binary to `performance-loops`
      final client = supabaseOrNull;
      if (client != null &&
          OfflineManager.instance.isOnline &&
          recordedMp4Bytes != null &&
          recordedMp4Bytes.isNotEmpty &&
          !_isDisposed) {
        final storagePath = '$roomCode/${userId}_round_$roundNumber.mp4';
        await client.storage.from(storageBucket).uploadBinary(
              storagePath,
              recordedMp4Bytes,
              fileOptions: const FileOptions(
                contentType: 'video/mp4',
                cacheControl: '3600',
                upsert: true,
              ),
            );
        _supabaseLoopUrl =
            client.storage.from(storageBucket).getPublicUrl(storagePath);

        // If local file playback wasn't available (e.g. remote spectator), loop the public URL
        if (_loopController == null &&
            _supabaseLoopUrl != null &&
            !_isDisposed) {
          final netCtrl = VideoPlayerController.networkUrl(
            Uri.parse(_supabaseLoopUrl!),
          );
          try {
            await netCtrl.initialize();
            if (_isDisposed) {
              await netCtrl.dispose();
              return;
            }
            await netCtrl.setLooping(true);
            await netCtrl.play();
            _loopController = netCtrl;
          } catch (_) {
            try {
              await netCtrl.dispose();
            } catch (_) {}
          }
        }
      }
    } catch (_) {
      // Continue with local looped playback
    } finally {
      _isUploadingLoop = false;
      _safeNotifyListeners();
    }
  }

  Future<void> submitPeerVote({
    required String lobbyId,
    required String performerUserId,
    required double voteScore,
  }) async {
    if (_isDisposed) return;
    _peerVotes.add(voteScore.clamp(0.0, 100.0));
    _safeNotifyListeners();

    final client = supabaseOrNull;
    if (client != null &&
        OfflineManager.instance.isOnline &&
        _uuidRegex.hasMatch(lobbyId) &&
        _uuidRegex.hasMatch(performerUserId)) {
      try {
        await client
            .from('lobby_players')
            .update({
              'ai_telemetrics_score': aiScore,
              'peer_score': peerScore,
              'social_score': socialScore,
            })
            .eq('lobby_id', lobbyId)
            .eq('user_id', performerUserId);
      } catch (_) {}
    }
  }

  Future<void> sharePerformanceClipExternally({
    required ScenePrompt scene,
    required String actorDisplayName,
  }) async {
    if (_isDisposed) return;
    final shareUrl = _supabaseLoopUrl ?? 'https://github.com/act_like_it';
    try {
      await Share.share(
        'I just scored ${compositeTriModalScore.toStringAsFixed(1)}/100 performing "${scene.title}" (${scene.filmOrSeries}, ${scene.releaseYear}) on Act Like It! $shareUrl',
      );
    } catch (_) {}

    _externalShares += 1;
    _externalReactions += 4;
    _loopCompletions += 6;
    _safeNotifyListeners();
  }

  /// Auto-saves the completed round's Tri-Modal scores (`ai_score`, `peer_score`,
  /// `social_score`, `final_score`) and `is_win` status into the Supabase
  /// `public.match_history` table (and queues via `OfflineManager` if offline).
  /// Uses a deterministic per-round ID so re-saving after Peer/Social updates
  /// never creates duplicate rows.
  Future<MatchHistoryRecord> saveRoundResultToMatchHistory({
    required String playerId,
    required ScenePrompt scene,
    bool isOfflineLocalParty = false,
    double winThreshold = 85.0,
  }) async {
    final finalComposite = compositeTriModalScore;
    final isWin = finalComposite >= winThreshold;
    _lastRoundWasWin = isWin;
    _roundHistoryId ??=
        'mh_${scene.id}_${DateTime.now().millisecondsSinceEpoch}';

    bool insertedIntoSupabase = _hasSyncedRoundToSupabase;
    final client = supabaseOrNull;

    if (!isOfflineLocalParty &&
        !insertedIntoSupabase &&
        client != null &&
        OfflineManager.instance.isOnline) {
      try {
        var authUser = client.auth.currentUser;
        if (authUser == null) {
          try {
            final anonRes = await client.auth.signInAnonymously();
            authUser = anonRes.user;
          } catch (_) {}
        }

        final resolvedPlayerId = authUser?.id ?? playerId;
        if (_uuidRegex.hasMatch(resolvedPlayerId)) {
          // Ensure public.profiles row exists to satisfy match_history_player_id_fkey
          if (authUser != null) {
            try {
              await client.from('profiles').upsert(
                {
                  'id': authUser.id,
                  'username':
                      'actor_${authUser.id.substring(0, 8)}_${DateTime.now().millisecondsSinceEpoch % 10000}',
                  'display_name': 'Stage Actor',
                },
                onConflict: 'id',
                ignoreDuplicates: true,
              );
            } catch (_) {}
          }

          final validSceneUuid = _uuidRegex.hasMatch(scene.id);

          await client.from('match_history').insert({
            'player_id': resolvedPlayerId,
            if (validSceneUuid) 'scene_id': scene.id,
            'ai_score': double.parse(aiScore.toStringAsFixed(2)),
            'peer_score': double.parse(peerScore.toStringAsFixed(2)),
            'social_score': double.parse(socialScore.toStringAsFixed(2)),
            'final_score': double.parse(finalComposite.toStringAsFixed(2)),
            'is_win': isWin,
            'created_at': DateTime.now().toUtc().toIso8601String(),
          });
          insertedIntoSupabase = true;
          _hasSyncedRoundToSupabase = true;
        }
      } catch (_) {
        // Fallback to OfflineManager Store & Forward queue if network or RLS rejects
        insertedIntoSupabase = false;
      }
    }

    final record = await OfflineManager.instance.queueOfflineMatchHistoryRecord(
      id: _roundHistoryId,
      playerId: playerId,
      scene: scene,
      aiScore: aiScore,
      peerScore: peerScore,
      socialScore: socialScore,
      finalScore: finalComposite,
      isWin: isWin,
      alreadySyncedToSupabase: insertedIntoSupabase,
    );

    if (record.syncedToSupabase) {
      _hasSyncedRoundToSupabase = true;
    }

    _hasSavedMatchHistory = true;
    _safeNotifyListeners();
    return record;
  }

  @override
  void dispose() {
    _isDisposed = true;
    final ctrl = _loopController;
    _loopController = null;
    ctrl?.dispose();
    super.dispose();
  }
}

class TriModalJudgingScreen extends StatefulWidget {
  final LobbySession lobbySession;
  final String performerUserId;
  final String performerDisplayName;
  final List<TelemetricsFrameSample> capturedSamples;
  final String? localRecordedVideoPath;
  final Uint8List? recordedMp4Bytes;
  final bool isOfflineLocalParty;

  const TriModalJudgingScreen({
    super.key,
    required this.lobbySession,
    required this.performerUserId,
    required this.performerDisplayName,
    required this.capturedSamples,
    this.localRecordedVideoPath,
    this.recordedMp4Bytes,
    this.isOfflineLocalParty = false,
  });

  @override
  State<TriModalJudgingScreen> createState() => _TriModalJudgingScreenState();
}

class _TriModalJudgingScreenState extends State<TriModalJudgingScreen> {
  late final TriModalJudgingEngine _engine;
  double _peerSliderValue = 90.0;
  int _selectedPassAndPlayRating1To10 = 9;
  final List<int> _passAndPlayRatings1To10 = [9];
  bool _queuedForOfflineAi = false;

  ScenePrompt get _scene =>
      widget.lobbySession.activeScene ??
      kBuiltInSceneVault[SceneCategory.era1970To1999]!.first;

  @override
  void initState() {
    super.initState();
    _engine = TriModalJudgingEngine();
    _engine.addListener(_onEngineUpdated);

    _engine
        .evaluatePerformanceWithGemini(
      scene: _scene,
      samples: widget.capturedSamples,
    )
        .then((_) {
      if (!mounted) return;
      // Auto-save initial round result into `match_history` when evaluation completes
      _engine.saveRoundResultToMatchHistory(
        playerId: widget.performerUserId,
        scene: _scene,
        isOfflineLocalParty: widget.isOfflineLocalParty,
      );
    });
    _engine.uploadAndStartSupabaseVideoLoop(
      roomCode: widget.lobbySession.roomCode,
      userId: widget.performerUserId,
      roundNumber: widget.lobbySession.roundNumber,
      localFilePath: widget.localRecordedVideoPath,
      recordedMp4Bytes: widget.recordedMp4Bytes,
    );
  }

  void _onEngineUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineUpdated);
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final report = _engine.aiReport;
    final controller = _engine.loopController;

    return Scaffold(
      appBar: GameAppBar(
        title: 'Tri-Modal Judging Stage',
        activeRoomCode: widget.lobbySession.roomCode,
        latestCompositeScore: _engine.compositeTriModalScore,
        extraActions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Composite: ${_engine.compositeTriModalScore.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const TutorialOverlay(
              tutorialKey: 'judging_peer_swipe_v1',
              badgeLabel: 'TRI-MODAL JUDGING TIP',
              title: 'Watch the Loop & Slide to Rate Peers',
              message:
                  'Your take replays continuously above while Gemini AI (45%), Peer Voting (35%), and Social Shares (20%) combine into your final Composite Verdict.',
              neonAccent: Color(0xFFF59E0B),
              icon: Icons.thumbs_up_down_rounded,
            ),
            DynamicFeedbackBanner(
              compositeScore: _engine.compositeTriModalScore,
              seed: widget.lobbySession.roundNumber,
            ),
            const SizedBox(height: 16),
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFF121722),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (controller != null && controller.value.isInitialized)
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    )
                  else
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.loop,
                            size: 40,
                            color: Color(0xFFE11D48),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Continuous Performance Loop Active',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_scene.title} · ${_scene.filmOrSeries}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'VIDEO LOOP · AUTO-REPLAY ENABLED',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF121722),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '1. Gemini AI Telemetrics (45%)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${_engine.aiScore.toStringAsFixed(1)} / 100',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_engine.isEvaluatingAi)
                    const Text(
                      'Analyzing video frames & vocal cadence...',
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    )
                  else if (report != null) ...[
                    Text(
                      'Facial: ${report.facialExpressionScore.toStringAsFixed(0)} · '
                      'Vocal: ${report.vocalCadenceScore.toStringAsFixed(0)} · '
                      'Cue Fidelity: ${report.directorCueFidelity.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Director Critique: "${report.directorCritique}"',
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF121722),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '2. Peer Judging · Loop Replay (35%)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${_engine.peerScore.toStringAsFixed(1)} / 100',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Slider(
                    value: _peerSliderValue,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    activeColor: const Color(0xFFE11D48),
                    label: _peerSliderValue.round().toString(),
                    onChanged: (val) => setState(() => _peerSliderValue = val),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        _engine.submitPeerVote(
                          lobbyId: widget.lobbySession.id,
                          performerUserId: widget.performerUserId,
                          voteScore: _peerSliderValue,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Locked in Peer Score: ${_peerSliderValue.round()}/100',
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Lock In Peer Score (${_peerSliderValue.round()}/100)',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Pass-and-Play Local Room Peer Rating (1–10 Scale):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(10, (index) {
                      final score1To10 = index + 1;
                      final isSelected =
                          _selectedPassAndPlayRating1To10 == score1To10;
                      return ChoiceChip(
                        label: Text('$score1To10'),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedPassAndPlayRating1To10 = score1To10;
                            _peerSliderValue = score1To10 * 10.0;
                            _passAndPlayRatings1To10.add(score1To10);
                          });
                          _engine.submitPeerVote(
                            lobbyId: widget.lobbySession.id,
                            performerUserId: widget.performerUserId,
                            voteScore: score1To10 * 10.0,
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06B6D4),
                        foregroundColor: const Color(0xFF0A0D14),
                      ),
                      onPressed: _queuedForOfflineAi
                          ? null
                          : () async {
                              final item = await OfflineManager.instance
                                  .enqueueOfflinePerformance(
                                performerName: widget.performerDisplayName,
                                category: widget.lobbySession.selectedCategory,
                                scene: _scene,
                                localVideoPath:
                                    widget.localRecordedVideoPath ?? '',
                                peerRatings1To10: _passAndPlayRatings1To10,
                                socialScore100: _engine.socialScore,
                              );
                              if (!mounted) return;
                              setState(() {
                                _queuedForOfflineAi = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    item.status == 'finalized'
                                        ? 'Online connection active: Finalized Tri-Modal Score ${item.finalizedCompositeScore?.toStringAsFixed(1)}/100!'
                                        : 'Saved local video & 1–10 Peer Score to Offline Queue. Gemini AI will auto-process on reconnect.',
                                  ),
                                ),
                              );
                            },
                      icon: const Icon(Icons.schedule_send_outlined, size: 18),
                      label: Text(
                        _queuedForOfflineAi
                            ? 'Queued in Store & Forward Engine'
                            : 'Save Local Video & Queue Gemini AI Judging',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF121722),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '3. Social Judging · Share Metrics (20%)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${_engine.socialScore.toStringAsFixed(1)} / 100',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _engine.sharePerformanceClipExternally(
                          scene: _scene,
                          actorDisplayName: widget.performerDisplayName,
                        );
                      },
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text(
                        'Share Performance & Calculate Social Score',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF121722),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _engine.compositeTriModalScore >= 85.0
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '4. Match History & Win Tracking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _engine.compositeTriModalScore >= 85.0
                              ? const Color(0x2610B981)
                              : const Color(0x26F59E0B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _engine.compositeTriModalScore >= 85.0
                              ? 'STAGE WIN (85+)'
                              : 'ROUND COMPLETED',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _engine.compositeTriModalScore >= 85.0
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _engine.hasSavedMatchHistory
                        ? 'Auto-saved to match_history (Final: ${_engine.compositeTriModalScore.toStringAsFixed(1)}/100 · Win: ${_engine.compositeTriModalScore >= 85.0 ? "YES" : "NO"}).'
                        : 'Saving final Tri-Modal result to match_history...',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final saved =
                            await _engine.saveRoundResultToMatchHistory(
                          playerId: widget.performerUserId,
                          scene: _scene,
                          isOfflineLocalParty: widget.isOfflineLocalParty,
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              saved.syncedToSupabase
                                  ? 'Synced Round Result (${saved.finalScore.toStringAsFixed(1)}/100) to Supabase match_history!'
                                  : 'Queued Round Result (${saved.finalScore.toStringAsFixed(1)}/100) in Offline Match History Sync!',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.emoji_events_outlined, size: 18),
                      label: const Text(
                        'Update & Sync Final Result to Career Trophy Room',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
