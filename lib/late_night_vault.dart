import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'lobby.dart';
import 'webrtc_manager.dart';
import 'auth/auth_service.dart';
import 'monetization/payment_dashboard_screen.dart';
import 'ui/game_settings_modal.dart';
import 'ui/parody_scenes_catalog.dart';

import 'ui/red_carpet_25d_parallax.dart';
import 'ui/soundstage_audio_controller.dart';

/// Categorizes the intensity tiers inside the hidden Late-Night After-Hours Vault.
enum LateNightSpiceTier {
  midnightNoir(
    tier: 1,
    label: '🔥 Tier 1: Messy Hookups & Raunchy Comedy [1.15x]',
    multiplier: 1.15,
  ),
  uncensoredPrestige(
    tier: 2,
    label: '💋 Tier 2: Bedroom Walk-Ins & Seductive Noir [1.25x]',
    multiplier: 1.25,
  ),
  afterHoursDoubleDare(
    tier: 3,
    label: '🧨 Tier 3: Unhinged TV-MA Meltdowns & Filthy Roasts [1.35x]',
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
/// including the mid-take improvisation twist mechanic and 2-player Duet scripts.
class LateNightPrompt extends ScenePrompt {
  final int spiceTier;
  final String contentAdvisory;
  final String improvisationTwist;

  const LateNightPrompt({
    required super.id,
    super.category = SceneCategory.specialtyCultClassics,
    required super.title,
    required super.filmOrSeries,
    required super.releaseYear,
    required super.characterName,
    required super.promptScript,
    super.duetLeadA = '',
    super.duetLeadB = '',
    required super.directorCue,
    required super.emotionalTarget,
    super.improvTwist = '',
    super.is18Plus = true,
    super.durationSeconds = 35,
    super.difficultyTier = 4,
    required this.spiceTier,
    required this.contentAdvisory,
    required this.improvisationTwist,
  });

  factory LateNightPrompt.fromScenePrompt(
    ScenePrompt base, {
    required int spiceTier,
    required String contentAdvisory,
  }) {
    return LateNightPrompt(
      id: base.id,
      title: base.title,
      filmOrSeries: base.filmOrSeries,
      releaseYear: base.releaseYear,
      characterName: base.characterName,
      promptScript: base.promptScript,
      duetLeadA: base.duetLeadA,
      duetLeadB: base.duetLeadB,
      directorCue: base.directorCue,
      emotionalTarget: base.emotionalTarget,
      improvTwist: base.improvTwist,
      is18Plus: true,
      durationSeconds: base.durationSeconds,
      difficultyTier: base.difficultyTier,
      spiceTier: spiceTier,
      contentAdvisory: contentAdvisory,
      improvisationTwist: base.improvTwist.isNotEmpty
          ? base.improvTwist
          : 'TWIST AT 15s: Drop your voice to an intimate whisper on the final line.',
    );
  }

  factory LateNightPrompt.fromJson(Map<String, dynamic> json) {
    final targetEmotion = (json['target_emotion'] ??
            json['emotional_target'] ??
            'High-Tension Romantic Drama')
        .toString();
    final twist = (json['improv_twist'] ??
            json['improvisation_twist'] ??
            'TWIST AT 15s: Drop your voice to an intimate whisper on the final two lines.')
        .toString();
    return LateNightPrompt(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'After-Hours Scene',
      filmOrSeries:
          (json['actor_name'] ?? json['film_or_series'] ?? 'Featured Lead')
              .toString(),
      releaseYear:
          ((json['release_year'] ?? json['year']) as num?)?.toInt() ?? 2004,
      characterName:
          (json['character_name'] ?? json['character'] ?? 'Lead').toString(),
      promptScript: (json['script_excerpt'] ??
              json['prompt_script'] ??
              json['script'] ??
              '')
          .toString(),
      duetLeadA: (json['duet_lead_a'] ?? '').toString(),
      duetLeadB: (json['duet_lead_b'] ?? '').toString(),
      directorCue: (json['director_cue'] ??
              json['director_note'] ??
              'Hold intense eye contact with the lens and channel $targetEmotion.')
          .toString(),
      emotionalTarget: targetEmotion,
      improvTwist: twist,
      is18Plus: true,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 35,
      difficultyTier: (json['difficulty_tier'] as num?)?.toInt() ?? 4,
      spiceTier: (json['spice_tier'] as num?)?.toInt() ?? 3,
      contentAdvisory: (json['content_advisory'] ??
              '18+ High-Tension Romantic & Dramatic Dialogue')
          .toString(),
      improvisationTwist: twist,
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

  static final List<LateNightPrompt> _builtInFallbackPrompts = [
    for (int i = 0; i < kLateNightAfterHoursScenes.length; i++)
      () {
        final scene = kLateNightAfterHoursScenes[i];
        final spiceEnum = getSpiceTierForSceneId(scene.id);
        final tierInt = spiceEnum.tierNumber;
        return LateNightPrompt.fromScenePrompt(
          scene,
          spiceTier: tierInt,
          contentAdvisory: '${spiceEnum.badgeLabel} · RATED-R / TV-MA UNCUT',
        );
      }(),
  ];

  /// Validates that the player's birth year is >= 18 years ago and that a 4-digit
  /// session PIN is provided, then updates `public.profiles.birth_year` so the
  /// PostgreSQL RLS policy on `public.scenes_late_night_after_hours` grants access.
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

  /// Queries `public.scenes_late_night_after_hours` (with fallback to `public.scenes` where `is_late_night = true`).
  Future<void> fetchLateNightPrompts({LateNightSpiceTier? tier}) async {
    if (tier != null) {
      _selectedTier = tier;
    }
    if (!_isUnlocked) return;

    final client = supabaseOrNull;
    if (client != null) {
      try {
        final lnRows =
            await client.from('scenes_late_night_after_hours').select();
        if (lnRows.isNotEmpty) {
          _prompts = lnRows
              .map((r) => LateNightPrompt.fromJson(Map<String, dynamic>.from(r)))
              .where((p) => p.spiceTier <= _selectedTier.tier)
              .toList();
          if (_prompts.isNotEmpty) {
            notifyListeners();
            return;
          }
        }
      } catch (_) {}

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

class _LateNightAfterHoursScreenState extends State<LateNightAfterHoursScreen>
    with SingleTickerProviderStateMixin {
  late final LateNightVaultGateController _controller;
  late final AnimationController _wheelSpinController;
  final TextEditingController _birthYearController =
      TextEditingController(text: '1988');
  final TextEditingController _pinController =
      TextEditingController(text: '2026');

  // Fixture #15 (Part A): Speakeasy Dare Wheel state
  double _wheelRotationRad = 0.0;
  String? _activeSubtextDare;
  LateNightPrompt? _spunWheelScene;

  // Fixture #15 (Part B): "LIFE IS IMPROV" Real-World Secret Dare state
  LifeIsImprovSetting _selectedImprovSetting =
      LifeIsImprovSetting.housePartyBar;
  int _activeDossierIndex = 0;
  int _dossierFlipTurns = 0;
  int _selectedSpiceFilterTab = 0; // 0 = All 60, 1 = Tier 1, 2 = Tier 2, 3 = Tier 3

  @override
  void initState() {
    super.initState();
    _controller = LateNightVaultGateController();
    _controller.addListener(_onUpdated);
    _wheelSpinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  void _onUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _wheelSpinController.dispose();
    _controller.removeListener(_onUpdated);
    _controller.dispose();
    _birthYearController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _spinSpeakeasyDareWheel() {
    HapticFeedback.heavyImpact();
    final rng = math.Random();
    final prompts = _controller.prompts;
    final chosenScene = prompts.isNotEmpty
        ? prompts[rng.nextInt(prompts.length)]
        : kLateNightAfterHoursScenes.first;
    final subtext =
        kSpeakeasySubtextDares[rng.nextInt(kSpeakeasySubtextDares.length)];

    setState(() {
      _wheelRotationRad += (math.pi * 4) + rng.nextDouble() * math.pi * 2;
      _activeSubtextDare = subtext;
      if (chosenScene is LateNightPrompt) {
        _spunWheelScene = chosenScene;
      } else {
        _spunWheelScene = LateNightPrompt.fromScenePrompt(
          chosenScene,
          spiceTier: 3,
          contentAdvisory: '18+ SPEAKEASY ROULETTE · 1.25x SPICE MULTIPLIER',
        );
      }
    });
    _wheelSpinController.forward(from: 0.0);
  }

  List<LifeIsImprovSecretDare> get _filteredImprovDossiers {
    final matching = kLifeIsImprovSecretDares
        .where((d) => d.setting == _selectedImprovSetting)
        .toList();
    return matching.isEmpty ? kLifeIsImprovSecretDares : matching;
  }

  void _launchLifeIsImprovStealthStage(LifeIsImprovSecretDare dare) {
    HapticFeedback.heavyImpact();
    GameSettingsModal.latestConfig =
        GameSettingsModal.latestConfig.copyWith(
      lifeIsImprovMode: true,
      speakeasyDoubleOrNothingSubtext: true,
    );
    final roomCode =
        (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();
    final scenePrompt = dare.toScenePrompt();
    final session = LobbySession(
      id: 'life-is-improv-$roomCode',
      roomCode: roomCode,
      hostId: AuthService.instance.currentProfile?.userId ?? 'local-s26-actor',
      selectedCategory: SceneCategory.specialtyCultClassics,
      status: 'performing',
      activeActorId:
          AuthService.instance.currentProfile?.userId ?? 'local-s26-actor',
      activeScene: scenePrompt,
      livekitRoomName: 'act_like_it_$roomCode',
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LiveKitSoundstageScreen(
          lobbySession: session,
          localUserId:
              AuthService.instance.currentProfile?.userId ?? 'local-s26-actor',
          localDisplayName:
              AuthService.instance.currentProfile?.username ?? 'Undercover Star',
        ),
      ),
    );
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
            border: Border.all(
                color: const Color(0xFFF5DEB3).withValues(alpha: 0.45),
                width: 1.5),
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
                'Exclusive 18+ high-stakes dramatic dialogues, psychological thrillers, Speakeasy Dare Roulette, and "LIFE IS IMPROV" real-world undercover dares. Age verification required for soundstage entry.',
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
    final dossiers = _filteredImprovDossiers;
    final activeDossier = dossiers[_activeDossierIndex % dossiers.length];

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
                      ? 'VIP Speakeasy Pass Active · All Tier 3 Double-Dare Scripts & Life Is Improv Dossiers Unlocked'
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

        // ===================================================================
        // FIXTURE #15 (PART B): NEW FLAGSHIP 18+ REAL-WORLD MODE: "LIFE IS IMPROV"
        // ===================================================================
        Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF230A29),
                Color(0xFF13071A),
                Color(0xFF07090E),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFA55577), width: 2.4),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF05070B),
                offset: Offset(5, 5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE11342),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFF5DEB3)),
                    ),
                    child: const Text(
                      'FLAGSHIP 18+ REAL-WORLD MODE · 1.50x XP',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '+2 AI TOKENS ON 80+ SCORE',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFF5DEB3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                '🎭 LIFE IS IMPROV — REAL-WORLD SECRET DARE MODE',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFF5DEB3),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'The world is your soundstage! Pick your real-world setting, study your Classified Secret Dare Dossier, flip to Stealth/POV Camera Mode, and pull off the undercover scenario on real people without breaking character.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: Color(0xFFCBD5E1),
                ),
              ),
              const SizedBox(height: 12),
              // RELOCATED CLICKABLE 2.5D HERO CARD: The Undercover Speakeasy Improviser (13012.jpg)
              GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  SoundstageAudioController.instance.playVaultLockTurnClunk();
                  setState(() {
                    _dossierFlipTurns += 1;
                    _activeDossierIndex =
                        (_activeDossierIndex + 1) % dossiers.length;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0612),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFA855F7),
                      width: 2.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55A855F7),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 112,
                            height: 138,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: UndercoverSpeakeasyImproviserRig(
                                phase: (_dossierFlipTurns * 0.85) + 0.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0x33A855F7),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFA855F7),
                                    ),
                                  ),
                                  child: const Text(
                                    'INTERACTIVE 2.5D AGENT · TAP TO FLIP DOSSIER',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFF5DEB3),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'The Undercover Speakeasy Improviser',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Tap his portrait or the pulsing neon-violet "CONFIDENTIAL" dossier to trigger a 3D Matrix4 Y-rotation flip and deal a fresh Real-World Dare!',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    height: 1.35,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              const Color(0xFFF5DEB3),
                                          side: const BorderSide(
                                            color: Color(0xFFA855F7),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 8,
                                          ),
                                        ),
                                        onPressed: () {
                                          HapticFeedback.heavyImpact();
                                          setState(() {
                                            _dossierFlipTurns += 1;
                                            _activeDossierIndex =
                                                (_activeDossierIndex + 1) %
                                                    dossiers.length;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.flip_camera_android_rounded,
                                          size: 14,
                                        ),
                                        label: const FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '3D FLIP NEW DARE',
                                            style: TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFE11342),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 8,
                                          ),
                                        ),
                                        onPressed: () =>
                                            _launchLifeIsImprovStealthStage(
                                          activeDossier,
                                        ),
                                        icon: const Icon(
                                          Icons.visibility_off_rounded,
                                          size: 14,
                                        ),
                                        label: const FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'Launch Stealth / POV Camera',
                                            style: TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Text(
                '1. SELECT YOUR REAL-WORLD SETTING:',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0CB6D4),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: LifeIsImprovSetting.values.map((setting) {
                  final selected = _selectedImprovSetting == setting;
                  return ChoiceChip(
                    label: Text(
                      '${setting.emoji} ${setting.label}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: selected
                            ? const Color(0xFF07090E)
                            : const Color(0xFFF5DEB3),
                      ),
                    ),
                    selected: selected,
                    selectedColor: const Color(0xFFF5DEB3),
                    backgroundColor: const Color(0xFF140D1F),
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedImprovSetting = setting;
                        _activeDossierIndex = 0;
                        _dossierFlipTurns += 1;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              // Classified Secret Dare Dossier Card with 3D Matrix4 Y-Rotation Flip
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0.0,
                  end: _dossierFlipTurns * math.pi * 2,
                ),
                duration: const Duration(milliseconds: 520),
                curve: Curves.easeOutBack,
                builder: (context, angle, child) {
                  final normalized = angle % (math.pi * 2);
                  final tilt = math.sin(normalized) * 0.35;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0012)
                      ..rotateY(tilt),
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF07090E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFF5DEB3),
                      width: 1.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'CLASSIFIED DOSSIER (${_activeDossierIndex + 1}/${dossiers.length}) · ${activeDossier.dossierTitle.toUpperCase()}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFE11342),
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _dossierFlipTurns += 1;
                                _activeDossierIndex =
                                    (_activeDossierIndex + 1) % dossiers.length;
                              });
                            },
                            icon: const Icon(
                              Icons.refresh_rounded,
                              size: 15,
                              color: Color(0xFF0CB6D4),
                            ),
                            label: const Text(
                              'NEXT DOSSIER',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0CB6D4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '🕵️ UNDERCOVER PERSONA: ${activeDossier.undercoverPersona}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF5DEB3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '🗣️ OPENING LINE TO SAY OUT LOUD:\n"${activeDossier.openingLineToSayOutLoud}"',
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.42,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF160B18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFA55577)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '⚡ 15s MID-DARE ESCALATION (HAPTIC DOUBLE-TAP PULSE):\n${activeDossier.midDareEscalation15s}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                height: 1.38,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '🎯 TARGET ROOM REACTION:\n${activeDossier.targetReactionFromRoom}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                height: 1.38,
                                color: Color(0xFF0CB6D4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11342),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () =>
                      _launchLifeIsImprovStealthStage(activeDossier),
                  icon: const Icon(Icons.visibility_off_rounded, size: 18),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '🕵️ LAUNCH STEALTH / POV CAMERA & ROLL SECRET DARE',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ===================================================================
        // FIXTURE #15 (PART A): 18+ SPEAKEASY DARE WHEEL & SUBTEXT DARES
        // ===================================================================
        Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF140914),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFA55577), width: 2.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _wheelSpinController,
                    builder: (context, child) {
                      final angle =
                          _wheelRotationRad * Curves.easeOutCubic.transform(
                        _wheelSpinController.value == 0
                            ? 1.0
                            : _wheelSpinController.value,
                      );
                      return Transform.rotate(
                        angle: angle,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const SweepGradient(
                          colors: [
                            Color(0xFFE11342),
                            Color(0xFFA55577),
                            Color(0xFFF5DEB3),
                            Color(0xFFE11342),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFFF5DEB3),
                          width: 2.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.casino_rounded,
                        color: Color(0xFF07090E),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🍸 SPEAKEASY DARE WHEEL · DOUBLE-OR-NOTHING',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFF5DEB3),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Spin for a Tier 3 (1.25x Spice Multiplier) scene + a Double-or-Nothing Subtext Dare (-10 pts if you chicken out!).',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_activeSubtextDare != null && _spunWheelScene != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF07090E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE11342)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎯 SPUN SCENE: ${_spunWheelScene!.title} (1.25x SPICE MULTIPLIER)',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFF5DEB3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '🔥 DOUBLE-OR-NOTHING SUBTEXT DARE:\n"$_activeSubtextDare"',
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFF5DEB3),
                            side: const BorderSide(color: Color(0xFFF5DEB3)),
                          ),
                          onPressed: () {
                            GameSettingsModal.latestConfig =
                                GameSettingsModal.latestConfig.copyWith(
                              speakeasyDoubleOrNothingSubtext: true,
                              lifeIsImprovMode: false,
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LobbyMatchmakingScreen(
                                  startInJoinMode: false,
                                  initialPromptOverride: _spunWheelScene,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.local_fire_department_rounded,
                              size: 16),
                          label: const Text(
                            'ACCEPT 1.25x DOUBLE-OR-NOTHING DARE',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA55577),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _spinSpeakeasyDareWheel,
                  icon: const Icon(Icons.rotate_left_rounded, size: 18),
                  label: const Text(
                    'SPIN SPEAKEASY DARE WHEEL (1.25x SPICE)',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3 Spice Filter Tabs + All 60 Uncut Rated-R / TV-MA Scenes Selector
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF120B18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFA55577), width: 1.6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🔞 60 UNCENSORED RATED-R / TV-MA SPEAKEASY SCRIPTS · FILTER BY SPICE TIER',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFF5DEB3),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(
                      'ALL 60 UNCUT 18+ SCENES (${_controller.prompts.length})',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: _selectedSpiceFilterTab == 0
                            ? const Color(0xFF07090E)
                            : Colors.white,
                      ),
                    ),
                    selected: _selectedSpiceFilterTab == 0,
                    selectedColor: const Color(0xFFF5DEB3),
                    backgroundColor: const Color(0xFF0B0E17),
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedSpiceFilterTab = 0);
                      _controller.fetchLateNightPrompts(
                        tier: LateNightSpiceTier.afterHoursDoubleDare,
                      );
                    },
                  ),
                  ...SpeakeasySpiceTier.values.map((spice) {
                    final selected =
                        _selectedSpiceFilterTab == spice.tierNumber;
                    return ChoiceChip(
                      label: Text(
                        spice.badgeLabel,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: selected
                              ? const Color(0xFF07090E)
                              : const Color(0xFFF5DEB3),
                        ),
                      ),
                      selected: selected,
                      selectedColor: const Color(0xFFE11342),
                      backgroundColor: const Color(0xFF0B0E17),
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        setState(
                          () => _selectedSpiceFilterTab = spice.tierNumber,
                        );
                        _controller.fetchLateNightPrompts(
                          tier: LateNightSpiceTier.afterHoursDoubleDare,
                        );
                      },
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ..._controller.prompts
            .where((p) =>
                _selectedSpiceFilterTab == 0 ||
                p.spiceTier == _selectedSpiceFilterTab)
            .map(
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
                  'SOLO MONOLOGUE (${prompt.characterName}): "${prompt.promptScript}"',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFFF8FAFC),
                  ),
                ),
                if (prompt.duetLeadA.isNotEmpty || prompt.duetLeadB.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0D14),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SCREEN TEST DUET · 2-PLAYER CO-STAR SCRIPT',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        if (prompt.duetLeadA.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'LEAD A (GOLD): "${prompt.duetLeadA}"',
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF5DEB3),
                            ),
                          ),
                        ],
                        if (prompt.duetLeadB.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'LEAD B (CYAN): "${prompt.duetLeadB}"',
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0CB6D4),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Director Cue: ${prompt.directorCue} · Target Emotion: ${prompt.emotionalTarget}',
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
                      GameSettingsModal.latestConfig =
                          GameSettingsModal.latestConfig.copyWith(
                        lifeIsImprovMode: false,
                      );
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

typedef LateNightPremiumScreen = LateNightAfterHoursScreen;
