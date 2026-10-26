import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../auth/auth_service.dart';
import '../main.dart';
import '../ui/game_settings_modal.dart';
import 'qa_web_portal.dart';

/// Tracks the active `PageRoute` across the application so Shake-to-Report
/// always captures the exact screen the tester is viewing.
class QaRouteObserver extends NavigatorObserver {
  QaRouteObserver._internal();
  static final QaRouteObserver instance = QaRouteObserver._internal();

  String _currentRouteName = '/intro-cinematic';
  final List<String> _routeBreadcrumb = <String>['/intro-cinematic'];

  String get currentRouteName => _currentRouteName;
  List<String> get routeBreadcrumb => List<String>.unmodifiable(_routeBreadcrumb);

  void _recordRoute(Route<dynamic>? route) {
    if (route == null) return;
    final name = route.settings.name ??
        route.runtimeType.toString().replaceAll('MaterialPageRoute<dynamic>', 'MaterialPageRoute');
    _currentRouteName = name;
    _routeBreadcrumb.add('${DateTime.now().toIso8601String()} -> $name');
    if (_routeBreadcrumb.length > 15) {
      _routeBreadcrumb.removeAt(0);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _recordRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _recordRoute(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _recordRoute(previousRoute);
  }
}

/// Immutable data model representing a row in `public.qa_feedback`.
class QaFeedbackReport {
  final String id;
  final String testerHandle;
  final String appVersion;
  final String bugType; // 'UI' | 'Audio' | 'AI Score' | 'Crash'
  final String? screenshotUrl;
  final Map<String, dynamic> deviceInfo;
  final Map<String, dynamic> localStateDump;
  final DateTime createdAt;

  const QaFeedbackReport({
    required this.id,
    required this.testerHandle,
    required this.appVersion,
    required this.bugType,
    this.screenshotUrl,
    required this.deviceInfo,
    required this.localStateDump,
    required this.createdAt,
  });

  factory QaFeedbackReport.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> parseMap(dynamic raw) {
      if (raw is Map) return Map<String, dynamic>.from(raw);
      if (raw is String && raw.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
        } catch (_) {}
      }
      return <String, dynamic>{};
    }

    return QaFeedbackReport(
      id: (json['id'] ?? const Uuid().v4()).toString(),
      testerHandle: (json['tester_handle'] ?? '@alpha_tester').toString(),
      appVersion: (json['app_version'] ?? '1.0.0+1').toString(),
      bugType: (json['bug_type'] ?? 'UI').toString(),
      screenshotUrl: json['screenshot_url']?.toString(),
      deviceInfo: parseMap(json['device_info']),
      localStateDump: parseMap(json['local_state_dump']),
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}') ??
          DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'tester_handle': testerHandle,
        'app_version': appVersion,
        'bug_type': bugType,
        'screenshot_url': screenshotUrl,
        'device_info': deviceInfo,
        'local_state_dump': localStateDump,
        'created_at': createdAt.toIso8601String(),
      };
}

/// Repository handling screenshot uploads to `qa-screenshots` and inserts/streams
/// for `public.qa_feedback` with automatic local cache fallback.
class QaTelemetryRepository {
  const QaTelemetryRepository();

  static const QaTelemetryRepository instance = QaTelemetryRepository();

  static const String storageBucket = 'qa-screenshots';
  static const String tableName = 'qa_feedback';
  static const String localCachePrefsKey = 'qa_feedback_local_cache_v1';
  static const String testerEnabledPrefsKey = 'is_tester';
  static const String appVersionString = '1.0.0+1 (S.O.A. Alpha)';

  /// Checks whether the current account has `is_tester = true` enabled.
  /// Defaults to `true` during the closed S.O.A. alpha test so every build
  /// is immediately instrumented out of the box.
  static Future<bool> isTesterAccountEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(testerEnabledPrefsKey)) {
        return prefs.getBool(testerEnabledPrefsKey) ?? true;
      }
      await prefs.setBool(testerEnabledPrefsKey, true);
      return true;
    } catch (_) {
      return true;
    }
  }

  /// Captures a complete dump of `SharedPreferences` and active route state.
  static Future<Map<String, dynamic>> buildLocalStateDump({
    required String testerNote,
    required String activeRoute,
  }) async {
    final prefsDump = <String, dynamic>{};
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in prefs.getKeys()) {
        if (key.contains('api_key') || key.contains('anon_key')) {
          final val = prefs.getString(key) ?? '';
          prefsDump[key] = val.isEmpty ? '<empty>' : '<redacted_${val.length}_chars>';
        } else {
          prefsDump[key] = prefs.get(key);
        }
      }
    } catch (e) {
      prefsDump['prefs_error'] = e.toString();
    }

    final profile = AuthService.instance.currentProfile;
    return <String, dynamic>{
      'tester_note': testerNote.trim(),
      'active_page_route': activeRoute,
      'route_breadcrumb': QaRouteObserver.instance.routeBreadcrumb,
      'active_profile': profile?.toJson() ?? <String, dynamic>{'status': 'guest'},
      'safe_boot_logs_tail': SafeBootDiagnostics.bootLogs.length > 10
          ? SafeBootDiagnostics.bootLogs
              .sublist(SafeBootDiagnostics.bootLogs.length - 10)
          : SafeBootDiagnostics.bootLogs,
      'shared_preferences_dump': prefsDump,
      'captured_at_utc': DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// Collects screen resolution, pixel ratio, and OS metadata via `device_info_plus`.
  static Future<Map<String, dynamic>> collectDeviceInfo(
    BuildContext? context,
  ) async {
    String physicalResolution = '1080x2340';
    String logicalResolution = '390x844';
    double pixelRatio = 3.0;

    try {
      final view = ui.PlatformDispatcher.instance.views.first;
      pixelRatio = view.devicePixelRatio;
      final phys = view.physicalSize;
      final log = phys / pixelRatio;
      physicalResolution = '${phys.width.round()}x${phys.height.round()}';
      logicalResolution = '${log.width.round()}x${log.height.round()}';
    } catch (_) {}

    final info = <String, dynamic>{
      'screen_resolution_px': physicalResolution,
      'logical_viewport_dp': logicalResolution,
      'device_pixel_ratio': double.parse(pixelRatio.toStringAsFixed(2)),
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
    };

    try {
      final plugin = DeviceInfoPlugin();
      if (kIsWeb) {
        final web = await plugin.webBrowserInfo;
        info['os'] = 'Web (${web.browserName.name})';
        info['user_agent'] = web.userAgent ?? 'Flutter Web';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final android = await plugin.androidInfo;
        info['os'] = 'Android ${android.version.release} (SDK ${android.version.sdkInt})';
        info['device_model'] = '${android.manufacturer} ${android.model}';
        info['hardware'] = android.hardware;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = await plugin.iosInfo;
        info['os'] = '${ios.systemName} ${ios.systemVersion}';
        info['device_model'] = ios.utsname.machine;
      }
    } catch (_) {
      info['os'] = kIsWeb ? 'Flutter Web' : defaultTargetPlatform.name;
    }

    return info;
  }

  /// Uploads PNG screenshot to `qa-screenshots` bucket and inserts bug report
  /// into `public.qa_feedback` (plus caches locally for instant portal access).
  static Future<QaFeedbackReport> submitBugReport({
    required String testerHandle,
    required String bugType,
    required String testerNote,
    required String activeRoute,
    Uint8List? screenshotBytes,
    BuildContext? context,
  }) async {
    final reportId = const Uuid().v4();
    final normalizedHandle = testerHandle.trim().isEmpty
        ? '@s26_alpha_tester'
        : (testerHandle.trim().startsWith('@')
            ? testerHandle.trim()
            : '@${testerHandle.trim()}');

    final deviceInfo = await collectDeviceInfo(context);
    final localStateDump = await buildLocalStateDump(
      testerNote: testerNote,
      activeRoute: activeRoute,
    );

    String? screenshotUrl;
    final client = supabaseOrNull;

    if (screenshotBytes != null && screenshotBytes.isNotEmpty) {
      if (client != null) {
        try {
          final cleanHandle =
              normalizedHandle.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
          final objectPath =
              '$cleanHandle/${DateTime.now().millisecondsSinceEpoch}_$reportId.png';
          await client.storage.from(storageBucket).uploadBinary(
                objectPath,
                screenshotBytes,
                fileOptions: const FileOptions(
                  contentType: 'image/png',
                  cacheControl: '3600',
                  upsert: true,
                ),
              );
          screenshotUrl =
              client.storage.from(storageBucket).getPublicUrl(objectPath);
        } catch (_) {}
      }

      // If offline or bucket not yet provisioned, store a compact data URL fallback
      screenshotUrl ??=
          'data:image/png;base64,${base64Encode(screenshotBytes)}';
    }

    final report = QaFeedbackReport(
      id: reportId,
      testerHandle: normalizedHandle,
      appVersion: appVersionString,
      bugType: bugType,
      screenshotUrl: screenshotUrl,
      deviceInfo: deviceInfo,
      localStateDump: localStateDump,
      createdAt: DateTime.now().toUtc(),
    );

    if (client != null) {
      try {
        await client.from(tableName).insert(report.toJson());
      } catch (_) {}
    }

    await _saveReportToLocalCache(report);
    return report;
  }

  /// Fixture #18 — 1-Tap Audience Test Screening Pulse (`[🔥 Instant Classic]`, `[😂 Great Curveball]`, `[⏱️ Pacing Off]`).
  Future<QaFeedbackReport> submitScenePulseRating({
    required String sceneId,
    required String sceneTitle,
    String gameMode = 'Tri-Modal Audition',
    required String pulseRating,
    double? compositeScore,
    BuildContext? context,
  }) async {
    final handle =
        AuthService.instance.currentProfile?.username ?? 's26_alpha_tester';
    final deviceInfo = await collectDeviceInfo(context);
    final localStateDump = await buildLocalStateDump(
      testerNote:
          '[SCENE_PULSE] scene_id=$sceneId | title="$sceneTitle" | game_mode=$gameMode | rating=$pulseRating | score=${compositeScore?.toStringAsFixed(1) ?? "N/A"}',
      activeRoute: '/match-finalization',
    );
    localStateDump['scene_id'] = sceneId;
    localStateDump['scene_title'] = sceneTitle;
    localStateDump['game_mode'] = gameMode;
    localStateDump['audience_pulse_rating'] = pulseRating;
    if (compositeScore != null) {
      localStateDump['composite_score'] = compositeScore;
    }

    final report = QaFeedbackReport(
      id: const Uuid().v4(),
      testerHandle: handle.startsWith('@') ? handle : '@$handle',
      appVersion: appVersionString,
      bugType: 'Scene Pulse: $pulseRating',
      screenshotUrl: null,
      deviceInfo: deviceInfo,
      localStateDump: localStateDump,
      createdAt: DateTime.now().toUtc(),
    );

    final client = supabaseOrNull;
    if (client != null) {
      try {
        await client.from(tableName).insert(report.toJson());
      } catch (_) {}
    }
    await _saveReportToLocalCache(report);
    return report;
  }

  static Future<void> _saveReportToLocalCache(QaFeedbackReport report) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await loadLocalCachedReports();
      final updated = <QaFeedbackReport>[report, ...existing].take(30).toList();
      await prefs.setString(
        localCachePrefsKey,
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  static Future<List<QaFeedbackReport>> loadLocalCachedReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(localCachePrefsKey);
      if (raw != null && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map((m) => QaFeedbackReport.fromJson(Map<String, dynamic>.from(m)))
              .toList();
        }
      }
    } catch (_) {}
    return <QaFeedbackReport>[];
  }
}

/// Surgical Shake-to-Report & Floating Bug Overlay (`lib/qa/qa_overlay.dart`).
/// Wrap inside `MaterialApp.builder` so it instruments every screen without
/// modifying any existing screen layouts.
class QaBugReporterOverlay extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;

  const QaBugReporterOverlay({
    super.key,
    required this.child,
    this.navigatorKey,
  });

  @override
  State<QaBugReporterOverlay> createState() => _QaBugReporterOverlayState();
}

class _QaBugReporterOverlayState extends State<QaBugReporterOverlay> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  StreamSubscription<UserAccelerometerEvent>? _userAccelSub;
  DateTime _lastShakeTriggeredAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool _isTester = true;
  bool _isSheetOpen = false;
  bool _isCapturingScreenshot = false;
  double _fabRightOffset = 12.0;
  double _fabBottomOffset = 92.0;

  @override
  void initState() {
    super.initState();
    _initTesterStatusAndShakeSensor();
  }

  Future<void> _initTesterStatusAndShakeSensor() async {
    final enabled = await QaTelemetryRepository.isTesterAccountEnabled();
    if (!mounted) return;
    setState(() {
      _isTester = enabled;
    });

    if (!enabled) return;

    try {
      _userAccelSub = userAccelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        (UserAccelerometerEvent event) {
          final magnitude = math.sqrt(
            (event.x * event.x) + (event.y * event.y) + (event.z * event.z),
          );
          // Trigger Shake-to-Report when linear acceleration exceeds ~15.5 m/s²
          if (magnitude > 15.5) {
            final now = DateTime.now();
            if (now.difference(_lastShakeTriggeredAt) >
                const Duration(milliseconds: 2500)) {
              _lastShakeTriggeredAt = now;
              _triggerBugReportCapture(triggerSource: 'SHAKE_SENSOR');
            }
          }
        },
        onError: (_) {
          // Silently ignore on devices/browsers without accelerometer access
        },
        cancelOnError: false,
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _userAccelSub?.cancel();
    super.dispose();
  }

  Future<Uint8List?> _captureActiveUiScreenshot() async {
    try {
      final boundaryContext = _repaintBoundaryKey.currentContext;
      if (boundaryContext == null) return null;
      final renderObject = boundaryContext.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) return null;

      final image = await renderObject.toImage(pixelRatio: 1.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _triggerBugReportCapture({
    String triggerSource = 'FLOATING_BUG_BUTTON',
  }) async {
    if (_isSheetOpen || _isCapturingScreenshot || !_isTester) return;
    _isCapturingScreenshot = true;
    HapticFeedback.heavyImpact();

    final screenshotBytes = await _captureActiveUiScreenshot();
    final activeRoute = QaRouteObserver.instance.currentRouteName;
    final statePreview = await QaTelemetryRepository.buildLocalStateDump(
      testerNote: '',
      activeRoute: activeRoute,
    );
    _isCapturingScreenshot = false;

    final navContext = widget.navigatorKey?.currentState?.overlay?.context ??
        widget.navigatorKey?.currentContext ??
        (mounted ? context : null);
    if (navContext == null ||
        !mounted ||
        Navigator.maybeOf(navContext) == null) {
      return;
    }

    _isSheetOpen = true;
    try {
      await showModalBottomSheet<void>(
        context: navContext,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetCtx) {
          return _QaBugReportBottomSheet(
            screenshotBytes: screenshotBytes,
            activeRoute: activeRoute,
            triggerSource: triggerSource,
            initialStateDump: statePreview,
            onOpenWebPortal: () {
              Navigator.of(sheetCtx).pop();
              widget.navigatorKey?.currentState?.push(
                MaterialPageRoute<void>(
                  settings: const RouteSettings(name: '/qa-dashboard'),
                  builder: (_) => const QaWebPortalDashboardScreen(),
                ),
              );
            },
          );
        },
      );
    } catch (_) {
      // Prevent unhandled exception if Navigator/Overlay is unavailable
    } finally {
      _isSheetOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hideForBroadcast =
        GameSettingsModal.latestConfig.cleanBroadcastScreenShareMode;
    final screenSize = MediaQuery.sizeOf(context);
    final maxRight =
        (screenSize.width - 110.0).clamp(8.0, 2000.0).toDouble();
    final maxBottom =
        (screenSize.height - 80.0).clamp(16.0, 2000.0).toDouble();
    final clampedRight = _fabRightOffset.clamp(8.0, maxRight).toDouble();
    final clampedBottom = _fabBottomOffset.clamp(16.0, maxBottom).toDouble();

    return RepaintBoundary(
      key: _repaintBoundaryKey,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (_isTester && !hideForBroadcast)
            Positioned(
              right: clampedRight,
              bottom: clampedBottom,
              child: SafeArea(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (DragUpdateDetails details) {
                    setState(() {
                      _fabRightOffset = (_fabRightOffset - details.delta.dx)
                          .clamp(8.0, maxRight)
                          .toDouble();
                      _fabBottomOffset = (_fabBottomOffset - details.delta.dy)
                          .clamp(16.0, maxBottom)
                          .toDouble();
                    });
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => _triggerBugReportCapture(
                        triggerSource: 'FLOATING_QA_FAB',
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xEE140C1C),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFFFFD700),
                            width: 2.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xCC05070B),
                              offset: Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bug_report_rounded,
                              size: 16,
                              color: Color(0xFFFFD700),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'QA BUG',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: Color(0xFFF5DEB3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QaBugReportBottomSheet extends StatefulWidget {
  final Uint8List? screenshotBytes;
  final String activeRoute;
  final String triggerSource;
  final Map<String, dynamic> initialStateDump;
  final VoidCallback onOpenWebPortal;

  const _QaBugReportBottomSheet({
    required this.screenshotBytes,
    required this.activeRoute,
    required this.triggerSource,
    required this.initialStateDump,
    required this.onOpenWebPortal,
  });

  @override
  State<_QaBugReportBottomSheet> createState() =>
      _QaBugReportBottomSheetState();
}

class _QaBugReportBottomSheetState extends State<_QaBugReportBottomSheet> {
  static const List<String> _bugTypes = <String>[
    'UI',
    'Audio',
    'AI Score',
    'Crash',
  ];

  String _selectedBugType = 'UI';
  late final TextEditingController _handleCtrl;
  final TextEditingController _noteCtrl = TextEditingController();
  bool _isSubmitting = false;
  bool _submittedSuccess = false;

  @override
  void initState() {
    super.initState();
    final currentUsername =
        AuthService.instance.currentProfile?.username ?? 's26_alpha_tester';
    _handleCtrl = TextEditingController(
      text: currentUsername.startsWith('@')
          ? currentUsername
          : '@$currentUsername',
    );
  }

  @override
  void dispose() {
    _handleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    await QaTelemetryRepository.submitBugReport(
      testerHandle: _handleCtrl.text,
      bugType: _selectedBugType,
      testerNote:
          '[${widget.triggerSource}] ${_noteCtrl.text.trim().isEmpty ? "Reported on ${widget.activeRoute}" : _noteCtrl.text.trim()}',
      activeRoute: widget.activeRoute,
      screenshotBytes: widget.screenshotBytes,
      context: context,
    );

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _submittedSuccess = true;
    });
    HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefsMap = widget.initialStateDump['shared_preferences_dump']
            as Map<String, dynamic>? ??
        <String, dynamic>{};

    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0E131F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF05070B),
            offset: Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(
                    Icons.vibration_rounded,
                    color: Color(0xFFF5DEB3),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'S.O.A. ALPHA · SHAKE-TO-REPORT QA',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                      Text(
                        'Route: ${widget.activeRoute} · ${prefsMap.length} SharedPrefs keys captured',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10.5,
                          color: Color(0xFF0CB6D4),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: widget.onOpenWebPortal,
                  icon: const Icon(
                    Icons.dashboard_customize_rounded,
                    size: 15,
                    color: Color(0xFFFFD700),
                  ),
                  label: const Text(
                    'QA Portal',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (widget.screenshotBytes != null) ...[
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF07090E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    AspectRatio(
                      aspectRatio: 9 / 16,
                      child: Image.memory(
                        widget.screenshotBytes!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'UI REPAINTBOUNDARY SNAPSHOT READY',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Payload size: ${(widget.screenshotBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB PNG\nTarget Bucket: qa-screenshots\nTable: public.qa_feedback',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                height: 1.4,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            const Text(
              '1. SELECT ISSUE CATEGORY',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFFF5DEB3),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _bugTypes.map((type) {
                final selected = _selectedBugType == type;
                return ChoiceChip(
                  label: Text(
                    type,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: selected
                          ? const Color(0xFF07090E)
                          : const Color(0xFFF5DEB3),
                    ),
                  ),
                  selected: selected,
                  selectedColor: const Color(0xFFFFD700),
                  backgroundColor: const Color(0xFF161E2E),
                  onSelected: (_) {
                    setState(() {
                      _selectedBugType = type;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _handleCtrl,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.5,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                labelText: 'Tester Handle',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              style: const TextStyle(fontSize: 13, color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'What broke or felt unbalanced?',
                hintText:
                    'e.g., AI score gave 74 on a loud take, or button clipped on S26 Ultra...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitReport,
                icon: Icon(
                  _submittedSuccess
                      ? Icons.check_circle_rounded
                      : Icons.cloud_upload_rounded,
                ),
                label: Text(
                  _submittedSuccess
                      ? 'TELEMETRY UPLOADED TO QA_FEEDBACK!'
                      : (_isSubmitting
                          ? 'UPLOADING SCREENSHOT & STATE DUMP...'
                          : 'SUBMIT S.O.A. BUG REPORT'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
