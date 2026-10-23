import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lobby.dart';
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
    tagline: 'New Hollywood & Silver Screen Classics',
    featuredReels: 'Neon Rain 1982 · Courtroom Honor · Diner Pulp · Midnight Cab',
    neonAccent: Color(0xFFF59E0B),
    icon: Icons.movie_filter_rounded,
  ),
  VaultEraTicketSpec(
    category: SceneCategory.era2000To2026,
    admitCode: 'BOX OFFICE · REEL 00–26',
    eraTitle: '2000–2026',
    tagline: 'Modern Prestige & High-Voltage Cinema',
    featuredReels: 'Tempo Obsession · Gotham Shadow · Atomic Horizon · Boardroom Dynasty',
    neonAccent: Color(0xFF06B6D4),
    icon: Icons.auto_awesome_motion_rounded,
  ),
  VaultEraTicketSpec(
    category: SceneCategory.specialtyCultClassics,
    admitCode: 'MIDNIGHT VAULT · CULT',
    eraTitle: 'Cult Classics',
    tagline: 'Underground Legends & Midnight Quotables',
    featuredReels: 'Bowling Alley Zen · Basement Rules · Midnight Time Warp · Velvet Tangent',
    neonAccent: Color(0xFFA855F7),
    icon: Icons.bolt_rounded,
  ),
  VaultEraTicketSpec(
    category: SceneCategory.awardsBestActor,
    admitCode: 'ACADEMY VAULT · LEAD',
    eraTitle: 'Best Actor',
    tagline: 'Tour-de-Force Award-Winning Monologues',
    featuredReels: 'Black Gold Tycoon · Rookie Precinct · Prime Time Broadcast',
    neonAccent: Color(0xFFE11D48),
    icon: Icons.emoji_events_rounded,
  ),
  VaultEraTicketSpec(
    category: SceneCategory.awardsBestVillain,
    admitCode: 'ACADEMY VAULT · NEMESIS',
    eraTitle: 'Best Villain',
    tagline: 'Cold Fatalism & Commanding Menace',
    featuredReels: 'Desert Coin Toss · Tavern Interrogation · Greed Street',
    neonAccent: Color(0xFF10B981),
    icon: Icons.whatshot_rounded,
  ),
  VaultEraTicketSpec(
    category: SceneCategory.awardsEmmyVault,
    admitCode: 'ACADEMY VAULT · EMMY',
    eraTitle: 'Emmy Vault',
    tagline: 'Prestige Television Showstoppers',
    featuredReels: 'Desert Chemistry · Waystar Boardroom · The Bear Kitchen',
    neonAccent: Color(0xFFEC4899),
    icon: Icons.live_tv_rounded,
  ),
];

/// Dedicated Vintage Box Office Scene Vault screen where players swipe through
/// oversized perforated movie tickets (1970–1999, 2000–2026, Cult Classics, etc.)
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

  Future<void> _onSelectTicket(VaultEraTicketSpec ticket) async {
    HapticFeedback.heavyImpact();
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
          startInJoinMode: false,
          autoCreateOnInit: true,
        ),
      ),
    );
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
                    'VINTAGE BOX OFFICE WINDOW · SWIPE REELS',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: activeTicket.neonAccent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'THE SCENE VAULT',
                    style: GoogleFonts.limelight(
                      fontSize: 30,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
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
                              color: ticket.neonAccent.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: ticket.neonAccent),
                            ),
                            child: Text(
                              ticket.admitCode,
                              overflow: TextOverflow.ellipsis,
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
                    const SizedBox(height: 20),
                    Text(
                      ticket.eraTitle,
                      style: GoogleFonts.limelight(
                        fontSize: 32,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        height: 1.1,
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
                    const SizedBox(height: 18),
                    // Perforated tear-line
                    Row(
                      children: List.generate(22, (i) {
                        return Expanded(
                          child: Container(
                            height: 1.6,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            color: i.isEven
                                ? ticket.neonAccent.withValues(alpha: 0.5)
                                : Colors.transparent,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
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
                    if (prompts.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF07090E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SPOTLIGHT SCRIPT · ${prompts.first.filmOrSeries} (${prompts.first.releaseYear})',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: ticket.neonAccent,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '"${prompts.first.promptScript}"',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontStyle: FontStyle.italic,
                                height: 1.45,
                                color: Colors.white70,
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
                icon: const Icon(Icons.confirmation_number_rounded, size: 20),
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
