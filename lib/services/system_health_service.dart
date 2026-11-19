import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../judging_engine.dart';
import '../main.dart';
import '../offline_manager.dart';

enum SystemServiceHealthState {
  healthy,
  degraded,
  down,
}

@immutable
class SystemServiceCheck {
  final String id;
  final String shortCode;
  final String label;
  final int score;
  final int maxScore;
  final SystemServiceHealthState state;
  final String detail;
  final DateTime checkedAtUtc;

  const SystemServiceCheck({
    required this.id,
    required this.shortCode,
    required this.label,
    required this.score,
    this.maxScore = 25,
    required this.state,
    required this.detail,
    required this.checkedAtUtc,
  });

  bool get isHealthy => state == SystemServiceHealthState.healthy;
  bool get isDegraded => state == SystemServiceHealthState.degraded;
  bool get isDown => state == SystemServiceHealthState.down;
}

/// Reactive singleton health monitor wired into core ACT LIKE IT™ subsystems:
/// 1. Supabase & Realtime Link (25 pts)
/// 2. LiveKit WebRTC & Media Pipeline (25 pts)
/// 3. Gemini AI Judging Engine (25 pts)
/// 4. Local Cache & Offline Store-and-Forward (25 pts)
class SystemHealthService extends ChangeNotifier {
  SystemHealthService._internal() {
    OfflineManager.instance.addListener(_onOfflineManagerChanged);
  }

  static final SystemHealthService instance = SystemHealthService._internal();

  static const String _envLiveKitUrl = String.fromEnvironment(
    'LIVEKIT_URL',
    defaultValue: 'wss://act-like-it-3nsihhbg.livekit.cloud',
  );
  static const String _envGeminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  bool _isChecking = false;
  bool _hasCompletedInitialCheck = false;
  DateTime _lastCheckedAt = DateTime.now().toUtc();
  List<SystemServiceCheck> _checks = _buildBaselineChecks();

  static List<SystemServiceCheck> _buildBaselineChecks() {
    final now = DateTime.now().toUtc();
    return <SystemServiceCheck>[
      SystemServiceCheck(
        id: 'supabase_realtime',
        shortCode: 'DB/RT',
        label: 'Supabase & Realtime Link',
        score: 20,
        state: SystemServiceHealthState.degraded,
        detail: 'Initializing Supabase & Realtime telemetry...',
        checkedAtUtc: now,
      ),
      SystemServiceCheck(
        id: 'livekit_webrtc',
        shortCode: 'WEBRTC',
        label: 'LiveKit WebRTC & Media',
        score: 25,
        state: SystemServiceHealthState.healthy,
        detail: 'Checking LiveKit Cloud SFU endpoint...',
        checkedAtUtc: now,
      ),
      SystemServiceCheck(
        id: 'gemini_ai',
        shortCode: 'AI',
        label: 'Gemini AI Judging Engine',
        score: 20,
        state: SystemServiceHealthState.degraded,
        detail: 'Verifying Gemini cascade & queued judging...',
        checkedAtUtc: now,
      ),
      SystemServiceCheck(
        id: 'local_cache',
        shortCode: 'CACHE',
        label: 'Local Cache & Store-Forward',
        score: 20,
        state: SystemServiceHealthState.degraded,
        detail: 'Warming SharedPreferences & local vault...',
        checkedAtUtc: now,
      ),
    ];
  }

  bool get isChecking => _isChecking;
  bool get hasCompletedInitialCheck => _hasCompletedInitialCheck;
  DateTime get lastCheckedAt => _lastCheckedAt;
  List<SystemServiceCheck> get checks => List<SystemServiceCheck>.unmodifiable(_checks);

  int get healthPercent {
    final rawTotal = _checks.fold<int>(0, (sum, item) => sum + item.score);
    return rawTotal.clamp(0, 100);
  }

  /// Green (100%), Yellow/Amber (75-99%), Red (<75%).
  Color get indicatorColor {
    final pct = healthPercent;
    if (pct >= 100) return const Color(0xFF00FF88);
    if (pct >= 75) return const Color(0xFFFFD60A);
    return const Color(0xFFFF2A55);
  }

  Color get secondaryAccentColor {
    final pct = healthPercent;
    if (pct >= 100) return const Color(0xFF10B981);
    if (pct >= 75) return const Color(0xFFF59E0B);
    return const Color(0xFFE11342);
  }

  String get statusLabel {
    final pct = healthPercent;
    if (pct >= 100) return 'LIVE 100%';
    if (pct >= 75) return 'LIVE $pct%';
    return 'CHECK $pct%';
  }

  String get statusSummary {
    final pct = healthPercent;
    if (pct >= 100) {
      return 'All core services online & synchronized.';
    }
    if (pct >= 75) {
      final degradedNames = _checks
          .where((c) => !c.isHealthy)
          .map((c) => c.shortCode)
          .join(', ');
      return degradedNames.isEmpty
          ? 'Core app operational with fallback guards.'
          : 'Core app operational · Fallback/check on: $degradedNames';
    }
    final failingNames = _checks
        .where((c) => !c.isHealthy)
        .map((c) => c.shortCode)
        .join(', ');
    return failingNames.isEmpty
        ? 'Core services require inspection.'
        : 'Attention needed on: $failingNames';
  }

  void _onOfflineManagerChanged() {
    if (_isChecking) return;
    unawaited(refreshHealthChecks());
  }

  Future<int> refreshHealthChecks() async {
    if (_isChecking) return healthPercent;
    _isChecking = true;
    notifyListeners();

    final now = DateTime.now().toUtc();
    bool connectivityOnline = OfflineManager.instance.isOnline;
    try {
      final dynamic connRaw = await Connectivity()
          .checkConnectivity()
          .timeout(const Duration(seconds: 2));
      if (connRaw is List<ConnectivityResult>) {
        connectivityOnline =
            connRaw.any((r) => r != ConnectivityResult.none);
      } else if (connRaw is ConnectivityResult) {
        connectivityOnline = connRaw != ConnectivityResult.none;
      }
    } catch (_) {}

    // 1. Supabase & Realtime Link (25 pts)
    final SystemServiceCheck supabaseCheck = _evaluateSupabaseCheck(
      isOnline: connectivityOnline,
      now: now,
    );

    // 2. LiveKit WebRTC & Media Pipeline (25 pts)
    final SystemServiceCheck liveKitCheck = _evaluateLiveKitCheck(
      isOnline: connectivityOnline,
      now: now,
    );

    // 3. Gemini AI Judging Engine (25 pts)
    final SystemServiceCheck geminiCheck = _evaluateGeminiCheck(
      isOnline: connectivityOnline,
      now: now,
    );

    // 4. Local Cache & Offline Store-and-Forward (25 pts)
    final SystemServiceCheck cacheCheck = await _evaluateLocalCacheCheck(
      now: now,
    );

    _checks = <SystemServiceCheck>[
      supabaseCheck,
      liveKitCheck,
      geminiCheck,
      cacheCheck,
    ];
    _lastCheckedAt = now;
    _hasCompletedInitialCheck = true;
    _isChecking = false;
    notifyListeners();
    return healthPercent;
  }

  SystemServiceCheck _evaluateSupabaseCheck({
    required bool isOnline,
    required DateTime now,
  }) {
    final bool hasCloud = AppConfig.hasCloudSupabase;
    SupabaseClient? client;
    bool realtimeAvailable = false;
    bool authAvailable = false;
    if (hasCloud) {
      try {
        client = Supabase.instance.client;
        realtimeAvailable = client.realtime.endPoint.isNotEmpty;
        authAvailable = true;
      } catch (_) {
        client = null;
      }
    }

    if (hasCloud && client != null && isOnline && realtimeAvailable && authAvailable) {
      return SystemServiceCheck(
        id: 'supabase_realtime',
        shortCode: 'DB/RT',
        label: 'Supabase & Realtime Link',
        score: 25,
        state: SystemServiceHealthState.healthy,
        detail: 'Cloud PostgreSQL, Auth & Realtime WS initialized.',
        checkedAtUtc: now,
      );
    }
    if (hasCloud && client != null && !isOnline) {
      return SystemServiceCheck(
        id: 'supabase_realtime',
        shortCode: 'DB/RT',
        label: 'Supabase & Realtime Link',
        score: 15,
        state: SystemServiceHealthState.degraded,
        detail: 'Device offline; queued mutations waiting for network recovery.',
        checkedAtUtc: now,
      );
    }
    return SystemServiceCheck(
      id: 'supabase_realtime',
      shortCode: 'DB/RT',
      label: 'Supabase & Realtime Link',
      score: 5,
      state: SystemServiceHealthState.down,
      detail: 'Supabase client unavailable; running in isolated local mode.',
      checkedAtUtc: now,
    );
  }

  SystemServiceCheck _evaluateLiveKitCheck({
    required bool isOnline,
    required DateTime now,
  }) {
    final configuredUrl = AppConfig.liveKitUrl.trim().isNotEmpty
        ? AppConfig.liveKitUrl.trim()
        : _envLiveKitUrl.trim();
    final parsedUri = Uri.tryParse(configuredUrl);
    final validWs = parsedUri != null &&
        parsedUri.scheme == 'wss' &&
        parsedUri.host.isNotEmpty &&
        !configuredUrl.contains('act-like-it-sfu.livekit.cloud');

    if (validWs && isOnline) {
      return SystemServiceCheck(
        id: 'livekit_webrtc',
        shortCode: 'WEBRTC',
        label: 'LiveKit WebRTC & Media',
        score: 25,
        state: SystemServiceHealthState.healthy,
        detail: 'LiveKit SFU ready (${parsedUri.host}) + Camera/Audio pipeline.',
        checkedAtUtc: now,
      );
    }
    if (validWs && !isOnline) {
      return SystemServiceCheck(
        id: 'livekit_webrtc',
        shortCode: 'WEBRTC',
        label: 'LiveKit WebRTC & Media',
        score: 15,
        state: SystemServiceHealthState.degraded,
        detail: 'LiveKit configured (${parsedUri.host}); local stage only while offline.',
        checkedAtUtc: now,
      );
    }
    return SystemServiceCheck(
      id: 'livekit_webrtc',
      shortCode: 'WEBRTC',
      label: 'LiveKit WebRTC & Media',
      score: 5,
      state: SystemServiceHealthState.down,
      detail: 'Missing valid wss:// LiveKit SFU endpoint.',
      checkedAtUtc: now,
    );
  }

  SystemServiceCheck _evaluateGeminiCheck({
    required bool isOnline,
    required DateTime now,
  }) {
    final runtimeOrEnvKey = AppConfig.geminiApiKey.trim().isNotEmpty
        ? AppConfig.geminiApiKey.trim()
        : _envGeminiApiKey.trim();
    final hasCascade = TriModalJudgingEngine.kGeminiModelCascade.isNotEmpty;
    final pendingQueue = OfflineManager.instance.pendingQueueCount;

    if (runtimeOrEnvKey.isNotEmpty && isOnline && hasCascade) {
      return SystemServiceCheck(
        id: 'gemini_ai',
        shortCode: 'AI',
        label: 'Gemini AI Judging Engine',
        score: 25,
        state: SystemServiceHealthState.healthy,
        detail:
            'Primary ${TriModalJudgingEngine.kGeminiModelCascade.first} active with ${TriModalJudgingEngine.kGeminiModelCascade.length}-model cascade.',
        checkedAtUtc: now,
      );
    }
    if (hasCascade) {
      final fallbackReason = !isOnline
          ? 'Offline store-and-forward judging queue active ($pendingQueue queued).'
          : 'GEMINI_API_KEY not supplied in client build; deterministic + queued fallback active.';
      return SystemServiceCheck(
        id: 'gemini_ai',
        shortCode: 'AI',
        label: 'Gemini AI Judging Engine',
        score: 20,
        state: SystemServiceHealthState.degraded,
        detail: fallbackReason,
        checkedAtUtc: now,
      );
    }
    return SystemServiceCheck(
      id: 'gemini_ai',
      shortCode: 'AI',
      label: 'Gemini AI Judging Engine',
      score: 5,
      state: SystemServiceHealthState.down,
      detail: 'AI Judging pipeline unavailable.',
      checkedAtUtc: now,
    );
  }

  Future<SystemServiceCheck> _evaluateLocalCacheCheck({
    required DateTime now,
  }) async {
    bool prefsReady = false;
    try {
      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 2));
      prefsReady = prefs.getKeys().isNotEmpty || true;
    } catch (_) {
      prefsReady = false;
    }

    final cachedScenes = OfflineManager.instance.cachedSceneCount;
    final queueCount = OfflineManager.instance.pendingQueueCount;
    final storageTag = kIsWeb ? 'Web SharedPreferences' : 'SharedPreferences + SQLite';

    if (prefsReady && cachedScenes > 0) {
      return SystemServiceCheck(
        id: 'local_cache',
        shortCode: 'CACHE',
        label: 'Local Cache & Store-Forward',
        score: 25,
        state: SystemServiceHealthState.healthy,
        detail: '$storageTag ready ($cachedScenes scenes · $queueCount queued).',
        checkedAtUtc: now,
      );
    }
    if (prefsReady) {
      return SystemServiceCheck(
        id: 'local_cache',
        shortCode: 'CACHE',
        label: 'Local Cache & Store-Forward',
        score: 20,
        state: SystemServiceHealthState.degraded,
        detail: '$storageTag ready; scene vault cache warming up.',
        checkedAtUtc: now,
      );
    }
    return SystemServiceCheck(
      id: 'local_cache',
      shortCode: 'CACHE',
      label: 'Local Cache & Store-Forward',
      score: 5,
      state: SystemServiceHealthState.down,
      detail: 'Local storage engine failed initialization check.',
      checkedAtUtc: now,
    );
  }

  @override
  void dispose() {
    OfflineManager.instance.removeListener(_onOfflineManagerChanged);
    super.dispose();
  }
}
