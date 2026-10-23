import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../dashboard_marquee.dart';
import '../ui/intro_cinematic.dart';
import 'auth_service.dart';

/// Represents a swipeable, neon-bordered movie ticket inside "The Red Carpet"
/// Onboarding Questionnaire.
class RedCarpetTicketOption {
  final String id;
  final String code;
  final String title;
  final String subtitle;
  final String directorNote;
  final Color neonAccent;
  final IconData icon;

  const RedCarpetTicketOption({
    required this.id,
    required this.code,
    required this.title,
    required this.subtitle,
    required this.directorNote,
    required this.neonAccent,
    required this.icon,
  });
}

const List<RedCarpetTicketOption> kRedCarpetEraTickets = <RedCarpetTicketOption>[
  RedCarpetTicketOption(
    id: '1970s',
    code: 'REEL · 1970s–1999',
    title: '1970s Silver Screen Icons',
    subtitle: 'Gritty New Hollywood, Noir & Classic Blockbusters',
    directorNote:
        'Unlocks high-tension character studies, method monologues, and classic cinema showdowns.',
    neonAccent: Color(0xFFF59E0B), // Neon Amber
    icon: Icons.movie_filter_rounded,
  ),
  RedCarpetTicketOption(
    id: '2000s',
    code: 'REEL · 2000s–2026',
    title: '2000s Modern Prestige',
    subtitle: 'High-Voltage Thrillers, Prestige TV & Viral Monologues',
    directorNote:
        'Prioritizes razor-sharp courtroom battles, intense boardroom breakdowns, and modern epics.',
    neonAccent: Color(0xFF06B6D4), // Neon Cyan
    icon: Icons.auto_awesome_motion_rounded,
  ),
];

const List<RedCarpetTicketOption> kRedCarpetStrengthTickets =
    <RedCarpetTicketOption>[
  RedCarpetTicketOption(
    id: 'Comedy',
    code: 'ARCHETYPE · COMEDY',
    title: 'Deadpan & High-Wire Comedy',
    subtitle: 'Rapid-fire timing, escalating panic & physical improv',
    directorNote:
        'Tunes AI Telemetrics to reward vocal rhythm, expressive micro-pauses, and comedic escalation.',
    neonAccent: Color(0xFF06B6D4), // Neon Cyan
    icon: Icons.theater_comedy_rounded,
  ),
  RedCarpetTicketOption(
    id: 'Drama',
    code: 'ARCHETYPE · DRAMA',
    title: 'Oscar-Caliber Heavy Drama',
    subtitle: 'Raw vulnerability, simmering grief & explosive catharsis',
    directorNote:
        'Tunes AI Telemetrics to track emotional conviction, vocal tremor, and sustained eye contact.',
    neonAccent: Color(0xFFA855F7), // Neon Purple
    icon: Icons.psychology_alt_rounded,
  ),
  RedCarpetTicketOption(
    id: 'Villain',
    code: 'ARCHETYPE · VILLAIN',
    title: 'Cold-Blooded Mastermind Villain',
    subtitle: 'Menacing whispers, theatrical arrogance & power plays',
    directorNote:
        'Tunes AI Telemetrics to measure controlled cadence, sinister intensity, and stage dominance.',
    neonAccent: Color(0xFFF59E0B), // Neon Amber
    icon: Icons.whatshot_rounded,
  ),
];

/// "The Red Carpet" Gamified Onboarding Questionnaire.
/// Users swipe through dynamic perforated movie tickets to select their
/// favorite eras (`1970s`, `2000s`), acting strengths (`Comedy`, `Drama`, `Villain`),
/// and 2.5D Cell-Shaded Avatar Archetype, verify their birth year for the 18+ gate,
/// and persist everything additively to Supabase.
class OnboardingQuestionnaireScreen extends StatefulWidget {
  final String initialUsername;
  final int initialBirthYear;
  final String initialArchetypeId;

  const OnboardingQuestionnaireScreen({
    super.key,
    this.initialUsername = '',
    this.initialBirthYear = 1998,
    this.initialArchetypeId = 'the_method_actor',
  });

  @override
  State<OnboardingQuestionnaireScreen> createState() =>
      _OnboardingQuestionnaireScreenState();
}

class _OnboardingQuestionnaireScreenState
    extends State<OnboardingQuestionnaireScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spotlightController;
  late final PageController _eraTicketController;
  late final PageController _strengthTicketController;
  late final TextEditingController _usernameController;

  int _activeStep = 0; // 0: Era Tickets, 1: Strength Tickets, 2: 2.5D Archetype & Credentials
  double _eraPageOffset = 0.0;
  double _strengthPageOffset = 0.0;
  late int _selectedBirthYear;
  late String _selectedArchetypeId;
  final Set<String> _selectedEras = <String>{'1970s'};
  final Set<String> _selectedStrengths = <String>{'Drama'};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = AuthService.instance.currentProfile;
    _usernameController = TextEditingController(
      text: widget.initialUsername.isNotEmpty
          ? widget.initialUsername
          : (existing?.username ?? 'StageStar'),
    );
    _selectedBirthYear = widget.initialBirthYear != 1998
        ? widget.initialBirthYear
        : (existing?.birthYear ?? widget.initialBirthYear);
    _selectedArchetypeId = widget.initialArchetypeId != 'the_method_actor'
        ? widget.initialArchetypeId
        : (existing?.avatarArchetypeId ?? widget.initialArchetypeId);
    if (existing != null) {
      if (existing.favoriteEras.isNotEmpty) {
        _selectedEras
          ..clear()
          ..addAll(existing.favoriteEras);
      }
      if (existing.actingStrengths.isNotEmpty) {
        _selectedStrengths
          ..clear()
          ..addAll(existing.actingStrengths);
      }
    }

    _spotlightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _eraTicketController = PageController(viewportFraction: 0.84)
      ..addListener(() {
        if (mounted) {
          setState(() {
            _eraPageOffset = _eraTicketController.page ?? 0.0;
          });
        }
      });

    _strengthTicketController = PageController(viewportFraction: 0.84)
      ..addListener(() {
        if (mounted) {
          setState(() {
            _strengthPageOffset = _strengthTicketController.page ?? 0.0;
          });
        }
      });
  }

  @override
  void dispose() {
    _spotlightController.dispose();
    _eraTicketController.dispose();
    _strengthTicketController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _toggleEraSelection(String eraId) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_selectedEras.contains(eraId)) {
        if (_selectedEras.length > 1) {
          _selectedEras.remove(eraId);
        }
      } else {
        _selectedEras.add(eraId);
      }
    });
  }

  void _toggleStrengthSelection(String strengthId) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_selectedStrengths.contains(strengthId)) {
        if (_selectedStrengths.length > 1) {
          _selectedStrengths.remove(strengthId);
        }
      } else {
        _selectedStrengths.add(strengthId);
      }
    });
  }

  Future<void> _completeRedCarpetOnboarding() async {
    if (_isSaving) return;
    HapticFeedback.heavyImpact();

    setState(() {
      _isSaving = true;
    });

    try {
      await AuthService.instance.saveOnboardingQuestionnaire(
        username: _usernameController.text.trim(),
        birthYear: _selectedBirthYear,
        favoriteEras: _selectedEras.toList(),
        actingStrengths: _selectedStrengths.toList(),
        avatarArchetypeId: _selectedArchetypeId,
        castingTrack: 'track_a_star',
      );

      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LivingMarqueeDashboardScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF991B1B),
          content: Text('Failed to save Red Carpet profile: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: Stack(
        children: [
          // Slow-moving animated neon spotlights (Cyan, Purple, Amber)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _spotlightController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _RedCarpetSpotlightPainter(
                    progress: _spotlightController.value,
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopHeader(),
                _buildStepProgressIndicator(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: _buildActiveStepBody(),
                  ),
                ),
                _buildBottomActionFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0E17),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, color: Color(0xFFF59E0B), size: 14),
                SizedBox(width: 6),
                Text(
                  'THE RED CARPET',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0E17),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF06B6D4), width: 1.1),
            ),
            child: Text(
              'STEP ${_activeStep + 1} OF 3',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF06B6D4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepProgressIndicator() {
    const stepLabels = <String>[
      '1. ERAS',
      '2. STRENGTHS',
      '3. VIP PASS',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: List<Widget>.generate(stepLabels.length, (index) {
          final isCurrent = index == _activeStep;
          final isDone = index < _activeStep;
          final activeColor = index == 0
              ? const Color(0xFFF59E0B)
              : index == 1
                  ? const Color(0xFFA855F7)
                  : const Color(0xFF06B6D4);

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < 2 ? 8.0 : 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isCurrent || isDone)
                          ? activeColor
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      stepLabels[index],
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: (isCurrent || isDone)
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveStepBody() {
    if (_activeStep == 0) {
      return _buildTicketSwipeStage(
        key: const ValueKey<String>('step_eras'),
        headline: 'SWIPE & STAMP YOUR CINEMA ERAS',
        subheadline:
            'Swipe through the perforated movie tickets and tap to stamp the eras you want prioritized in your Scene Vault.',
        tickets: kRedCarpetEraTickets,
        selectedIds: _selectedEras,
        controller: _eraTicketController,
        pageOffset: _eraPageOffset,
        onToggleTicket: _toggleEraSelection,
      );
    }

    if (_activeStep == 1) {
      return _buildTicketSwipeStage(
        key: const ValueKey<String>('step_strengths'),
        headline: 'SELECT YOUR ACTING ARCHETYPES',
        subheadline:
            'Swipe the casting tickets to calibrate Gemini AI Telemetrics to your natural stage strengths.',
        tickets: kRedCarpetStrengthTickets,
        selectedIds: _selectedStrengths,
        controller: _strengthTicketController,
        pageOffset: _strengthPageOffset,
        onToggleTicket: _toggleStrengthSelection,
      );
    }

    return _buildFinalCredentialsStage();
  }

  Widget _buildTicketSwipeStage({
    required Key key,
    required String headline,
    required String subheadline,
    required List<RedCarpetTicketOption> tickets,
    required Set<String> selectedIds,
    required PageController controller,
    required double pageOffset,
    required ValueChanged<String> onToggleTicket,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headline,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subheadline,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: controller,
            itemCount: tickets.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final isSelected = selectedIds.contains(ticket.id);
              final delta = (index - pageOffset).clamp(-1.0, 1.0);
              final scale = 1.0 - (delta.abs() * 0.07);

              return Transform.scale(
                scale: scale,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  child: GestureDetector(
                    onTap: () => onToggleTicket(ticket.id),
                    child: CustomPaint(
                      foregroundPainter: _RedCarpetPerforatedTicketBorderPainter(
                        borderColor: isSelected
                            ? ticket.neonAccent
                            : const Color(0xFF334155),
                        strokeWidth: isSelected ? 2.6 : 1.5,
                        showPerforationLine: true,
                      ),
                      child: ClipPath(
                        clipper: _RedCarpetTicketClipper(),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B0E17),
                            boxShadow: isSelected
                                ? <BoxShadow>[
                                    BoxShadow(
                                      color: ticket.neonAccent
                                          .withValues(alpha: 0.28),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : const <BoxShadow>[],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ticket.neonAccent.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: ticket.neonAccent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    ticket.code,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                      color: ticket.neonAccent,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? ticket.neonAccent
                                        : const Color(0xFF111827),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.verified_rounded
                                            : Icons.touch_app_rounded,
                                        size: 13,
                                        color: isSelected
                                            ? const Color(0xFF07090E)
                                            : const Color(0xFF94A3B8),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isSelected ? 'STAMPED' : 'TAP TO STAMP',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: isSelected
                                              ? const Color(0xFF07090E)
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: ticket.neonAccent.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: ticket.neonAccent.withOpacity(0.6),
                                ),
                              ),
                              child: Icon(
                                ticket.icon,
                                color: ticket.neonAccent,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              ticket.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ticket.subtitle,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: ticket.neonAccent,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF07090E),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.bolt_rounded,
                                    color: ticket.neonAccent,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      ticket.directorNote,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFCBD5E1),
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: tickets.map((t) {
              final active = selectedIds.contains(t.id);
              return FilterChip(
                selected: active,
                onSelected: (_) => onToggleTicket(t.id),
                backgroundColor: const Color(0xFF0B0E17),
                selectedColor: t.neonAccent.withOpacity(0.22),
                checkmarkColor: t.neonAccent,
                side: BorderSide(
                  color: active ? t.neonAccent : const Color(0xFF334155),
                ),
                label: Text(
                  t.id.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: active ? t.neonAccent : const Color(0xFF94A3B8),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalCredentialsStage() {
    final currentYear = DateTime.now().year;
    final calculatedAge = currentYear - _selectedBirthYear;
    final is18Plus = calculatedAge >= 18;
    final chosenArchetype = resolveAvatarArchetype(_selectedArchetypeId);

    return SingleChildScrollView(
      key: const ValueKey<String>('step_credentials'),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ActLikeItBrandCenterpiece(
            height: 98,
            compact: true,
          ),
          const SizedBox(height: 12),
          const Text(
            'SELECT YOUR 2.5D CELL-SHADED ARCHETYPE & CREDENTIALS',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your 2.5D Boondocks-inspired avatar physically populates the Red Carpet and reflects inside the Silver Elevator doors.',
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF94A3B8),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          CustomPaint(
            foregroundPainter: _RedCarpetPerforatedTicketBorderPainter(
              borderColor: chosenArchetype.primaryInkColor,
              strokeWidth: 2.2,
              showPerforationLine: true,
            ),
            child: ClipPath(
              clipper: _RedCarpetTicketClipper(),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF0B0E17),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        BoondocksAvatarPortrait(
                          archetype: chosenArchetype,
                          size: 64,
                          isSelected: true,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chosenArchetype.roleBadge,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: chosenArchetype.primaryInkColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                chosenArchetype.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                chosenArchetype.catchphrase,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFFFDE68A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 66,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        itemCount: kFourteenAvatarArchetypes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final arch = kFourteenAvatarArchetypes[index];
                          final selected = arch.id == _selectedArchetypeId;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedArchetypeId = arch.id;
                              });
                            },
                            child: BoondocksAvatarPortrait(
                              archetype: arch,
                              size: selected ? 62 : 52,
                              isSelected: selected,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0E17),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF06B6D4), width: 1.4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'STAGE HANDLE (PUBLIC USERNAME)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF06B6D4),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g., MethodMaverick',
                    hintStyle: const TextStyle(color: Color(0xFF64748B)),
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      color: Color(0xFF06B6D4),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF07090E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1E293B)),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'BIRTH YEAR (18+ VAULT GATE)',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: is18Plus
                            ? const Color(0xFF10B981).withOpacity(0.18)
                            : const Color(0xFFEF4444).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: is18Plus
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                      child: Text(
                        is18Plus
                            ? '18+ AFTER-HOURS CLEARED ($_selectedBirthYear)'
                            : 'UNDER 18 · VAULT LOCKED ($_selectedBirthYear)',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: is18Plus
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildStep3BirthYearPickerRow(currentYear, is18Plus),
                const Divider(color: Color(0xFF1E293B), height: 24),
                _buildSummaryRow(
                  label: 'STAMPED ERAS',
                  value: _selectedEras.join(' · '),
                  accent: const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 10),
                _buildSummaryRow(
                  label: 'ACTING STRENGTHS',
                  value: _selectedStrengths.join(' · '),
                  accent: const Color(0xFFA855F7),
                ),
                const SizedBox(height: 10),
                _buildSummaryRow(
                  label: 'STARTER AI TELEMETRICS BALANCE',
                  value: '${AuthService.instance.aiTokenBalance} AI TOKENS',
                  accent: const Color(0xFF10B981),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    required Color accent,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3BirthYearPickerRow(int currentYear, bool is18Plus) {
    final minYear = 1945;
    final maxYear = currentYear - 13;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF07090E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'SELECT BIRTH YEAR',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF94A3B8),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: _selectedBirthYear > minYear
                    ? () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedBirthYear -= 1);
                      }
                    : null,
                icon: const Icon(
                  Icons.remove_circle_outline_rounded,
                  color: Color(0xFFF59E0B),
                ),
              ),
              GestureDetector(
                onTap: () => _openStep3YearWheelModal(minYear, maxYear),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0E17),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFF59E0B),
                      width: 1.4,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_selectedBirthYear',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.unfold_more_rounded,
                        size: 15,
                        color: Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: _selectedBirthYear < maxYear
                    ? () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedBirthYear += 1);
                      }
                    : null,
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openStep3YearWheelModal(int minYear, int maxYear) async {
    final years = List<int>.generate(
      maxYear - minYear + 1,
      (i) => maxYear - i,
    );
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0B0E17),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: 320,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'SELECT BIRTH YEAR (18+ VAULT GATE)',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ),
                const Divider(color: Color(0xFF1E293B), height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: years.length,
                    itemBuilder: (context, index) {
                      final yr = years[index];
                      final selected = yr == _selectedBirthYear;
                      return ListTile(
                        dense: true,
                        selected: selected,
                        selectedTileColor:
                            const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        title: Text(
                          '$yr',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 15,
                            fontWeight:
                                selected ? FontWeight.w900 : FontWeight.w600,
                            color: selected
                                ? const Color(0xFFF59E0B)
                                : Colors.white,
                          ),
                        ),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedBirthYear = yr);
                          Navigator.of(ctx).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActionFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      child: Row(
        children: [
          if (_activeStep > 0) ...[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF334155)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 15,
                ),
              ),
              onPressed: _isSaving
                  ? null
                  : () {
                      setState(() {
                        _activeStep -= 1;
                      });
                    },
              child: const Text(
                'BACK',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _activeStep < 2
                    ? const Color(0xFF06B6D4)
                    : const Color(0xFFF59E0B),
                foregroundColor: const Color(0xFF07090E),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSaving
                  ? null
                  : () {
                      if (_activeStep < 2) {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _activeStep += 1;
                        });
                      } else {
                        _completeRedCarpetOnboarding();
                      }
                    },
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Color(0xFF07090E),
                      ),
                    )
                  : Icon(
                      _activeStep < 2
                          ? Icons.arrow_forward_rounded
                          : Icons.movie_filter_rounded,
                    ),
              label: Text(
                _activeStep < 2
                    ? 'NEXT RED CARPET REEL'
                    : 'SAVE PROFILE & ENTER MARQUEE',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom clipper that cuts authentic semicircular cinema ticket notches into
/// the left and right edges of each Red Carpet questionnaire card.
class _RedCarpetTicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const cornerRadius = 18.0;
    const notchRadius = 14.0;
    final notchCenterY = size.height * 0.68;
    final path = Path()
      ..moveTo(cornerRadius, 0)
      ..lineTo(size.width - cornerRadius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, cornerRadius)
      ..lineTo(size.width, notchCenterY - notchRadius)
      ..arcToPoint(
        Offset(size.width, notchCenterY + notchRadius),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      )
      ..lineTo(size.width, size.height - cornerRadius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - cornerRadius,
        size.height,
      )
      ..lineTo(cornerRadius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - cornerRadius)
      ..lineTo(0, notchCenterY + notchRadius)
      ..arcToPoint(
        Offset(0, notchCenterY - notchRadius),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      )
      ..lineTo(0, cornerRadius)
      ..quadraticBezierTo(0, 0, cornerRadius, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Paints the neon border along the notched [_RedCarpetTicketClipper] path and
/// draws a horizontal dashed perforation line between the semicircular notches.
class _RedCarpetPerforatedTicketBorderPainter extends CustomPainter {
  final Color borderColor;
  final double strokeWidth;
  final bool showPerforationLine;

  const _RedCarpetPerforatedTicketBorderPainter({
    required this.borderColor,
    required this.strokeWidth,
    this.showPerforationLine = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _RedCarpetTicketClipper().getClip(size);
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );

    if (showPerforationLine) {
      final notchY = size.height * 0.68;
      final dashPaint = Paint()
        ..color = borderColor.withValues(alpha: 0.45)
        ..strokeWidth = 1.4;
      double x = 18.0;
      while (x < size.width - 18.0) {
        canvas.drawLine(Offset(x, notchY), Offset(x + 6.0, notchY), dashPaint);
        x += 12.0;
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant _RedCarpetPerforatedTicketBorderPainter oldDelegate,
  ) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Renders slow-moving Cyan, Purple, and Amber neon spotlights across the
/// `#07090E` dark obsidian backstage canvas.
class _RedCarpetSpotlightPainter extends CustomPainter {
  final double progress;

  const _RedCarpetSpotlightPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final theta = progress * math.pi * 2;

    final cyanCenter = Offset(
      size.width * (0.22 + 0.16 * math.sin(theta)),
      size.height * (0.20 + 0.10 * math.cos(theta)),
    );
    final purpleCenter = Offset(
      size.width * (0.78 - 0.18 * math.cos(theta * 0.8)),
      size.height * (0.52 + 0.12 * math.sin(theta * 0.8)),
    );
    final amberCenter = Offset(
      size.width * (0.45 + 0.20 * math.sin(theta * 0.6)),
      size.height * (0.84 - 0.08 * math.cos(theta * 0.6)),
    );

    _drawGlow(
      canvas,
      center: cyanCenter,
      radius: size.width * 0.68,
      color: const Color(0xFF06B6D4).withOpacity(0.16),
    );
    _drawGlow(
      canvas,
      center: purpleCenter,
      radius: size.width * 0.72,
      color: const Color(0xFFA855F7).withOpacity(0.15),
    );
    _drawGlow(
      canvas,
      center: amberCenter,
      radius: size.width * 0.65,
      color: const Color(0xFFF59E0B).withOpacity(0.14),
    );
  }

  void _drawGlow(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[color, Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RedCarpetSpotlightPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
