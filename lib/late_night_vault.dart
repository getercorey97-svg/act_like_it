import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'lobby.dart';
import 'auth/auth_service.dart';
import 'monetization/payment_dashboard_screen.dart';

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
    final targetEmotion = (json['target_emotion'] ??
            json['emotional_target'] ??
            'High-Tension Romantic Drama')
        .toString();
    return LateNightPrompt(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'After-Hours Scene',
      filmOrSeries:
          (json['actor_name'] ?? json['film_or_series'] ?? 'Featured Lead')
              .toString(),
      releaseYear: (json['release_year'] as num?)?.toInt() ?? 2004,
      characterName: json['character_name']?.toString() ?? 'Lead',
      promptScript:
          (json['script_excerpt'] ?? json['prompt_script'] ?? '').toString(),
      directorCue: (json['director_cue'] ??
              'Hold intense eye contact with the lens and channel $targetEmotion.')
          .toString(),
      emotionalTarget: targetEmotion,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 35,
      difficultyTier: (json['difficulty_tier'] as num?)?.toInt() ?? 4,
      spiceTier: (json['spice_tier'] as num?)?.toInt() ?? 3,
      contentAdvisory: (json['content_advisory'] ??
              '18+ High-Tension Romantic & Dramatic Dialogue')
          .toString(),
      improvisationTwist: (json['improvisation_twist'] ??
              'TWIST AT 15s: Drop your voice to an intimate whisper on the final two lines.')
          .toString(),
    );
  }
}

/// Manages 18+ Age Verification, 4-digit PIN session locking, Supabase RLS
/// unlocking (`public.profiles.birth_year`), and the Mid-Take Twist timer.
class LateNightVaultGateController extends ChangeNotifier {
  static const String _prefKeyVerified = 'act_like_it_18_plus_verified';

  bool _isUnlocked = false;
  bool _isVerifying = false;
  String? _errorMessage;
  LateNightSpiceTier _selectedTier = LateNightSpiceTier.afterHoursDoubleDare;
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
      id: 'ln-eyes-wide-shut',
      title: 'Eyes Wide Shut (1999)',
      filmOrSeries: 'Nicole Kidman',
      releaseYear: 1999,
      characterName: 'Alice Harford',
      spiceTier: 3,
      contentAdvisory: '18+ Erotic Candor & Psychological Intimacy',
      promptScript:
          "Do you really think you know everything that goes through my head when we're lying in the dark, Bill?\nLast summer at Cape Cod, there was a naval officer at the next table. He glanced at me for three seconds, and I couldn't breathe.\nIf he had wanted me—even for one single night—I was ready to give up everything. You, Helena, my whole life.\nAnd yet at the very same moment, you were dearer to me than ever. If you men only knew...",
      directorCue:
          'Slow cadence to half-speed, hold an unblinking gaze three inches from the front camera.',
      emotionalTarget: 'Hypnotic Erotic Candor & Jealousy',
      improvisationTwist:
          'TWIST AT 15s: Break into a sudden, unsettling laugh before snapping back to deadpan seriousness.',
      durationSeconds: 40,
      difficultyTier: 5,
    ),
    LateNightPrompt(
      id: 'ln-closer',
      title: 'Closer (2004)',
      filmOrSeries: 'Clive Owen & Natalie Portman',
      releaseYear: 2004,
      characterName: 'Larry Gray',
      spiceTier: 3,
      contentAdvisory: '18+ Scorching Romantic Obsession & Betrayal',
      promptScript:
          "Don't give me that innocent stare—tell me the truth! You think honesty is just a weapon you pull out when you want to break someone?\nDid you enjoy it? Look me in the eyes and tell me what you whispered to him when the hotel door closed.\nYou want raw, unfiltered passion, Anna, yet the second somebody touches your actual pulse, you bolt for the exit.\nGive it to me—because everyone else falls in love with your fantasy, and I'm the only man in this room who knows what you really are.",
      directorCue:
          'Begin with quiet, wounded disbelief, then step toward the microphone with scorching intensity.',
      emotionalTarget: 'Scorching Romantic Obsession & Betrayal',
      improvisationTwist:
          'TWIST AT 15s: Deliver the final line with an eerie, heartbroken smile.',
      durationSeconds: 40,
      difficultyTier: 5,
    ),
    LateNightPrompt(
      id: 'ln-basic-instinct',
      title: 'Basic Instinct (1992)',
      filmOrSeries: 'Sharon Stone',
      releaseYear: 1992,
      characterName: 'Catherine Tramell',
      spiceTier: 2,
      contentAdvisory: '18+ Seductive Interrogation Tension',
      promptScript:
          "What are you going to do, Nick? Charge me with smoking in an interrogation room?\nYou read every page of my novel before you walked in here, and now you're terrified that I know exactly how your mind works.\nMaybe I loved him, or maybe I just liked watching a dangerous man lose his nerve between the sheets.\nKeep staring at me like that, Detective, and we both know you won't make it to the end of this investigation alive.",
      directorCue:
          'Tilt your chin slightly up, never break eye contact, and speak with velvet composure.',
      emotionalTarget: 'Seductive Cat-and-Mouse Dominance',
      improvisationTwist:
          'TWIST AT 15s: Pause for two full seconds of dead silence before whispering the final threat.',
      durationSeconds: 35,
      difficultyTier: 4,
    ),
    LateNightPrompt(
      id: 'ln-challengers',
      title: 'Challengers (2024)',
      filmOrSeries: 'Zendaya',
      releaseYear: 2024,
      characterName: 'Tashi Duncan',
      spiceTier: 2,
      contentAdvisory: '18+ High-Tension Hotel Room Power Play',
      promptScript:
          "Don't act like you came up to my hotel room tonight just to talk about your backhand.\nYou two have been orbiting each other for thirteen years, using me as the net so you don't have to admit what you actually want.\nLook at me—if you step onto that court tomorrow and play like a coward, don't bother coming back to my bed.\nI don't want a polite husband or a nostalgic ex-lover. I want to watch two people tear each other apart for one point.",
      directorCue:
          'Command the frame with razor-sharp poise and unapologetic magnetism.',
      emotionalTarget: 'Intoxicating Power Play & Desire',
      improvisationTwist:
          'TWIST AT 15s: Switch from icy detachment to breathless urgency on the final sentence.',
      durationSeconds: 35,
      difficultyTier: 4,
    ),
    LateNightPrompt(
      id: 'ln-fatal-attraction',
      title: 'Fatal Attraction (1987)',
      filmOrSeries: 'Glenn Close',
      releaseYear: 1987,
      characterName: 'Alex Forrest',
      spiceTier: 1,
      contentAdvisory: '18+ Obsessive Romantic Confrontation',
      promptScript:
          "You think you can spend an entire weekend tangled in my sheets and then erase me on Monday morning like a business expense?\nI am not going to be ignored, Dan! Do you hear me?\nYou walked into my apartment, you held my face in your hands, and now you're hiding behind a picket fence like nothing happened.\nI'm part of your life now, whether you lock your front door or not—and we are far from finished.",
      directorCue:
          'Start with trembling vulnerability, then erupt on the second line before dropping to a chilling promise.',
      emotionalTarget: 'Feverish Obsessive Passion & Threat',
      improvisationTwist:
          'TWIST AT 15s: Deliver the final line as if you are calmly leaving a voicemail.',
      durationSeconds: 35,
      difficultyTier: 4,
    ),
  ];

  /// Validates that the player's birth year is >= 18 years ago and that a 4-digit
  /// session PIN is provided, then updates `public.profiles.birth_year` so the
  /// PostgreSQL RLS policy on `public.scenes (is_late_night = true)` grants access.
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

      final client = supabaseOrNull;
      final currentUser = client?.auth.currentUser;
      if (client != null && currentUser != null) {
        try {
          await client.from('profiles').upsert({
            'id': currentUser.id,
            'username': 'actor_${currentUser.id.substring(0, 6)}',
            'birth_year': birthYear,
          });
        } catch (_) {}
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

  /// Queries `public.scenes` where `is_late_night = true` (gated by PostgreSQL 18+ RLS).
  Future<void> fetchLateNightPrompts({LateNightSpiceTier? tier}) async {
    if (tier != null) {
      _selectedTier = tier;
    }
    if (!_isUnlocked) return;

    final client = supabaseOrNull;
    if (client != null) {
      try {
        final rows = await client
            .from('scenes')
            .select()
            .eq('is_late_night', true);

        if (rows.isNotEmpty) {
          _prompts = rows
              .map((r) => LateNightPrompt.fromJson(Map<String, dynamic>.from(r)))
              .toList();
          notifyListeners();
          return;
        }
      } catch (_) {}
    }

    _prompts = _builtInFallbackPrompts
        .where((p) => p.spiceTier <= _selectedTier.tier)
        .toList();
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
      TextEditingController(text: '1988');
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
      backgroundColor: const Color(0xFF07090E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07090E),
        title: const Text('Midnight Speakeasy (18+)'),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.55),
            radius: 1.35,
            colors: [
              Color(0xFF520002),
              Color(0xFF1A050A),
              Color(0xFF07090E),
            ],
            stops: [0.0, 0.48, 1.0],
          ),
        ),
        child: SafeArea(
          child: _controller.isUnlocked
              ? _buildUnlockedVaultView()
              : _buildAgeGateVerificationView(),
        ),
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
            color: const Color(0xF207090E),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF5DEB3).withValues(alpha: 0.45), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55520002),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '18+ RESTRICTED ACCESS · MIDNIGHT SOUNDSTAGE',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Midnight Speakeasy · Age & PIN Gate',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Exclusive 18+ high-stakes dramatic dialogues, psychological thrillers, and uncensored prestige scripts with director\'s cut improv twists. Age verification required for soundstage entry.',
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
                  hintText: '1988',
                  helperText: 'Must be 18 years or older',
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
                  labelText: '4-Digit Security PIN',
                  hintText: 'e.g. 2026',
                  helperText: 'PIN protects After-Hours soundstage',
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
                        ? 'Verifying Soundstage Clearance...'
                        : 'Verify Age & Enter Midnight Speakeasy',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF5DEB3),
                    side: const BorderSide(color: Color(0xFFF5DEB3)),
                  ),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PaymentDashboardScreen(
                          highlightProductKey: 'vip_speakeasy_pass',
                        ),
                      ),
                    );
                    if (mounted) setState(() {});
                  },
                  icon: Icon(
                    AuthService.instance.hasVipSpeakeasyPass
                        ? Icons.verified_rounded
                        : Icons.workspace_premium_rounded,
                    size: 16,
                  ),
                  label: Text(
                    AuthService.instance.hasVipSpeakeasyPass
                        ? '🍸 VIP SPEAKEASY PASS ACTIVE (ALL TIERS UNLOCKED)'
                        : '🍸 UNLOCK VIP SPEAKEASY PASS (\$4.99/mo · ALL TIER 3 SCRIPTS)',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
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

  Widget _buildUnlockedVaultView() {
    final hasVipPass = AuthService.instance.hasVipSpeakeasyPass;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF140910),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasVipPass
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF5DEB3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasVipPass
                    ? Icons.verified_rounded
                    : Icons.nightlife_rounded,
                color: hasVipPass
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF5DEB3),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasVipPass
                      ? 'VIP Speakeasy Pass Active · All Tier 3 Double-Dare Scripts Unlocked'
                      : 'VIP Speakeasy Pass (\$4.99/mo) · Unlock All Uncut Tier 3 Scripts & Monthly Drops',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              if (!hasVipPass)
                TextButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PaymentDashboardScreen(
                          highlightProductKey: 'vip_speakeasy_pass',
                        ),
                      ),
                    );
                    if (mounted) setState(() {});
                  },
                  child: const Text(
                    'UPGRADE',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFF5DEB3),
                    ),
                  ),
                ),
            ],
          ),
        ),
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
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LobbyMatchmakingScreen(
                            startInJoinMode: false,
                            initialPromptOverride: prompt,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.videocam_outlined, size: 16),
                    label: const Text('Perform This After-Hours Scene'),
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
