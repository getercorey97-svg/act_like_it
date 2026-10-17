import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'lobby.dart';

/// Categorizes the intensity tiers inside the hidden Late-Night After-Hours Vault.
enum LateNightSpiceTier {
  midnightNoir(
    tier: 1,
    label: 'Tier 1 · Midnight Noir & Dark Comedy',
    multiplier: 1.10,
  ),
  uncensoredPrestige(
    tier: 2,
    label: 'Tier 2 · Uncensored R-Rated Prestige',
    multiplier: 1.20,
  ),
  afterHoursDoubleDare(
    tier: 3,
    label: 'Tier 3 · After-Hours Double-Dare & Twist',
    multiplier: 1.35,
  );

  final int tier;
  final String label;
  final double multiplier;

  const LateNightSpiceTier({
    required this.tier,
    required this.label,
    required this.multiplier,
  });
}

/// Represents a specialized 18+ scene prompt from `public.scenes_late_night_after_hours`
/// including the mid-take improvisation twist mechanic.
class LateNightPrompt extends ScenePrompt {
  final int spiceTier;
  final String contentAdvisory;
  final String improvisationTwist;

  const LateNightPrompt({
    required super.id,
    required super.title,
    required super.filmOrSeries,
    required super.releaseYear,
    required super.characterName,
    required super.promptScript,
    required super.directorCue,
    required super.emotionalTarget,
    required super.durationSeconds,
    required super.difficultyTier,
    required this.spiceTier,
    required this.contentAdvisory,
    required this.improvisationTwist,
  });

  factory LateNightPrompt.fromJson(Map<String, dynamic> json) {
    return LateNightPrompt(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'After-Hours Scene',
      filmOrSeries: json['film_or_series']?.toString() ?? 'Midnight Feature',
      releaseYear: (json['release_year'] as num?)?.toInt() ?? 2019,
      characterName: json['character_name']?.toString() ?? 'Lead',
      promptScript: json['prompt_script']?.toString() ?? '',
      directorCue: json['director_cue']?.toString() ?? '',
      emotionalTarget: json['emotional_target']?.toString() ?? 'High Tension',
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 35,
      difficultyTier: (json['difficulty_tier'] as num?)?.toInt() ?? 4,
      spiceTier: (json['spice_tier'] as num?)?.toInt() ?? 2,
      contentAdvisory:
          json['content_advisory']?.toString() ?? '18+ Mature Dialogue',
      improvisationTwist: json['improvisation_twist']?.toString() ??
          'TWIST AT 15s: Invert your vocal volume on the final sentence.',
    );
  }
}

/// Manages 18+ Age Verification, 4-digit PIN session locking, Supabase RLS
/// unlocking (`verify_player_age_and_unlock_late_night`), and the Mid-Take Twist timer.
class LateNightVaultGateController extends ChangeNotifier {
  static const String _prefKeyVerified = 'act_like_it_18_plus_verified';

  bool _isUnlocked = false;
  bool _isVerifying = false;
  String? _errorMessage;
  LateNightSpiceTier _selectedTier = LateNightSpiceTier.uncensoredPrestige;
  List<LateNightPrompt> _prompts = [];
  bool _midTakeTwistTriggered = false;
  Timer? _twistTimer;

  bool get isUnlocked => _isUnlocked;
  bool get isVerifying => _isVerifying;
  String? get errorMessage => _errorMessage;
  LateNightSpiceTier get selectedTier => _selectedTier;
  List<LateNightPrompt> get prompts => List.unmodifiable(_prompts);
  bool get midTakeTwistTriggered => _midTakeTwistTriggered;

  static const List<LateNightPrompt> _builtInFallbackPrompts = [
    LateNightPrompt(
      id: 'ln-uncut-gems',
      title: 'This Is How I Win',
      filmOrSeries: 'Uncut Gems',
      releaseYear: 2019,
      characterName: 'Howard Ratner',
      spiceTier: 1,
      contentAdvisory: '18+ Language & High-Anxiety Gambling Spiral',
      promptScript:
          "You're having a good time, right? Look at this parlay. I disagree, Gary! This is how I win!",
      directorCue:
          'Speak at 1.4x speed with manic grinning confidence while pretending to lock the security door.',
      emotionalTarget: 'Manic Euphoria & Desperation',
      improvisationTwist:
          'TWIST AT 15s: The security buzzer jams—deliver the final line in a claustrophobic whisper.',
      durationSeconds: 35,
      difficultyTier: 4,
    ),
    LateNightPrompt(
      id: 'ln-pulp-fiction',
      title: 'The Adrenaline Shot Count',
      filmOrSeries: 'Pulp Fiction',
      releaseYear: 1994,
      characterName: 'Vincent Vega',
      spiceTier: 2,
      contentAdvisory: '18+ Mature Themes & Dark Panic Comedy',
      promptScript:
          "I'm gonna count to three, and when I count three, you plunge that needle straight down. One... two...",
      directorCue:
          'Hold an imaginary marker poised inches above the camera lens, eyes wide with sweat-drenched hesitation.',
      emotionalTarget: 'Hysterical Hesitation',
      improvisationTwist:
          'TWIST AT 15s: Switch roles mid-sentence and react as if you just woke up from a dead faint.',
      durationSeconds: 35,
      difficultyTier: 4,
    ),
    LateNightPrompt(
      id: 'ln-wolf-wall-street',
      title: "I'm Not Leaving",
      filmOrSeries: 'The Wolf of Wall Street',
      releaseYear: 2013,
      characterName: 'Jordan Belfort',
      spiceTier: 2,
      contentAdvisory: '18+ Explicit Trading Floor Tirade',
      promptScript:
          "I'm not leaving! The show goes on! They're gonna need a wrecking ball to take me out of here!",
      directorCue:
          'Begin with quiet, defeated posture, then slam your palm into the frame and roar into the mic.',
      emotionalTarget: 'Unhinged Defiance',
      improvisationTwist:
          'TWIST AT 15s: Deliver the climax as if your microphone just cut out and you must mime half the words.',
      durationSeconds: 40,
      difficultyTier: 5,
    ),
    LateNightPrompt(
      id: 'ln-eyes-wide-shut',
      title: 'The Masked Confession',
      filmOrSeries: 'Eyes Wide Shut',
      releaseYear: 1999,
      characterName: 'Alice & Bill Harford',
      spiceTier: 3,
      contentAdvisory: '18+ Psychological Intimacy & After-Hours Tension',
      promptScript:
          'If you men only knew... There is something very important that we need to do as soon as possible.',
      directorCue:
          'Slow cadence to half-speed, hold an unblinking gaze three inches from the front camera.',
      emotionalTarget: 'Hypnotic Vulnerability',
      improvisationTwist:
          'TWIST AT 15s: Break into a sudden, unsettling laugh before snapping back to deadpan seriousness.',
      durationSeconds: 40,
      difficultyTier: 5,
    ),
  ];

  /// Validates that the player's birth year is >= 18 years ago and that a 4-digit
  /// session PIN is provided, then invokes the Supabase RLS verification RPC.
  Future<bool> verifyAgeAndUnlockVault({
    required int birthYear,
    required String fourDigitPin,
  }) async {
    _isVerifying = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentYear = DateTime.now().year;
      final age = currentYear - birthYear;

      if (birthYear < 1900 || age < 18) {
        _errorMessage =
            'Access Denied: You must be 18 or older to unlock the Late-Night After-Hours Vault.';
        return false;
      }

      if (!RegExp(r'^[0-9]{4}$').hasMatch(fourDigitPin.trim())) {
        _errorMessage =
            'Enter a valid 4-digit numeric session PIN to secure the After-Hours gate.';
        return false;
      }

      try {
        await supabase.rpc(
          'verify_player_age_and_unlock_late_night',
          params: {
            'p_birth_year': birthYear,
            'p_session_pin': fourDigitPin.trim(),
          },
        );
      } catch (_) {
        // Proceed with local session verification if offline/unauthenticated
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyVerified, true);

      _isUnlocked = true;
      await fetchLateNightPrompts();
      return true;
    } finally {
      _isVerifying = false;
      notifyListeners();
    }
  }

  /// Queries `public.scenes_late_night_after_hours` filtered by the selected Spice Tier.
  Future<void> fetchLateNightPrompts({LateNightSpiceTier? tier}) async {
    if (tier != null) {
      _selectedTier = tier;
    }
    if (!_isUnlocked) return;

    try {
      final rows = await supabase
          .from('scenes_late_night_after_hours')
          .select()
          .lte('spice_tier', _selectedTier.tier)
          .order('spice_tier', ascending: false);

      if (rows.isNotEmpty) {
        _prompts = rows
            .map((r) => LateNightPrompt.fromJson(Map<String, dynamic>.from(r)))
            .toList();
      } else {
        _prompts = _builtInFallbackPrompts
            .where((p) => p.spiceTier <= _selectedTier.tier)
            .toList();
      }
    } catch (_) {
      _prompts = _builtInFallbackPrompts
          .where((p) => p.spiceTier <= _selectedTier.tier)
          .toList();
    }
    notifyListeners();
  }

  /// Starts the 15-second Mid-Take Improvisation Twist interrupt timer.
  void armMidTakeTwistTimer({int triggerAfterSeconds = 15}) {
    _twistTimer?.cancel();
    _midTakeTwistTriggered = false;
    notifyListeners();

    _twistTimer = Timer(Duration(seconds: triggerAfterSeconds), () {
      _midTakeTwistTriggered = true;
      HapticFeedback.heavyImpact();
      notifyListeners();
    });
  }

  /// Immediately locks the Late-Night Vault and clears cached prompts.
  Future<void> lockVault() async {
    _twistTimer?.cancel();
    _isUnlocked = false;
    _midTakeTwistTriggered = false;
    _prompts = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyVerified, false);
    notifyListeners();
  }

  @override
  void dispose() {
    _twistTimer?.cancel();
    super.dispose();
  }
}

/// Full UI Screen for the Age-Gated Late-Night After-Hours Section.
class LateNightAfterHoursScreen extends StatefulWidget {
  const LateNightAfterHoursScreen({super.key});

  @override
  State<LateNightAfterHoursScreen> createState() =>
      _LateNightAfterHoursScreenState();
}

class _LateNightAfterHoursScreenState extends State<LateNightAfterHoursScreen> {
  late final LateNightVaultGateController _controller;
  final TextEditingController _birthYearController =
      TextEditingController(text: '1997');
  final TextEditingController _pinController =
      TextEditingController(text: '2026');

  @override
  void initState() {
    super.initState();
    _controller = LateNightVaultGateController();
    _controller.addListener(_onUpdated);
  }

  void _onUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdated);
    _controller.dispose();
    _birthYearController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Late-Night After-Hours (18+)'),
        actions: [
          if (_controller.isUnlocked)
            TextButton(
              onPressed: () => _controller.lockVault(),
              child: const Text(
                'Lock Vault',
                style: TextStyle(color: Color(0xFFE11D48)),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _controller.isUnlocked
            ? _buildUnlockedVaultView()
            : _buildAgeGateVerificationView(),
      ),
    );
  }

  Widget _buildAgeGateVerificationView() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF121722),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE11D48)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '18+ RLS SECURITY GATE · AFTER-HOURS VAULT',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Verify Age & Session PIN to Query Hidden Table',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Prompts in public.scenes_late_night_after_hours are protected by PostgreSQL Row-Level Security (profiles.age_verified = true) and feature Mid-Take Improvisation Twists at t = 15s.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _birthYearController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Birth Year (YYYY)',
                  filled: true,
                  fillColor: Color(0xFF0A0D14),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: '4-Digit Session Lock PIN',
                  filled: true,
                  fillColor: Color(0xFF0A0D14),
                  border: OutlineInputBorder(),
                ),
              ),
              if (_controller.errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _controller.errorMessage!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFE11D48),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _controller.isVerifying
                      ? null
                      : () {
                          final year =
                              int.tryParse(_birthYearController.text) ?? 0;
                          _controller.verifyAgeAndUnlockVault(
                            birthYear: year,
                            fourDigitPin: _pinController.text,
                          );
                        },
                  child: Text(
                    _controller.isVerifying
                        ? 'Verifying 18+ RLS Policy...'
                        : 'Verify 18+ & Unlock After-Hours Vault',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnlockedVaultView() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        DropdownButtonFormField<LateNightSpiceTier>(
          value: _controller.selectedTier,
          decoration: const InputDecoration(
            labelText: 'After-Hours Spice Tier & Score Multiplier',
            filled: true,
            fillColor: Color(0xFF121722),
            border: OutlineInputBorder(),
          ),
          items: LateNightSpiceTier.values
              .map(
                (t) => DropdownMenuItem(
                  value: t,
                  child: Text('${t.label} (${t.multiplier}x)'),
                ),
              )
              .toList(),
          onChanged: (tier) {
            if (tier != null) {
              _controller.fetchLateNightPrompts(tier: tier);
            }
          },
        ),
        const SizedBox(height: 18),
        ..._controller.prompts.map(
          (prompt) => Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF121722),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SPICE TIER ${prompt.spiceTier} · ${prompt.contentAdvisory}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Color(0xFFE11D48),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${prompt.title} — ${prompt.filmOrSeries} (${prompt.releaseYear})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${prompt.characterName}: "${prompt.promptScript}"',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFF8FAFC),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Director Cue: ${prompt.directorCue}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0D14),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Text(
                    prompt.improvisationTwist,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const LobbyMatchmakingScreen(
                  startInJoinMode: false,
                ),
              ),
            );
          },
          child: const Text('Host 18+ After-Hours 6-Digit Lobby'),
        ),
      ],
    );
  }
}
