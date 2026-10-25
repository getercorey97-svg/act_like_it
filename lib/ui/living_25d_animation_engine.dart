import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show MaskFilter, PathMetric;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Exact native aspect ratio of all 11 finalized 2.5D cell-shaded assets
/// (`768x1376` and `1536x2752` => `24 : 43` = `0.5581395348837209`).
/// Enforces zero stretching, squashing, or clipping across all viewports.
const double kLiving25dNativeAspectRatio = 768.0 / 1376.0;

/// Canonical asset registry for the 11 finalized 2.5D cell-shaded character,
/// crowd, and prop designs.
class Living25DAssetPaths {
  static const String oscarTrophyVipBoxOffice13007 =
      'assets/living_25d/13007.jpg';
  static const String speakeasyDareWheel13008 = 'assets/living_25d/13008.jpg';
  static const String cuttingRoomReelShears13009 =
      'assets/living_25d/13009.jpg';
  static const String writersRoomTypewriter13010 =
      'assets/living_25d/13010.jpg';
  static const String luxuryClapperboard13011 = 'assets/living_25d/13011.jpg';
  static const String undercoverSpeakeasyImproviser13012 =
      'assets/living_25d/13012.jpg';
  static const String screenTestRivalsDuel13013 = 'assets/living_25d/13013.jpg';
  static const String ruthlessCastingDirector13014 =
      'assets/living_25d/13014.jpg';
  static const String rightFlankVipEntourage13015 =
      'assets/living_25d/13015.jpg';
  static const String leftFlankPaparazziDuo13016 =
      'assets/living_25d/13016.jpg';
  static const String firstPersonRedCarpetPov13017 =
      'assets/living_25d/13017.jpg';
}

/// Enumerates the 3 reusable 2.5D Hero Character rigs (5-Layer Living Portrait Engine).
enum Living25DHeroCharacterType {
  undercoverSpeakeasyImproviser, // 13012.jpg
  ruthlessCastingDirector, // 13014.jpg
  screenTestRivalsDuel, // 13013.jpg
}

/// Enumerates the 5 interactive 2.5D Prop & Game Mode Card rigs (60fps Tactile Loops).
enum Living25DPropCardType {
  writersRoomTypewriter, // 13010.jpg
  speakeasyDareWheel, // 13008.jpg
  cuttingRoomReelShears, // 13009.jpg
  luxuryHollywoodClapperboard, // 13011.jpg
  oscarTrophyVipBoxOffice, // 13007.jpg
}

/// 4K High-DPI Native Ratio Image Renderer.
/// Guarantees that every 2.5D asset is rendered in its exact native `768:1376`
/// (`1536:2752`) aspect ratio with `FilterQuality.high` and 4K-ready pixel scaling
/// for flagship displays like the Samsung Galaxy S26 Ultra.
class Native4KLiving25DImage extends StatelessWidget {
  final String assetPath;
  final Widget? overlayPainterWidget;
  final BorderRadius? borderRadius;

  const Native4KLiving25DImage({
    super.key,
    required this.assetPath,
    this.overlayPainterWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context).clamp(2.0, 4.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final targetLogicalWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 384.0;
        final cacheWidthPx = (targetLogicalWidth * dpr).round().clamp(
          768,
          2160,
        );

        Widget content = AspectRatio(
          aspectRatio: kLiving25dNativeAspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                assetPath,
                fit: BoxFit.contain,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
                cacheWidth: cacheWidthPx,
                errorBuilder: (context, _, __) => const ColoredBox(
                  color: Color(0xFF090C15),
                  child: Center(
                    child: Icon(
                      Icons.movie_creation_outlined,
                      color: Color(0xFFFFD700),
                      size: 32,
                    ),
                  ),
                ),
              ),
              if (overlayPainterWidget != null)
                Positioned.fill(child: overlayPainterWidget!),
            ],
          ),
        );

        if (borderRadius != null) {
          content = ClipRRect(borderRadius: borderRadius!, child: content);
        }
        return content;
      },
    );
  }
}

// ============================================================================
// 1. 2.5D CROWD & RED CARPET ENVIRONMENT (PARALLAX RIGS: 13017, 13016, 13015)
// ============================================================================

/// Multi-layered 60/120fps Red Carpet Parallax Environment that reacts to user
/// scrolling and device gyroscope:
/// - Base Layer (`13017.jpg`): First-Person Red Carpet POV with dynamic `Matrix4`
///   perspective tilt that shifts as the user scrolls and tilts their device.
/// - Left-Flank (`13016.jpg`): Hero Paparazzi Duo with blinding white-gold
///   `RadialGradient` flashbulb bursts, an 80ms screen vignette pulse, and
///   reporter breathing + shifting crimson sequin shimmer.
/// - Right-Flank (`13015.jpg`): Hype VIP Entourage with sweeping sunglasses
///   reflection on the pinstripe agent, glowing/recording cyan smartphone screen
///   on the fan, and animated clapping loop on the blonde starlet.
class RedCarpet25DParallaxEnvironment extends StatefulWidget {
  final double scrollOffset;
  final double scrollVelocity;
  final Offset? touchPosition;
  final double extraFrenzyIntensity;
  final bool showFlankCardsOverlay;

  const RedCarpet25DParallaxEnvironment({
    super.key,
    required this.scrollOffset,
    this.scrollVelocity = 0.0,
    this.touchPosition,
    this.extraFrenzyIntensity = 0.0,
    this.showFlankCardsOverlay = true,
  });

  @override
  State<RedCarpet25DParallaxEnvironment> createState() =>
      _RedCarpet25DParallaxEnvironmentState();
}

class _RedCarpet25DParallaxEnvironmentState
    extends State<RedCarpet25DParallaxEnvironment>
    with TickerProviderStateMixin {
  late final AnimationController _masterLoopController;
  late final AnimationController _flashVignettePulseController;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  double _gyroTiltX = 0.0;
  double _gyroTiltY = 0.0;
  Timer? _flashbulbIntervalTimer;

  @override
  void initState() {
    super.initState();
    _masterLoopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    )..repeat();

    // 80ms screen vignette pulse synced with the Left-Flank Paparazzi flashbulb
    _flashVignettePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 140),
    );

    _flashbulbIntervalTimer = Timer.periodic(
      const Duration(milliseconds: 2200),
      (_) {
        if (!mounted) return;
        _trigger80msFlashVignettePulse();
      },
    );

    try {
      _gyroSub = gyroscopeEventStream().listen(
        (GyroscopeEvent event) {
          if (!mounted) return;
          setState(() {
            _gyroTiltX = (_gyroTiltX * 0.82 + event.x * 0.18).clamp(-0.35, 0.35);
            _gyroTiltY = (_gyroTiltY * 0.82 + event.y * 0.18).clamp(-0.35, 0.35);
          });
        },
        onError: (_) {},
        cancelOnError: false,
      );
    } catch (_) {}
  }

  Future<void> _trigger80msFlashVignettePulse() async {
    if (!mounted) return;
    await _flashVignettePulseController.forward(from: 0.0);
    if (!mounted) return;
    await _flashVignettePulseController.reverse();
  }

  @override
  void dispose() {
    _flashbulbIntervalTimer?.cancel();
    _gyroSub?.cancel();
    _masterLoopController.dispose();
    _flashVignettePulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _masterLoopController,
        _flashVignettePulseController,
      ]),
      builder: (context, _) {
        final t = _masterLoopController.value;
        final phase = t * 2 * math.pi;
        final flashPulse = (_flashVignettePulseController.value +
                widget.extraFrenzyIntensity * 0.7)
            .clamp(0.0, 1.0);

        // Scroll + Gyroscope dynamic Matrix4 perspective tilt
        final scrollNormalized = (widget.scrollOffset / 900.0).clamp(-1.0, 1.0);
        final touchTiltY = widget.touchPosition != null && screenSize.width > 0
            ? ((widget.touchPosition!.dx / screenSize.width) - 0.5) * 0.10
            : 0.0;
        final touchTiltX = widget.touchPosition != null && screenSize.height > 0
            ? ((widget.touchPosition!.dy / screenSize.height) - 0.5) * -0.08
            : 0.0;

        final perspectiveRotateX =
            (scrollNormalized * 0.085) + (_gyroTiltX * 0.16) + touchTiltX;
        final perspectiveRotateY =
            (math.sin(phase * 0.5) * 0.025) + (_gyroTiltY * 0.16) + touchTiltY;

        final povMatrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0014)
          ..rotateX(perspectiveRotateX)
          ..rotateY(perspectiveRotateY)
          ..translate(
            _gyroTiltY * -14.0,
            -(widget.scrollOffset * 0.04).clamp(0.0, 28.0),
          );

        final flankParallaxOffset = (widget.scrollOffset * 0.065).clamp(
          -36.0,
          36.0,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            // Deep obsidian cinema backdrop
            const ColoredBox(color: Color(0xFF05070C)),

            // BASE LAYER: First-Person Red Carpet (13017.jpg) in exact native ratio
            Center(
              child: Transform(
                alignment: Alignment.center,
                transform: povMatrix,
                child: Native4KLiving25DImage(
                  assetPath: Living25DAssetPaths.firstPersonRedCarpetPov13017,
                  overlayPainterWidget: CustomPaint(
                    painter: _FirstPersonRedCarpetPovShaderPainter(
                      phase: phase,
                      scrollOffset: widget.scrollOffset,
                      flashPulse: flashPulse,
                    ),
                  ),
                ),
              ),
            ),

            // LEFT & RIGHT FLANK PARALLAX CROWD RIGS (13016.jpg & 13015.jpg)
            if (widget.showFlankCardsOverlay) ...[
              // Left-Flank Hero Paparazzi Duo (13016.jpg)
              Positioned(
                left: 6 + (_gyroTiltY * 10.0),
                bottom: 58 + flankParallaxOffset * 0.4,
                width: (screenSize.width * 0.27).clamp(96.0, 148.0),
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.92,
                    child: LeftFlankPaparazziDuoRig(
                      externalPhase: phase,
                      flashPulse: flashPulse,
                    ),
                  ),
                ),
              ),

              // Right-Flank Hype VIP Entourage (13015.jpg)
              Positioned(
                right: 6 - (_gyroTiltY * 10.0),
                bottom: 58 - flankParallaxOffset * 0.4,
                width: (screenSize.width * 0.27).clamp(96.0, 148.0),
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.92,
                    child: RightFlankVipEntourageRig(
                      externalPhase: phase,
                    ),
                  ),
                ),
              ),
            ],

            // 80ms Full-Screen Paparazzi Flashbulb Vignette Pulse
            if (flashPulse > 0.01)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ScreenFlashVignettePulsePainter(
                      intensity: flashPulse,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Interactive Showcase Strip of the 3 Parallax Environment Rigs (`13016.jpg`, `13017.jpg`, `13015.jpg`)
/// rendered in their locked 4K native `768:1376` aspect ratio so players can inspect
/// and trigger the Left-Flank Paparazzi Duo, First-Person Red Carpet POV, and Right-Flank VIP Entourage.
class RedCarpetFlankShowcaseRow extends StatefulWidget {
  final double scrollOffset;
  final VoidCallback? onFlashTriggered;

  const RedCarpetFlankShowcaseRow({
    super.key,
    required this.scrollOffset,
    this.onFlashTriggered,
  });

  @override
  State<RedCarpetFlankShowcaseRow> createState() =>
      _RedCarpetFlankShowcaseRowState();
}

class _RedCarpetFlankShowcaseRowState extends State<RedCarpetFlankShowcaseRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _manualFlashBoost = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerManualFlash() {
    HapticFeedback.heavyImpact();
    widget.onFlashTriggered?.call();
    setState(() => _manualFlashBoost = 1.0);
    Future<void>.delayed(const Duration(milliseconds: 80), () {
      if (mounted) setState(() => _manualFlashBoost = 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final phase = _controller.value * 2 * math.pi;
        final autoFlash = (math.sin(phase * 2.0) > 0.92) ? 0.95 : 0.0;
        final flashIntensity = math.max(autoFlash, _manualFlashBoost);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xD907090F),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD700), width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF05070B),
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '📸 2.5D RED CARPET PARALLAX FLANKS · NATIVE 4K RATIO',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _triggerManualFlash,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x3300E5FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF00E5FF)),
                      ),
                      child: const Text(
                        '⚡ SNAP 80ms FLASH',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF00E5FF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left-Flank Hero Paparazzi Duo (13016.jpg)
                  Expanded(
                    child: GestureDetector(
                      onTap: _triggerManualFlash,
                      child: Column(
                        children: [
                          LeftFlankPaparazziDuoRig(
                            externalPhase: phase,
                            flashPulse: flashIntensity,
                          ),
                          const SizedBox(height: 6),
                          const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'LEFT FLANK · PAPARAZZI DUO',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF00E5FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Center First-Person Red Carpet POV (13017.jpg)
                  Expanded(
                    child: Column(
                      children: [
                        FirstPersonRedCarpetPovCardRig(
                          externalPhase: phase,
                          scrollOffset: widget.scrollOffset,
                          flashPulse: flashIntensity,
                        ),
                        const SizedBox(height: 6),
                        const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'POV · RED CARPET RUNNER',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFFD700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Right-Flank Hype VIP Entourage (13015.jpg)
                  Expanded(
                    child: Column(
                      children: [
                        RightFlankVipEntourageRig(externalPhase: phase),
                        const SizedBox(height: 6),
                        const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'RIGHT FLANK · VIP HYPE',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFF43F5E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// First-Person Red Carpet POV Rig (`13017.jpg`) with `Matrix4` perspective tilt.
class FirstPersonRedCarpetPovCardRig extends StatelessWidget {
  final double externalPhase;
  final double scrollOffset;
  final double flashPulse;

  const FirstPersonRedCarpetPovCardRig({
    super.key,
    required this.externalPhase,
    this.scrollOffset = 0.0,
    this.flashPulse = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final tiltX =
        (scrollOffset * 0.0004).clamp(-0.09, 0.09) +
        math.sin(externalPhase) * 0.03;
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0016)
      ..rotateX(tiltX);

    return Transform(
      alignment: Alignment.center,
      transform: matrix,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFD700), width: 1.8),
        ),
        child: Native4KLiving25DImage(
          assetPath: Living25DAssetPaths.firstPersonRedCarpetPov13017,
          borderRadius: BorderRadius.circular(12),
          overlayPainterWidget: CustomPaint(
            painter: _FirstPersonRedCarpetPovShaderPainter(
              phase: externalPhase,
              scrollOffset: scrollOffset,
              flashPulse: flashPulse,
            ),
          ),
        ),
      ),
    );
  }
}

/// Left-Flank Hero Paparazzi Duo (`13016.jpg`):
/// - Crouched photographer fires blinding white-gold `RadialGradient` flashbulb bursts.
/// - Female reporter breathes subtly with a shifting crimson sequin shimmer across her gown.
class LeftFlankPaparazziDuoRig extends StatelessWidget {
  final double externalPhase;
  final double flashPulse;

  const LeftFlankPaparazziDuoRig({
    super.key,
    required this.externalPhase,
    this.flashPulse = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final breatheY = math.sin(externalPhase * 1.4) * 2.2;
    final breatheScaleY = 1.0 + math.sin(externalPhase * 1.4) * 0.012;

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0012)
      ..translate(0.0, breatheY)
      ..scale(1.0, breatheScaleY, 1.0);

    return Transform(
      alignment: Alignment.bottomCenter,
      transform: matrix,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF00E5FF), width: 1.8),
        ),
        child: Native4KLiving25DImage(
          assetPath: Living25DAssetPaths.leftFlankPaparazziDuo13016,
          borderRadius: BorderRadius.circular(12),
          overlayPainterWidget: CustomPaint(
            painter: _LeftFlankPaparazziDuoPainter(
              phase: externalPhase,
              flashPulse: flashPulse,
            ),
          ),
        ),
      ),
    );
  }
}

class _LeftFlankPaparazziDuoPainter extends CustomPainter {
  final double phase;
  final double flashPulse;

  const _LeftFlankPaparazziDuoPainter({
    required this.phase,
    required this.flashPulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Crouched photographer lens position (lower-left quadrant of 13016.jpg)
    final lensCenter = Offset(size.width * 0.42, size.height * 0.56);
    final burstWave = math.max(
      flashPulse,
      ((math.sin(phase * 3.0) - 0.55) / 0.45).clamp(0.0, 1.0),
    );

    if (burstWave > 0.02) {
      final flashRadius = size.width * (0.32 + burstWave * 0.48);
      final flashPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: (0.95 * burstWave).clamp(0.0, 1.0)),
            const Color(
              0xFFFFF59D,
            ).withValues(alpha: (0.78 * burstWave).clamp(0.0, 1.0)),
            const Color(
              0xFF00E5FF,
            ).withValues(alpha: (0.42 * burstWave).clamp(0.0, 1.0)),
            Colors.transparent,
          ],
          stops: const [0.0, 0.28, 0.62, 1.0],
        ).createShader(Rect.fromCircle(center: lensCenter, radius: flashRadius));
      canvas.drawCircle(lensCenter, flashRadius, flashPaint);

      // 8-point comic star flare rays on the camera flashbulb
      final rayPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9 * burstWave)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 4; i++) {
        final angle = i * (math.pi / 4) + phase * 0.4;
        final len = flashRadius * (i.isEven ? 0.95 : 0.55);
        canvas.drawLine(
          Offset(
            lensCenter.dx - math.cos(angle) * len,
            lensCenter.dy - math.sin(angle) * len,
          ),
          Offset(
            lensCenter.dx + math.cos(angle) * len,
            lensCenter.dy + math.sin(angle) * len,
          ),
          rayPaint,
        );
      }
    }

    // 2. Reporter crimson sequin dress shimmer (right half of 13016.jpg)
    final dressRect = Rect.fromLTWH(
      size.width * 0.52,
      size.height * 0.44,
      size.width * 0.40,
      size.height * 0.44,
    );
    final shimmerShift = (phase / (2 * math.pi)) % 1.0;
    final sequinShader = LinearGradient(
      begin: Alignment(-1.0 + shimmerShift * 2.0, -0.8),
      end: Alignment(-0.2 + shimmerShift * 2.0, 0.8),
      colors: [
        Colors.transparent,
        const Color(0xFFFF1744).withValues(alpha: 0.28),
        const Color(0xFFFFD700).withValues(alpha: 0.36),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 0.55, 1.0],
    ).createShader(dressRect);

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(dressRect, const Radius.circular(18)),
    );
    canvas.drawRect(
      dressRect,
      Paint()
        ..shader = sequinShader
        ..blendMode = BlendMode.plus,
    );

    // Individual sparkling crimson/gold sequin glints on her gown
    for (int i = 0; i < 7; i++) {
      final glintPhase = (phase * 2.2 + i * 1.1);
      final alpha = ((math.sin(glintPhase) + 1.0) * 0.5).clamp(0.0, 1.0);
      if (alpha > 0.55) {
        final gx = dressRect.left + ((i * 37) % 100) / 100.0 * dressRect.width;
        final gy = dressRect.top + ((i * 53) % 100) / 100.0 * dressRect.height;
        canvas.drawCircle(
          Offset(gx, gy),
          2.2 * alpha,
          Paint()..color = const Color(0xFFFFF59D).withValues(alpha: alpha),
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LeftFlankPaparazziDuoPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.flashPulse != flashPulse;
}

/// Right-Flank Hype VIP Entourage (`13015.jpg`):
/// - Pinstripe agent with sweeping specular reflection across his sunglasses.
/// - Hyped fan with a glowing/recording cyan smartphone screen.
/// - Blonde starlet with an animated clapping loop and gold sequin sparkles.
class RightFlankVipEntourageRig extends StatelessWidget {
  final double externalPhase;

  const RightFlankVipEntourageRig({
    super.key,
    required this.externalPhase,
  });

  @override
  Widget build(BuildContext context) {
    final breatheY = math.cos(externalPhase * 1.5) * 2.0;

    return Transform.translate(
      offset: Offset(0, breatheY),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF43F5E), width: 1.8),
        ),
        child: Native4KLiving25DImage(
          assetPath: Living25DAssetPaths.rightFlankVipEntourage13015,
          borderRadius: BorderRadius.circular(12),
          overlayPainterWidget: CustomPaint(
            painter: _RightFlankVipEntouragePainter(phase: externalPhase),
          ),
        ),
      ),
    );
  }
}

class _RightFlankVipEntouragePainter extends CustomPainter {
  final double phase;

  const _RightFlankVipEntouragePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Pinstripe Agent Sunglasses Sweeping Reflection (upper-left of 13015.jpg)
    final shadesRect = Rect.fromCenter(
      center: Offset(size.width * 0.25, size.height * 0.25),
      width: size.width * 0.26,
      height: size.height * 0.06,
    );
    final sweepT = ((phase / (2 * math.pi)) * 1.6) % 1.0;
    final sweepX = shadesRect.left + shadesRect.width * sweepT;
    final glarePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.92),
          const Color(0xFFFFD700).withValues(alpha: 0.55),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(sweepX, shadesRect.center.dy),
          radius: size.width * 0.12,
        ),
      );
    canvas.drawCircle(
      Offset(sweepX, shadesRect.center.dy),
      size.width * 0.12,
      glarePaint,
    );

    // 2. Fan's Glowing/Recording Cyan Smartphone Screen (center of 13015.jpg)
    final phoneCenter = Offset(size.width * 0.45, size.height * 0.40);
    final cyanPulse = 0.65 + 0.35 * math.sin(phase * 4.0);
    final phoneGlowRadius = size.width * 0.16 * cyanPulse;
    canvas.drawCircle(
      phoneCenter,
      phoneGlowRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF00E5FF).withValues(alpha: 0.68 * cyanPulse),
            const Color(0xFF00E5FF).withValues(alpha: 0.22 * cyanPulse),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: phoneCenter, radius: phoneGlowRadius),
        ),
    );
    // Blinking crimson REC dot on the fan's smartphone
    if (math.sin(phase * 5.0) > 0) {
      canvas.drawCircle(
        Offset(phoneCenter.dx + size.width * 0.02, phoneCenter.dy - 4),
        2.5,
        Paint()..color = const Color(0xFFFF1744),
      );
    }

    // 3. Starlet Animated Clapping Loop (right side of 13015.jpg)
    final clapHandsCenter = Offset(size.width * 0.70, size.height * 0.44);
    final clapBeat = (math.sin(phase * 6.0) + 1.0) * 0.5;
    if (clapBeat > 0.62) {
      final burstFactor = (clapBeat - 0.62) / 0.38;
      final clapRadius = size.width * (0.06 + burstFactor * 0.12);
      final clapPaint = Paint()
        ..color = const Color(
          0xFFFFD700,
        ).withValues(alpha: (1.0 - burstFactor) * 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(clapHandsCenter, clapRadius, clapPaint);

      // Comic clap impact lines radiating from her hands
      for (int i = 0; i < 6; i++) {
        final angle = i * (math.pi / 3) + 0.3;
        final r1 = clapRadius * 0.7;
        final r2 = clapRadius * 1.25;
        canvas.drawLine(
          Offset(
            clapHandsCenter.dx + math.cos(angle) * r1,
            clapHandsCenter.dy + math.sin(angle) * r1,
          ),
          Offset(
            clapHandsCenter.dx + math.cos(angle) * r2,
            clapHandsCenter.dy + math.sin(angle) * r2,
          ),
          clapPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RightFlankVipEntouragePainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _FirstPersonRedCarpetPovShaderPainter extends CustomPainter {
  final double phase;
  final double scrollOffset;
  final double flashPulse;

  const _FirstPersonRedCarpetPovShaderPainter({
    required this.phase,
    required this.scrollOffset,
    required this.flashPulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Sweeping golden searchlight beams across the upper sky of 13017.jpg
    final leftBeamSwing = math.sin(phase * 0.8) * size.width * 0.18;
    final rightBeamSwing = math.cos(phase * 0.9) * size.width * 0.18;
    final horizonY = size.height * 0.34;

    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFFFFD700).withValues(alpha: 0.22),
          const Color(0xFF00E5FF).withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);

    final leftBeam = Path()
      ..moveTo(size.width * 0.24, horizonY)
      ..lineTo(size.width * 0.15 + leftBeamSwing, 0)
      ..lineTo(size.width * 0.42 + leftBeamSwing, 0)
      ..close();
    canvas.drawPath(leftBeam, beamPaint);

    final rightBeam = Path()
      ..moveTo(size.width * 0.76, horizonY)
      ..lineTo(size.width * 0.58 + rightBeamSwing, 0)
      ..lineTo(size.width * 0.85 + rightBeamSwing, 0)
      ..close();
    canvas.drawPath(rightBeam, beamPaint);

    // Synchronized Paparazzi Flashes along both sides of the velvet rope
    final flashPositions = <Offset>[
      Offset(size.width * 0.18, size.height * 0.46),
      Offset(size.width * 0.82, size.height * 0.44),
      Offset(size.width * 0.14, size.height * 0.62),
      Offset(size.width * 0.86, size.height * 0.60),
    ];

    for (int i = 0; i < flashPositions.length; i++) {
      final localFlash =
          ((math.sin(phase * 3.2 + i * 1.7) - 0.6) / 0.4).clamp(0.0, 1.0);
      final combined = math.max(localFlash, flashPulse * 0.85);
      if (combined > 0.05) {
        final pos = flashPositions[i];
        final r = size.width * (0.09 + combined * 0.12);
        canvas.drawCircle(
          pos,
          r,
          Paint()
            ..shader = RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.9 * combined),
                const Color(0xFFFFF59D).withValues(alpha: 0.55 * combined),
                Colors.transparent,
              ],
            ).createShader(Rect.fromCircle(center: pos, radius: r)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant _FirstPersonRedCarpetPovShaderPainter oldDelegate,
  ) =>
      oldDelegate.phase != phase ||
      oldDelegate.scrollOffset != scrollOffset ||
      oldDelegate.flashPulse != flashPulse;
}

class _ScreenFlashVignettePulsePainter extends CustomPainter {
  final double intensity;

  const _ScreenFlashVignettePulsePainter({required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final alpha = intensity.clamp(0.0, 1.0);
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.95,
        colors: [
          Colors.transparent,
          const Color(0xFFFFF59D).withValues(alpha: alpha * 0.24),
          Colors.white.withValues(alpha: alpha * 0.52),
        ],
        stops: const [0.45, 0.80, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _ScreenFlashVignettePulsePainter oldDelegate) =>
      oldDelegate.intensity != intensity;
}

// ============================================================================
// 2. REUSABLE HERO CHARACTERS (5-LAYER 2.5D LIVING PORTRAIT ENGINE:
//    13012.jpg, 13014.jpg, 13013.jpg)
// ============================================================================

/// 5-Layer 2.5D Living Portrait Engine for the Reusable Hero Characters:
/// 1. Layer 1 — Parallax Shadow (dynamic depth shadow beneath the character rig)
/// 2. Layer 2 — Breathing Torso (smooth vertical breathing expansion in locked 768:1376 ratio)
/// 3. Layer 3 — Articulated Head Micro-Tilt (subtle harmonic head nod/tilt transform)
/// 4. Layer 4 — Blinking Eyes (periodic natural eyelid blink & eye specular glint)
/// 5. Layer 5 — Active Prop Shader:
///    - `13012.jpg` (Undercover Speakeasy Improviser): Pulsing neon-violet glow &
///      rising smoke on the `"CONFIDENTIAL"` dossier card behind his back.
///    - `13014.jpg` (Ruthless Casting Director): Sweeping specular 24K gold sheen
///      across her clipboard and held designer glasses + rhythmic pen-tapping loop.
///    - `13013.jpg` (Lead A & Lead B Screen Test Rivals): Split-screen duel with
///      opposing breathing cycles + center clapperboard snapping shut on an interval,
///      emitting 2.5D particle sparks across the split threshold.
class Living25DHeroCharacterRig extends StatefulWidget {
  final Living25DHeroCharacterType characterType;
  final VoidCallback? onTap;
  final bool showCaptionBadge;

  const Living25DHeroCharacterRig({
    super.key,
    required this.characterType,
    this.onTap,
    this.showCaptionBadge = true,
  });

  @override
  State<Living25DHeroCharacterRig> createState() =>
      _Living25DHeroCharacterRigState();
}

class _Living25DHeroCharacterRigState extends State<Living25DHeroCharacterRig>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _assetPath {
    switch (widget.characterType) {
      case Living25DHeroCharacterType.undercoverSpeakeasyImproviser:
        return Living25DAssetPaths.undercoverSpeakeasyImproviser13012;
      case Living25DHeroCharacterType.ruthlessCastingDirector:
        return Living25DAssetPaths.ruthlessCastingDirector13014;
      case Living25DHeroCharacterType.screenTestRivalsDuel:
        return Living25DAssetPaths.screenTestRivalsDuel13013;
    }
  }

  String get _title {
    switch (widget.characterType) {
      case Living25DHeroCharacterType.undercoverSpeakeasyImproviser:
        return 'THE UNDERCOVER SPEAKEASY IMPROVISER';
      case Living25DHeroCharacterType.ruthlessCastingDirector:
        return 'THE RUTHLESS CASTING DIRECTOR';
      case Living25DHeroCharacterType.screenTestRivalsDuel:
        return 'LEAD A & LEAD B · SCREEN TEST RIVALS';
    }
  }

  String get _subtitle {
    switch (widget.characterType) {
      case Living25DHeroCharacterType.undercoverSpeakeasyImproviser:
        return 'CONFIDENTIAL DOSSIER · NEON-VIOLET SMOKE RIG';
      case Living25DHeroCharacterType.ruthlessCastingDirector:
        return '24K CLIPBOARD SHEEN · IMPATIENT PEN-TAP LOOP';
      case Living25DHeroCharacterType.screenTestRivalsDuel:
        return 'OPPOSING BREATHING · CLAPPER SPARK DUEL';
    }
  }

  Color get _accentColor {
    switch (widget.characterType) {
      case Living25DHeroCharacterType.undercoverSpeakeasyImproviser:
        return const Color(0xFFD500F9);
      case Living25DHeroCharacterType.ruthlessCastingDirector:
        return const Color(0xFFFFD700);
      case Living25DHeroCharacterType.screenTestRivalsDuel:
        return const Color(0xFF00E5FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final phase = t * 2 * math.pi;

          // Layer 2 & 3: Breathing Torso + Articulated Head Micro-Tilt
          final breatheCycle = math.sin(phase);
          final torsoTranslateY = breatheCycle * -2.8;
          final torsoScaleY = 1.0 + (breatheCycle * 0.012);
          final headTiltZ = math.sin(phase * 0.5) * 0.012;

          // Layer 1: Parallax Shadow offset
          final shadowOffsetX = 5.0 + math.sin(phase) * 2.5;
          final shadowOffsetY = 6.0 + math.cos(phase) * 2.5;

          final rigMatrix = Matrix4.identity()
            ..setEntry(3, 2, 0.0014)
            ..translate(0.0, torsoTranslateY)
            ..rotateZ(headTiltZ)
            ..scale(1.0, torsoScaleY, 1.0);

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                // Layer 1: Dynamic 2.5D Parallax Shadow
                BoxShadow(
                  color: const Color(0xFF04060A),
                  offset: Offset(shadowOffsetX, shadowOffsetY),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: _accentColor.withValues(
                    alpha: 0.28 + 0.14 * ((breatheCycle + 1) * 0.5),
                  ),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF070910),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _accentColor, width: 2.2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Native 768:1376 4K 5-Layer Portrait Canvas
                    Transform(
                      alignment: Alignment.bottomCenter,
                      transform: rigMatrix,
                      child: Native4KLiving25DImage(
                        assetPath: _assetPath,
                        overlayPainterWidget: CustomPaint(
                          painter: _HeroCharacter5LayerOverlayPainter(
                            characterType: widget.characterType,
                            phase: phase,
                            normalizedTime: t,
                          ),
                        ),
                      ),
                    ),
                    if (widget.showCaptionBadge)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xF207090E),
                          border: Border(
                            top: BorderSide(
                              color: Color(0x33FFFFFF),
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _title,
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 15,
                                  letterSpacing: 1.1,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _subtitle,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  color: _accentColor,
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
          );
        },
      ),
    );
  }
}

class _HeroCharacter5LayerOverlayPainter extends CustomPainter {
  final Living25DHeroCharacterType characterType;
  final double phase;
  final double normalizedTime;

  const _HeroCharacter5LayerOverlayPainter({
    required this.characterType,
    required this.phase,
    required this.normalizedTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Layer 4: Natural Blinking Eyes & Eye Specular Glint (periodic 140ms blink)
    final isBlinking =
        (normalizedTime > 0.46 && normalizedTime < 0.495) ||
        (normalizedTime > 0.92 && normalizedTime < 0.95);

    switch (characterType) {
      case Living25DHeroCharacterType.undercoverSpeakeasyImproviser:
        _paintUndercoverSpeakeasyImproviser(canvas, size, isBlinking);
        break;
      case Living25DHeroCharacterType.ruthlessCastingDirector:
        _paintRuthlessCastingDirector(canvas, size, isBlinking);
        break;
      case Living25DHeroCharacterType.screenTestRivalsDuel:
        _paintScreenTestRivalsDuel(canvas, size, isBlinking);
        break;
    }
  }

  /// 13012.jpg — The Undercover Speakeasy Improviser:
  /// - Smooth vertical breathing highlight beneath his black turtleneck.
  /// - Pulsing neon-violet glow and rising smoke wisps on the `"CONFIDENTIAL"`
  ///   dossier card behind his back.
  void _paintUndercoverSpeakeasyImproviser(
    Canvas canvas,
    Size size,
    bool isBlinking,
  ) {
    // Turtleneck breathing rim highlight
    final breathAlpha = 0.14 + 0.10 * ((math.sin(phase) + 1.0) * 0.5);
    final torsoRect = Rect.fromCenter(
      center: Offset(size.width * 0.48, size.height * 0.56),
      width: size.width * 0.44,
      height: size.height * 0.28,
    );
    canvas.drawOval(
      torsoRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: breathAlpha),
            Colors.transparent,
          ],
        ).createShader(torsoRect),
    );

    // Eye blink / glint
    final leftEye = Offset(size.width * 0.42, size.height * 0.255);
    final rightEye = Offset(size.width * 0.53, size.height * 0.255);
    _drawEyeBlinkOrGlint(canvas, leftEye, rightEye, isBlinking);

    // Active Prop: "CONFIDENTIAL" Dossier Card behind his back (bottom-left of 13012.jpg)
    final cardCenter = Offset(size.width * 0.24, size.height * 0.72);
    final violetPulse = 0.60 + 0.40 * math.sin(phase * 2.5);
    final glowRadius = size.width * (0.24 + 0.06 * violetPulse);

    canvas.drawCircle(
      cardCenter,
      glowRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFE040FB).withValues(alpha: 0.62 * violetPulse),
            const Color(0xFF7C4DFF).withValues(alpha: 0.28 * violetPulse),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: cardCenter, radius: glowRadius)),
    );

    // Rising neon-violet smoke wisps ascending from the CONFIDENTIAL card
    for (int i = 0; i < 4; i++) {
      final wispProgress = ((normalizedTime * 1.5) + i * 0.25) % 1.0;
      final startX = cardCenter.dx + (i - 1.5) * (size.width * 0.045);
      final startY = cardCenter.dy + size.height * 0.04;
      final endY = cardCenter.dy - size.height * (0.16 + wispProgress * 0.14);
      final sway = math.sin(phase * 2.0 + i) * (size.width * 0.04);

      final smokePath = Path()
        ..moveTo(startX, startY)
        ..cubicTo(
          startX - sway,
          startY - (startY - endY) * 0.35,
          startX + sway,
          startY - (startY - endY) * 0.70,
          startX + sway * 0.5,
          endY,
        );

      final smokeAlpha = math.sin(wispProgress * math.pi) * 0.65;
      canvas.drawPath(
        smokePath,
        Paint()
          ..color = const Color(0xFFEA80FC).withValues(alpha: smokeAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  /// 13014.jpg — The Ruthless Casting Director:
  /// - Sweeping specular 24K gold sheen across her clipboard and held designer glasses.
  /// - Impatient, rhythmic pen-tapping loop on her right hand.
  void _paintRuthlessCastingDirector(
    Canvas canvas,
    Size size,
    bool isBlinking,
  ) {
    final leftEye = Offset(size.width * 0.45, size.height * 0.245);
    final rightEye = Offset(size.width * 0.54, size.height * 0.245);
    _drawEyeBlinkOrGlint(canvas, leftEye, rightEye, isBlinking);

    // 1. Sweeping 24K gold specular sheen across her lap clipboard (bottom-center of 13014.jpg)
    final clipboardRect = Rect.fromCenter(
      center: Offset(size.width * 0.45, size.height * 0.72),
      width: size.width * 0.36,
      height: size.height * 0.18,
    );
    final sheenSweep = ((normalizedTime * 1.8) % 1.0) * 2.4 - 1.2;
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(clipboardRect, const Radius.circular(12)),
    );
    canvas.drawRect(
      clipboardRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(sheenSweep - 0.35, -0.8),
          end: Alignment(sheenSweep + 0.35, 0.8),
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.65),
            const Color(0xFFFFD700).withValues(alpha: 0.75),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 0.55, 1.0],
        ).createShader(clipboardRect),
    );
    canvas.restore();

    // 2. Sweeping specular glint on her held designer glasses (middle-right of 13014.jpg)
    final glassesCenter = Offset(size.width * 0.68, size.height * 0.50);
    final glassesPulse = ((math.sin(phase * 2.2) + 1.0) * 0.5);
    final glintRadius = size.width * (0.06 + 0.05 * glassesPulse);
    canvas.drawCircle(
      glassesCenter,
      glintRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.85 * glassesPulse),
            const Color(0xFFFFD700).withValues(alpha: 0.45 * glassesPulse),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: glassesCenter, radius: glintRadius),
        ),
    );

    // 3. Impatient rhythmic pen-tapping loop on her hand (upper-left near chin of 13014.jpg)
    final penTipPivot = Offset(size.width * 0.36, size.height * 0.34);
    final tapAngle = math.sin(phase * 6.0) * 0.22;
    final tapBeat = (math.sin(phase * 6.0) > 0.75);

    canvas.save();
    canvas.translate(penTipPivot.dx, penTipPivot.dy);
    canvas.rotate(tapAngle);
    canvas.drawLine(
      const Offset(-14, 6),
      const Offset(8, -6),
      Paint()
        ..color = const Color(0xFFFFD700)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    if (tapBeat) {
      // Rhythmic comic "TAP!" impact arcs around the gold pen tip
      final arcPaint = Paint()
        ..color = const Color(0xFFFFF59D).withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      canvas.drawArc(
        Rect.fromCircle(center: penTipPivot, radius: 10),
        -math.pi * 0.8,
        math.pi * 0.6,
        false,
        arcPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: penTipPivot, radius: 15),
        -math.pi * 0.75,
        math.pi * 0.5,
        false,
        arcPaint,
      );
    }
  }

  /// 13013.jpg — Lead A & Lead B Screen Test Rivals:
  /// - Split-screen duel with dynamic opposing breathing cycles.
  /// - Center clapperboard snaps shut on an interval, emitting 2.5D particle
  ///   sparks that cross the split threshold.
  void _paintScreenTestRivalsDuel(
    Canvas canvas,
    Size size,
    bool isBlinking,
  ) {
    // Opposing breathing aura for Lead A (left, gold/crimson) vs Lead B (right, cyan)
    final leadABreath = (math.sin(phase * 2.0) + 1.0) * 0.5;
    final leadBBreath = (math.sin(phase * 2.0 + math.pi) + 1.0) * 0.5;

    final leadARect = Rect.fromLTWH(
      0,
      size.height * 0.15,
      size.width * 0.48,
      size.height * 0.55,
    );
    final leadBRect = Rect.fromLTWH(
      size.width * 0.52,
      size.height * 0.15,
      size.width * 0.48,
      size.height * 0.55,
    );

    canvas.drawOval(
      leadARect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.18 * leadABreath),
            Colors.transparent,
          ],
        ).createShader(leadARect),
    );
    canvas.drawOval(
      leadBRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF00E5FF).withValues(alpha: 0.18 * leadBBreath),
            Colors.transparent,
          ],
        ).createShader(leadBRect),
    );

    // Center Clapperboard Snap & Cross-Threshold Particle Sparks
    final clapperCenter = Offset(size.width * 0.50, size.height * 0.74);
    final snapWindow = (normalizedTime * 2.0) % 1.0;
    final isSnapping = snapWindow < 0.38;

    if (isSnapping) {
      final burstT = (snapWindow / 0.38).clamp(0.0, 1.0);
      final sparkCount = 14;
      for (int i = 0; i < sparkCount; i++) {
        final angle = (i / sparkCount) * 2 * math.pi + 0.25;
        final dist = size.width * (0.06 + burstT * 0.34);
        final sx = clapperCenter.dx + math.cos(angle) * dist;
        final sy = clapperCenter.dy + math.sin(angle) * dist;
        final sparkColor = i.isEven
            ? const Color(0xFFFFD700)
            : const Color(0xFF00E5FF);

        canvas.drawCircle(
          Offset(sx, sy),
          (3.6 * (1.0 - burstT)).clamp(1.0, 4.0),
          Paint()
            ..color = sparkColor.withValues(alpha: (1.0 - burstT))
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }

      // Shockwave ring across the split threshold
      canvas.drawCircle(
        clapperCenter,
        size.width * 0.28 * burstT,
        Paint()
          ..color = const Color(0xFFFFF59D).withValues(alpha: 1.0 - burstT)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6 * (1.0 - burstT),
      );
    }
  }

  void _drawEyeBlinkOrGlint(
    Canvas canvas,
    Offset leftEye,
    Offset rightEye,
    bool isBlinking,
  ) {
    if (isBlinking) {
      final lidPaint = Paint()
        ..color = const Color(0xFF1A0F0A)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        leftEye.translate(-5, 0),
        leftEye.translate(5, 0),
        lidPaint,
      );
      canvas.drawLine(
        rightEye.translate(-5, 0),
        rightEye.translate(5, 0),
        lidPaint,
      );
    } else {
      final glintPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.85);
      canvas.drawCircle(leftEye.translate(1.5, -1.0), 1.6, glintPaint);
      canvas.drawCircle(rightEye.translate(1.5, -1.0), 1.6, glintPaint);
    }
  }

  @override
  bool shouldRepaint(
    covariant _HeroCharacter5LayerOverlayPainter oldDelegate,
  ) =>
      oldDelegate.phase != phase ||
      oldDelegate.normalizedTime != normalizedTime ||
      oldDelegate.characterType != characterType;
}

/// Horizontal/Grid Showcase of the 3 Reusable 2.5D Hero Character Rigs (`13012.jpg`, `13014.jpg`, `13013.jpg`)
/// in their locked native `768:1376` aspect ratio.
class Living25DHeroCharactersTrioSection extends StatelessWidget {
  final void Function(Living25DHeroCharacterType type)? onCharacterSelected;

  const Living25DHeroCharactersTrioSection({
    super.key,
    this.onCharacterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xEB120A1E), Color(0xEB070910)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700), width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF05070B),
            offset: Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.theater_comedy_rounded,
                color: Color(0xFFFFD700),
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '🎭 5-LAYER 2.5D LIVING HERO PORTRAITS · 60FPS NATIVE RIGS',
                    style: GoogleFonts.chakraPetch(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Living25DHeroCharacterRig(
                  characterType:
                      Living25DHeroCharacterType.undercoverSpeakeasyImproviser,
                  onTap: () => onCharacterSelected?.call(
                    Living25DHeroCharacterType.undercoverSpeakeasyImproviser,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Living25DHeroCharacterRig(
                  characterType:
                      Living25DHeroCharacterType.ruthlessCastingDirector,
                  onTap: () => onCharacterSelected?.call(
                    Living25DHeroCharacterType.ruthlessCastingDirector,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Living25DHeroCharacterRig(
                  characterType:
                      Living25DHeroCharacterType.screenTestRivalsDuel,
                  onTap: () => onCharacterSelected?.call(
                    Living25DHeroCharacterType.screenTestRivalsDuel,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 3. INTERACTIVE UI PROPS & GAME MODE CARDS (60FPS TACTILE PROP LOOPS:
//    13010.jpg, 13008.jpg, 13009.jpg, 13011.jpg, 13007.jpg)
// ============================================================================

/// Renders any of the 5 finalized 2.5D Interactive Prop & Game Mode Card assets
/// in its exact native `768:1376` (`1536:2752`) aspect ratio with a dedicated
/// 60fps `CustomPainter` + `Matrix4` animation rig.
class Living25DAnimatedPropRig extends StatefulWidget {
  final Living25DPropCardType propType;
  final double? externalPhase;
  final VoidCallback? onTap;

  const Living25DAnimatedPropRig({
    super.key,
    required this.propType,
    this.externalPhase,
    this.onTap,
  });

  @override
  State<Living25DAnimatedPropRig> createState() =>
      _Living25DAnimatedPropRigState();
}

class _Living25DAnimatedPropRigState extends State<Living25DAnimatedPropRig>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _assetPath {
    switch (widget.propType) {
      case Living25DPropCardType.writersRoomTypewriter:
        return Living25DAssetPaths.writersRoomTypewriter13010;
      case Living25DPropCardType.speakeasyDareWheel:
        return Living25DAssetPaths.speakeasyDareWheel13008;
      case Living25DPropCardType.cuttingRoomReelShears:
        return Living25DAssetPaths.cuttingRoomReelShears13009;
      case Living25DPropCardType.luxuryHollywoodClapperboard:
        return Living25DAssetPaths.luxuryClapperboard13011;
      case Living25DPropCardType.oscarTrophyVipBoxOffice:
        return Living25DAssetPaths.oscarTrophyVipBoxOffice13007;
    }
  }

  Color get _borderColor {
    switch (widget.propType) {
      case Living25DPropCardType.writersRoomTypewriter:
        return const Color(0xFF00E5FF);
      case Living25DPropCardType.speakeasyDareWheel:
        return const Color(0xFFE040FB);
      case Living25DPropCardType.cuttingRoomReelShears:
        return const Color(0xFFFF1744);
      case Living25DPropCardType.luxuryHollywoodClapperboard:
        return const Color(0xFFFFD700);
      case Living25DPropCardType.oscarTrophyVipBoxOffice:
        return const Color(0xFFF5DEB3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final phase = widget.externalPhase ?? (t * 2 * math.pi);

        // Subtle floating hover for the prop container
        final floatY = math.sin(phase * 1.2) * 2.4;
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0014)
          ..translate(0.0, floatY);

        Widget card = Transform(
          alignment: Alignment.center,
          transform: matrix,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor, width: 2.2),
              boxShadow: [
                const BoxShadow(
                  color: Color(0xFF05070B),
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: _borderColor.withValues(alpha: 0.30),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Native4KLiving25DImage(
              assetPath: _assetPath,
              borderRadius: BorderRadius.circular(14),
              overlayPainterWidget: CustomPaint(
                painter: _PropCardTactileLoopPainter(
                  propType: widget.propType,
                  phase: phase,
                  normalizedTime: t,
                ),
              ),
            ),
          ),
        );

        if (widget.onTap != null) {
          card = GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.onTap!();
            },
            child: card,
          );
        }
        return card;
      },
    );
  }
}

class _PropCardTactileLoopPainter extends CustomPainter {
  final Living25DPropCardType propType;
  final double phase;
  final double normalizedTime;

  const _PropCardTactileLoopPainter({
    required this.propType,
    required this.phase,
    required this.normalizedTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    switch (propType) {
      case Living25DPropCardType.writersRoomTypewriter:
        _paintWritersRoomTypewriter(canvas, size);
        break;
      case Living25DPropCardType.speakeasyDareWheel:
        _paintSpeakeasyDareWheel(canvas, size);
        break;
      case Living25DPropCardType.cuttingRoomReelShears:
        _paintCuttingRoomReelShears(canvas, size);
        break;
      case Living25DPropCardType.luxuryHollywoodClapperboard:
        _paintLuxuryHollywoodClapperboard(canvas, size);
        break;
      case Living25DPropCardType.oscarTrophyVipBoxOffice:
        _paintOscarTrophyVipBoxOffice(canvas, size);
        break;
    }
  }

  /// 13010.jpg — The Writer's Room Typewriter:
  /// - Mechanical keys rhythmically clacking down.
  /// - Glowing golden screenplay pages swirling and floating upward along a Bezier path.
  /// - Espresso cup on the bottom-left emitting rising translucent wispy steam.
  void _paintWritersRoomTypewriter(Canvas canvas, Size size) {
    // 1. Mechanical keys clacking down (keyboard zone of 13010.jpg)
    final keyRowY = size.height * 0.72;
    const int keyCount = 8;
    final activeKeyIndex = ((normalizedTime * 16).floor()) % keyCount;
    for (int i = 0; i < keyCount; i++) {
      final kx = size.width * (0.28 + (i / (keyCount - 1)) * 0.44);
      final isClacking = i == activeKeyIndex;
      final ky = keyRowY + (isClacking ? 3.5 : 0.0);
      canvas.drawCircle(
        Offset(kx, ky),
        isClacking ? 4.2 : 2.6,
        Paint()
          ..color = isClacking
              ? const Color(0xFFFFD700)
              : const Color(0x66F5DEB3),
      );
      if (isClacking) {
        // Tiny gold mechanical strike spark at the platen roller
        canvas.drawCircle(
          Offset(size.width * 0.50, size.height * 0.58),
          5.0,
          Paint()
            ..color = const Color(0xFF00E5FF).withValues(alpha: 0.75)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }

    // 2. Glowing golden screenplay pages swirling upward along a cubic Bezier path
    final bezierPath = Path()
      ..moveTo(size.width * 0.50, size.height * 0.56)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.42,
        size.width * 0.76,
        size.height * 0.26,
        size.width * 0.48,
        size.height * 0.08,
      );

    final metrics = bezierPath.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final PathMetric metric = metrics.first;
      for (int p = 0; p < 3; p++) {
        final pageProgress = ((normalizedTime + p * 0.33) % 1.0);
        final tangent = metric.getTangentForOffset(
          metric.length * pageProgress,
        );
        if (tangent != null) {
          final pos = tangent.position;
          final alpha = math.sin(pageProgress * math.pi).clamp(0.0, 1.0);
          canvas.save();
          canvas.translate(pos.dx, pos.dy);
          canvas.rotate(tangent.angle * 0.35 + math.sin(phase + p) * 0.2);
          final pageRect = Rect.fromCenter(
            center: Offset.zero,
            width: size.width * 0.14,
            height: size.width * 0.18,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(pageRect, const Radius.circular(3)),
            Paint()
              ..color = const Color(
                0xFFFFD700,
              ).withValues(alpha: 0.45 * alpha)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(pageRect, const Radius.circular(3)),
            Paint()
              ..color = const Color(0xFF00E5FF).withValues(alpha: 0.75 * alpha)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4,
          );
          canvas.restore();
        }
      }
    }

    // 3. Espresso cup emitting rising translucent wispy steam (bottom-left of 13010.jpg)
    final cupRim = Offset(size.width * 0.17, size.height * 0.77);
    for (int s = 0; s < 3; s++) {
      final steamT = ((normalizedTime * 1.4) + s * 0.33) % 1.0;
      final steamStartX = cupRim.dx + (s - 1) * 5.0;
      final steamEndY = cupRim.dy - size.height * (0.09 + steamT * 0.08);
      final curl = math.sin(phase * 2.0 + s) * 7.0;

      final steamPath = Path()
        ..moveTo(steamStartX, cupRim.dy)
        ..quadraticBezierTo(
          steamStartX + curl,
          cupRim.dy - (cupRim.dy - steamEndY) * 0.5,
          steamStartX - curl * 0.5,
          steamEndY,
        );

      canvas.drawPath(
        steamPath,
        Paint()
          ..color = Colors.white.withValues(
            alpha: math.sin(steamT * math.pi) * 0.55,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  /// 13008.jpg — 18+ Speakeasy Dare Wheel:
  /// - Brass-and-violet casino wheel continuously spinning behind the glowing golden keyhole.
  /// - Pulsing keyhole core.
  /// - Metallic shimmer sweeping across the flanking masquerade masks.
  void _paintSpeakeasyDareWheel(Canvas canvas, Size size) {
    final wheelCenter = Offset(size.width * 0.50, size.height * 0.52);
    final wheelRadius = size.width * 0.34;

    // 1. Continuously spinning brass-and-violet wheel spokes & rim behind the keyhole
    canvas.save();
    canvas.translate(wheelCenter.dx, wheelCenter.dy);
    canvas.rotate(phase);
    const int spokeCount = 12;
    for (int i = 0; i < spokeCount; i++) {
      final angle = (i / spokeCount) * 2 * math.pi;
      final spokeColor = i.isEven
          ? const Color(0xFFFFD700).withValues(alpha: 0.42)
          : const Color(0xFFE040FB).withValues(alpha: 0.42);
      canvas.drawLine(
        Offset(math.cos(angle) * (wheelRadius * 0.28), math.sin(angle) * (wheelRadius * 0.28)),
        Offset(math.cos(angle) * wheelRadius, math.sin(angle) * wheelRadius),
        Paint()
          ..color = spokeColor
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();

    // 2. Pulsing golden/cyan keyhole core at the wheel's center
    final keyholePulse = 0.65 + 0.35 * math.sin(phase * 3.2);
    final coreRadius = size.width * (0.12 + 0.05 * keyholePulse);
    canvas.drawCircle(
      wheelCenter,
      coreRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.92 * keyholePulse),
            const Color(0xFF00E5FF).withValues(alpha: 0.65 * keyholePulse),
            const Color(0xFFFFD700).withValues(alpha: 0.35 * keyholePulse),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: wheelCenter, radius: coreRadius)),
    );

    // 3. Metallic shimmer across the flanking masquerade masks (top-left, top-right, bottom-left)
    final maskCenters = <Offset>[
      Offset(size.width * 0.22, size.height * 0.22),
      Offset(size.width * 0.78, size.height * 0.23),
      Offset(size.width * 0.23, size.height * 0.79),
    ];
    for (int m = 0; m < maskCenters.length; m++) {
      final shimmer = ((math.sin(phase * 2.4 + m * 1.8) + 1.0) * 0.5);
      final mc = maskCenters[m];
      final mr = size.width * 0.13;
      canvas.drawCircle(
        mc,
        mr,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFF59D).withValues(alpha: 0.45 * shimmer),
              const Color(0xFFE040FB).withValues(alpha: 0.20 * shimmer),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: mc, radius: mr)),
      );
    }
  }

  /// 13009.jpg — The Cutting Room Reel & Shears:
  /// - 24K gold 35mm film reel rotating continuously.
  /// - Surrounding celluloid film strips rippling like ribbons.
  /// - Dynamic flickering flame shader (`CustomPainter`) for the floating neon crimson fire.
  void _paintCuttingRoomReelShears(Canvas canvas, Size size) {
    final reelCenter = Offset(size.width * 0.48, size.height * 0.47);
    final reelRadius = size.width * 0.26;

    // 1. Rotating 24K gold 35mm film reel sprockets & specular rim
    canvas.save();
    canvas.translate(reelCenter.dx, reelCenter.dy);
    canvas.rotate(phase);
    for (int i = 0; i < 6; i++) {
      final angle = i * (math.pi / 3);
      final holeCenter = Offset(
        math.cos(angle) * reelRadius * 0.58,
        math.sin(angle) * reelRadius * 0.58,
      );
      canvas.drawCircle(
        holeCenter,
        reelRadius * 0.14,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.38)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }
    canvas.restore();

    // 2. Surrounding celluloid film strips rippling like cyan/gold ribbons
    final ribbonPath = Path();
    final startY = size.height * 0.62;
    ribbonPath.moveTo(size.width * 0.12, startY);
    for (int x = 0; x <= 20; x++) {
      final t = x / 20.0;
      final px = size.width * (0.12 + t * 0.76);
      final py =
          startY +
          math.sin(t * math.pi * 3 + phase * 2.5) * (size.height * 0.025);
      ribbonPath.lineTo(px, py);
    }
    canvas.drawPath(
      ribbonPath,
      Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // 3. Dynamic flickering neon crimson flame shader (`CustomPainter`)
    final flameNodes = <Offset>[
      Offset(size.width * 0.20, size.height * 0.24),
      Offset(size.width * 0.80, size.height * 0.22),
      Offset(size.width * 0.18, size.height * 0.52),
      Offset(size.width * 0.82, size.height * 0.58),
      Offset(size.width * 0.50, size.height * 0.82),
    ];

    for (int f = 0; f < flameNodes.length; f++) {
      final base = flameNodes[f];
      final flicker = 0.65 + 0.35 * math.sin(phase * 5.0 + f * 1.3);
      final flameHeight = size.height * (0.055 * flicker);
      final flameSway = math.cos(phase * 4.0 + f) * 5.0;

      final flamePath = Path()
        ..moveTo(base.dx - 7, base.dy)
        ..quadraticBezierTo(
          base.dx - 9 + flameSway,
          base.dy - flameHeight * 0.6,
          base.dx + flameSway,
          base.dy - flameHeight,
        )
        ..quadraticBezierTo(
          base.dx + 9 + flameSway,
          base.dy - flameHeight * 0.6,
          base.dx + 7,
          base.dy,
        )
        ..close();

      canvas.drawPath(
        flamePath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              const Color(0xFFFF1744).withValues(alpha: 0.78),
              const Color(0xFFFF9100).withValues(alpha: 0.65),
              const Color(0xFFFFF59D).withValues(alpha: 0.25),
            ],
          ).createShader(
            Rect.fromLTWH(
              base.dx - 12,
              base.dy - flameHeight,
              24,
              flameHeight,
            ),
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  /// 13011.jpg — Luxury Hollywood Clapperboard:
  /// - Clapperboard hovering in the golden spotlight beam.
  /// - Hinge snaps shut sharply on an interval, releasing a burst of comic-style
  ///   gold stars and camera flash sparks.
  void _paintLuxuryHollywoodClapperboard(Canvas canvas, Size size) {
    final hingePivot = Offset(size.width * 0.24, size.height * 0.42);
    final clapperCenter = Offset(size.width * 0.50, size.height * 0.45);

    // Golden spotlight cone beam pulsing from top-left
    final beamPulse = 0.70 + 0.30 * math.sin(phase * 2.0);
    final spotlightPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.35, 0)
      ..lineTo(size.width * 0.90, size.height * 0.75)
      ..lineTo(size.width * 0.15, size.height * 0.85)
      ..close();
    canvas.drawPath(
      spotlightPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF59D).withValues(alpha: 0.24 * beamPulse),
            const Color(0xFFFFD700).withValues(alpha: 0.10 * beamPulse),
            Colors.transparent,
          ],
        ).createShader(Offset.zero & size),
    );

    // Periodic sharp hinge snap & comic gold star burst
    final snapCycle = (normalizedTime * 1.8) % 1.0;
    final isSnappingShut = snapCycle < 0.35;
    final barAngle = isSnappingShut
        ? -0.26 * (1.0 - (snapCycle / 0.35))
        : -0.26 * ((snapCycle - 0.35) / 0.65).clamp(0.0, 1.0);

    // Animated top clapper bar overlay
    canvas.save();
    canvas.translate(hingePivot.dx, hingePivot.dy);
    canvas.rotate(barAngle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, -8, size.width * 0.52, 8),
        const Radius.circular(3),
      ),
      Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.restore();

    if (snapCycle > 0.28 && snapCycle < 0.62) {
      final burstT = ((snapCycle - 0.28) / 0.34).clamp(0.0, 1.0);
      for (int i = 0; i < 8; i++) {
        final angle = (i / 8) * 2 * math.pi + 0.2;
        final dist = size.width * (0.10 + burstT * 0.32);
        final starPos = Offset(
          clapperCenter.dx + math.cos(angle) * dist,
          clapperCenter.dy + math.sin(angle) * dist,
        );
        _drawComicFourPointStar(
          canvas,
          starPos,
          (7.5 * (1.0 - burstT)).clamp(2.0, 8.0),
          const Color(0xFFFFF59D).withValues(alpha: 1.0 - burstT),
        );
      }
    }
  }

  /// 13007.jpg — 24K Oscar-Style Trophy & VIP Box Office:
  /// - Seamless loop of sparkling comic-book light flares traveling up the gold statuette.
  /// - Subtle floating idle animation on the stack of `"VIP BOX OFFICE ADMISSION"` tickets.
  void _paintOscarTrophyVipBoxOffice(Canvas canvas, Size size) {
    // 1. Sparkling comic-book light flares traveling up the 24K gold statuette
    final statuetteBottomY = size.height * 0.66;
    final statuetteTopY = size.height * 0.14;
    final statuetteCenterX = size.width * 0.43;

    for (int i = 0; i < 4; i++) {
      final travelT = ((normalizedTime + i * 0.25) % 1.0);
      final fy =
          statuetteBottomY - (statuetteBottomY - statuetteTopY) * travelT;
      final fx =
          statuetteCenterX + math.sin(travelT * math.pi * 2 + i) * (size.width * 0.06);
      final alpha = math.sin(travelT * math.pi).clamp(0.0, 1.0);

      _drawComicFourPointStar(
        canvas,
        Offset(fx, fy),
        4.5 + 4.5 * alpha,
        const Color(0xFFFFF59D).withValues(alpha: alpha),
      );
    }

    // 2. Subtle floating idle animation glow on the stack of "VIP BOX OFFICE ADMISSION" tickets (bottom-right)
    final ticketFloatY = math.sin(phase * 1.8) * 4.5;
    final ticketRect = Rect.fromCenter(
      center: Offset(size.width * 0.56, size.height * 0.84 + ticketFloatY),
      width: size.width * 0.52,
      height: size.height * 0.11,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(ticketRect, const Radius.circular(10)),
      Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  void _drawComicFourPointStar(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PropCardTactileLoopPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.normalizedTime != normalizedTime ||
      oldDelegate.propType != propType;
}
