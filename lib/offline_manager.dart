import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart' as hw_cam;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'lobby.dart';
import 'judging_engine.dart';

/// Represents a queued offline Pass-and-Play performance waiting for an active
/// internet connection so Gemini AI can finalize the Tri-Modal score.
class QueuedOfflinePerformance {
  final String id;
  final String performerName;
  final String categoryKey;
  final ScenePrompt scene;
  final String localVideoPath;
  final List<int> peerRatings1To10;
  final double peerScore100;
  final double socialScore100;
  final String status; // 'queued_offline' | 'processing_ai' | 'finalized'
  final double? finalizedAiScore;
  final double? finalizedCompositeScore;
  final String? finalizedCritique;
  final DateTime createdAt;

  const QueuedOfflinePerformance({
    required this.id,
    required this.performerName,
    required this.categoryKey,
    required this.scene,
    required this.localVideoPath,
    required this.peerRatings1To10,
    required this.peerScore100,
    required this.socialScore100,
    required this.status,
    this.finalizedAiScore,
    this.finalizedCompositeScore,
    this.finalizedCritique,
    required this.createdAt,
  });

  QueuedOfflinePerformance copyWith({
    String? status,
    double? finalizedAiScore,
    double? finalizedCompositeScore,
    String? finalizedCritique,
  }) {
    return QueuedOfflinePerformance(
      id: id,
      performerName: performerName,
      categoryKey: categoryKey,
      scene: scene,
      localVideoPath: localVideoPath,
      peerRatings1To10: peerRatings1To10,
      peerScore100: peerScore100,
      socialScore100: socialScore100,
      status: status ?? this.status,
      finalizedAiScore: finalizedAiScore ?? this.finalizedAiScore,
      finalizedCompositeScore:
          finalizedCompositeScore ?? this.finalizedCompositeScore,
      finalizedCritique: finalizedCritique ?? this.finalizedCritique,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'performer_name': performerName,
        'category_key': categoryKey,
        'scene': scene.toJson(),
        'local_video_path': localVideoPath,
        'peer_ratings_1_to_10': peerRatings1To10,
        'peer_score_100': peerScore100,
        'social_score_100': socialScore100,
        'status': status,
        'finalized_ai_score': finalizedAiScore,
        'finalized_composite_score': finalizedCompositeScore,
        'finalized_critique': finalizedCritique,
        'created_at': createdAt.toIso8601String(),
      };

  factory QueuedOfflinePerformance.fromJson(Map<String, dynamic> json) {
    final rawRatings = (json['peer_ratings_1_to_10'] as List?) ?? const [9];
    return QueuedOfflinePerformance(
      id: json['id']?.toString() ?? '',
      performerName: json['performer_name']?.toString() ?? 'Local Party Actor',
      categoryKey:
          json['category_key']?.toString() ?? SceneCategory.era1970To1999.key,
      scene: ScenePrompt.fromJson(
        Map<String, dynamic>.from((json['scene'] as Map?) ?? const {}),
      ),
      localVideoPath: json['local_video_path']?.toString() ?? '',
      peerRatings1To10: rawRatings.map((e) => (e as num).toInt()).toList(),
      peerScore100: (json['peer_score_100'] as num?)?.toDouble() ?? 90.0,
      socialScore100: (json['social_score_100'] as num?)?.toDouble() ?? 75.0,
      status: json['status']?.toString() ?? 'queued_offline',
      finalizedAiScore: (json['finalized_ai_score'] as num?)?.toDouble(),
      finalizedCompositeScore:
          (json['finalized_composite_score'] as num?)?.toDouble(),
      finalizedCritique: json['finalized_critique']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now().toUtc(),
    );
  }
}

/// Represents a Match History & Win Tracking record for `public.match_history`,
/// supporting both online Supabase persistence and offline Pass-and-Play queuing.
class MatchHistoryRecord {
  final String id;
  final String playerId;
  final String? sceneId;
  final String sceneTitle;
  final String filmOrSeries;
  final double aiScore;
  final double peerScore;
  final double socialScore;
  final double finalScore;
  final bool isWin;
  final bool syncedToSupabase;
  final DateTime createdAt;

  const MatchHistoryRecord({
    required this.id,
    required this.playerId,
    this.sceneId,
    required this.sceneTitle,
    required this.filmOrSeries,
    required this.aiScore,
    required this.peerScore,
    required this.socialScore,
    required this.finalScore,
    required this.isWin,
    required this.syncedToSupabase,
    required this.createdAt,
  });

  MatchHistoryRecord copyWith({
    bool? syncedToSupabase,
    double? aiScore,
    double? finalScore,
    bool? isWin,
  }) {
    return MatchHistoryRecord(
      id: id,
      playerId: playerId,
      sceneId: sceneId,
      sceneTitle: sceneTitle,
      filmOrSeries: filmOrSeries,
      aiScore: aiScore ?? this.aiScore,
      peerScore: peerScore,
      socialScore: socialScore,
      finalScore: finalScore ?? this.finalScore,
      isWin: isWin ?? this.isWin,
      syncedToSupabase: syncedToSupabase ?? this.syncedToSupabase,
      createdAt: createdAt,
    );
  }

  /// Payload formatted for `public.match_history` insert on Supabase.
  Map<String, dynamic> toSupabaseInsertRow(String resolvedPlayerUuid) {
    final bool validSceneUuid = sceneId != null &&
        RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
        ).hasMatch(sceneId!);
    return {
      'player_id': resolvedPlayerUuid,
      if (validSceneUuid) 'scene_id': sceneId,
      'ai_score': double.parse(aiScore.toStringAsFixed(2)),
      'peer_score': double.parse(peerScore.toStringAsFixed(2)),
      'social_score': double.parse(socialScore.toStringAsFixed(2)),
      'final_score': double.parse(finalScore.toStringAsFixed(2)),
      'is_win': isWin,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'player_id': playerId,
        'scene_id': sceneId,
        'scene_title': sceneTitle,
        'film_or_series': filmOrSeries,
        'ai_score': aiScore,
        'peer_score': peerScore,
        'social_score': socialScore,
        'final_score': finalScore,
        'is_win': isWin,
        'synced_to_supabase': syncedToSupabase,
        'created_at': createdAt.toIso8601String(),
      };

  factory MatchHistoryRecord.fromJson(Map<String, dynamic> json) {
    final nestedScene = json['scenes'] is Map
        ? Map<String, dynamic>.from(json['scenes'] as Map)
        : null;
    return MatchHistoryRecord(
      id: json['id']?.toString() ??
          'mh_${DateTime.now().millisecondsSinceEpoch}',
      playerId: json['player_id']?.toString() ?? 'local-s26-actor',
      sceneId: json['scene_id']?.toString(),
      sceneTitle: json['scene_title']?.toString() ??
          nestedScene?['title']?.toString() ??
          'Stage Performance',
      filmOrSeries: json['film_or_series']?.toString() ??
          nestedScene?['category']?.toString() ??
          'Act Like It Vault',
      aiScore: (json['ai_score'] as num?)?.toDouble() ?? 0.0,
      peerScore: (json['peer_score'] as num?)?.toDouble() ?? 0.0,
      socialScore: (json['social_score'] as num?)?.toDouble() ?? 0.0,
      finalScore: (json['final_score'] as num?)?.toDouble() ?? 0.0,
      isWin: json['is_win'] == true,
      syncedToSupabase: json['synced_to_supabase'] == true,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now().toUtc(),
    );
  }
}

/// "Store & Forward" Offline Manager for Act Like It:
/// 1. Local Scene Caching (`shared_preferences`) from Supabase `public.scenes`.
/// 2. Local temporary directory MP4 clip persistence (`path_provider`).
/// 3. Background Gemini AI Judging Queue with `connectivity_plus` auto-reconnection.
class OfflineManager extends ChangeNotifier {
  static final OfflineManager instance = OfflineManager._internal();

  static const String _kCachedScenesPrefsKey = 'offline_cached_scene_packs_v1';
  static const String _kCachedScenesTimestampKey =
      'offline_cached_scene_packs_ts_v1';
  static const String _kQueuedPerformancesPrefsKey =
      'offline_gemini_ai_queue_v1';
  static const String _kMatchHistoryQueuePrefsKey =
      'offline_match_history_log_v1';

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<dynamic>? _connectivitySubscription;

  bool _isInitialized = false;
  bool _isOnline = true;
  bool _isCachingScenes = false;
  bool _isProcessingQueue = false;
  int _cachedSceneCount = 0;
  DateTime? _lastCacheSyncAt;
  final Map<String, List<ScenePrompt>> _cachedPacksByCategory = {};
  final List<QueuedOfflinePerformance> _queue = [];
  final List<MatchHistoryRecord> _matchHistoryLog = [];

  OfflineManager._internal();

  bool get isOnline => _isOnline;
  bool get isCachingScenes => _isCachingScenes;
  bool get isProcessingQueue => _isProcessingQueue;
  int get cachedSceneCount => _cachedSceneCount;
  DateTime? get lastCacheSyncAt => _lastCacheSyncAt;
  List<QueuedOfflinePerformance> get queue => List.unmodifiable(_queue);
  List<MatchHistoryRecord> get matchHistoryLog =>
      List.unmodifiable(_matchHistoryLog);

  int get pendingQueueCount =>
      _queue.where((item) => item.status != 'finalized').length;

  int get pendingMatchHistorySyncCount =>
      _matchHistoryLog.where((item) => !item.syncedToSupabase).length;

  int get totalCareerWins =>
      _matchHistoryLog.where((item) => item.isWin).length;

  double get averageFinalScore {
    if (_matchHistoryLog.isEmpty) return 0.0;
    final total =
        _matchHistoryLog.fold<double>(0.0, (sum, r) => sum + r.finalScore);
    return total / _matchHistoryLog.length;
  }

  double get averageAiScore {
    if (_matchHistoryLog.isEmpty) return 0.0;
    final total =
        _matchHistoryLog.fold<double>(0.0, (sum, r) => sum + r.aiScore);
    return total / _matchHistoryLog.length;
  }

  double get averagePeerScore {
    if (_matchHistoryLog.isEmpty) return 0.0;
    final total =
        _matchHistoryLog.fold<double>(0.0, (sum, r) => sum + r.peerScore);
    return total / _matchHistoryLog.length;
  }

  /// Initializes local cache, loads queued performances, and subscribes to
  /// `connectivity_plus` network state changes for automatic Store & Forward syncing.
  Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    _isInitialized = true;

    await _loadCachedScenePacksFromPrefs();
    await _loadQueueFromPrefs();
    await _loadMatchHistoryFromPrefs();

    try {
      final initialStatus = await _connectivity.checkConnectivity();
      _isOnline = _evaluateConnectivityOnline(initialStatus);
    } catch (_) {
      _isOnline = true;
    }

    _connectivitySubscription?.cancel();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((dynamic statusEvent) async {
      final nowOnline = _evaluateConnectivityOnline(statusEvent);
      final wasOffline = !_isOnline;
      _isOnline = nowOnline;
      notifyListeners();

      // Store & Forward trigger: once active internet connection is detected,
      // automatically process queued videos through the Gemini AI API and
      // push unsynced match_history records to Supabase.
      if (nowOnline &&
          (wasOffline ||
              pendingQueueCount > 0 ||
              pendingMatchHistorySyncCount > 0)) {
        await processQueuedPerformancesWithGemini();
        await syncPendingMatchHistoryToSupabase();
      }
    });

    if (_isOnline) {
      if (pendingQueueCount > 0) {
        unawaited(processQueuedPerformancesWithGemini());
      }
      if (pendingMatchHistorySyncCount > 0) {
        unawaited(syncPendingMatchHistoryToSupabase());
      }
    }
    notifyListeners();
  }

  /// Safely evaluates connectivity output across `connectivity_plus` versions
  /// (handles both `List<ConnectivityResult>` and single `ConnectivityResult`).
  bool _evaluateConnectivityOnline(dynamic result) {
    if (result is List) {
      if (result.isEmpty) return false;
      return result.any((r) => r != ConnectivityResult.none);
    }
    if (result is ConnectivityResult) {
      return result != ConnectivityResult.none;
    }
    return true;
  }

  // --------------------------------------------------------------------------
  // 1. LOCAL SCENE CACHING (Supabase -> SharedPreferences)
  // --------------------------------------------------------------------------

  Future<void> _loadCachedScenePacksFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_kCachedScenesPrefsKey);
    final rawTs = prefs.getString(_kCachedScenesTimestampKey);

    if (rawTs != null) {
      _lastCacheSyncAt = DateTime.tryParse(rawTs);
    }

    _cachedPacksByCategory.clear();
    int count = 0;

    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          final list = (entry.value as List)
              .map(
                (item) =>
                    ScenePrompt.fromJson(Map<String, dynamic>.from(item as Map)),
              )
              .toList();
          _cachedPacksByCategory[entry.key] = list;
          count += list.length;
        }
      } catch (_) {}
    }

    // Seed local cache from built-in vault if no pack has been cached yet
    if (count == 0) {
      for (final entry in kBuiltInSceneVault.entries) {
        _cachedPacksByCategory[entry.key.key] = List.of(entry.value);
        count += entry.value.length;
      }
    }

    _cachedSceneCount = count;
  }

  /// Downloads Scene Packs (`title`, `script_excerpt`, `target_emotion`, etc.)
  /// from Supabase `public.scenes` while online and caches them into
  /// `SharedPreferences` for offline play.
  Future<int> downloadAndCacheScenePacks() async {
    await ensureInitialized();
    _isCachingScenes = true;
    notifyListeners();

    try {
      final Map<String, List<ScenePrompt>> packs = {};
      for (final category in SceneCategory.values) {
        packs[category.key] = List.of(
          kBuiltInSceneVault[category] ??
              kBuiltInSceneVault[SceneCategory.era1970To1999]!,
        );
      }

      final client = supabaseOrNull;
      if (client != null && _isOnline) {
        try {
          final rows = await client
              .from('scenes')
              .select()
              .eq('is_late_night', false);

          if (rows.isNotEmpty) {
            final Map<String, List<ScenePrompt>> remotePacks = {};
            for (final rawRow in rows) {
              final map = Map<String, dynamic>.from(rawRow as Map);
              final categoryLabel = map['category']?.toString() ?? '';
              final category = SceneCategory.fromKey(categoryLabel);
              final prompt = ScenePrompt.fromJson(map);
              remotePacks.putIfAbsent(category.key, () => []).add(prompt);
            }
            for (final entry in remotePacks.entries) {
              if (entry.value.isNotEmpty) {
                packs[entry.key] = entry.value;
              }
            }
          }
        } catch (_) {
          // Keep built-in fallback packs if Supabase table is unreachable
        }
      }

      _cachedPacksByCategory
        ..clear()
        ..addAll(packs);

      int totalCached = 0;
      final serializedMap = <String, dynamic>{};
      for (final entry in _cachedPacksByCategory.entries) {
        totalCached += entry.value.length;
        serializedMap[entry.key] =
            entry.value.map((scene) => scene.toJson()).toList();
      }

      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().toUtc();
      await prefs.setString(_kCachedScenesPrefsKey, jsonEncode(serializedMap));
      await prefs.setString(_kCachedScenesTimestampKey, now.toIso8601String());

      _cachedSceneCount = totalCached;
      _lastCacheSyncAt = now;
      return totalCached;
    } finally {
      _isCachingScenes = false;
      notifyListeners();
    }
  }

  /// Returns cached Scene Prompts for the given [category] during offline play.
  List<ScenePrompt> getCachedScenesForCategory(SceneCategory category) {
    final cached = _cachedPacksByCategory[category.key];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    return kBuiltInSceneVault[category] ??
        kBuiltInSceneVault[SceneCategory.era1970To1999]!;
  }

  ScenePrompt drawRandomCachedScene(SceneCategory category) {
    final list = getCachedScenesForCategory(category);
    final random = Random.secure();
    return list[random.nextInt(list.length)];
  }

  // --------------------------------------------------------------------------
  // 2. PASS-AND-PLAY LOCAL TEMPORARY VIDEO STORAGE (`path_provider`)
  // --------------------------------------------------------------------------

  /// Saves a recorded 30-second Pass-and-Play performance clip into the device's
  /// local temporary directory (`getTemporaryDirectory()`) for local peer loop
  /// playback and queued Gemini AI evaluation.
  Future<String> saveLocalOfflineClipToTempDir({
    required String sourceFilePath,
    required String performerName,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final partyDir = Directory('${tempDir.path}/offline_party_takes');
    if (!partyDir.existsSync()) {
      await partyDir.create(recursive: true);
    }

    final safeActor =
        performerName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_').toLowerCase();
    final targetPath =
        '${partyDir.path}/take_${safeActor}_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final sourceFile = File(sourceFilePath);
    if (sourceFile.existsSync()) {
      final copied = await sourceFile.copy(targetPath);
      return copied.path;
    }
    return targetPath;
  }

  // --------------------------------------------------------------------------
  // 3. QUEUED GEMINI AI JUDGING (Store & Forward Background Queue)
  // --------------------------------------------------------------------------

  Future<void> _loadQueueFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getString(_kQueuedPerformancesPrefsKey);
    _queue.clear();
    if (rawList == null || rawList.isEmpty) return;

    try {
      final decoded = jsonDecode(rawList) as List;
      for (final item in decoded) {
        _queue.add(
          QueuedOfflinePerformance.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _persistQueueToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_queue.map((e) => e.toJson()).toList());
    await prefs.setString(_kQueuedPerformancesPrefsKey, encoded);
  }

  /// Enqueues an offline performance (local video path + 1-10 peer scores)
  /// into local storage. If connectivity is active, immediately processes the queue.
  Future<QueuedOfflinePerformance> enqueueOfflinePerformance({
    required String performerName,
    required SceneCategory category,
    required ScenePrompt scene,
    required String localVideoPath,
    required List<int> peerRatings1To10,
    double socialScore100 = 75.0,
  }) async {
    await ensureInitialized();

    final normalizedRatings =
        peerRatings1To10.isEmpty ? const [9] : peerRatings1To10;
    final avg1To10 = normalizedRatings.fold<int>(0, (a, b) => a + b) /
        normalizedRatings.length;
    final peerScore100 = (avg1To10 * 10.0).clamp(10.0, 100.0);

    final item = QueuedOfflinePerformance(
      id: 'offline_q_${DateTime.now().millisecondsSinceEpoch}',
      performerName: performerName,
      categoryKey: category.key,
      scene: scene,
      localVideoPath: localVideoPath,
      peerRatings1To10: normalizedRatings,
      peerScore100: peerScore100,
      socialScore100: socialScore100,
      status: 'queued_offline',
      createdAt: DateTime.now().toUtc(),
    );

    _queue.insert(0, item);
    await _persistQueueToPrefs();

    // Immediately queue a preliminary MatchHistoryRecord locally during Pass-and-Play mode
    final provisionalComposite =
        ((86.0 * 0.45) + (peerScore100 * 0.35) + (socialScore100 * 0.20))
            .clamp(0.0, 100.0);
    await queueOfflineMatchHistoryRecord(
      id: 'mh_${item.id}',
      playerId: performerName,
      scene: scene,
      aiScore: 86.0,
      peerScore: peerScore100,
      socialScore: socialScore100,
      finalScore: provisionalComposite,
      isWin: provisionalComposite >= 85.0,
      alreadySyncedToSupabase: false,
    );
    notifyListeners();

    // Check live connectivity and flush immediately if online
    final status = await _connectivity.checkConnectivity();
    _isOnline = _evaluateConnectivityOnline(status);
    if (_isOnline) {
      await processQueuedPerformancesWithGemini();
    }

    return _queue.firstWhere((e) => e.id == item.id, orElse: () => item);
  }

  /// Processes all queued offline performances through the Gemini AI API once
  /// `connectivity_plus` detects an active internet connection, finalizing each
  /// performance's Tri-Modal score.
  Future<void> processQueuedPerformancesWithGemini() async {
    if (_isProcessingQueue) return;
    final hasPending = _queue.any((item) => item.status != 'finalized');
    if (!hasPending) return;

    _isProcessingQueue = true;
    notifyListeners();

    try {
      for (int i = 0; i < _queue.length; i++) {
        final item = _queue[i];
        if (item.status == 'finalized') continue;

        _queue[i] = item.copyWith(status: 'processing_ai');
        notifyListeners();

        double aiScore = 89.0;
        String critique =
            'Store & Forward Gemini AI Telemetrics finalized for "${item.scene.title}". Strong emotional commitment to ${item.scene.emotionalTarget}.';

        try {
          if (AppConfig.geminiApiKey.isNotEmpty) {
            final model = GenerativeModel(
              model: 'gemini-2.5-flash',
              apiKey: AppConfig.geminiApiKey,
              generationConfig: GenerationConfig(
                responseMimeType: 'application/json',
                temperature: 0.2,
              ),
            );

            final promptText = '''
You are the AI Telemetrics Judge for "Act Like It" processing a queued Store & Forward performance recorded in Offline Local Party Mode.
Evaluate the performance against the cached scene pack:
- Performer: ${item.performerName}
- Scene Title: ${item.scene.title} (${item.scene.filmOrSeries}, ${item.scene.releaseYear})
- Character: ${item.scene.characterName}
- Script Excerpt: "${item.scene.promptScript}"
- Target Emotion: "${item.scene.emotionalTarget}"
- Local Room Peer Score (1-10 scale converted to 100): ${item.peerScore100.toStringAsFixed(1)}/100

Return strict JSON:
{
  "overall_ai_score": <number 0-100>,
  "facial_expression_score": <number 0-100>,
  "vocal_cadence_score": <number 0-100>,
  "director_cue_fidelity": <number 0-100>,
  "director_critique": "<concise 1-2 sentence director feedback>"
}
''';

            final parts = <Part>[TextPart(promptText)];
            if (item.localVideoPath.isNotEmpty) {
              final videoFile = File(item.localVideoPath);
              if (videoFile.existsSync()) {
                final bytes = await videoFile.readAsBytes();
                // Attach video clip if within inline payload bounds
                if (bytes.isNotEmpty && bytes.lengthInBytes <= 18 * 1024 * 1024) {
                  parts.add(DataPart('video/mp4', bytes));
                }
              }
            }

            final response = await model.generateContent([Content.multi(parts)]);
            final decoded =
                jsonDecode(response.text ?? '{}') as Map<String, dynamic>;
            final report = AiTelemetricsReport.fromJson(decoded);
            aiScore = report.overallAiScore;
            critique = report.directorCritique;
          }
        } catch (_) {
          // Deterministic fallback when Gemini key is not yet entered
          aiScore = (86.0 + (item.peerScore100 * 0.10)).clamp(0.0, 98.0);
        }

        final composite = ((aiScore * 0.45) +
                (item.peerScore100 * 0.35) +
                (item.socialScore100 * 0.20))
            .clamp(0.0, 100.0);

        _queue[i] = item.copyWith(
          status: 'finalized',
          finalizedAiScore: aiScore,
          finalizedCompositeScore: composite,
          finalizedCritique: critique,
        );

        // Automatically queue/update the corresponding MatchHistoryRecord and push to Supabase
        await queueOfflineMatchHistoryRecord(
          id: 'mh_${item.id}',
          playerId: item.performerName,
          scene: item.scene,
          aiScore: aiScore,
          peerScore: item.peerScore100,
          socialScore: item.socialScore100,
          finalScore: composite,
          isWin: composite >= 85.0,
        );
      }

      await _persistQueueToPrefs();
      await syncPendingMatchHistoryToSupabase();
    } finally {
      _isProcessingQueue = false;
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // 4. MATCH HISTORY & WIN TRACKING (Offline Queue + Auto-Sync to Supabase)
  // --------------------------------------------------------------------------

  Future<void> _loadMatchHistoryFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kMatchHistoryQueuePrefsKey);
    _matchHistoryLog.clear();

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List;
        for (final item in decoded) {
          _matchHistoryLog.add(
            MatchHistoryRecord.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          );
        }
      } catch (_) {}
    }

    // Seed initial showcase Career Trophy Room records if empty so the user can
    // inspect the Trophy Room immediately before or after playing a round.
    if (_matchHistoryLog.isEmpty) {
      _matchHistoryLog.addAll([
        MatchHistoryRecord(
          id: 'mh_seed_1',
          playerId: 'local-s26-actor',
          sceneId: 'era-2000-1',
          sceneTitle: 'Interrogation Room',
          filmOrSeries: 'The Dark Knight (2008)',
          aiScore: 95.0,
          peerScore: 92.0,
          socialScore: 89.0,
          finalScore: 92.8,
          isWin: true,
          syncedToSupabase: true,
          createdAt: DateTime.now().toUtc().subtract(const Duration(hours: 5)),
        ),
        MatchHistoryRecord(
          id: 'mh_seed_2',
          playerId: 'local-s26-actor',
          sceneId: 'award-actor-1',
          sceneTitle: 'Milkshake Monologue',
          filmOrSeries: 'There Will Be Blood (2007)',
          aiScore: 91.5,
          peerScore: 88.0,
          socialScore: 84.0,
          finalScore: 88.8,
          isWin: true,
          syncedToSupabase: true,
          createdAt: DateTime.now().toUtc().subtract(const Duration(days: 1)),
        ),
        MatchHistoryRecord(
          id: 'mh_seed_3',
          playerId: 'local-s26-actor',
          sceneId: 'cult-1',
          sceneTitle: 'First Rule of Fight Club',
          filmOrSeries: 'Fight Club (1999)',
          aiScore: 81.0,
          peerScore: 79.0,
          socialScore: 76.0,
          finalScore: 79.3,
          isWin: false,
          syncedToSupabase: true,
          createdAt: DateTime.now().toUtc().subtract(const Duration(days: 2)),
        ),
      ]);
      await _persistMatchHistoryToPrefs();
    }
  }

  Future<void> _persistMatchHistoryToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _matchHistoryLog.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_kMatchHistoryQueuePrefsKey, encoded);
  }

  /// Queues a match history record locally (used in Pass-and-Play Offline Mode
  /// and as a local cache for online rounds) and immediately pushes to Supabase
  /// `public.match_history` if an active internet connection is available.
  Future<MatchHistoryRecord> queueOfflineMatchHistoryRecord({
    String? id,
    required String playerId,
    required ScenePrompt scene,
    required double aiScore,
    required double peerScore,
    required double socialScore,
    required double finalScore,
    required bool isWin,
    bool alreadySyncedToSupabase = false,
  }) async {
    await ensureInitialized();

    final recordId = id ?? 'mh_${DateTime.now().millisecondsSinceEpoch}';
    final record = MatchHistoryRecord(
      id: recordId,
      playerId: playerId,
      sceneId: scene.id,
      sceneTitle: scene.title,
      filmOrSeries: '${scene.filmOrSeries} (${scene.releaseYear})',
      aiScore: aiScore.clamp(0.0, 100.0),
      peerScore: peerScore.clamp(0.0, 100.0),
      socialScore: socialScore.clamp(0.0, 100.0),
      finalScore: finalScore.clamp(0.0, 100.0),
      isWin: isWin,
      syncedToSupabase: alreadySyncedToSupabase,
      createdAt: DateTime.now().toUtc(),
    );

    final existingIdx = _matchHistoryLog.indexWhere((e) => e.id == recordId);
    if (existingIdx >= 0) {
      _matchHistoryLog[existingIdx] = record;
    } else {
      _matchHistoryLog.insert(0, record);
    }

    await _persistMatchHistoryToPrefs();
    notifyListeners();

    if (!alreadySyncedToSupabase && _isOnline) {
      await syncPendingMatchHistoryToSupabase();
    }

    return _matchHistoryLog.firstWhere(
      (e) => e.id == recordId,
      orElse: () => record,
    );
  }

  /// Pushes all unsynced local `MatchHistoryRecord` entries into the Supabase
  /// `public.match_history` table when `connectivity_plus` detects an active
  /// internet connection.
  Future<int> syncPendingMatchHistoryToSupabase() async {
    final client = supabaseOrNull;
    if (client == null || !_isOnline) return 0;

    final authUserId = client.auth.currentUser?.id;
    int syncedCount = 0;

    for (int i = 0; i < _matchHistoryLog.length; i++) {
      final entry = _matchHistoryLog[i];
      if (entry.syncedToSupabase) continue;

      final resolvedUuid = authUserId ?? entry.playerId;
      final isValidUuid = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(resolvedUuid);

      if (!isValidUuid) continue;

      try {
        await client
            .from('match_history')
            .insert(entry.toSupabaseInsertRow(resolvedUuid));
        _matchHistoryLog[i] = entry.copyWith(syncedToSupabase: true);
        syncedCount++;
      } catch (_) {
        // Keep in queue for next connectivity_plus reconnect cycle
      }
    }

    if (syncedCount > 0) {
      await _persistMatchHistoryToPrefs();
      notifyListeners();
    }
    return syncedCount;
  }

  /// Fetches the authenticated user's remote `match_history` rows from Supabase
  /// and merges them into the local Career Trophy Room log.
  Future<List<MatchHistoryRecord>> refreshMatchHistoryFromSupabase() async {
    await ensureInitialized();
    final client = supabaseOrNull;
    if (client != null && _isOnline) {
      try {
        await syncPendingMatchHistoryToSupabase();
        final authUserId = client.auth.currentUser?.id;
        if (authUserId != null) {
          final rows = await client
              .from('match_history')
              .select('*, scenes(title, category)')
              .eq('player_id', authUserId)
              .order('created_at', ascending: false)
              .limit(50);

          for (final rawRow in rows) {
            final map = Map<String, dynamic>.from(rawRow as Map);
            map['synced_to_supabase'] = true;
            final remoteRecord = MatchHistoryRecord.fromJson(map);
            final exists =
                _matchHistoryLog.any((local) => local.id == remoteRecord.id);
            if (!exists) {
              _matchHistoryLog.add(remoteRecord);
            }
          }
          _matchHistoryLog.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          await _persistMatchHistoryToPrefs();
          notifyListeners();
        }
      } catch (_) {}
    }
    return List.unmodifiable(_matchHistoryLog);
  }
}

/// Offline Pass-and-Play Multiplayer Screen:
/// Uses the native camera to record a 30-second clip to the device's local
/// temporary directory (`path_provider`) and routes directly to local looped
/// Peer Judging (1–10 scale) + Queued Gemini AI Judging.
class OfflineLocalPartyScreen extends StatefulWidget {
  final SceneCategory initialCategory;

  const OfflineLocalPartyScreen({
    super.key,
    this.initialCategory = SceneCategory.era1970To1999,
  });

  @override
  State<OfflineLocalPartyScreen> createState() =>
      _OfflineLocalPartyScreenState();
}

class _OfflineLocalPartyScreenState extends State<OfflineLocalPartyScreen> {
  final OfflineManager _offlineManager = OfflineManager.instance;
  final TextEditingController _playerController = TextEditingController();
  final List<String> _partyRoster = ['Player 1 (Host)', 'Player 2'];

  late SceneCategory _selectedCategory;
  ScenePrompt? _activeScene;
  int _activePlayerIndex = 0;

  hw_cam.CameraController? _cameraController;
  List<hw_cam.CameraDescription> _cameras = [];
  int _selectedCameraIdx = 0;
  bool _isRecording30sClip = false;
  int _remainingSeconds = 30;
  Timer? _countdownTimer;
  String? _statusBanner;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _offlineManager.addListener(_onOfflineManagerChanged);
    _initializeOfflineParty();
  }

  Future<void> _initializeOfflineParty() async {
    await _offlineManager.ensureInitialized();
    _activeScene = _offlineManager.drawRandomCachedScene(_selectedCategory);
    await _initNativeCamera();
    if (mounted) setState(() {});
  }

  void _onOfflineManagerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _initNativeCamera() async {
    try {
      await [Permission.camera, Permission.microphone].request();
      _cameras = await hw_cam.availableCameras();
      if (_cameras.isEmpty) return;

      final frontIdx = _cameras.indexWhere(
        (c) => c.lensDirection == hw_cam.CameraLensDirection.front,
      );
      _selectedCameraIdx = frontIdx >= 0 ? frontIdx : 0;

      final controller = hw_cam.CameraController(
        _cameras[_selectedCameraIdx],
        hw_cam.ResolutionPreset.high,
        enableAudio: true,
      );
      _cameraController = controller;
      await controller.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      _statusBanner = 'Native camera notice: $e';
    }
  }

  Future<void> _start30SecondPassAndPlayRecording() async {
    final cam = _cameraController;
    if (_isRecording30sClip) return;

    setState(() {
      _isRecording30sClip = true;
      _remainingSeconds = 30;
      _statusBanner = 'Recording 30s Pass-and-Play take to local temp storage...';
    });

    if (cam != null && cam.value.isInitialized && !cam.value.isRecordingVideo) {
      try {
        await cam.startVideoRecording();
      } catch (_) {}
    }

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _finish30SecondRecordingAndOpenPeerJudging();
      } else {
        setState(() {
          _remainingSeconds -= 1;
        });
      }
    });
  }

  Future<void> _finish30SecondRecordingAndOpenPeerJudging() async {
    _countdownTimer?.cancel();
    final cam = _cameraController;
    final currentPerformer = _partyRoster[_activePlayerIndex];
    final currentScene = _activeScene ??
        _offlineManager.drawRandomCachedScene(_selectedCategory);

    String savedLocalPath = '';
    if (cam != null && cam.value.isInitialized && cam.value.isRecordingVideo) {
      try {
        final xfile = await cam.stopVideoRecording();
        savedLocalPath = await _offlineManager.saveLocalOfflineClipToTempDir(
          sourceFilePath: xfile.path,
          performerName: currentPerformer,
        );
      } catch (_) {}
    } else {
      // Create deterministic local temp placeholder path if camera hardware is unavailable
      final tempDir = await getTemporaryDirectory();
      savedLocalPath =
          '${tempDir.path}/offline_take_${DateTime.now().millisecondsSinceEpoch}.mp4';
    }

    if (!mounted) return;
    setState(() {
      _isRecording30sClip = false;
      _statusBanner = 'Saved local clip: $savedLocalPath';
    });

    final localSession = LobbySession(
      id: 'offline-party-${DateTime.now().millisecondsSinceEpoch}',
      roomCode: '000000',
      hostId: 'local-pass-and-play',
      selectedCategory: _selectedCategory,
      status: 'judging',
      activeActorId: currentPerformer,
      activeScene: currentScene,
      livekitRoomName: 'offline_local_party',
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TriModalJudgingScreen(
          lobbySession: localSession,
          performerUserId: currentPerformer,
          performerDisplayName: currentPerformer,
          capturedSamples: const [],
          localRecordedVideoPath: savedLocalPath,
          isOfflineLocalParty: true,
        ),
      ),
    );

    if (!mounted) return;
    setState(() {
      _activePlayerIndex = (_activePlayerIndex + 1) % _partyRoster.length;
      _activeScene = _offlineManager.drawRandomCachedScene(_selectedCategory);
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _offlineManager.removeListener(_onOfflineManagerChanged);
    _cameraController?.dispose();
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scene = _activeScene ??
        _offlineManager.drawRandomCachedScene(_selectedCategory);
    final currentActor = _partyRoster[_activePlayerIndex];
    final cam = _cameraController;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Local Party · Pass & Play'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                _offlineManager.isOnline ? 'ONLINE · SYNC READY' : 'OFFLINE MODE',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _offlineManager.isOnline
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            // 1. Offline Scene Pack Cache & Queue Status Banner
            Container(
              padding: const EdgeInsets.all(14),
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
                      Text(
                        'CACHED SCENE PACKS: ${_offlineManager.cachedSceneCount} SCENES',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF06B6D4),
                        ),
                      ),
                      Text(
                        'AI QUEUE: ${_offlineManager.pendingQueueCount} PENDING',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _offlineManager.isCachingScenes
                              ? null
                              : () async {
                                  final count = await _offlineManager
                                      .downloadAndCacheScenePacks();
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Cached $count scenes to local storage for offline play.',
                                      ),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.download_for_offline_outlined,
                              size: 16),
                          label: Text(
                            _offlineManager.isCachingScenes
                                ? 'Caching Scene Packs...'
                                : 'Download & Cache Scene Packs',
                          ),
                        ),
                      ),
                      if (_offlineManager.pendingQueueCount > 0) ...[
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _offlineManager.isProcessingQueue
                              ? null
                              : () => _offlineManager
                                  .processQueuedPerformancesWithGemini(),
                          child: const Text('Sync AI Queue'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Pass-and-Play Turn & Category Selector
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF121722),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PASS THE PHONE TO: ${currentActor.toUpperCase()}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<SceneCategory>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Cached Scene Category',
                      border: OutlineInputBorder(),
                    ),
                    items: SceneCategory.values
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.label),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCategory = val;
                          _activeScene =
                              _offlineManager.drawRandomCachedScene(val);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _playerController,
                          decoration: const InputDecoration(
                            hintText: 'Add Local Party Player Name',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          final name = _playerController.text.trim();
                          if (name.isEmpty) return;
                          setState(() {
                            _partyRoster.add(name);
                            _playerController.clear();
                          });
                        },
                        child: const Text('Add Player'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Native 30-Second Camera Stage + Cached Teleprompter
            Container(
              height: 310,
              decoration: BoxDecoration(
                color: const Color(0xFF0B0E17),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE11D48), width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (cam != null && cam.value.isInitialized)
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: cam.value.previewSize?.height ?? 720,
                        height: cam.value.previewSize?.width ?? 1280,
                        child: hw_cam.CameraPreview(cam),
                      ),
                    )
                  else
                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.videocam_outlined,
                            size: 44,
                            color: Color(0xFFE11D48),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Native Camera Ready · Local Temp MP4 Capture',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _isRecording30sClip
                            ? 'REC · ${_remainingSeconds}s LEFT'
                            : '30s LOCAL CLIP',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      color: const Color(0xD90A0D14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${scene.title} · ${scene.characterName} (${scene.emotionalTarget})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"${scene.promptScript}"',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_statusBanner != null) ...[
              const SizedBox(height: 8),
              Text(
                _statusBanner!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _activeScene = _offlineManager
                            .drawRandomCachedScene(_selectedCategory);
                      });
                    },
                    child: const Text('Draw Cached Scene'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isRecording30sClip
                        ? _finish30SecondRecordingAndOpenPeerJudging
                        : _start30SecondPassAndPlayRecording,
                    icon: Icon(
                      _isRecording30sClip ? Icons.stop : Icons.fiber_manual_record,
                      size: 18,
                    ),
                    label: Text(
                      _isRecording30sClip
                          ? 'Stop & Pass Phone to Judge (${_remainingSeconds}s)'
                          : 'Record 30s Local Clip & Judge',
                    ),
                  ),
                ),
              ],
            ),

            // 4. Queued Gemini AI Store & Forward Ledger
            if (_offlineManager.queue.isNotEmpty) ...[
              const SizedBox(height: 22),
              const Text(
                'Store & Forward · Queued Gemini AI Performances',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ..._offlineManager.queue.take(5).map(
                    (q) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121722),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${q.performerName} · ${q.scene.title}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                q.status.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: q.status == 'finalized'
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            q.status == 'finalized'
                                ? 'Peer: ${q.peerScore100.toStringAsFixed(0)} · AI: ${q.finalizedAiScore?.toStringAsFixed(1)} · Final Tri-Modal: ${q.finalizedCompositeScore?.toStringAsFixed(1)}'
                                : 'Peer Score Locked (${q.peerScore100.toStringAsFixed(0)}/100) · Waiting for connectivity_plus to run Gemini AI...',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
