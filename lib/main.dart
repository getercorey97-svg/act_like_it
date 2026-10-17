import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lobby.dart';
import 'late_night_vault.dart';

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

  static String get supabaseUrl =>
      _runtimeSupabaseUrl.isNotEmpty ? _runtimeSupabaseUrl : _envSupabaseUrl;

  static String get supabaseAnonKey => _runtimeSupabaseAnonKey.isNotEmpty
      ? _runtimeSupabaseAnonKey
      : _envSupabaseAnonKey;

  static String get liveKitUrl =>
      _runtimeLiveKitUrl.isNotEmpty ? _runtimeLiveKitUrl : _envLiveKitUrl;

  static String get geminiApiKey =>
      _runtimeGeminiApiKey.isNotEmpty ? _runtimeGeminiApiKey : _envGeminiApiKey;

  static bool get hasCloudSupabase =>
      supabaseUrl.startsWith('https://') &&
      !supabaseUrl.contains('your-project-id') &&
      supabaseAnonKey.isNotEmpty &&
      _supabaseInitialized;

  static bool get hasLiveKitCloud =>
      liveKitUrl.startsWith('wss://') &&
      !liveKitUrl.contains('act-like-it-sfu.livekit.cloud');

  static Future<void> loadSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    _runtimeSupabaseUrl = prefs.getString('cfg_supabase_url') ?? '';
    _runtimeSupabaseAnonKey = prefs.getString('cfg_supabase_anon_key') ?? '';
    _runtimeLiveKitUrl = prefs.getString('cfg_livekit_url') ?? '';
    _runtimeGeminiApiKey = prefs.getString('cfg_gemini_api_key') ?? '';

    if (supabaseUrl.startsWith('https://') && supabaseAnonKey.isNotEmpty) {
      try {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
          realtimeClientOptions: const RealtimeClientOptions(
            eventsPerSecond: 10,
          ),
        );
        _supabaseInitialized = true;
      } catch (_) {
        _supabaseInitialized = false;
      }
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
      } catch (_) {}
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await AppConfig.loadSavedConfig();

  runApp(const ActLikeItApp());
}

/// Safe accessor for Supabase client when cloud mode is configured.
SupabaseClient? get supabaseOrNull =>
    AppConfig.hasCloudSupabase ? Supabase.instance.client : null;

class ActLikeItApp extends StatelessWidget {
  const ActLikeItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Act Like It',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0D14),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE11D48),
          secondary: Color(0xFFF59E0B),
          surface: Color(0xFF121722),
          onPrimary: Colors.white,
          onSecondary: Color(0xFF0A0D14),
          onSurface: Color(0xFFF8FAFC),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0D14),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Color(0xFFF8FAFC),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE11D48),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const SoundstageShellScreen(),
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
