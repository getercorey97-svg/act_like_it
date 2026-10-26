import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lobby.dart';
import 'late_night_vault.dart';
import 'dashboard_marquee.dart';
import 'ui/intro_cinematic.dart';
import 'offline_manager.dart';
import 'qa/qa_overlay.dart';
import 'qa/qa_web_portal.dart';
import 'auth/nda_tester_gate.dart';

/// Captures startup, plugin, and widget build exceptions in Release APKs so the
/// app never fails silently with a blank white screen on Android devices.
class SafeBootDiagnostics {
  static Object? bootException;
  static StackTrace? bootStackTrace;
  static final List<String> bootLogs = <String>[];
  static final ValueNotifier<FlutterErrorDetails?> latestWidgetError =
      ValueNotifier<FlutterErrorDetails?>(null);

  static void log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    bootLogs.add('[$timestamp] $message');
  }

  static void recordException(
    Object error,
    StackTrace? stack, {
    String phase = 'BOOT',
  }) {
    bootException ??= error;
    bootStackTrace ??= stack;
    log('[$phase ERROR] $error');
    final details = FlutterErrorDetails(
      exception: error,
      stack: stack,
      library: 'act_like_it/$phase',
      context: ErrorDescription('Captured during $phase'),
    );

    // Prevent "setState() or markNeedsBuild() called during build" when
    // FlutterError.onError fires synchronously inside a widget build/layout pass.
    try {
      final schedulerPhase = SchedulerBinding.instance.schedulerPhase;
      if (schedulerPhase == SchedulerPhase.persistentCallbacks ||
          schedulerPhase == SchedulerPhase.midFrameMicrotasks) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          latestWidgetError.value = details;
        });
      } else {
        latestWidgetError.value = details;
      }
    } catch (_) {
      latestWidgetError.value = details;
    }
  }

  static void clearErrors() {
    bootException = null;
    bootStackTrace = null;
    latestWidgetError.value = null;
  }
}

/// Application Configuration Constants & Runtime Overrides.
/// Supports both CI `--dart-define` secrets AND in-app configuration on the
/// Samsung Galaxy S26 Ultra so the APK works out-of-the-box immediately.
class AppConfig {
  static const String _envSupabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String _envSupabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
  static const String _envLiveKitUrl = String.fromEnvironment(
    'LIVEKIT_URL',
    defaultValue: '',
  );
  static const String _envGeminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static String _runtimeSupabaseUrl = '';
  static String _runtimeSupabaseAnonKey = '';
  static String _runtimeLiveKitUrl = '';
  static String _runtimeGeminiApiKey = '';
  static bool _supabaseInitialized = false;

  static String _sanitizeDefine(String raw) {
    final trimmed = raw.trim();
    if (trimmed.length >= 2 &&
        ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
            (trimmed.startsWith("'") && trimmed.endsWith("'")))) {
      return trimmed.substring(1, trimmed.length - 1).trim();
    }
    return trimmed;
  }

  static String get supabaseUrl => _runtimeSupabaseUrl.isNotEmpty
      ? _runtimeSupabaseUrl
      : _sanitizeDefine(_envSupabaseUrl);

  static String get supabaseAnonKey => _runtimeSupabaseAnonKey.isNotEmpty
      ? _runtimeSupabaseAnonKey
      : _sanitizeDefine(_envSupabaseAnonKey);

  static String get liveKitUrl => _runtimeLiveKitUrl.isNotEmpty
      ? _runtimeLiveKitUrl
      : _sanitizeDefine(_envLiveKitUrl);

  static String get geminiApiKey => _runtimeGeminiApiKey.isNotEmpty
      ? _runtimeGeminiApiKey
      : _sanitizeDefine(_envGeminiApiKey);

  static bool get hasCloudSupabase =>
      supabaseUrl.startsWith('https://') &&
      !supabaseUrl.contains('your-project-id') &&
      supabaseAnonKey.isNotEmpty &&
      _supabaseInitialized;

  static bool get hasLiveKitCloud =>
      liveKitUrl.startsWith('wss://') &&
      !liveKitUrl.contains('act-like-it-sfu.livekit.cloud');

  static Future<void> loadSavedConfig() async {
    SafeBootDiagnostics.log('Loading SharedPreferences runtime config...');
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 4),
      );
    } catch (e) {
      SafeBootDiagnostics.log(
        'Native SharedPreferences channel fallback (in-memory mode): $e',
      );
      try {
        SharedPreferences.setMockInitialValues({});
        prefs = await SharedPreferences.getInstance();
      } catch (_) {}
    }

    if (prefs != null) {
      try {
        _runtimeSupabaseUrl =
            (prefs.getString('cfg_supabase_url') ?? '').trim();
        _runtimeSupabaseAnonKey =
            (prefs.getString('cfg_supabase_anon_key') ?? '').trim();
        _runtimeLiveKitUrl = (prefs.getString('cfg_livekit_url') ?? '').trim();
        _runtimeGeminiApiKey =
            (prefs.getString('cfg_gemini_api_key') ?? '').trim();
        SafeBootDiagnostics.log('SharedPreferences loaded successfully.');
      } catch (e) {
        SafeBootDiagnostics.log('SharedPreferences read notice: $e');
      }
    }

    final parsedSupabaseUri = Uri.tryParse(supabaseUrl);
    final hasValidSupabaseUri = parsedSupabaseUri != null &&
        parsedSupabaseUri.scheme == 'https' &&
        parsedSupabaseUri.host.isNotEmpty &&
        !parsedSupabaseUri.host.contains('your-project-id');

    if (!_supabaseInitialized &&
        hasValidSupabaseUri &&
        supabaseAnonKey.isNotEmpty) {
      try {
        SafeBootDiagnostics.log('Initializing Supabase client...');
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
          realtimeClientOptions: const RealtimeClientOptions(
            eventsPerSecond: 10,
          ),
        ).timeout(const Duration(seconds: 5));
        _supabaseInitialized = true;
        SafeBootDiagnostics.log('Supabase initialized successfully.');
      } catch (e, st) {
        _supabaseInitialized = false;
        SafeBootDiagnostics.log('Supabase init warning (falling back): $e');
        SafeBootDiagnostics.recordException(
          e,
          st,
          phase: 'SUPABASE_INIT',
        );
      }
    } else {
      SafeBootDiagnostics.log(
        'No valid SUPABASE_URL configured; booting in standalone/offline-ready mode.',
      );
    }

    // Warm up OfflineManager local scene cache & connectivity listener with timeout guard
    try {
      await OfflineManager.instance
          .ensureInitialized()
          .timeout(const Duration(seconds: 4));
      SafeBootDiagnostics.log(
        'OfflineManager initialized (${OfflineManager.instance.cachedSceneCount} cached scenes).',
      );
    } catch (e) {
      SafeBootDiagnostics.log('OfflineManager warm-up notice: $e');
    }
  }

  static Future<void> saveRuntimeConfig({
    required String geminiKey,
    required String supabaseProjectUrl,
    required String supabaseKey,
    required String liveKitServerUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _runtimeGeminiApiKey = geminiKey.trim();
    _runtimeSupabaseUrl = supabaseProjectUrl.trim();
    _runtimeSupabaseAnonKey = supabaseKey.trim();
    _runtimeLiveKitUrl = liveKitServerUrl.trim();

    await prefs.setString('cfg_gemini_api_key', _runtimeGeminiApiKey);
    await prefs.setString('cfg_supabase_url', _runtimeSupabaseUrl);
    await prefs.setString('cfg_supabase_anon_key', _runtimeSupabaseAnonKey);
    await prefs.setString('cfg_livekit_url', _runtimeLiveKitUrl);

    if (!_supabaseInitialized &&
        supabaseUrl.startsWith('https://') &&
        supabaseAnonKey.isNotEmpty) {
      try {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
          realtimeClientOptions: const RealtimeClientOptions(
            eventsPerSecond: 10,
          ),
        );
        _supabaseInitialized = true;
      } catch (e, st) {
        SafeBootDiagnostics.recordException(
          e,
          st,
          phase: 'SUPABASE_RUNTIME_SAVE',
        );
      }
    }
  }
}

Future<void> main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      SafeBootDiagnostics.log('WidgetsFlutterBinding initialized.');

      // 1. Catch all Flutter framework build/layout/paint errors
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        SafeBootDiagnostics.recordException(
          details.exception,
          details.stack,
          phase: 'FLUTTER_FRAMEWORK',
        );
      };

      // 2. Catch uncaught asynchronous platform/isolate errors
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        SafeBootDiagnostics.recordException(
          error,
          stack,
          phase: 'PLATFORM_DISPATCHER',
        );
        return true; // Prevent native Android crash / white screen
      };

      // 3. Replace Release Mode's blank white/grey ErrorWidget with a visual Safe Boot UI
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return Material(
          color: const Color(0xFF0A0D14),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1016),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE11D48),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFE11D48),
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'SAFE BOOT · WIDGET RENDER EXCEPTION',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFE11D48),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SelectableText(
                      details.exceptionAsString(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    if (details.stack != null) ...[
                      const SizedBox(height: 8),
                      SelectableText(
                        details.stack.toString(),
                        maxLines: 12,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      };

      // 4. Safely configure portrait orientation without blocking boot on failure
      try {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]).timeout(const Duration(seconds: 2));
      } catch (e, st) {
        SafeBootDiagnostics.recordException(
          e,
          st,
          phase: 'SYSTEM_CHROME_ORIENTATION',
        );
      }

      // 5. Safely load saved config & Supabase with timeouts
      try {
        await AppConfig.loadSavedConfig();
      } catch (e, st) {
        SafeBootDiagnostics.recordException(
          e,
          st,
          phase: 'APP_CONFIG_LOAD',
        );
      }

      // 6. Mount the root application wrapped in the SafeBootErrorBoundary
      runApp(const SafeBootErrorBoundary(child: ActLikeItApp()));
    },
    (Object error, StackTrace stackTrace) {
      SafeBootDiagnostics.recordException(
        error,
        stackTrace,
        phase: 'RUN_ZONED_GUARDED',
      );
      runApp(
        SafeBootEmergencyApp(
          error: error,
          stackTrace: stackTrace,
        ),
      );
    },
  );
}

/// Safe accessor for Supabase client when cloud mode is configured.
SupabaseClient? get supabaseOrNull {
  if (!AppConfig.hasCloudSupabase) return null;
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}

/// Top-level visual Safe Boot wrapper that surfaces any initialization or
/// runtime exceptions in an interactive diagnostic banner/modal rather than
/// allowing a blank white screen.
class SafeBootErrorBoundary extends StatefulWidget {
  final Widget child;

  const SafeBootErrorBoundary({
    super.key,
    required this.child,
  });

  @override
  State<SafeBootErrorBoundary> createState() => _SafeBootErrorBoundaryState();
}

class _SafeBootErrorBoundaryState extends State<SafeBootErrorBoundary> {
  bool _dismissedDiagnosticBanner = false;
  bool _useSafeModeFallbackShell = false;

  @override
  Widget build(BuildContext context) {
    if (_useSafeModeFallbackShell) {
      if (!OfficialClosedAlphaNdaGateWrapper.isSessionUnlockedSync()) {
        return const MaterialApp(
          title: 'Act Like It · Gate Locked',
          debugShowCheckedModeBanner: false,
          home: OfficialClosedAlphaNdaGateWrapper(
            child: SoundstageShellScreen(),
          ),
        );
      }
      return MaterialApp(
        title: 'Act Like It (Safe Mode)',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true),
        home: const SoundstageShellScreen(),
      );
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          ValueListenableBuilder<FlutterErrorDetails?>(
            valueListenable: SafeBootDiagnostics.latestWidgetError,
            builder: (context, errorDetails, _) {
              final hasError =
                  errorDetails != null || SafeBootDiagnostics.bootException != null;
              if (!hasError || _dismissedDiagnosticBanner) {
                return const SizedBox.shrink();
              }

              final errorText = errorDetails?.exceptionAsString() ??
                  SafeBootDiagnostics.bootException.toString();
              final stackText = (errorDetails?.stack ??
                      SafeBootDiagnostics.bootStackTrace)
                  ?.toString() ??
                  'No stack trace available.';

              return SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Material(
                      color: const Color(0xF5140C14),
                      elevation: 16,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 360),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE11D48),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.bug_report_rounded,
                                  color: Color(0xFFE11D48),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'SAFE BOOT DIAGNOSTIC INTERCEPTOR',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFF59E0B),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _dismissedDiagnosticBanner = true;
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: Colors.white70,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Flexible(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectableText(
                                      errorText,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    SelectableText(
                                      stackText,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 10,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: '$errorText\n\n$stackText',
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'COPY ERROR',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      SafeBootDiagnostics.clearErrors();
                                      if (!OfficialClosedAlphaNdaGateWrapper.isSessionUnlockedSync()) {
                                        setState(() {
                                          _dismissedDiagnosticBanner = true;
                                          _useSafeModeFallbackShell = false;
                                        });
                                      } else {
                                        setState(() {
                                          _useSafeModeFallbackShell = true;
                                        });
                                      }
                                    },
                                    child: Text(
                                      OfficialClosedAlphaNdaGateWrapper.isSessionUnlockedSync()
                                          ? 'BOOT SAFE SHELL'
                                          : 'RELOAD SECURITY GATE',
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 10,
                                      ),
                                    ),
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
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Emergency standalone application mounted if an unhandled fatal exception
/// occurs inside `runZonedGuarded` before `ActLikeItApp` can mount.
class SafeBootEmergencyApp extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;

  const SafeBootEmergencyApp({
    super.key,
    required this.error,
    required this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Act Like It · Safe Boot Recovery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: Builder(
        builder: (ctx) {
          return Scaffold(
            backgroundColor: const Color(0xFF0A0D14),
            appBar: AppBar(
              backgroundColor: const Color(0xFF140C14),
              title: const Text(
                'SAFE BOOT · INITIALIZATION ERROR',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE11D48),
                ),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1016),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE11D48)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EXCEPTION MESSAGE:',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            error.toString(),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121722),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            'BOOT LOGS:\n${SafeBootDiagnostics.bootLogs.join('\n')}\n\nSTACK TRACE:\n$stackTrace',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: const Color(0xFF05060A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        SafeBootDiagnostics.clearErrors();
                        final isUnlocked =
                            OfficialClosedAlphaNdaGateWrapper.isSessionUnlockedSync();
                        Navigator.of(ctx).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => isUnlocked
                                ? const LivingMarqueeDashboardScreen()
                                : const OfficialClosedAlphaNdaGateWrapper(
                                    child: LivingMarqueeDashboardScreen(),
                                  ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.security_rounded),
                      label: Text(
                        OfficialClosedAlphaNdaGateWrapper.isSessionUnlockedSync()
                            ? 'CONTINUE TO LIVING MARQUEE DASHBOARD'
                            : 'RETURN TO MANDATORY SECURITY GATE',
                        style: const TextStyle(
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
        },
      ),
    );
  }
}

class ActLikeItApp extends StatelessWidget {
  const ActLikeItApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Act Like It',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      navigatorObservers: <NavigatorObserver>[QaRouteObserver.instance],
      onGenerateRoute: (RouteSettings settings) {
        final uri = Uri.tryParse(settings.name ?? '');
        if (uri != null && uri.queryParameters.containsKey('room')) {
          final room = uri.queryParameters['room'];
          if (room != null && room.trim().isNotEmpty) {
            OfficialClosedAlphaNdaGateWrapper.pendingDeepLinkRoomCode = room.trim();
          }
        }
        if (!OfficialClosedAlphaNdaGateWrapper.isSessionUnlockedSync()) {
          return MaterialPageRoute<void>(
            settings: const RouteSettings(name: '/'),
            builder: (_) => const CellShadedIntroCinematicScreen(),
          );
        }
        if (settings.name == '/qa-dashboard') {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const QaWebPortalDashboardScreen(),
          );
        }
        return null;
      },
      routes: <String, WidgetBuilder>{
        '/qa-dashboard': (_) => const QaWebPortalDashboardScreen(),
      },
      builder: (BuildContext context, Widget? child) {
        return QaBugReporterOverlay(
          navigatorKey: navigatorKey,
          child: OfficialClosedAlphaNdaGateWrapper(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07090E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE11342),
          secondary: Color(0xFFF5DEB3),
          tertiary: Color(0xFF0CB6D4),
          surface: Color(0xFF07090E),
          onPrimary: Color(0xFFF5DEB3),
          onSecondary: Color(0xFF07090E),
          onSurface: Color(0xFFF5DEB3),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF07090E),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Color(0xFFF5DEB3),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE11342),
            foregroundColor: const Color(0xFFF5DEB3),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFF05070B), width: 2.0),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      home: const CellShadedIntroCinematicScreen(),
    );
  }
}

class SoundstageShellScreen extends StatefulWidget {
  const SoundstageShellScreen({super.key});

  @override
  State<SoundstageShellScreen> createState() => _SoundstageShellScreenState();
}

class _SoundstageShellScreenState extends State<SoundstageShellScreen> {
  SceneCategory _selectedCategory = SceneCategory.era1970To1999;
  bool _lateNightUnlocked = false;

  static const List<Map<String, dynamic>> _coreCategories = [
    {
      'category': SceneCategory.era1970To1999,
      'group': 'Eras (1970–1999)',
      'subtitle': 'New Hollywood & Blockbuster Golden Age',
      'table': 'scenes_era_1970_1999',
    },
    {
      'category': SceneCategory.era2000To2026,
      'group': 'Eras (2000–2026)',
      'subtitle': 'Modern Prestige Cinema & Streaming Defining Moments',
      'table': 'scenes_era_2000_2026',
    },
    {
      'category': SceneCategory.awardsBestActor,
      'group': 'Awards: Best Actor',
      'subtitle': 'Academy & Guild Leading Performances',
      'table': 'scenes_awards_vault',
    },
    {
      'category': SceneCategory.awardsBestActress,
      'group': 'Awards: Best Actress',
      'subtitle': 'Iconic Dramatic & Psychological Showcase',
      'table': 'scenes_awards_vault',
    },
    {
      'category': SceneCategory.awardsBestVillain,
      'group': 'Awards: Best Villain',
      'subtitle': 'Unblinking Dread & Scene-Stealing Antagonists',
      'table': 'scenes_awards_vault',
    },
    {
      'category': SceneCategory.awardsEmmyVault,
      'group': 'Awards: Emmy Vault',
      'subtitle': 'Prestige Television Monologues',
      'table': 'scenes_awards_vault',
    },
    {
      'category': SceneCategory.specialtyCultClassics,
      'group': 'Specialty: Cult Classics',
      'subtitle': 'Midnight Cinema & Unforgettable Quotables',
      'table': 'scenes_cult_classics',
    },
  ];

  void _openCloudConfigSheet() {
    final geminiCtrl = TextEditingController(text: AppConfig.geminiApiKey);
    final supaUrlCtrl = TextEditingController(text: AppConfig.supabaseUrl);
    final supaKeyCtrl = TextEditingController(text: AppConfig.supabaseAnonKey);
    final liveKitCtrl = TextEditingController(text: AppConfig.liveKitUrl);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cloud API & Standalone Hybrid Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'The app runs immediately on your S26 Ultra using hardware camera recording and built-in scene vaults. Optionally enter your cloud keys below to enable live Gemini API & Supabase sync.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: geminiCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Gemini API Key (AI Telemetrics)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: supaUrlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Supabase Project URL (https://...)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: supaKeyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Supabase Anon Public Key',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: liveKitCtrl,
                  decoration: const InputDecoration(
                    labelText: 'LiveKit WebSocket URL (wss://...)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await AppConfig.saveRuntimeConfig(
                        geminiKey: geminiCtrl.text,
                        supabaseProjectUrl: supaUrlCtrl.text,
                        supabaseKey: supaKeyCtrl.text,
                        liveKitServerUrl: liveKitCtrl.text,
                      );
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                      }
                      setState(() {});
                    },
                    child: const Text('Save Runtime Configuration'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!OfficialClosedAlphaNdaGateWrapper.isSessionUnlockedSync()) {
      return const OfficialClosedAlphaNdaGateWrapper(child: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Act Like It'),
        actions: [
          IconButton(
            onPressed: _openCloudConfigSheet,
            tooltip: 'Cloud & API Key Settings',
            icon: const Icon(Icons.tune, color: Color(0xFFF59E0B)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildStageHeader(),
            const SizedBox(height: 24),
            _buildTriModalOverview(),
            const SizedBox(height: 24),
            _buildCategoryPreviewSection(),
            const SizedBox(height: 24),
            _buildLateNightGateCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStageHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF121722),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Soundstage & Telemetrics Engine',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Host a 6-digit lobby or launch an instant soundstage session on your Galaxy S26 Ultra. Perform iconic cinema prompts with live camera capture, looped replay, and Gemini AI Telemetrics.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.blueGrey.shade200,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LobbyMatchmakingScreen(
                          initialCategory: _selectedCategory,
                          startInJoinMode: false,
                        ),
                      ),
                    );
                  },
                  child: const Text('Create 6-Digit Lobby'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LobbyMatchmakingScreen(
                          initialCategory: _selectedCategory,
                          startInJoinMode: true,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF8FAFC),
                    side: const BorderSide(color: Color(0xFF334155)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Join Room Code'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTriModalOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121722),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tri-Modal Judging Architecture',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF8FAFC),
            ),
          ),
          SizedBox(height: 12),
          Text(
            '1. AI Telemetrics · Gemini API multimodal video/audio frame analysis\n'
            '2. Peer Judging · Looped video replay (Device & Supabase Storage)\n'
            '3. Social Judging · External share engagement metric calculation',
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Scene Vault Category (Tap to Launch)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF8FAFC),
          ),
        ),
        const SizedBox(height: 12),
        ..._coreCategories.map((cat) {
          final categoryEnum = cat['category'] as SceneCategory;
          final isSelected = _selectedCategory == categoryEnum;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                setState(() {
                  _selectedCategory = categoryEnum;
                });
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LobbyMatchmakingScreen(
                      initialCategory: categoryEnum,
                      startInJoinMode: false,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1E293B)
                      : const Color(0xFF121722),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFE11D48)
                        : const Color(0xFF1E293B),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat['group'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF8FAFC),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cat['subtitle'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFFF59E0B),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLateNightGateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121722),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Late-Night After-Hours Vault (18+)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF8FAFC),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Age-gated 18+ vault with 15s Mid-Take Improvisation Twists.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _lateNightUnlocked,
            activeColor: const Color(0xFFE11D48),
            onChanged: (val) {
              setState(() {
                _lateNightUnlocked = val;
              });
              if (val) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LateNightAfterHoursScreen(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
