import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lobby.dart';
import '../auth/auth_service.dart';
import '../monetization/payment_dashboard_screen.dart';
import 'premiere_red_carpet_painters.dart';
import 'parody_scenes_catalog.dart';
import 'game_app_bar.dart';
import 'game_settings_modal.dart';

/// Descriptor for each oversized vintage Movie Ticket inside `SceneVaultScreen`.
class VaultEraTicketSpec {
  final SceneCategory category;
  final String admitCode;
  final String eraTitle;
  final String tagline;
  final String featuredReels;
  final Color neonAccent;
  final IconData icon;

  const VaultEraTicketSpec({
    required this.category,
    required this.admitCode,
    required this.eraTitle,
    required this.tagline,
    required this.featuredReels,
    required this.neonAccent,
    required this.icon,
  });
}

const List<VaultEraTicketSpec> kVaultEraTickets = [
  VaultEraTicketSpec(
    category: SceneCategory.era1970To1999,
    admitCode: 'BOX OFFICE · REEL 70–99',
    eraTitle: '1970–1999',
    tagline: 'New Hollywood & Silver Screen Classics (10 Reels)',
    featuredReels:
        'Neon Rain 1982 · Courtroom Honor · Midnight Diner · Galaxy Father · Shark Mayor · Mafia Offer',
    neonAccent: Color(0xFFF59E0B),
    icon: Icons.movie_filter_rounded,
  ),
  VaultEraTicketSpec(
    category: SceneCategory.era2000To2026,
    admitCode: 'BOX OFFICE · REEL 00–26',
    eraTitle: '2000–2026',
    tagline: 'Modern Prestige & High-Voltage Cinema (10 Reels)',
    featuredReels:
        'Tempo Obsession · Parallel Laundromat · Social Billionaire · Wall Street Wolf · Pirate Captain',
    neonAccent: Color(0xFF06B6D4),
    icon: Icons.auto_awesome_motion_rounded,
  ),
  VaultEraTicketSpec(
    category: SceneCategory.awardsBestActor,
    admitCode: 'ACADEMY VAULT · LEAD ACTOR',
    eraTitle: 'Best Actor',
    tagline: 'Tour-de-Force Award-Winning Monologues (10 Reels)',
    featuredReels:
        'The Pipeline Reaches · Corrupt Cop · King Speech · Atomic Physicist · Method Actor Breakdown',
    neonAccent: Color(0xFFE11D48),
    icon: Icons.emoji_events_rounded,
  ),
  VaultEraTicketSpec(
    category: SceneCategory.awardsBestActress,
    admitCode: 'ACADEMY VAULT · LEAD ACTRESS',
    eraTitle: 'Best Actress',
    tagline: 'Commanding Leading Lady Showstoppers (10 Reels)',
    featuredReels:
        'Open Pasture Gate · Fashion Magazine Devil · Black Swan Ballerina · Southern Belle · Pop Star',
    neonAccent: Color(0xFFF43F5E),
    icon: Icons.stars_rounded,
  ),
  VaultEraTicketSpec(
    category: SceneCategory.awardsBestSupportingActor,
    admitCode: 'ACADEMY VAULT · SUPPORTING',
    eraTitle: 'Best Supporting',
    tagline: 'Scene-Stealing Mentors, Detectives & Wildcards (10 Reels)',
    featuredReels:
        'Beyond the Textbook · Grumpy Mentor · Loyal Sidekick · Eccentric Detective · Fast-Talking Agent',
    neonAccent: Color(0xFF38BDF8),
    icon: Icons.theater_comedy_rounded,
  ),
  VaultEraTicketSpec(
    category: SceneCategory.awardsBestVillain,
    admitCode: 'ACADEMY VAULT · NEMESIS',
    eraTitle: 'Best Villain',
    tagline: 'Cold Fatalism & Commanding Menace (10 Reels)',
    featuredReels:
        'Call It in the Dust · Chaos Clown ·Polyglot Hunter · Cyber Overlord · Vampire Aristocrat',
    neonAccent: Color(0xFF10B981),
    icon: Icons.whatshot_rounded,
  ),
  VaultEraTicketSpec(
    category: SceneCategory.awardsEmmyVault,
    admitCode: 'ACADEMY VAULT · EMMY',
    eraTitle: 'Emmy Vault',
    tagline: 'Prestige Television Showstoppers (10 Reels)',
    featuredReels:
        'The Storm at the Gate · Media Patriarch · Chaotic Chef · Dragon Queen · Zombie Survivor',
    neonAccent: Color(0xFFEC4899),
    icon: Icons.live_tv_rounded,
  ),
  VaultEraTicketSpec(
    category: SceneCategory.specialtyCultClassics,
    admitCode: 'MIDNIGHT VAULT · CULT',
    eraTitle: 'Cult Classics',
    tagline: 'Underground Legends & Midnight Quotables (10 Reels)',
    featuredReels:
        'Espresso Is for Closers · Bowling Zen · Basement Fight Club · Worst Room Ever · High School Queen',
    neonAccent: Color(0xFFA855F7),
    icon: Icons.bolt_rounded,
  ),
  VaultEraTicketSpec(
    category: SceneCategory.specialtyBlockbusterSciFi,
    admitCode: 'IMAX VAULT · SCI-FI & ACTION',
    eraTitle: 'Sci-Fi & Action',
    tagline: 'Blockbuster Spectacles & Multiverse Epics (10 Reels)',
    featuredReels:
        'Time Loop Soldier · Giant Robot Pilot · Asteroid Drillers · Dinosaur Park · Superhero Landing',
    neonAccent: Color(0xFF22D3EE),
    icon: Icons.rocket_launch_rounded,
  ),
];

/// Dedicated Vintage Box Office Scene Vault screen where players swipe through
/// oversized perforated movie tickets (all 9 categories × 10 scenes = 90 general scenes)
/// and trigger the Director's Call Sheet (`GameSettingsModal`) before entering
/// the matchmaking soundstage.
class SceneVaultScreen extends StatefulWidget {
  const SceneVaultScreen({super.key});

  @override
  State<SceneVaultScreen> createState() => _SceneVaultScreenState();
}

class _SceneVaultScreenState extends State<SceneVaultScreen> {
  late final PageController _ticketController;
  int _activeIndex = 0;
  double _pagePosition = 0.0;
  final Map<SceneCategory, int> _selectedPromptIndexByCategory = {};

  @override
  void initState() {
    super.initState();
    _ticketController = PageController(viewportFraction: 0.86)
      ..addListener(() {
        if (!mounted || !_ticketController.hasClients) return;
        setState(() {
          _pagePosition = _ticketController.page ?? _activeIndex.toDouble();
        });
      });
  }

  @override
  void dispose() {
    _ticketController.dispose();
    super.dispose();
  }

  ScenePrompt? _activePromptForCategory(SceneCategory category) {
    final prompts = kBuiltInSceneVault[category] ?? const [];
    if (prompts.isEmpty) return null;
    final idx = (_selectedPromptIndexByCategory[category] ?? 0)
        .clamp(0, prompts.length - 1);
    return prompts[idx];
  }

  void _cyclePrompt(SceneCategory category, int delta) {
    final prompts = kBuiltInSceneVault[category] ?? const [];
    if (prompts.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      final current = _selectedPromptIndexByCategory[category] ?? 0;
      _selectedPromptIndexByCategory[category] =
          (current + delta) % prompts.length < 0
              ? prompts.length - 1
              : (current + delta) % prompts.length;
    });
  }

  Future<void> _onSelectTicket(VaultEraTicketSpec ticket) async {
    HapticFeedback.heavyImpact();
    final selectedPrompt = _activePromptForCategory(ticket.category);
    final settings = await showModalBottomSheet<GameSettingsConfig>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GameSettingsModal(modeTitle: ticket.eraTitle),
    );
    if (settings == null || !mounted) return;

    await Navigator.of(context).push(
      StageSharedTransitionRoute(
        page: LobbyMatchmakingScreen(
          initialCategory: ticket.category,
          initialPromptOverride: selectedPrompt,
          startInJoinMode: false,
          autoCreateOnInit: true,
        ),
      ),
    );
  }

  Future<void> _openHostPaysUnlock(VaultEraTicketSpec ticket) async {
    HapticFeedback.mediumImpact();
    final key = (ticket.category == SceneCategory.awardsEmmyVault ||
            ticket.category == SceneCategory.specialtyCultClassics)
        ? 'emmy_cult_bundle'
        : 'all_era_vault';
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentDashboardScreen(highlightProductKey: key),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final activeTicket = kVaultEraTickets[_activeIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      appBar: const GameAppBar(
        title: 'The Scene Vault',
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.6),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VINTAGE BOX OFFICE WINDOW · 9 CATEGORIES · $totalGeneralSceneCount GENERAL SCRIPTS',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: activeTicket.neonAccent,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'THE SCENE VAULT',
                              style: GoogleFonts.limelight(
                                fontSize: 30,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Fixture #13: "The Writer's Room" AI Custom Scene Generator Button (1 AI Token)
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFFD700),
                            side: const BorderSide(
                              color: Color(0xFFFFD700),
                              width: 1.6,
                            ),
                            backgroundColor: const Color(0xD9161108),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                          onPressed: _openWritersRoomCustomSceneModal,
                          icon: const Icon(Icons.edit_note_rounded, size: 17),
                          label: const Text(
                            '✍️ WRITER\'S ROOM (1 TOKEN)',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _ticketController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: kVaultEraTickets.length,
                  onPageChanged: (idx) {
                    HapticFeedback.selectionClick();
                    setState(() => _activeIndex = idx);
                  },
                  itemBuilder: (context, index) {
                    final ticket = kVaultEraTickets[index];
                    final delta = (_pagePosition - index).abs().clamp(0.0, 1.0);
                    final scale = 1.0 - (delta * 0.07);

                    return Transform.scale(
                      scale: scale,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 16,
                        ),
                        child: _buildLargeMovieTicket(ticket),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(kVaultEraTickets.length, (i) {
                    final selected = i == _activeIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: selected ? 28 : 8,
                      decoration: BoxDecoration(
                        color: selected
                            ? activeTicket.neonAccent
                            : const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeMovieTicket(VaultEraTicketSpec ticket) {
    final prompts = kBuiltInSceneVault[ticket.category] ?? const [];
    final promptIndex = (_selectedPromptIndexByCategory[ticket.category] ?? 0)
        .clamp(0, prompts.isEmpty ? 0 : prompts.length - 1);
    final activePrompt = prompts.isNotEmpty ? prompts[promptIndex] : null;
    final isUnlocked = AuthService.instance.hasAllEraBundle ||
        AuthService.instance.hasEmmyAndCultVault;

    return GestureDetector(
      onTap: () => _onSelectTicket(ticket),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: ticket.neonAccent.withValues(alpha: 0.28),
              blurRadius: 28,
              spreadRadius: 2,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipPath(
          clipper: BoxOfficeTicketNotchClipper(),
          child: CustomPaint(
            foregroundPainter: _SceneVaultTicketBorderPainter(
              accentColor: ticket.neonAccent,
            ),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF141A29),
                    Color(0xFF0A0D16),
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        ticket.neonAccent.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: ticket.neonAccent),
                                  ),
                                  child: Text(
                                    ticket.admitCode,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: ticket.neonAccent,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                ticket.icon,
                                color: ticket.neonAccent,
                                size: 32,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              ticket.eraTitle,
                              style: GoogleFonts.limelight(
                                fontSize: 32,
                                color: Colors.white,
                                letterSpacing: 1.2,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ticket.tagline,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => _openHostPaysUnlock(ticket),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isUnlocked
                                    ? const Color(0x2610B981)
                                    : const Color(0x26F5DEB3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isUnlocked
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF5DEB3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isUnlocked
                                        ? Icons.verified_rounded
                                        : Icons.workspace_premium_rounded,
                                    size: 14,
                                    color: isUnlocked
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFF5DEB3),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      isUnlocked
                                          ? 'HOST-PAYS PACK UNLOCKED · ALL GUESTS PLAY FREE'
                                          : 'HOST-PAYS UNLOCK · GUESTS PLAY FREE (TAP FOR VIP BOX OFFICE)',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        color: isUnlocked
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFF5DEB3),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Perforated tear-line
                          Row(
                            children: List.generate(22, (i) {
                              return Expanded(
                                child: Container(
                                  height: 1.6,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  color: i.isEven
                                      ? ticket.neonAccent.withValues(alpha: 0.5)
                                      : Colors.transparent,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'FEATURED SOUNDSTAGE REELS',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ticket.featuredReels,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                          if (activePrompt != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF07090E),
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: const Color(0xFF1E293B)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'SCRIPT ${promptIndex + 1}/${prompts.length} · ${activePrompt.title} (${activePrompt.releaseYear})',
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                            color: ticket.neonAccent,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 28,
                                              minHeight: 28,
                                            ),
                                            tooltip: 'Previous Script',
                                            onPressed: () =>
                                                _cyclePrompt(ticket.category, -1),
                                            icon: Icon(
                                              Icons.chevron_left_rounded,
                                              color: ticket.neonAccent,
                                              size: 20,
                                            ),
                                          ),
                                          IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 28,
                                              minHeight: 28,
                                            ),
                                            tooltip: 'Next Script',
                                            onPressed: () =>
                                                _cyclePrompt(ticket.category, 1),
                                            icon: Icon(
                                              Icons.chevron_right_rounded,
                                              color: ticket.neonAccent,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ROLE: ${activePrompt.characterName} · EMOTION: ${activePrompt.emotionalTarget}',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '"${activePrompt.promptScript}"',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontStyle: FontStyle.italic,
                                      height: 1.45,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (activePrompt.duetLeadA.isNotEmpty ||
                                      activePrompt.duetLeadB.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'LEAD A (GOLD): "${activePrompt.duetLeadA}"',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        height: 1.4,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFF5DEB3),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'LEAD B (CYAN): "${activePrompt.duetLeadB}"',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        height: 1.4,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0CB6D4),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Text(
                                    'Director\'s Note: ${activePrompt.directorCue}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFCBD5E1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ticket.neonAccent,
                        foregroundColor: const Color(0xFF07090E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _onSelectTicket(ticket),
                      icon: const Icon(Icons.confirmation_number_rounded,
                          size: 20),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'STAMP TICKET & OPEN CALL SHEET',
                          style: GoogleFonts.limelight(
                            fontSize: 14,
                            letterSpacing: 1.1,
                            color: const Color(0xFF07090E),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Fixture #13: "The Writer's Room" AI Custom Scene Generator (1 AI Token).
  Future<void> _openWritersRoomCustomSceneModal() async {
    HapticFeedback.mediumImpact();
    final objectCtrl = TextEditingController(text: 'A Haunted Toaster');
    final jobCtrl = TextEditingController(text: 'A Corrupt Senator');
    final emotionCtrl = TextEditingController(text: 'Paranoid Whispering');

    final createdScene = await showModalBottomSheet<OriginalParodySceneEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B0E17),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
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
                const Text(
                  '✍️ THE WRITER\'S ROOM · AI CUSTOM SCENE GENERATOR',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pitch 3 ingredients (1 AI Token). Gemini 2.5 Flash synthesizes a custom Solo + Duet script with a 15-second Improv Curveball.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: objectCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: '1. Bizarre Object (e.g., A Haunted Toaster)',
                    filled: true,
                    fillColor: Color(0xFF141926),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: jobCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: '2. Occupation (e.g., A Corrupt Senator)',
                    filled: true,
                    fillColor: Color(0xFF141926),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emotionCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: '3. Emotional State (e.g., Paranoid Whispering)',
                    filled: true,
                    fillColor: Color(0xFF141926),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: const Color(0xFF05070B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    final scene = buildFallbackWritersRoomScene(
                      bizarreObject: objectCtrl.text,
                      occupation: jobCtrl.text,
                      emotionalState: emotionCtrl.text,
                    );
                    Navigator.of(ctx).pop(scene);
                  },
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'GENERATE CUSTOM SCRIPT & STEP ONTO SET (1 AI TOKEN)',
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
        );
      },
    );

    if (createdScene != null && mounted) {
      kWritersRoomCustomScenes.insert(0, createdScene);
      setState(() {});
      final customPrompt = ScenePrompt(
        id: createdScene.id,
        category: SceneCategory.specialtyCultClassics,
        title: createdScene.title,
        filmOrSeries: 'The Writer\'s Room Original',
        releaseYear: createdScene.releaseYear,
        characterName: createdScene.characterName,
        promptScript: createdScene.script,
        directorCue: createdScene.directorNote,
        emotionalTarget: createdScene.targetEmotion,
        duetLeadA: createdScene.duetLeadA,
        duetLeadB: createdScene.duetLeadB,
        improvTwist: createdScene.improvTwist,
      );
      await Navigator.of(context).push(
        StageSharedTransitionRoute(
          page: LobbyMatchmakingScreen(
            initialCategory: SceneCategory.specialtyCultClassics,
            initialPromptOverride: customPrompt,
            startInJoinMode: false,
            autoCreateOnInit: true,
          ),
        ),
      );
    }
  }
}

class _SceneVaultTicketBorderPainter extends CustomPainter {
  final Color accentColor;

  const _SceneVaultTicketBorderPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = BoxOfficeTicketNotchClipper().getClip(size);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 5.0
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = accentColor
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _SceneVaultTicketBorderPainter oldDelegate) =>
      oldDelegate.accentColor != accentColor;
}
