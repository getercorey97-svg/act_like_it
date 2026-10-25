import 'dart:math' as math;
import 'dart:ui' show ImageFilter, MaskFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/auth_service.dart';
import 'intro_cinematic.dart';
import 'living_25d_animation_engine.dart';
import 'premiere_red_carpet_painters.dart';

export 'living_25d_animation_engine.dart';

// ============================================================================
// INTERACTIVE 3D HOLOGRAPHIC MARQUEE ("ACT LIKE IT")
// ============================================================================

class Interactive3DHolographicMarquee extends StatefulWidget {
  final double phase;
  final VoidCallback onPaparazziFrenzy;
  final Widget? trailingControls;

  const Interactive3DHolographicMarquee({
    super.key,
    required this.phase,
    required this.onPaparazziFrenzy,
    this.trailingControls,
  });

  @override
  State<Interactive3DHolographicMarquee> createState() =>
      _Interactive3DHolographicMarqueeState();
}

class _Interactive3DHolographicMarqueeState
    extends State<Interactive3DHolographicMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleMarqueeTap() {
    widget.onPaparazziFrenzy();
    _bounceController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleMarqueeTap,
      child: AnimatedBuilder(
        animation: _bounceController,
        builder: (context, _) {
          final t = _bounceController.value;
          final elasticScale = t == 0.0
              ? 1.0
              : 1.0 + math.sin(t * math.pi * 2.5) * 0.09 * (1.0 - t);
          final tiltX =
              t == 0.0 ? 0.0 : math.sin(t * math.pi * 2) * 0.16 * (1.0 - t);

          final matrix = Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateX(tiltX)
            ..scale(elasticScale, elasticScale, 1.0);

          return Transform(
            alignment: Alignment.center,
            transform: matrix,
            child: SizedBox(
              height: 158,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RepaintBoundary(
                    child: CustomPaint(
                      painter: _VolumetricSearchlightsPainter(
                        phase: widget.phase,
                      ),
                    ),
                  ),
                  RepaintBoundary(
                    child: CustomPaint(
                      foregroundPainter: _MarqueeFilamentBulbsPainter(
                        phase: widget.phase,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ActLikeItBrandLogo(
                              heroTag: kActLikeItBrandLogoHeroTag,
                              height: 150,
                              compact: true,
                              subtitle:
                                  '2.5D GRAND PREMIERE SOUNDSTAGE · TAP FOR FLASH FRENZY',
                              onTap: _handleMarqueeTap,
                            ),
                            if (widget.trailingControls != null)
                              Positioned(
                                top: 8,
                                right: 10,
                                child: widget.trailingControls!,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VolumetricSearchlightsPainter extends CustomPainter {
  final double phase;

  const _VolumetricSearchlightsPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final leftAngle = math.sin(phase * 0.85) * 0.42 + 0.35;
    final rightAngle = math.cos(phase * 0.95) * 0.42 - 0.35;

    _drawSearchlightCone(
      canvas,
      size,
      origin: Offset(size.width * 0.16, size.height),
      angle: leftAngle,
      color: const Color(0x66F5DEB3),
    );
    _drawSearchlightCone(
      canvas,
      size,
      origin: Offset(size.width * 0.84, size.height),
      angle: rightAngle,
      color: const Color(0x550CB6D4),
    );
  }

  void _drawSearchlightCone(
    Canvas canvas,
    Size size, {
    required Offset origin,
    required double angle,
    required Color color,
  }) {
    final length = size.height * 1.65;
    final topCenter = Offset(
      origin.dx + math.sin(angle) * length,
      origin.dy - math.cos(angle) * length,
    );
    const spread = 44.0;
    final path = Path()
      ..moveTo(origin.dx - 6, origin.dy)
      ..lineTo(topCenter.dx - spread, topCenter.dy)
      ..lineTo(topCenter.dx + spread, topCenter.dy)
      ..lineTo(origin.dx + 6, origin.dy)
      ..close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          color,
          color.withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _VolumetricSearchlightsPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _MarqueeFilamentBulbsPainter extends CustomPainter {
  final double phase;

  const _MarqueeFilamentBulbsPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 24 || size.height <= 28) return;
    final rect = Rect.fromLTWH(10, 12, size.width - 20, size.height - 24);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(20));
    final metrics = (Path()..addRRect(rrect)).computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    const int bulbCount = 30;
    final chaserStep = ((phase / (2 * math.pi)) * bulbCount);

    for (int i = 0; i < bulbCount; i++) {
      final distance = (metric.length / bulbCount) * i;
      final tangent = metric.getTangentForOffset(distance);
      if (tangent == null) continue;

      final pos = tangent.position;
      final wave = (math.sin((i - chaserStep) * 0.65) + 1.0) * 0.5;
      final isHot = wave > 0.55;

      final glowPaint = Paint()
        ..color = (isHot ? const Color(0xFFFDE68A) : const Color(0xFFF59E0B))
            .withValues(alpha: 0.25 + 0.65 * wave)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(pos, isHot ? 4.8 : 3.2, glowPaint);

      final corePaint = Paint()
        ..color = isHot ? Colors.white : const Color(0xFFFBBF24);
      canvas.drawCircle(pos, isHot ? 2.3 : 1.6, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MarqueeFilamentBulbsPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

// ============================================================================
// 3D TOUCH-TILT PHYSICS & MECHANICAL DOOR WRAPPER (`Interactive3DDoorCard`)
// ============================================================================

class Interactive3DDoorCard extends StatefulWidget {
  final ScrollController scrollController;
  final int index;
  final Color specularColor;
  final BorderRadius borderRadius;
  final CustomClipper<Path>? customClipper;
  final VoidCallback onTap;
  final Widget Function(BuildContext context, bool isPressed, double pressValue)
      builder;

  const Interactive3DDoorCard({
    super.key,
    required this.scrollController,
    required this.index,
    required this.specularColor,
    required this.onTap,
    required this.builder,
    this.borderRadius = const BorderRadius.all(Radius.circular(26)),
    this.customClipper,
  });

  @override
  State<Interactive3DDoorCard> createState() => _Interactive3DDoorCardState();
}

class _Interactive3DDoorCardState extends State<Interactive3DDoorCard>
    with SingleTickerProviderStateMixin {
  Offset _normalizedTouch = Offset.zero;
  Alignment _specularAlignment = Alignment.topLeft;
  bool _isTouching = false;

  late final AnimationController _activationController;

  @override
  void initState() {
    super.initState();
    _activationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _activationController.dispose();
    super.dispose();
  }

  void _updateTouchTilt(Offset localPosition, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final nx = ((localPosition.dx / size.width) * 2.0 - 1.0).clamp(-1.0, 1.0);
    final ny = ((localPosition.dy / size.height) * 2.0 - 1.0).clamp(-1.0, 1.0);
    setState(() {
      _isTouching = true;
      _normalizedTouch = Offset(nx, ny);
      _specularAlignment = Alignment(nx, ny);
    });
  }

  void _resetTouchTilt() {
    if (!mounted) return;
    setState(() {
      _isTouching = false;
      _normalizedTouch = Offset.zero;
    });
  }

  Future<void> _handleDoorActivate() async {
    HapticFeedback.mediumImpact();
    setState(() => _isTouching = true);
    await _activationController.forward();
    await _activationController.reverse();
    if (!mounted) return;
    _resetTouchTilt();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.scrollController,
        _activationController,
      ]),
      builder: (context, _) {
        double scrollCurveRotateX = 0.0;
        double scrollScale = 1.0;

        if (widget.scrollController.hasClients) {
          final scrollOffset = widget.scrollController.offset;
          final expectedItemTop = 210.0 + (widget.index * 195.0);
          final viewportCenter = scrollOffset + 340.0;
          final deltaFromCenter =
              ((expectedItemTop - viewportCenter) / 480.0).clamp(-1.0, 1.0);
          scrollCurveRotateX = deltaFromCenter * -0.09;
          scrollScale = 1.0 - (deltaFromCenter.abs() * 0.035);
        }

        const double maxTiltRadians = 0.21;
        final double touchRotateX = -_normalizedTouch.dy * maxTiltRadians;
        final double touchRotateY = _normalizedTouch.dx * maxTiltRadians;
        final double pressScale = 1.0 -
            (_activationController.value * 0.04) +
            (_isTouching ? 0.015 : 0.0);

        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..rotateX(scrollCurveRotateX + touchRotateX)
          ..rotateY(touchRotateY)
          ..scale(scrollScale * pressScale, scrollScale * pressScale, 1.0);

        return LayoutBuilder(
          builder: (context, constraints) {
            final safeWidth =
                constraints.maxWidth.isFinite ? constraints.maxWidth : 360.0;
            final cardSize = Size(safeWidth, 178);
            Widget cardBody = Stack(
              children: [
                widget.builder(
                  context,
                  _isTouching || _activationController.isAnimating,
                  _activationController.value,
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: _isTouching ? 1.0 : 0.32,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: widget.borderRadius,
                          gradient: RadialGradient(
                            center: _specularAlignment,
                            radius: 0.95,
                            colors: [
                              Colors.white.withValues(
                                alpha: _isTouching ? 0.24 : 0.08,
                              ),
                              widget.specularColor.withValues(
                                alpha: _isTouching ? 0.18 : 0.04,
                              ),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.42, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );

            if (widget.customClipper != null) {
              cardBody = ClipPath(
                clipper: widget.customClipper,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: cardBody,
                ),
              );
            } else {
              cardBody = ClipRRect(
                borderRadius: widget.borderRadius,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: cardBody,
                ),
              );
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanDown: (d) => _updateTouchTilt(d.localPosition, cardSize),
              onPanUpdate: (d) => _updateTouchTilt(d.localPosition, cardSize),
              onPanEnd: (_) => _resetTouchTilt(),
              onPanCancel: _resetTouchTilt,
              onTap: _handleDoorActivate,
              child: Transform(
                alignment: Alignment.center,
                transform: matrix,
                child: cardBody,
              ),
            );
          },
        );
      },
    );
  }
}

// ============================================================================
// SIX BESPOKE ARCHITECTURAL DOORS (NO GENERIC BOXES)
// ============================================================================

class BespokePremiereDoorsList {
  static List<Widget> buildSixDoors({
    required BuildContext context,
    required ScrollController scrollController,
    required double phase,
    required int careerWins,
    required double averageScore,
    required VoidCallback onPremiereDoorTap,
    required VoidCallback onAirlockJoinTap,
    required VoidCallback onAfterHoursTap,
    required VoidCallback onTrophyVaultTap,
    required VoidCallback onCameraViewfinderTap,
    required VoidCallback onBoxOfficeVaultTap,
    VoidCallback? onCuttingRoomElevatorTap,
  }) {
    return [
      _buildPersistentFirstPersonArchetypeCrowdBar(phase: phase),
      const SizedBox(height: 16),
      const Living25DHeroCharactersTrioSection(),
      const SizedBox(height: 18),
      Interactive3DDoorCard(
        scrollController: scrollController,
        index: 0,
        specularColor: const Color(0xFFF5DEB3),
        onTap: onPremiereDoorTap,
        builder: (context, isPressed, pressValue) => _buildPremiereClapperDoor(
          phase: phase,
          isPressed: isPressed,
          pressValue: pressValue,
        ),
      ),
      const SizedBox(height: 22),
      Interactive3DDoorCard(
        scrollController: scrollController,
        index: 1,
        specularColor: const Color(0xFF0CB6D4),
        onTap: onAirlockJoinTap,
        builder: (context, isPressed, pressValue) =>
            _buildSoundstageAirlockDoor(
          phase: phase,
          isPressed: isPressed,
        ),
      ),
      const SizedBox(height: 22),
      Interactive3DDoorCard(
        scrollController: scrollController,
        index: 2,
        specularColor: const Color(0xFFE11342),
        onTap: onAfterHoursTap,
        builder: (context, isPressed, pressValue) => _buildVelvetSpeakeasyDoor(
          phase: phase,
          isPressed: isPressed,
        ),
      ),
      const SizedBox(height: 22),
      if (onCuttingRoomElevatorTap != null) ...[
        Interactive3DDoorCard(
          scrollController: scrollController,
          index: 3,
          specularColor: const Color(0xFFF5DEB3),
          onTap: onCuttingRoomElevatorTap,
          builder: (context, isPressed, pressValue) =>
              _buildSilverElevatorCuttingRoomDoor(
            phase: phase,
            isPressed: isPressed,
          ),
        ),
        const SizedBox(height: 22),
      ],
      Interactive3DDoorCard(
        scrollController: scrollController,
        index: 4,
        specularColor: const Color(0xFFF5DEB3),
        onTap: onTrophyVaultTap,
        builder: (context, isPressed, pressValue) =>
            _buildAcademyTrophyVaultDoor(
          phase: phase,
          careerWins: careerWins,
          averageScore: averageScore,
        ),
      ),
      const SizedBox(height: 22),
      Interactive3DDoorCard(
        scrollController: scrollController,
        index: 5,
        specularColor: const Color(0xFF0CB6D4),
        onTap: onCameraViewfinderTap,
        builder: (context, isPressed, pressValue) =>
            _buildCameraViewfinderDoor(
          phase: phase,
        ),
      ),
      const SizedBox(height: 22),
      Interactive3DDoorCard(
        scrollController: scrollController,
        index: 6,
        specularColor: const Color(0xFFF5DEB3),
        customClipper: BoxOfficeTicketNotchClipper(),
        onTap: onBoxOfficeVaultTap,
        builder: (context, isPressed, pressValue) => _buildBoxOfficeVaultDoor(
          phase: phase,
        ),
      ),
    ];
  }

  static Widget _buildPersistentFirstPersonArchetypeCrowdBar({
    required double phase,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFFFD700),
                size: 15,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'RED CARPET ENTOURAGE · TAP ANY 2.5D STAR FOR SPOTLIGHT BIO',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: kFourteenAvatarArchetypes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final arch = kFourteenAvatarArchetypes[index];
              final isEquipped =
                  AuthService.instance.currentProfile?.avatarArchetypeId ==
                      arch.id;
              return GestureDetector(
                onTap: () => showBoondocksCharacterSpotlightModal(
                  context,
                  arch,
                ),
                child: SizedBox(
                  width: 88,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BoondocksCharacterRig(
                        archetype: arch,
                        size: 72,
                        isSelected: isEquipped,
                        externalPhase: phase + index * 0.45,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xEB07090E),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isEquipped
                                ? const Color(0xFFFFD700)
                                : arch.primaryInkColor,
                            width: isEquipped ? 1.8 : 1.2,
                          ),
                        ),
                        child: Text(
                          arch.name.replaceFirst('The ', ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
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
    );
  }

  static Widget _buildSilverElevatorCuttingRoomDoor({
    required double phase,
    required bool isPressed,
  }) {
    final neonPulse = 0.72 + 0.28 * math.sin(phase * 4.5);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xF01E293B),
            Color(0xF50F172A),
            Color(0xF01E1B4B),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 2.6,
        ),
        boxShadow: <BoxShadow>[
          const BoxShadow(
            color: Color(0xFF05070B),
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFFEC4899).withValues(alpha: 0.34 * neonPulse),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF07090E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEC4899),
                width: 2.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.elevator_rounded,
                  color: Color(0xFFF9A8D4),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '★ THE CUTTING ROOM FLOOR · SILVER ELEVATOR ★',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.chakraPetch(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.3,
                      color: const Color(0xFFF9A8D4),
                      shadows: const <Shadow>[
                        Shadow(color: Color(0xFFEC4899), blurRadius: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 72,
                child: Living25DAnimatedPropRig(
                  propType: Living25DPropCardType.cuttingRoomReelShears,
                  externalPhase: phase,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VELVET ROPE · 2 SECURITY GUARDS · FIRST-PERSON POV',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF67E8F9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter The Cutting Room Floor',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 26,
                        letterSpacing: 1.4,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Step into the VIP Silver Elevator to watch, rate, and roast top audition reels.',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        height: 1.35,
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => showBoondocksCharacterSpotlightModal(
                    ctx,
                    kFourteenAvatarArchetypes[5],
                  ),
                  child: BoondocksCharacterRig(
                    archetype: kFourteenAvatarArchetypes[5],
                    size: 56,
                    isSelected: true,
                    externalPhase: phase,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildPremiereClapperDoor({
    required double phase,
    required bool isPressed,
    required double pressValue,
  }) {
    final openAngle = -0.14 * (1.0 - pressValue) * (isPressed ? 0.15 : 1.0);
    final pulse = 0.65 + 0.35 * math.sin(phase * 2.4);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xF2520002),
            Color(0xF807090E),
            Color(0xE6291507),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFF5DEB3),
          width: 2.5,
        ),
        boxShadow: [
          const BoxShadow(
            color: Color(0xFF05070B),
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFFE11342).withValues(alpha: 0.40 * pulse),
            blurRadius: 28,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Transform.rotate(
            angle: openAngle,
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              height: 26,
              child: CustomPaint(
                painter: _HollywoodClapperboardBarPainter(
                  accentColor: const Color(0xFFF5DEB3),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Living25DAnimatedPropRig(
                    propType: Living25DPropCardType.luxuryHollywoodClapperboard,
                    externalPhase: phase,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF10B981),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: pulse),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'READY TO ROLL · STAGE A',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                              color: Color(0xFFF5DEB3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CREATE LOBBY / QUICK PLAY',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 28,
                          color: Colors.white,
                          letterSpacing: 1.8,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Snap the clapperboard, dial in your Director\'s Call Sheet, and open a private soundstage for 2 to 8 stars.',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          height: 1.35,
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const SizedBox(
                  width: 66,
                  child: Living25DHeroCharacterRig(
                    characterType:
                        Living25DHeroCharacterType.ruthlessCastingDirector,
                    showCaptionBadge: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSoundstageAirlockDoor({
    required double phase,
    required bool isPressed,
  }) {
    final onAirPulse = (math.sin(phase * 3.0) + 1.0) * 0.5;
    final capsuleColor = Color.lerp(
      const Color(0xFF0CB6D4),
      const Color(0xFFE11342),
      onAirPulse,
    )!;

    return CustomPaint(
      foregroundPainter: _SoundstageAirlockPainter(phase: phase),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 26),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xF50B1926),
              Color(0xF807090E),
            ],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color(0xFF0CB6D4),
            width: 2.5,
          ),
          boxShadow: [
            const BoxShadow(
              color: Color(0xFF05070B),
              offset: Offset(6, 6),
              blurRadius: 0,
            ),
            BoxShadow(
              color: const Color(0xFF0CB6D4).withValues(alpha: 0.30),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: capsuleColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: capsuleColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: capsuleColor.withValues(alpha: 0.45),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sensors_rounded,
                          size: 15, color: capsuleColor),
                      const SizedBox(width: 6),
                      Text(
                        'ON AIR · LIVE ENSEMBLE',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.dialpad_rounded,
                  color: Color(0xFF0CB6D4),
                  size: 26,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'JOIN 6-DIGIT ROOM',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Punch in your castmate\'s 6-digit backstage pass and step directly under the live studio lights.',
                        style: GoogleFonts.montserrat(
                          fontSize: 12.5,
                          height: 1.35,
                          color: const Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const SizedBox(
                  width: 68,
                  child: Living25DHeroCharacterRig(
                    characterType:
                        Living25DHeroCharacterType.screenTestRivalsDuel,
                    showCaptionBadge: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 22,
              width: double.infinity,
              child: CustomPaint(
                painter: _AudioEqualizerWavePainter(phase: phase),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildVelvetSpeakeasyDoor({
    required double phase,
    required bool isPressed,
  }) {
    final flickerWave = math.sin(phase * 7.0) * math.cos(phase * 13.0);
    final neonOpacity = (0.82 + 0.18 * flickerWave).clamp(0.45, 1.0);
    final neonColor = const Color(0xFFE11342).withValues(alpha: neonOpacity);

    return CustomPaint(
      foregroundPainter: _VelvetSpeakeasyCurtainPainter(phase: phase),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xF2520002),
              Color(0xF807090E),
            ],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: neonColor,
            width: 2.5,
          ),
          boxShadow: [
            const BoxShadow(
              color: Color(0xFF05070B),
              offset: Offset(6, 6),
              blurRadius: 0,
            ),
            BoxShadow(
              color: neonColor.withValues(alpha: 0.35),
              blurRadius: 26,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 68,
              child: Living25DAnimatedPropRig(
                propType: Living25DPropCardType.speakeasyDareWheel,
                externalPhase: phase,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Midnight Speakeasy Lounge',
                    style: GoogleFonts.satisfy(
                      fontSize: 22,
                      color: const Color(0xFFF5DEB3),
                      shadows: [
                        Shadow(
                          color: neonColor,
                          blurRadius: 14,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '18+ After-Hours',
                    style: GoogleFonts.montserrat(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Guarded by Don Corleone Jr. (The Mob Boss) — unhook the crimson rope for uncut scripts & cigar-smoke lounge twists.',
                    style: GoogleFonts.montserrat(
                      fontSize: 12.5,
                      height: 1.35,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const SizedBox(
              width: 66,
              child: Living25DHeroCharacterRig(
                characterType:
                    Living25DHeroCharacterType.undercoverSpeakeasyImproviser,
                showCaptionBadge: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildAcademyTrophyVaultDoor({
    required double phase,
    required int careerWins,
    required double averageScore,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xF01C1608),
            Color(0xF807090E),
            Color(0xF0071A14),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFF5DEB3),
          width: 2.5,
        ),
        boxShadow: [
          const BoxShadow(
            color: Color(0xFF05070B),
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFFF5DEB3).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Living25DAnimatedPropRig(
              propType: Living25DPropCardType.oscarTrophyVipBoxOffice,
              externalPhase: phase,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$careerWins STATUETTES · ${averageScore.toStringAsFixed(1)} CAREER RATING',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: Color(0xFFF5DEB3),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Career Trophy Room',
                  style: GoogleFonts.cinzel(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Enter the Academy archive to review your Golden Statuettes, standing ovations, and critic verdicts.',
                  style: GoogleFonts.montserrat(
                    fontSize: 12.5,
                    height: 1.35,
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => showBoondocksCharacterSpotlightModal(
                ctx,
                kFourteenAvatarArchetypes[4],
              ),
              child: BoondocksCharacterRig(
                archetype: kFourteenAvatarArchetypes[4],
                size: 56,
                isSelected: true,
                externalPhase: phase,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCameraViewfinderDoor({required double phase}) {
    final recBlink = math.sin(phase * 4.0) > -0.2;
    final seconds =
        ((phase / (2 * math.pi)) * 59).floor().toString().padLeft(2, '0');

    return CustomPaint(
      foregroundPainter: _ViewfinderFilmSprocketsPainter(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xF507090E),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color(0xFF0CB6D4),
            width: 2.4,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF05070B),
              offset: Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: recBlink ? 1.0 : 0.2,
                  child: const Icon(
                    Icons.fiber_manual_record_rounded,
                    color: Color(0xFFE11342),
                    size: 14,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'REC 00:00:$seconds:18 · ISO 800 · 24FPS · BAT 99%',
                      style: GoogleFonts.courierPrime(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE11342),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 68,
                  child: Living25DAnimatedPropRig(
                    propType: Living25DPropCardType.writersRoomTypewriter,
                    externalPhase: phase,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '[ HOW TO PLAY / DIRECTOR\'S GUIDE ]',
                        style: GoogleFonts.courierPrime(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Interactive storyboards covering Pre-Roll, AI Telemetrics, Ensemble Voting, and Viral Encore reels.',
                        style: GoogleFonts.courierPrime(
                          fontSize: 12.5,
                          height: 1.35,
                          color: const Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Builder(
                  builder: (ctx) => GestureDetector(
                    onTap: () => showBoondocksCharacterSpotlightModal(
                      ctx,
                      kFourteenAvatarArchetypes[13],
                    ),
                    child: BoondocksCharacterRig(
                      archetype: kFourteenAvatarArchetypes[13],
                      size: 56,
                      isSelected: true,
                      externalPhase: phase,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildBoxOfficeVaultDoor({required double phase}) {
    return CustomPaint(
      foregroundPainter: _ArtDecoFiligreePainter(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xF0520002),
              Color(0xF807090E),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFF5DEB3),
            width: 2.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF05070B),
              offset: Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 68,
              child: Living25DAnimatedPropRig(
                propType: Living25DPropCardType.writersRoomTypewriter,
                externalPhase: phase,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ADMIT ONE · VINTAGE BOX OFFICE ROTUNDA',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Color(0xFFF5DEB3),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'The Scene Vault',
                    style: GoogleFonts.limelight(
                      fontSize: 25,
                      color: Colors.white,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Step up to the brass window and browse perforated reels from 1970–1999, 2000–2026, and Cult Classics.',
                    style: GoogleFonts.montserrat(
                      fontSize: 12.5,
                      height: 1.35,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Builder(
              builder: (ctx) => GestureDetector(
                onTap: () => showBoondocksCharacterSpotlightModal(
                  ctx,
                  kFourteenAvatarArchetypes[3],
                ),
                child: BoondocksCharacterRig(
                  archetype: kFourteenAvatarArchetypes[3],
                  size: 56,
                  isSelected: true,
                  externalPhase: phase,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HollywoodClapperboardBarPainter extends CustomPainter {
  final Color accentColor;

  const _HollywoodClapperboardBarPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF090C14);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Offset.zero & size,
        topLeft: const Radius.circular(24),
        topRight: const Radius.circular(24),
      ),
      bgPaint,
    );

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndCorners(
        Offset.zero & size,
        topLeft: const Radius.circular(24),
        topRight: const Radius.circular(24),
      ),
    );

    final stripePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    const double stripeWidth = 22.0;
    for (double x = -size.height;
        x < size.width + size.height;
        x += stripeWidth * 2) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + stripeWidth, size.height)
        ..lineTo(x + stripeWidth + 16, 0)
        ..lineTo(x + 16, 0)
        ..close();
      canvas.drawPath(path, stripePaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HollywoodClapperboardBarPainter oldDelegate) =>
      false;
}

class _SoundstageAirlockPainter extends CustomPainter {
  final double phase;

  const _SoundstageAirlockPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final rivetPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.fill;

    const offsets = [
      Offset(12, 12),
      Offset(12, 48),
      Offset(12, 84),
    ];
    for (final o in offsets) {
      canvas.drawCircle(o, 2.4, rivetPaint);
      canvas.drawCircle(Offset(size.width - o.dx, o.dy), 2.4, rivetPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SoundstageAirlockPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _AudioEqualizerWavePainter extends CustomPainter {
  final double phase;

  const _AudioEqualizerWavePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    const int barCount = 12;
    const double spacing = 6.0;
    final double safeW = math.max(2.0, size.width);
    final double safeH = math.max(4.0, size.height);
    final double barWidth =
        ((safeW - (spacing * (barCount - 1))) / barCount).clamp(2.0, safeW);

    for (int i = 0; i < barCount; i++) {
      final wave = (math.sin(phase * 3.2 + i * 0.75) + 1.0) * 0.5;
      final barHeight = (4.0 + wave * (safeH - 4.0)).clamp(4.0, safeH);
      final left = i * (barWidth + spacing);
      final top = size.height - barHeight;

      final paint = Paint()
        ..color = Color.lerp(
          const Color(0xFF06B6D4),
          const Color(0xFFE11D48),
          wave,
        )!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barWidth, barHeight),
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AudioEqualizerWavePainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _VelvetSpeakeasyCurtainPainter extends CustomPainter {
  final double phase;

  const _VelvetSpeakeasyCurtainPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final drapePaint = Paint()
      ..color = const Color(0x669F1239)
      ..style = PaintingStyle.fill;

    final path = Path()..moveTo(0, 0);
    const int scallops = 6;
    final double segW = size.width / scallops;
    for (int i = 0; i < scallops; i++) {
      final startX = i * segW;
      path.quadraticBezierTo(
        startX + segW * 0.5,
        18.0 + math.sin(phase + i) * 2.5,
        startX + segW,
        0,
      );
    }
    path.close();
    canvas.drawPath(path, drapePaint);

    final brassHookPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    for (int i = 1; i < scallops; i++) {
      canvas.drawCircle(Offset(i * segW, 4), 2.5, brassHookPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VelvetSpeakeasyCurtainPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _RotatingSunburstHaloPainter extends CustomPainter {
  final double phase;

  const _RotatingSunburstHaloPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final rayPaint = Paint()
      ..color = const Color(0x55FBBF24)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const int rays = 12;
    for (int i = 0; i < rays; i++) {
      final angle = phase + (i * (2 * math.pi / rays));
      final inner = Offset(
        center.dx + math.cos(angle) * 18,
        center.dy + math.sin(angle) * 18,
      );
      final outer = Offset(
        center.dx + math.cos(angle) * 32,
        center.dy + math.sin(angle) * 32,
      );
      canvas.drawLine(inner, outer, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RotatingSunburstHaloPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _ViewfinderFilmSprocketsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bracketPaint = Paint()
      ..color = const Color(0xFFA855F7)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    const double len = 16.0;
    const double pad = 10.0;
    canvas.drawLine(
        const Offset(pad, pad), const Offset(pad + len, pad), bracketPaint);
    canvas.drawLine(
        const Offset(pad, pad), const Offset(pad, pad + len), bracketPaint);
    canvas.drawLine(
      Offset(size.width - pad, pad),
      Offset(size.width - pad - len, pad),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(size.width - pad, pad),
      Offset(size.width - pad, pad + len),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(pad, size.height - pad),
      Offset(pad + len, size.height - pad),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(pad, size.height - pad),
      Offset(pad, size.height - pad - len),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(size.width - pad, size.height - pad),
      Offset(size.width - pad - len, size.height - pad),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(size.width - pad, size.height - pad),
      Offset(size.width - pad, size.height - pad - len),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArtDecoFiligreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x88F59E0B)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
