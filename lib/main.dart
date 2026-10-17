import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lobby.dart';

/// Application Configuration Constants
/// Configured via --dart-define during cloud CI/CD or runtime environment injection.
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project-id.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-supabase-anon-key',
  );
  static const String liveKitUrl = String.fromEnvironment(
    'LIVEKIT_URL',
    defaultValue: 'wss://act-like-it-sfu.livekit.cloud',
  );
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for consistent mobile stage framing on Galaxy S26 Ultra
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase (PostgreSQL, Realtime Channels, Edge Storage)
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    realtimeClientOptions: const RealtimeClientOptions(
      eventsPerSecond: 10,
    ),
  );

  runApp(const ActLikeItApp());
}

/// Global convenience accessor for the Supabase client instance.
final SupabaseClient supabase = Supabase.instance.client;

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
          primary: Color(0xFFE11D48), // Stage Crimson
          secondary: Color(0xFFF59E0B), // Academy Gold
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
        cardTheme: CardTheme(
          color: const Color(0xFF121722),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF1E293B), width: 1),
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

/// Foundational Shell Screen connected to Part 2 Matchmaking (lib/lobby.dart).
class SoundstageShellScreen extends StatefulWidget {
  const SoundstageShellScreen({super.key});

  @override
  State<SoundstageShellScreen> createState() => _SoundstageShellScreenState();
}

class _SoundstageShellScreenState extends State<SoundstageShellScreen> {
  String _selectedCategoryGroup = 'Eras (1970–1999)';
  bool _lateNightUnlocked = false;

  static const List<Map<String, String>> _coreCategories = [
    {
      'group': 'Eras (1970–1999)',
      'subtitle': 'New Hollywood & Blockbuster Golden Age',
      'table': 'scenes_era_1970_1999',
    },
    {
      'group': 'Eras (2000–2026)',
      'subtitle': 'Modern Prestige Cinema & Streaming Defining Moments',
      'table': 'scenes_era_2000_2026',
    },
    {
      'group': 'Awards Vault',
      'subtitle': 'Best Actor · Best Actress · Best Villain · Emmy Vault',
      'table': 'scenes_awards_vault',
    },
    {
      'group': 'Specialty',
      'subtitle': 'Cult Classics & Unforgettable Monologues',
      'table': 'scenes_cult_classics',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Act Like It'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'SFU 2–8 Players · Tri-Modal Judging',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueGrey.shade300,
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
            'Enter a 6-digit lobby code or host a remote 2–8 player LiveKit SFU room. Perform iconic cinema prompts live while Gemini Multimodal AI and peers score your emotional cadence.',
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
                        builder: (_) => const LobbyMatchmakingScreen(
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
                        builder: (_) => const LobbyMatchmakingScreen(
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
            '2. Peer Judging · Looped video replay via Supabase Edge Storage\n'
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
          'Supabase Scene Vaults',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF8FAFC),
          ),
        ),
        const SizedBox(height: 12),
        ..._coreCategories.map((cat) {
          final isSelected = _selectedCategoryGroup == cat['group'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                setState(() {
                  _selectedCategoryGroup = cat['group']!;
                });
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
                            cat['group']!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF8FAFC),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cat['subtitle']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      cat['table']!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Color(0xFFF59E0B),
                      ),
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
                  'Hidden, age-gated Supabase table configured in Part 5.',
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
            },
          ),
        ],
      ),
    );
  }
}
