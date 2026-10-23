import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Canonical Hero tag used for the signature "ACT LIKE IT" brand emblem (`ulogo`)
/// gliding smoothly across the Opening Climax -> Sign Up / Sign In -> Main Dashboard.
const String kActLikeItBrandLogoHeroTag = 'act_like_it_ulogo';

/// Dedicated, reusable stateful brand emblem widget `ActLikeItBrandLogo` (`ulogo`)
/// with `Hero(tag: 'act_like_it_ulogo')` support:
/// 1. Crest Emblem: Twin split golden Comedy & Tragedy theater masks parting at
///    the center to reveal a glowing Soundstage Cyan (`#0CB6D4`) cybernetic camera
///    lens with a pulsing red `[REC]` indicator and mini angled clapperboard top bar.
/// 2. Sweeping 35mm Crimson Film Ribbon: Curved, cell-shaded crimson (`#E11342`)
///    and gold sprocketed 35mm film strip wrapping dynamically behind the typography.
/// 3. 3D Extruded Metallic Gold Typography ("ACT LIKE IT"): Stacked, slightly tilted
///    upper-case display lettering layered with a 3D deep-bronze/black extruded
///    drop-shadow stack, thick cell-shaded ink outline, and a continuous 3-second
///    24K Gold & Chrome `LinearGradient` `ShaderMask` specular light sweep.
/// 4. Interactive "Paparazzi Frenzy" Touch Response: Tapping triggers
///    `HapticFeedback.heavyImpact()`, an elastic 3D scale bounce (`Curves.elasticOut`),
///    and a burst of 6 four-point golden/cyan star lens flares around the emblem.
/// 5. Zero Clipping: All text and sub-labels are wrapped in `FittedBox` so nothing
///    ever truncates with `...` or bleeds outside the frame.
class ActLikeItBrandLogo extends StatefulWidget {
  final double height;
  final bool compact;
  final bool enableHero;
  final String heroTag;
  final String? subtitle;
  final VoidCallback? onTap;

  const ActLikeItBrandLogo({
    super.key,
    this.height = 142,
    this.compact = false,
    this.enableHero = true,
    this.heroTag = kActLikeItBrandLogoHeroTag,
    this.subtitle,
    this.onTap,
  });

  @override
  State<ActLikeItBrandLogo> createState() => _ActLikeItBrandLogoState();
}

class _ActLikeItBrandLogoState extends State<ActLikeItBrandLogo>
    with TickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final AnimationController _frenzyBounceController;
  Offset _tiltOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    // Continuous 3-second 24K Gold & Chrome specular light sweep
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Elastic 3D bounce + 6 four-point star lens flare burst on tap
    _frenzyBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _frenzyBounceController.dispose();
    super.dispose();
  }

  void _triggerPaparazziFrenzy() {
    HapticFeedback.heavyImpact();
    _frenzyBounceController.forward(from: 0.0);
    widget.onTap?.call();
  }

  void _updateTouchTilt(Offset localPos, Size boxSize) {
    if (boxSize.width <= 0 || boxSize.height <= 0) return;
    final dx = ((localPos.dx / boxSize.width) - 0.5) * 2.0;
    final dy = ((localPos.dy / boxSize.height) - 0.5) * 2.0;
    setState(() {
      _tiltOffset = Offset(dx.clamp(-1.0, 1.0), dy.clamp(-1.0, 1.0));
    });
  }

  Widget _buildEmblemCore(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite ? constraints.maxWidth : 340.0;
        final boxSize = Size(maxW, widget.height);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _updateTouchTilt(d.localPosition, boxSize),
          onPanUpdate: (d) => _updateTouchTilt(d.localPosition, boxSize),
          onPanEnd: (_) => setState(() => _tiltOffset = Offset.zero),
          onTapCancel: () => setState(() => _tiltOffset = Offset.zero),
          onTap: () {
            setState(() => _tiltOffset = Offset.zero);
            _triggerPaparazziFrenzy();
          },
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _shimmerController,
              _frenzyBounceController,
            ]),
            builder: (context, _) {
              final shimmerT = _shimmerController.value;
              final frenzyRaw = _frenzyBounceController.value;
              final elasticCurve = frenzyRaw > 0.0
                  ? Curves.elasticOut.transform(frenzyRaw.clamp(0.0, 1.0))
                  : 0.0;
              final bounceScale = frenzyRaw > 0.0
                  ? 1.0 + math.sin(frenzyRaw * math.pi) * 0.11 * (1.2 - elasticCurve * 0.5)
                  : 1.0;
              final flareIntensity = frenzyRaw > 0.0
                  ? math.sin(frenzyRaw * math.pi).clamp(0.0, 1.0)
                  : 0.0;

              final matrix = Matrix4.identity()
                ..setEntry(3, 2, 0.0016)
                ..rotateX(-_tiltOffset.dy * 0.14)
                ..rotateY(_tiltOffset.dx * 0.16)
                ..scale(bounceScale.clamp(0.88, 1.18));

              return Transform(
                alignment: Alignment.center,
                transform: matrix,
                child: SizedBox(
                  width: maxW,
                  height: widget.height,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // 1. Background 35mm Crimson Film Ribbon, Split Gold Masks,
                      //    Cyan Cybernetic [REC] Lens & Clapperboard Crest Painter
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ActLikeItUniqueBrandEmblemPainter(
                            shimmerProgress: shimmerT,
                            flareBurstProgress: flareIntensity,
                            compact: widget.compact,
                          ),
                        ),
                      ),

                      // 2. Optional `assets/app_logo.png` overlay (gracefully hidden
                      //    via errorBuilder if not bundled so vector emblem shines)
                      Positioned(
                        top: widget.compact ? 4 : 6,
                        child: SizedBox(
                          height: widget.height * 0.36,
                          child: Image.asset(
                            'assets/app_logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ),

                      // 3. 3D Extruded Metallic Gold Typography ("ACT LIKE IT")
                      Positioned(
                        left: 10,
                        right: 10,
                        bottom: widget.compact ? 4 : 8,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.rotate(
                              angle: -0.032,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Deep-Bronze & Obsidian 3D Extruded Drop-Shadow Stack
                                      Transform.translate(
                                        offset: const Offset(4.5, 5.0),
                                        child: Text(
                                          'ACT LIKE IT',
                                          style: GoogleFonts.anton(
                                            fontSize: widget.compact ? 38 : 48,
                                            letterSpacing: 3.4,
                                            height: 0.96,
                                            color: const Color(0xFF05070B),
                                          ),
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: const Offset(2.5, 3.0),
                                        child: Text(
                                          'ACT LIKE IT',
                                          style: GoogleFonts.anton(
                                            fontSize: widget.compact ? 38 : 48,
                                            letterSpacing: 3.4,
                                            height: 0.96,
                                            color: const Color(0xFF5D3A00),
                                          ),
                                        ),
                                      ),
                                      // Thick Cell-Shaded Black Ink Stroke Outline
                                      Text(
                                        'ACT LIKE IT',
                                        style: GoogleFonts.anton(
                                          fontSize: widget.compact ? 38 : 48,
                                          letterSpacing: 3.4,
                                          height: 0.96,
                                          foreground: Paint()
                                            ..style = PaintingStyle.stroke
                                            ..strokeWidth = 5.5
                                            ..strokeJoin = StrokeJoin.round
                                            ..color = const Color(0xFF05070B),
                                        ),
                                      ),
                                      // Continuous 3-Second 24K Gold & Chrome Specular Sweep
                                      ShaderMask(
                                        shaderCallback: (bounds) {
                                          final sweepPos = -1.2 + (shimmerT * 3.4);
                                          return LinearGradient(
                                            begin: Alignment(sweepPos - 0.55, -0.8),
                                            end: Alignment(sweepPos + 0.55, 0.8),
                                            colors: const <Color>[
                                              Color(0xFFFFB300),
                                              Color(0xFFFFE082),
                                              Colors.white,
                                              Color(0xFF84FFFF),
                                              Color(0xFFFFD600),
                                              Color(0xFFFF8F00),
                                            ],
                                            stops: const <double>[
                                              0.0,
                                              0.32,
                                              0.48,
                                              0.54,
                                              0.72,
                                              1.0,
                                            ],
                                          ).createShader(bounds);
                                        },
                                        child: Text(
                                          'ACT LIKE IT',
                                          style: GoogleFonts.anton(
                                            fontSize: widget.compact ? 38 : 48,
                                            letterSpacing: 3.4,
                                            height: 0.96,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (widget.subtitle != null || !widget.compact) ...[
                              const SizedBox(height: 3),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xE607090E),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(0xFFFFD600)
                                          .withValues(alpha: 0.75),
                                      width: 1.4,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFF1744),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        widget.subtitle ??
                                            'REC · 2.5D PREMIERE SOUNDSTAGE · TAP FOR FLASH FRENZY',
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.9,
                                          color: Color(0xFFF5DEB3),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final core = Material(
      type: MaterialType.transparency,
      child: _buildEmblemCore(context),
    );

    if (!widget.enableHero) return core;

    return Hero(
      tag: widget.heroTag,
      flightShuttleBuilder: (
        flightContext,
        animation,
        flightDirection,
        fromHeroContext,
        toHeroContext,
      ) {
        final Hero toHero = toHeroContext.widget as Hero;
        return Material(
          type: MaterialType.transparency,
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 340,
              height: widget.height,
              child: toHero.child,
            ),
          ),
        );
      },
      child: core,
    );
  }
}

/// Renders the vector/shader 3D crest emblem behind the "ACT LIKE IT" typography:
/// 1. Sweeping 35mm Crimson (`#E11342`) & Gold sprocketed film ribbon.
/// 2. Twin split golden Comedy & Tragedy theater masks parting at the center.
/// 3. Glowing Soundstage Cyan (`#0CB6D4`) cybernetic camera lens with a pulsing
///    red `[REC]` indicator and mini angled clapperboard top bar.
/// 4. 6 four-point golden/cyan star lens flares bursting on touch or shimmer climax.
class _ActLikeItUniqueBrandEmblemPainter extends CustomPainter {
  final double shimmerProgress;
  final double flareBurstProgress;
  final bool compact;

  const _ActLikeItUniqueBrandEmblemPainter({
    required this.shimmerProgress,
    required this.flareBurstProgress,
    required this.compact,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final crestY = h * (compact ? 0.34 : 0.32);
    final s = size.shortestSide;
    final phase = shimmerProgress * math.pi * 2;

    // -------------------------------------------------------------------------
    // 1. Ambient Golden & Soundstage Cyan Backlight Halo
    // -------------------------------------------------------------------------
    final haloRadius = s * 0.65;
    canvas.drawCircle(
      Offset(cx, crestY + h * 0.12),
      haloRadius,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            const Color(0xFFFFB300).withValues(alpha: 0.28),
            const Color(0xFF0CB6D4).withValues(alpha: 0.14),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.55, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(cx, crestY + h * 0.12),
            radius: haloRadius,
          ),
        ),
    );

    // -------------------------------------------------------------------------
    // 2. Sweeping 35mm Crimson (#E11342) & Gold Sprocketed Film Ribbon
    // -------------------------------------------------------------------------
    final ribbonY = h * (compact ? 0.56 : 0.54);
    final waveOffset = math.sin(phase) * (h * 0.03);
    final ribbonPath = Path()
      ..moveTo(w * 0.06, ribbonY + h * 0.10)
      ..cubicTo(
        w * 0.30,
        ribbonY - h * 0.22 + waveOffset,
        w * 0.70,
        ribbonY + h * 0.20 - waveOffset,
        w * 0.94,
        ribbonY - h * 0.10,
      );

    // Thick black comic ink outline
    canvas.drawPath(
      ribbonPath,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = s * 0.23
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    // 24K Gold outer sprocket rail
    canvas.drawPath(
      ribbonPath,
      Paint()
        ..color = const Color(0xFFFFD600)
        ..strokeWidth = s * 0.19
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    // Crimson Velvet (#E11342) inner 35mm film strip
    canvas.drawPath(
      ribbonPath,
      Paint()
        ..color = const Color(0xFFE11342)
        ..strokeWidth = s * 0.145
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // -------------------------------------------------------------------------
    // 3. Crest Emblem: Twin Split Golden Masks + Cyan Cybernetic [REC] Camera Lens
    // -------------------------------------------------------------------------
    final maskR = s * (compact ? 0.22 : 0.24);
    final splitSpread = maskR * 0.56 + math.sin(phase) * 1.8;

    // Left Half: 24K Gold Comedy Mask
    final leftMaskCenter = Offset(cx - splitSpread, crestY);
    final leftMaskRect = Rect.fromCenter(
      center: leftMaskCenter,
      width: maskR * 1.35,
      height: maskR * 1.65,
    );
    canvas.drawOval(
      leftMaskRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFFFE082),
            Color(0xFFFFB300),
            Color(0xFFFF6F00),
          ],
        ).createShader(leftMaskRect),
    );
    canvas.drawOval(
      leftMaskRect,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 2.6
        ..style = PaintingStyle.stroke,
    );
    // Comedy mask arched eye & smile
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(leftMaskCenter.dx - maskR * 0.12, leftMaskCenter.dy - maskR * 0.12),
        width: maskR * 0.44,
        height: maskR * 0.26,
      ),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(leftMaskCenter.dx - maskR * 0.05, leftMaskCenter.dy + maskR * 0.22),
        width: maskR * 0.56,
        height: maskR * 0.34,
      ),
      0.1,
      math.pi - 0.2,
      false,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke,
    );

    // Right Half: 24K Gold Tragedy Mask
    final rightMaskCenter = Offset(cx + splitSpread, crestY);
    final rightMaskRect = Rect.fromCenter(
      center: rightMaskCenter,
      width: maskR * 1.35,
      height: maskR * 1.65,
    );
    canvas.drawOval(
      rightMaskRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: <Color>[
            Color(0xFFFFE082),
            Color(0xFFFFB300),
            Color(0xFFE65100),
          ],
        ).createShader(rightMaskRect),
    );
    canvas.drawOval(
      rightMaskRect,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 2.6
        ..style = PaintingStyle.stroke,
    );
    // Tragedy mask glowing crimson eye & frown
    canvas.drawCircle(
      Offset(rightMaskCenter.dx + maskR * 0.12, rightMaskCenter.dy - maskR * 0.10),
      maskR * 0.13,
      Paint()..color = const Color(0xFFE11342),
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(rightMaskCenter.dx + maskR * 0.05, rightMaskCenter.dy + maskR * 0.34),
        width: maskR * 0.52,
        height: maskR * 0.28,
      ),
      math.pi + 0.15,
      math.pi - 0.3,
      false,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke,
    );

    // Center Parted Core: Soundstage Cyan (#0CB6D4) Cybernetic Camera Lens
    final lensCenter = Offset(cx, crestY);
    canvas.drawCircle(
      lensCenter,
      maskR * 0.68,
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.drawCircle(
      lensCenter,
      maskR * 0.68,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      lensCenter,
      maskR * 0.48,
      Paint()
        ..shader = RadialGradient(
          colors: const <Color>[
            Color(0xFF84FFFF),
            Color(0xFF0CB6D4),
            Color(0xFF052029),
          ],
        ).createShader(Rect.fromCircle(center: lensCenter, radius: maskR * 0.48)),
    );
    canvas.drawCircle(
      lensCenter,
      maskR * 0.22,
      Paint()..color = const Color(0xFF05070B),
    );
    canvas.drawCircle(
      Offset(lensCenter.dx - maskR * 0.14, lensCenter.dy - maskR * 0.14),
      maskR * 0.09,
      Paint()..color = Colors.white,
    );

    // Pulsing Red [REC] Indicator above the Cybernetic Lens
    if ((shimmerProgress * 4).floor().isEven) {
      canvas.drawCircle(
        Offset(lensCenter.dx + maskR * 0.42, lensCenter.dy - maskR * 0.44),
        maskR * 0.13,
        Paint()..color = const Color(0xFFFF1744),
      );
    }

    // Mini Angled Black & Gold Clapperboard Top Bar crowning the Crest
    canvas.save();
    canvas.translate(cx - maskR * 0.95, crestY - maskR * 0.76);
    canvas.rotate(-0.14);
    final clapBarRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, maskR * 1.9, maskR * 0.28),
      const Radius.circular(4),
    );
    canvas.drawRRect(clapBarRect, Paint()..color = const Color(0xFF0B0E17));
    for (double x = 4; x < maskR * 1.8; x += maskR * 0.36) {
      final stripe = Path()
        ..moveTo(x, 0)
        ..lineTo(x + maskR * 0.18, 0)
        ..lineTo(x + maskR * 0.08, maskR * 0.28)
        ..lineTo(x - maskR * 0.10, maskR * 0.28)
        ..close();
      canvas.drawPath(stripe, Paint()..color = const Color(0xFFFFD600));
    }
    canvas.drawRRect(
      clapBarRect,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );
    canvas.restore();

    // -------------------------------------------------------------------------
    // 4. Interactive "Paparazzi Frenzy" 6 Four-Point Star Lens Flares
    // -------------------------------------------------------------------------
    final baseTwinkle = 0.38 + 0.62 * flareBurstProgress;
    final starPositions = <Offset>[
      Offset(cx - w * 0.34, crestY - h * 0.10),
      Offset(cx + w * 0.34, crestY - h * 0.10),
      Offset(cx - w * 0.26, ribbonY + h * 0.06),
      Offset(cx + w * 0.26, ribbonY + h * 0.06),
      Offset(cx - w * 0.14, crestY - h * 0.22),
      Offset(cx + w * 0.14, crestY - h * 0.22),
    ];

    for (int i = 0; i < starPositions.length; i++) {
      final localPulse =
          ((math.sin(phase + i * 1.1) + 1.0) * 0.5) * baseTwinkle +
              flareBurstProgress * 0.65;
      if (localPulse > 0.22) {
        final pt = starPositions[i];
        final r = s * (0.06 + 0.09 * localPulse.clamp(0.0, 1.2));
        final starColor =
            i.isEven ? const Color(0xFFFFE082) : const Color(0xFF84FFFF);
        final starPaint = Paint()
          ..color = starColor.withValues(alpha: localPulse.clamp(0.0, 1.0))
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(Offset(pt.dx - r, pt.dy), Offset(pt.dx + r, pt.dy), starPaint);
        canvas.drawLine(Offset(pt.dx, pt.dy - r), Offset(pt.dx, pt.dy + r), starPaint);
        canvas.drawCircle(
          pt,
          r * 0.22,
          Paint()..color = Colors.white.withValues(alpha: localPulse.clamp(0.0, 1.0)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ActLikeItUniqueBrandEmblemPainter oldDelegate) {
    return oldDelegate.shimmerProgress != shimmerProgress ||
        oldDelegate.flareBurstProgress != flareBurstProgress ||
        oldDelegate.compact != compact;
  }
}
