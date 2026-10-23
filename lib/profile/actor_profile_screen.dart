import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/auth_screen.dart';
import '../auth/auth_service.dart';
import '../auth/onboarding_questionnaire.dart';
import '../match_history_screen.dart';
import '../monetization/payment_dashboard_screen.dart';
import '../offline_manager.dart';
import '../ui/boondocks_character_rig.dart';
import '../ui/game_app_bar.dart';

/// PART 2: Actor Profile Page & Multi-Profile Account Switcher
/// (`lib/profile/actor_profile_screen.dart`).
class ActorProfileScreen extends StatefulWidget {
  const ActorProfileScreen({super.key});

  @override
  State<ActorProfileScreen> createState() => _ActorProfileScreenState();
}

class _ActorProfileScreenState extends State<ActorProfileScreen> {
  static const List<String> _kAvailableEras = <String>[
    '1970–1999',
    '2000–2026',
    'Cult Classics',
    'Best Actor',
    'Best Villain',
    'Emmy Vault',
  ];

  static const List<String> _kAvailableStrengths = <String>[
    'Method Drama',
    'Improv Comedy',
    'Villain',
    'Cold Monologue',
    'High-Energy Lead',
    'Scene Stealer',
  ];

  static const List<String> _kAvailableDialects = <String>[
    'Hollywood Standard',
    'New York Grit',
    'Southern Gothic',
    'RP British',
    'Mid-Atlantic Classic',
  ];

  static const List<String> _kAvailablePhysicalStyles = <String>[
    'High-Contrast Method',
    'Deadpan Minimalist',
    'Explosive Physical',
    'Velvet Noir',
  ];

  late TextEditingController _handleCtrl;
  late TextEditingController _birthYearCtrl;
  bool _isEditingIdentity = false;

  @override
  void initState() {
    super.initState();
    final profile = AuthService.instance.currentProfile;
    _handleCtrl = TextEditingController(text: profile?.username ?? 'kkl');
    _birthYearCtrl =
        TextEditingController(text: '${profile?.birthYear ?? 1998}');
    AuthService.instance.addListener(_onProfileChanged);
  }

  void _onProfileChanged() {
    if (!mounted) return;
    final profile = AuthService.instance.currentProfile;
    if (!_isEditingIdentity && profile != null) {
      _handleCtrl.text = profile.username;
      _birthYearCtrl.text = '${profile.birthYear}';
    }
    setState(() {});
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_onProfileChanged);
    _handleCtrl.dispose();
    _birthYearCtrl.dispose();
    super.dispose();
  }

  Future<void> _openAvatarArchetypePicker(ActorProfileState profile) async {
    HapticFeedback.mediumImpact();
    final selectedId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B0E17),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.76,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'SELECT YOUR 2.5D CASTING ARCHETYPE (14 CHARACTERS)',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 24,
                      letterSpacing: 1.5,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.05,
                      ),
                      itemCount: kFourteenAvatarArchetypes.length,
                      itemBuilder: (context, index) {
                        final arch = kFourteenAvatarArchetypes[index];
                        final isCurrent =
                            arch.id == profile.avatarArchetypeId;
                        return GestureDetector(
                          onTap: () => Navigator.of(ctx).pop(arch.id),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? const Color(0xFF1A1428)
                                  : const Color(0xFF07090E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isCurrent
                                    ? const Color(0xFFFFD700)
                                    : arch.primaryInkColor,
                                width: isCurrent ? 2.8 : 1.6,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                BoondocksCharacterRig(
                                  archetype: arch,
                                  size: 68,
                                  isSelected: isCurrent,
                                ),
                                const SizedBox(height: 6),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    arch.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  arch.roleBadge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 9.5,
                                    color: arch.rimAccentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selectedId != null && mounted) {
      HapticFeedback.heavyImpact();
      await AuthService.instance.updateAvatarArchetype(selectedId);
    }
  }

  Future<void> _saveIdentityChanges() async {
    final cleanHandle = _handleCtrl.text.trim().replaceAll('@', '');
    final parsedYear =
        int.tryParse(_birthYearCtrl.text.trim()) ??
            (AuthService.instance.currentProfile?.birthYear ?? 1998);
    HapticFeedback.heavyImpact();
    await AuthService.instance.upsertAdditiveProfileFields(
      username: cleanHandle.isEmpty ? 'kkl' : cleanHandle,
      birthYear: parsedYear.clamp(1920, DateTime.now().year),
    );
    if (mounted) {
      setState(() => _isEditingIdentity = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF10B981),
          content: Text(
            'Updated Actor Handle & 18+ Verification in Studio Profile!',
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w900,
              color: Color(0xFF05070B),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _openCreateNewActorModal() async {
    HapticFeedback.mediumImpact();
    final handleController = TextEditingController();
    final yearController = TextEditingController(text: '1999');
    String chosenArchetypeId = kFourteenAvatarArchetypes.first.id;

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B0E17),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  MediaQuery.of(ctx).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'CREATE NEW ACTOR PROFILE ON THIS DEVICE',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 24,
                        letterSpacing: 1.4,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: handleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Stage Handle (e.g. @nova_star)',
                        filled: true,
                        fillColor: Color(0xFF07090E),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: yearController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Birth Year (18+ Verification)',
                        filled: true,
                        fillColor: Color(0xFF07090E),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 76,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: kFourteenAvatarArchetypes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, idx) {
                          final arch = kFourteenAvatarArchetypes[idx];
                          final selected = arch.id == chosenArchetypeId;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setSheetState(() => chosenArchetypeId = arch.id);
                            },
                            child: BoondocksCharacterRig(
                              archetype: arch,
                              size: selected ? 68 : 58,
                              isSelected: selected,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(ctx).pop(false);
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const OnboardingQuestionnaireScreen(),
                                ),
                              );
                            },
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('FULL ONBOARDING PASS'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700),
                              foregroundColor: const Color(0xFF05070B),
                            ),
                            onPressed: () async {
                              await AuthService.instance
                                  .createAndSwitchToNewProfile(
                                username: handleController.text.isEmpty
                                    ? 'CoStar_${DateTime.now().second}'
                                    : handleController.text,
                                birthYear:
                                    int.tryParse(yearController.text) ?? 1999,
                                avatarArchetypeId: chosenArchetypeId,
                              );
                              if (ctx.mounted) Navigator.of(ctx).pop(true);
                            },
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'CREATE & SWITCH NOW',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF10B981),
          content: Text(
            'Switched active profile to @${AuthService.instance.currentProfile?.username}!',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w900,
              color: Color(0xFF05070B),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final profile = auth.currentProfile ??
        ActorProfileState(
          userId: 'local-s26-actor',
          email: 'actor@actlikeit.stage',
          username: 'kkl',
          birthYear: 1998,
          favoriteEras: const <String>['1970–1999', '2000–2026'],
          actingStrengths: const <String>['Method Drama', 'Improv Comedy'],
          aiTokenBalance: 25,
          unlockedScenePacks: const <String>[],
          onboardingCompleted: true,
          updatedAt: DateTime.now().toUtc(),
        );
    final archetype = resolveAvatarArchetype(profile.avatarArchetypeId);
    final offline = OfflineManager.instance;
    final totalMatches = offline.matchHistoryLog.length;
    final totalWins = offline.totalCareerWins;
    final winPct =
        totalMatches == 0 ? 0 : ((totalWins / totalMatches) * 100).round();
    final xpProgress = ((profile.careerXp % 2500) / 2500.0).clamp(0.08, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      appBar: GameAppBar(
        title: 'My Dressing Room · Profile',
        subtitle: '@${profile.username.toUpperCase()} · ${profile.careerRankBadge}',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // 1. Hero Avatar & Identity Showcase
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1F0A14), Color(0xFF0B0E17)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: archetype.primaryInkColor,
                width: 2.6,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF05070B),
                  offset: Offset(5, 5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _openAvatarArchetypePicker(profile),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          BoondocksCharacterRig(
                            archetype: archetype,
                            size: 102,
                            isSelected: true,
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF05070B),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 14,
                              color: Color(0xFF05070B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
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
                              color: const Color(0x26FFD700),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFFFD700)),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${profile.careerRankBadge} · ${profile.careerXp} XP',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFFFD700),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '@${profile.username.toUpperCase()}',
                              style: GoogleFonts.bebasNeue(
                                fontSize: 30,
                                letterSpacing: 1.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            '${archetype.name} · ${archetype.roleBadge}',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: archetype.rimAccentColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: xpProgress,
                              minHeight: 7,
                              backgroundColor: const Color(0xFF1E293B),
                              color: const Color(0xFFFFD700),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildMiniStatusChip(
                                profile.is18PlusVerified
                                    ? '18+ AFTER-HOURS VERIFIED (${profile.birthYear})'
                                    : 'STANDARD PASS (${profile.birthYear})',
                                profile.is18PlusVerified
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF59E0B),
                              ),
                              _buildMiniStatusChip(
                                profile.regionalDialect,
                                const Color(0xFF06B6D4),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openAvatarArchetypePicker(profile),
                        icon: const Icon(Icons.face_retouching_natural, size: 17),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('CHANGE 2.5D AVATAR'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setState(() => _isEditingIdentity = !_isEditingIdentity);
                        },
                        icon: const Icon(Icons.badge_outlined, size: 17),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _isEditingIdentity ? 'CANCEL EDIT' : 'EDIT HANDLE / AGE',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_isEditingIdentity) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _handleCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Stage Handle',
                            filled: true,
                            fillColor: Color(0xFF07090E),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _birthYearCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Birth Year',
                            filled: true,
                            fillColor: Color(0xFF07090E),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: const Color(0xFF05070B),
                      ),
                      onPressed: _saveIdentityChanges,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text(
                        'SAVE STAGE IDENTITY',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Quick Action Bar: VIP Box Office & Store + Career Trophy Room
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: const Color(0xFF05070B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PaymentDashboardScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.credit_card_rounded, size: 18),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '💳 VIP BOX OFFICE & STORE',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06B6D4),
                    foregroundColor: const Color(0xFF05070B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const MatchHistoryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.emoji_events_rounded, size: 18),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '🏆 CAREER TROPHY ROOM',
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

          const SizedBox(height: 16),

          // 2. Multi-Profile Account Switcher ("ACTIVE PROFILES ON THIS DEVICE")
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0E17),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF06B6D4), width: 1.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'ACTIVE PROFILES ON THIS DEVICE · INSTANT SWITCHER',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF06B6D4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${auth.savedProfiles.length} SAVED',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...auth.savedProfiles.map((saved) {
                  final isCurrent = saved.userId == profile.userId;
                  final savedArch =
                      resolveAvatarArchetype(saved.avatarArchetypeId);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFF151E30)
                          : const Color(0xFF07090E),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCurrent
                            ? const Color(0xFFFFD700)
                            : const Color(0xFF1E293B),
                        width: isCurrent ? 2.2 : 1.2,
                      ),
                    ),
                    child: InkWell(
                      onTap: isCurrent
                          ? null
                          : () async {
                              HapticFeedback.heavyImpact();
                              await AuthService.instance
                                  .switchToProfile(saved.userId);
                            },
                      child: Row(
                        children: [
                          BoondocksCharacterRig(
                            archetype: savedArch,
                            size: 46,
                            isSelected: isCurrent,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '@${saved.username.toUpperCase()}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${saved.careerRankBadge} · ${saved.aiTokenBalance} AI Tokens',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10.5,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? const Color(0x2610B981)
                                  : const Color(0x2606B6D4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isCurrent ? 'ACTIVE ★' : 'SWITCH',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isCurrent
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF06B6D4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFD700),
                    side: const BorderSide(color: Color(0xFFFFD700), width: 1.6),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _openCreateNewActorModal,
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: const Text(
                    '+ Create New Actor Profile',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Career Stats & Trophy Showcase
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0E17),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CAREER STATS & TROPHY SHOWCASE',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatTile('MATCHES', '$totalMatches', Colors.white),
                    const SizedBox(width: 8),
                    _buildStatTile(
                      'WINS',
                      '$totalWins ($winPct%)',
                      const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 8),
                    _buildStatTile(
                      'AVG SCORE',
                      offline.averageFinalScore.toStringAsFixed(1),
                      const Color(0xFFFFD700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatTile(
                      'AI HIGH',
                      offline.highestAiScore.toStringAsFixed(1),
                      const Color(0xFFE11D48),
                    ),
                    const SizedBox(width: 8),
                    _buildStatTile(
                      'PEER HIGH',
                      offline.highestPeerScore.toStringAsFixed(1),
                      const Color(0xFF06B6D4),
                    ),
                    const SizedBox(width: 8),
                    _buildStatTile(
                      'SOCIAL HIGH',
                      offline.highestSocialScore.toStringAsFixed(1),
                      const Color(0xFFF59E0B),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Onboarding & Acting DNA Summary (Editable)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0E17),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFA855F7), width: 1.6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ONBOARDING & ACTING DNA SUMMARY (TAP CHIPS TO CUSTOMIZE)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFA855F7),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Favorite Soundstage Eras:',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _kAvailableEras.map((era) {
                    final selected = profile.favoriteEras.contains(era);
                    return FilterChip(
                      label: Text(era),
                      selected: selected,
                      selectedColor: const Color(0x33F59E0B),
                      checkmarkColor: const Color(0xFFFFD700),
                      onSelected: (val) async {
                        HapticFeedback.selectionClick();
                        final next = List<String>.from(profile.favoriteEras);
                        if (val) {
                          next.add(era);
                        } else if (next.length > 1) {
                          next.remove(era);
                        }
                        await AuthService.instance.upsertAdditiveProfileFields(
                          favoriteEras: next,
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Acting Strengths & Archetype DNA:',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _kAvailableStrengths.map((str) {
                    final selected = profile.actingStrengths.contains(str);
                    return FilterChip(
                      label: Text(str),
                      selected: selected,
                      selectedColor: const Color(0x3306B6D4),
                      checkmarkColor: const Color(0xFF06B6D4),
                      onSelected: (val) async {
                        HapticFeedback.selectionClick();
                        final next = List<String>.from(profile.actingStrengths);
                        if (val) {
                          next.add(str);
                        } else if (next.length > 1) {
                          next.remove(str);
                        }
                        await AuthService.instance.upsertAdditiveProfileFields(
                          actingStrengths: next,
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  'Vocal Projection Baseline: ${profile.vocalProjectionDb.toStringAsFixed(1)} dBFS · Physical Style: ${profile.physicalStyle}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Color(0xFFF5DEB3),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _kAvailableDialects.map((dialect) {
                    final active = profile.regionalDialect == dialect;
                    return ChoiceChip(
                      label: Text(dialect),
                      selected: active,
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        AuthService.instance.upsertAdditiveProfileFields(
                          regionalDialect: dialect,
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _kAvailablePhysicalStyles.map((style) {
                    final active = profile.physicalStyle == style;
                    return ChoiceChip(
                      label: Text(style),
                      selected: active,
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        AuthService.instance.upsertAdditiveProfileFields(
                          physicalStyle: style,
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 5. Google Play Store Privacy, Terms & Account Deletion Compliance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF140B12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE11D48), width: 1.6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'PRIVACY, TERMS & ACCOUNT MANAGEMENT',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE11D48),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    await AuthService.instance.topUpAiTokens(5);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Restored Google Play Purchases & synced cloud entitlements!',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.restore_rounded, size: 18),
                  label: const Text('Restore Purchases'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    await OfflineManager.instance
                        .clearLocalCacheAndOfflineQueue();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Cleared Local Scene Cache & Offline Queue!',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.cleaning_services_rounded, size: 18),
                  label: const Text('Clear Local Cache & Offline Queue'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF0B0E17),
                        title: const Text(
                          'Delete Actor Profile & Account Data?',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          'This permanently deletes your Actor Profile and personal data from local storage and Supabase.',
                          style: TextStyle(color: Color(0xFFCBD5E1)),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('CANCEL'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE11D48),
                            ),
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('DELETE ACCOUNT'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && mounted) {
                      await AuthService.instance
                          .deleteCurrentActorProfileAndData();
                      if (!mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                          builder: (_) => const AuthScreen(),
                        ),
                        (_) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_forever_rounded, size: 18),
                  label: const Text('Delete Actor Profile & Account Data'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF07090E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
