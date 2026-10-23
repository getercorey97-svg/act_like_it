import 'dart:math' as math;
import 'dart:ui' show ImageFilter, MaskFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// CustomClipper that carves authentic vintage Box Office ticket semicircular notches
/// into the left and right edges of Door 5 and Scene Vault tickets.
class BoxOfficeTicketNotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double r = 24.0;
    const double notchRadius = 15.0;
    final double midY = size.height * 0.5;

    return Path()
      ..moveTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..lineTo(size.width - r, 0)
      ..quadraticBezierTo(size.width, 0, size.width, r)
      ..lineTo(size.width, midY - notchRadius)
      ..arcToPoint(
        Offset(size.width, midY + notchRadius),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      )
      ..lineTo(size.width, size.height - r)
      ..quadraticBezierTo(size.width, size.height, size.width - r, size.height)
      ..lineTo(r, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - r)
      ..lineTo(0, midY + notchRadius)
      ..arcToPoint(
        Offset(0, midY - notchRadius),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      )
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ============================================================================
// UPGRADED HOLOGRAPHIC "LIVE WIRE" BROADCAST CHYRON
// ============================================================================

class HolographicLiveWireChyron extends StatelessWidget {
  final Animation<double> tickerAnimation;
  final List<String> feedItems;

  const HolographicLiveWireChyron({
    super.key,
    required this.tickerAnimation,
    required this.feedItems,
  });

  @override
  Widget build(BuildContext context) {
    final joinedFeed = feedItems.join('   ✦   ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xE607090E),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: const Color(0xFFF5DEB3),
                width: 2.0,
              ),
              boxShadow: [
                const BoxShadow(
                  color: Color(0xFF05070B),
                  blurRadius: 0,
                  offset: Offset(4, 4),
                ),
                BoxShadow(
                  color: const Color(0xFFF5DEB3).withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: tickerAnimation,
                  builder: (context, _) {
                    final pulse = 0.45 +
                        0.55 * math.sin(tickerAnimation.value * math.pi * 8);
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE11342),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFE11342).withValues(alpha: pulse),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'LIVE WIRE',
                  style: GoogleFonts.chakraPetch(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: const Color(0xFFF5DEB3),
                  ),
                ),
                Container(
                  width: 1.5,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: const Color(0xFF334155),
                ),
                Expanded(
                  child: ClipRect(
                    child: AnimatedBuilder(
                      animation: tickerAnimation,
                      builder: (context, _) {
                        return FractionalTranslation(
                          translation: Offset(
                            1.0 - (tickerAnimation.value * 2.2),
                            0.0,
                          ),
                          child: Text(
                            '$joinedFeed   ✦   $joinedFeed',
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            style: GoogleFonts.montserrat(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 3D PERSPECTIVE RED CARPET, BRASS STANCHIONS & 42 GOLDEN BOKEH PARTICLES
// ============================================================================

class PaparazziRedCarpetPainter extends CustomPainter {
  final double scrollOffset;
  final double phase;
  final double scrollVelocity;
  final Offset? touchPosition;

  const PaparazziRedCarpetPainter({
    required this.scrollOffset,
    required this.phase,
    this.scrollVelocity = 0.0,
    this.touchPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Deep Obsidian Soundstage Sky & Horizon Glow
    final bgRect = Offset.zero & size;
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF05070B),
          Color(0xFF0B0F1A),
          Color(0xFF14070C),
        ],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, skyPaint);

    // 2. Volumetric Dual Searchlight Cones Sweeping Across the Sky
    final horizonY = size.height * 0.22;
    final leftConeAngle = math.sin(phase * 0.7) * 0.35;
    final rightConeAngle = math.cos(phase * 0.85) * 0.35;

    final conePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFFF5DEB3).withValues(alpha: 0.16),
          const Color(0xFF0CB6D4).withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(bgRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    final leftCone = Path()
      ..moveTo(size.width * 0.18, horizonY)
      ..lineTo(size.width * (0.05 + leftConeAngle), 0)
      ..lineTo(size.width * (0.42 + leftConeAngle), 0)
      ..close();
    canvas.drawPath(leftCone, conePaint);

    final rightCone = Path()
      ..moveTo(size.width * 0.82, horizonY)
      ..lineTo(size.width * (0.58 + rightConeAngle), 0)
      ..lineTo(size.width * (0.95 + rightConeAngle), 0)
      ..close();
    canvas.drawPath(rightCone, conePaint);

    // 3. 3D Perspective Crimson Velvet Red Carpet Runner
    final topHalfWidth = size.width * 0.19;
    final bottomHalfWidth = size.width * 0.49;
    final centerX = size.width * 0.5;

    final carpetPath = Path()
      ..moveTo(centerX - topHalfWidth, horizonY)
      ..lineTo(centerX + topHalfWidth, horizonY)
      ..lineTo(centerX + bottomHalfWidth, size.height)
      ..lineTo(centerX - bottomHalfWidth, size.height)
      ..close();

    final carpetPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFF3B0004),
          Color(0xFF7A0614),
          Color(0xFFA30B1E),
          Color(0xFF520002),
        ],
        stops: const [0.0, 0.35, 0.75, 1.0],
      ).createShader(bgRect);
    canvas.drawPath(carpetPath, carpetPaint);

    // Bold 2.5D Cel-Shaded Ink & Gold Trim Borders along the Red Carpet
    final goldTrimPaint = Paint()
      ..color = const Color(0xFFF5DEB3).withValues(alpha: 0.85)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centerX - topHalfWidth, horizonY),
      Offset(centerX - bottomHalfWidth, size.height),
      goldTrimPaint,
    );
    canvas.drawLine(
      Offset(centerX + topHalfWidth, horizonY),
      Offset(centerX + bottomHalfWidth, size.height),
      goldTrimPaint,
    );

    // 4. Scrolling Perspective CarpetSteps & Brass Stanchions
    const int stanchionPairs = 7;
    final normalizedScroll = (scrollOffset * 0.0045) % 1.0;

    for (int i = 0; i < stanchionPairs; i++) {
      final rawT = ((i / stanchionPairs) + normalizedScroll) % 1.0;
      // Exponential perspective depth curve
      final depth = rawT * rawT;
      final y = horizonY + depth * (size.height - horizonY);
      final halfW = topHalfWidth + depth * (bottomHalfWidth - topHalfWidth);

      // Subtle step line across the velvet runner
      final stepPaint = Paint()
        ..color = const Color(0xFF05070B).withValues(alpha: 0.18 + 0.25 * depth)
        ..strokeWidth = 1.0 + depth * 2.2;
      canvas.drawLine(
        Offset(centerX - halfW, y),
        Offset(centerX + halfW, y),
        stepPaint,
      );

      final postHeight = 14.0 + depth * 42.0;
      final leftBase = Offset(centerX - halfW - 6.0 * depth, y);
      final leftTop = Offset(leftBase.dx, y - postHeight);
      final rightBase = Offset(centerX + halfW + 6.0 * depth, y);
      final rightTop = Offset(rightBase.dx, y - postHeight);

      _drawStanchionPost(
        canvas,
        base: leftBase,
        top: leftTop,
        scale: depth,
      );
      _drawStanchionPost(
        canvas,
        base: rightBase,
        top: rightTop,
        scale: depth,
      );
    }

    // 5. 42 Floating Golden Champagne Bokeh Particles with Touch Repulsion
    for (int i = 0; i < 42; i++) {
      final seed = i * 1.6180339;
      final baseX = ((math.sin(seed * 13.7 + phase * 0.35) + 1.0) * 0.5) *
          size.width;
      final baseY = ((math.cos(seed * 9.3 - phase * 0.45) + 1.0) * 0.5) *
          size.height;
      var pos = Offset(baseX, baseY);

      if (touchPosition != null) {
        final delta = pos - touchPosition!;
        final dist = delta.distance;
        if (dist > 0.1 && dist < 110.0) {
          final push = ((110.0 - dist) / 110.0) * 28.0;
          pos += (delta / dist) * push;
        }
      }

      final radius = 1.4 + (i % 4) * 1.15;
      final alpha = (0.18 + 0.35 * ((math.sin(phase * 1.8 + i) + 1.0) * 0.5))
          .clamp(0.05, 0.75);
      final bokehPaint = Paint()
        ..color = (i.isEven
                ? const Color(0xFFF5DEB3)
                : const Color(0xFF0CB6D4))
            .withValues(alpha: alpha);
      canvas.drawCircle(pos, radius, bokehPaint);
    }
  }

  void _drawStanchionPost(
    Canvas canvas, {
    required Offset base,
    required Offset top,
    required double scale,
  }) {
    final postInkPaint = Paint()
      ..color = const Color(0xFF05070B).withValues(alpha: 0.5 + 0.5 * scale)
      ..strokeWidth = 4.0 + scale * 4.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base, top, postInkPaint);

    final postPaint = Paint()
      ..color = const Color(0xFFF5DEB3).withValues(alpha: 0.45 + 0.55 * scale)
      ..strokeWidth = 2.0 + scale * 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base, top, postPaint);

    // Gold finial sphere on top of stanchion with ink ring
    final finialPaint = Paint()
      ..color = const Color(0xFFF5DEB3).withValues(alpha: 0.55 + 0.45 * scale);
    canvas.drawCircle(top, 2.6 + scale * 3.8, finialPaint);
  }

  @override
  bool shouldRepaint(covariant PaparazziRedCarpetPainter oldDelegate) {
    return oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.phase != phase ||
        oldDelegate.scrollVelocity != scrollVelocity ||
        oldDelegate.touchPosition != touchPosition;
  }
}

/// Multi-Stage Paparazzi Crowd Silhouettes & 4-Point Star-Burst Camera Flash Painter
class PaparazziFlashOverlayPainter extends CustomPainter {
  final double progress;
  final double scrollVelocity;
  final double frenzyIntensity;

  const PaparazziFlashOverlayPainter({
    required this.progress,
    this.scrollVelocity = 0.0,
    this.frenzyIntensity = 0.0,
  });

  static const List<Offset> _flashAnchors = [
    Offset(0.09, 0.18),
    Offset(0.91, 0.21),
    Offset(0.06, 0.38),
    Offset(0.94, 0.42),
    Offset(0.11, 0.58),
    Offset(0.89, 0.62),
    Offset(0.08, 0.76),
    Offset(0.92, 0.74),
    Offset(0.22, 0.28),
    Offset(0.78, 0.31),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 2.5D Cel-Shaded Photographer Crowd Silhouettes along left and right edges
    final silhouettePaint = Paint()
      ..color = const Color(0xAA05070B)
      ..style = PaintingStyle.fill;
    final rimInkPaint = Paint()
      ..color = const Color(0x330CB6D4)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 6; i++) {
      final y = size.height * (0.18 + i * 0.13);
      // Left photographer silhouette head & camera lens barrel
      canvas.drawCircle(Offset(14, y), 11, silhouettePaint);
      canvas.drawCircle(Offset(14, y), 11, rimInkPaint);
      final leftBody = RRect.fromRectAndRadius(
        Rect.fromLTWH(2, y + 10, 24, 28),
        const Radius.circular(8),
      );
      canvas.drawRRect(leftBody, silhouettePaint);
      canvas.drawRRect(leftBody, rimInkPaint);

      // Right photographer silhouette
      canvas.drawCircle(Offset(size.width - 14, y + 8), 11, silhouettePaint);
      canvas.drawCircle(Offset(size.width - 14, y + 8), 11, rimInkPaint);
      final rightBody = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 26, y + 18, 24, 28),
        const Radius.circular(8),
      );
      canvas.drawRRect(rightBody, silhouettePaint);
      canvas.drawRRect(rightBody, rimInkPaint);
    }

    // 2. Multi-Stage Lens Flashes (4-Point Star-Burst + Lens Core + Radial Bloom)
    final speedMultiplier = 1.0 + (scrollVelocity * 0.08).clamp(0.0, 2.5);
    final activeThreshold =
        (0.16 * speedMultiplier + frenzyIntensity * 0.75).clamp(0.16, 0.92);

    for (int i = 0; i < _flashAnchors.length; i++) {
      final phaseOffset = (i * 0.31) % 1.0;
      final localPhase = ((progress * speedMultiplier + phaseOffset) % 1.0);
      if (localPhase > activeThreshold && frenzyIntensity <= 0.01) continue;

      final rawIntensity = localPhase <= activeThreshold
          ? (1.0 - (localPhase / activeThreshold))
          : 0.0;
      final intensity =
          math.max(rawIntensity, frenzyIntensity).clamp(0.0, 1.0);
      if (intensity <= 0.02) continue;

      final anchor = _flashAnchors[i];
      final center = Offset(size.width * anchor.dx, size.height * anchor.dy);
      final bloomRadius = (85.0 + (i % 3) * 32.0) * (0.8 + 0.4 * intensity);

      // a) Soft Radial Screen Bloom with MaskFilter.blur
      final bloomPaint = Paint()
        ..color = const Color(0xFFF5DEB3).withValues(alpha: 0.36 * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
      canvas.drawCircle(center, bloomRadius * 0.65, bloomPaint);

      // b) Sharp 4-Point Star-Burst Path
      final spikeLen = 36.0 + 48.0 * intensity;
      final spikeThickness = 3.2 * intensity;
      final starPath = Path()
        ..moveTo(center.dx - spikeLen, center.dy)
        ..lineTo(center.dx - spikeThickness, center.dy - spikeThickness)
        ..lineTo(center.dx, center.dy - spikeLen)
        ..lineTo(center.dx + spikeThickness, center.dy - spikeThickness)
        ..lineTo(center.dx + spikeLen, center.dy)
        ..lineTo(center.dx + spikeThickness, center.dy + spikeThickness)
        ..lineTo(center.dx, center.dy + spikeLen)
        ..lineTo(center.dx - spikeThickness, center.dy + spikeThickness)
        ..close();

      final starPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.94 * intensity)
        ..style = PaintingStyle.fill;
      canvas.drawPath(starPath, starPaint);

      // c) Bright Lens Flare Core
      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: intensity);
      canvas.drawCircle(center, 5.5 * intensity, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant PaparazziFlashOverlayPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.scrollVelocity != scrollVelocity ||
        oldDelegate.frenzyIntensity != frenzyIntensity;
  }
}

/// Backwards-compatible 3D Paparazzi Cinema Door Card widget
class PaparazziCinemaDoorCard extends StatelessWidget {
  final String doorBadge;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color neonAccent;
  final VoidCallback onTap;

  const PaparazziCinemaDoorCard({
    super.key,
    required this.doorBadge,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.neonAccent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xE607090E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: neonAccent, width: 2.2),
          boxShadow: [
            const BoxShadow(
              color: Color(0xFF05070B),
              blurRadius: 0,
              offset: Offset(6, 6),
            ),
            BoxShadow(
              color: neonAccent.withValues(alpha: 0.28),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: neonAccent, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doorBadge,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: neonAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.limelight(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 12.5,
                      color: const Color(0xFFCBD5E1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sleek glassmorphic VIP Credential Bar showing the player's Actor Handle,
/// Rank Icon, live AI Token Balance (`telemetrics_tokens`), and Online/Offline LED.
class VipCredentialHeaderBar extends StatelessWidget {
  final String actorHandle;
  final int telemetricsTokens;
  final int careerWins;
  final bool isOnline;

  const VipCredentialHeaderBar({
    super.key,
    required this.actorHandle,
    required this.telemetricsTokens,
    required this.careerWins,
    required this.isOnline,
  });

  String get _rankTitle {
    if (careerWins >= 10) return 'ACADEMY LEGEND';
    if (careerWins >= 3) return 'HEADLINER STAR';
    return 'RISING TALENT';
  }

  @override
  Widget build(BuildContext context) {
    final ledColor =
        isOnline ? const Color(0xFF0CB6D4) : const Color(0xFFF5DEB3);

    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xE607090E),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: const Color(0xFFF5DEB3),
              width: 2.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF05070B),
                blurRadius: 0,
                offset: Offset(4, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ledColor,
                  boxShadow: [
                    BoxShadow(
                      color: ledColor.withValues(alpha: 0.8),
                      blurRadius: 8,
                      spreadRadius: 1.5,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xFFF5DEB3),
                size: 17,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$actorHandle · $_rankTitle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.chakraPetch(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x260CB6D4),
                  borderRadius: BorderRadius.circular(99),
                  border:
                      Border.all(color: const Color(0xFF0CB6D4), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 13,
                      color: Color(0xFF0CB6D4),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$telemetricsTokens AI TOKENS',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
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
    );
  }
}

/// Glowing, dismissible "ACTIVE SET IN PROGRESS — TAP TO REJOIN" banner at the
/// top of the Red Carpet for 1-tap reconnection to an unfinished 6-digit room.
class ActiveSetRejoinBanner extends StatelessWidget {
  final String roomCode;
  final VoidCallback onRejoinTap;
  final VoidCallback onDismissTap;

  const ActiveSetRejoinBanner({
    super.key,
    required this.roomCode,
    required this.onRejoinTap,
    required this.onDismissTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRejoinTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xF02B0918),
              Color(0xF00B1726),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF10B981), width: 1.8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.sensors_rounded,
              color: Color(0xFF10B981),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACTIVE SET IN PROGRESS — TAP TO REJOIN',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Reconnect immediately to Soundstage Room #$roomCode',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
              tooltip: 'Dismiss Active Set Banner',
              onPressed: onDismissTap,
            ),
          ],
        ),
      ),
    );
  }
}
