import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../auth/auth_screen.dart';
import '../auth/auth_service.dart';
import '../auth/nda_tester_gate.dart';
import '../dashboard_marquee.dart';
import 'boondocks_character_rig.dart';
import 'brand_logo.dart';
import 'living_25d_animation_engine.dart';
import 'opening_maestro_hero.dart';
import 'transitions.dart';

export 'boondocks_character_rig.dart';
export 'brand_logo.dart';
export 'living_25d_animation_engine.dart';
export 'opening_maestro_hero.dart';

/// MODULE 1: Official 8-Second "ACT LIKE IT" Opening Video & Logo Climax
/// (`lib/ui/intro_cinematic.dart`).
/// - Plays `assets/videos/intro_opening.mp4` (`12871.mp4`) full-screen (`BoxFit.cover`)
///   with a 60fps CustomPainter Red Carpet + 14-character fallback.
/// - At `t = 1.2s`, triggers the clapperboard golden shockwave bloom +
///   `HapticFeedback.heavyImpact()` and locks `ActLikeItBrandLogo` (`Hero(tag: 'act_like_it_ulogo')`)
///   across the lower third.
/// - At 8.0s (or when `"SKIP TO SIGN IN"` is tapped), executes the 900ms
///   `BespokeTransitionEngine.navigateToAuthWithLogoGlide` transition directly
///   into `AuthScreen` while zooming the video canvas (`1.0 -> 1.08`).
class CellShadedIntroCinematicScreen extends StatefulWidget {
  const CellShadedIntroCinematicScreen({super.key});

  @override
  State<CellShadedIntroCinematicScreen> createState() =>
      _CellShadedIntroCinematicScreenState();
}

class _CellShadedIntroCinematicScreenState
    extends State<CellShadedIntroCinematicScreen>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _isVideoReady = false;

  late final AnimationController _walkController;
  late final AnimationController _climaxShockwaveController;
  late final AnimationController _exitZoomController;
  late final AudioPlayer _openingAudioPlayer;

  Timer? _climaxTriggerTimer;
  Timer? _autoAuthTransitionTimer;
  Timer? _spotlightCycleTimer;

  bool _hasTriggeredLogoClimax = false;
  bool _isTransitioningToAuth = false;
  bool _isMusicMuted = false;
  int _spotlightArchetypeIndex = 0;

  @override
  void initState() {
    super.initState();
    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _climaxShockwaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _exitZoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _openingAudioPlayer = AudioPlayer();
    _initializeOpeningVideoAndScore();

    // Slow character spotlight cycle (2.5s per character)
    _spotlightCycleTimer = Timer.periodic(
      const Duration(milliseconds: 2500),
      (_) {
        if (!mounted || _isTransitioningToAuth) return;
        setState(() {
          _spotlightArchetypeIndex =
              (_spotlightArchetypeIndex + 1) % kFourteenAvatarArchetypes.length;
        });
      },
    );

    // At t = 1.2s, trigger the clapperboard snap golden shockwave + Brand Logo lock-in
    _climaxTriggerTimer = Timer(const Duration(milliseconds: 1200), () {
      _triggerLogoClimaxOverlay();
    });

    // At t = 8.0s, automatically execute the 900ms Hero glide to AuthScreen
    _autoAuthTransitionTimer = Timer(const Duration(milliseconds: 8000), () {
      if (mounted && !_isTransitioningToAuth) {
        _triggerChoreographedGlideToAuth();
      }
    });
  }

  Future<void> _initializeOpeningVideoAndScore() async {
    try {
      final controller = VideoPlayerController.asset(
        'assets/videos/intro_opening.mp4',
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      _videoController = controller;
      await controller.initialize();
      await controller.setLooping(false);
      await controller.setVolume(_isMusicMuted ? 0.0 : 1.0);
      controller.addListener(_onVideoTick);
      if (mounted) {
        setState(() {
          _isVideoReady = true;
        });
        await controller.play();
      }
    } catch (_) {
      // Seamless fallback to synthesized premiere fanfare + 60fps CustomPainter
      _startFallbackPremiereScore();
    }
  }

  void _onVideoTick() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    final pos = controller.value.position;
    final dur = controller.value.duration;

    if (!_hasTriggeredLogoClimax &&
        pos >= const Duration(milliseconds: 1200)) {
      _triggerLogoClimaxOverlay();
    }

    if (!_isTransitioningToAuth &&
        dur > Duration.zero &&
        pos >= dur - const Duration(milliseconds: 120)) {
      _triggerChoreographedGlideToAuth();
    }
  }

  void _triggerLogoClimaxOverlay() {
    if (_hasTriggeredLogoClimax || !mounted) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _hasTriggeredLogoClimax = true;
    });
    _climaxShockwaveController.forward(from: 0.0);
  }

  Future<void> _startFallbackPremiereScore() async {
    try {
      await _openingAudioPlayer.setReleaseMode(ReleaseMode.loop);
      await _openingAudioPlayer.setVolume(_isMusicMuted ? 0.0 : 0.48);
      final wavBytes =
          OpeningPremiereMusicSynthesizer.buildOpeningFanfareWav();
      await _openingAudioPlayer.play(BytesSource(wavBytes));
    } catch (_) {}
  }

  Future<void> _toggleOpeningMusic() async {
    HapticFeedback.selectionClick();
    setState(() {
      _isMusicMuted = !_isMusicMuted;
    });
    try {
      await _videoController?.setVolume(_isMusicMuted ? 0.0 : 1.0);
      await _openingAudioPlayer.setVolume(_isMusicMuted ? 0.0 : 0.48);
    } catch (_) {}
  }

  @override
  void dispose() {
    _climaxTriggerTimer?.cancel();
    _autoAuthTransitionTimer?.cancel();
    _spotlightCycleTimer?.cancel();
    _videoController?.removeListener(_onVideoTick);
    _videoController?.dispose();
    _openingAudioPlayer.stop();
    _openingAudioPlayer.dispose();
    _walkController.dispose();
    _climaxShockwaveController.dispose();
    _exitZoomController.dispose();
    super.dispose();
  }

  Future<void> _handleFastSkipToRedCarpet() async {
    if (!OfficialClosedAlphaNdaGateWrapper.isSessionUnlockedSync()) return;
    if (_isTransitioningToAuth) return;
    _climaxTriggerTimer?.cancel();
    _autoAuthTransitionTimer?.cancel();
    HapticFeedback.heavyImpact();
    try {
      await _videoController?.pause();
      await _openingAudioPlayer.stop();
    } catch (_) {}

    await AuthService.instance.initialize();
    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 360),
        pageBuilder: (_, __, ___) => const LivingMarqueeDashboardScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  Future<void> _triggerChoreographedGlideToAuth() async {
    if (!OfficialClosedAlphaNdaGateWrapper.isSessionUnlockedSync()) return;
    if (_isTransitioningToAuth || !mounted) return;
    _climaxTriggerTimer?.cancel();
    _autoAuthTransitionTimer?.cancel();
    if (!_hasTriggeredLogoClimax) {
      setState(() {
        _hasTriggeredLogoClimax = true;
      });
    }
    HapticFeedback.heavyImpact();

    setState(() {
      _isTransitioningToAuth = true;
    });
    _exitZoomController.forward(from: 0.0);

    try {
      await _videoController?.pause();
      await _openingAudioPlayer.stop();
    } catch (_) {}

    if (!mounted) return;
    await BespokeTransitionEngine.navigateToAuthWithLogoGlide<void>(
      context: context,
      destination: const AuthScreen(),
      replace: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!OfficialClosedAlphaNdaGateWrapper.isSessionUnlockedSync()) {
      return const OfficialClosedAlphaNdaGateWrapper(
        child: CellShadedIntroCinematicScreen(),
      );
    }

    final activeArchetype =
        kFourteenAvatarArchetypes[_spotlightArchetypeIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _walkController,
          _climaxShockwaveController,
          _exitZoomController,
        ]),
        builder: (context, _) {
          final walkProgress = _walkController.value;
          final shockwaveT = _climaxShockwaveController.value;
          final zoomScale = 1.0 +
              Curves.easeOutCubic.transform(_exitZoomController.value) * 0.08;

          final stepBobY = math.sin(walkProgress * math.pi * 16) * 4.5;
          final stepSwayX = math.cos(walkProgress * math.pi * 8) * 3.5;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Layer 1: Official 8s Opening Video (BoxFit.cover) + 60fps Fallback
              Transform.scale(
                scale: zoomScale,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Transform.translate(
                      offset: Offset(stepSwayX, stepBobY),
                      child: RedCarpet25DParallaxEnvironment(
                        scrollOffset: walkProgress * 640.0,
                        scrollVelocity: 12.0,
                        extraFrenzyIntensity: shockwaveT,
                        showFlankCardsOverlay: true,
                      ),
                    ),
                    ..._buildRedCarpetAdvancingCharacterRigs(
                      context,
                      walkProgress,
                    ),
                    if (_isVideoReady &&
                        _videoController != null &&
                        _videoController!.value.isInitialized)
                      Positioned.fill(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          clipBehavior: Clip.hardEdge,
                          child: SizedBox(
                            width: _videoController!.value.size.width > 0
                                ? _videoController!.value.size.width
                                : 1080,
                            height: _videoController!.value.size.height > 0
                                ? _videoController!.value.size.height
                                : 1920,
                            child: VideoPlayer(_videoController!),
                          ),
                        ),
                      ),
                    // Subtle cinema vignette for legible HUD & Lower-Third Logo
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              const Color(0xFF05070B).withValues(alpha: 0.58),
                              Colors.transparent,
                              const Color(0xFF05070B).withValues(alpha: 0.86),
                            ],
                            stops: const <double>[0.0, 0.42, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Layer 2: Golden Clapperboard Shockwave Bloom at t = 1.2s
              if (shockwaveT > 0.0 && shockwaveT < 1.0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ClapperGoldenShockwavePainter(
                        progress: shockwaveT,
                      ),
                    ),
                  ),
                ),

              // Layer 3: Foreground HUD, Cast Spotlight & Lower-Third Unique Brand Logo
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Bar: Audio Toggle + Fast-Skip to Red Carpet + SKIP TO SIGN IN
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _toggleOpeningMusic,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xE607090E),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: _isMusicMuted
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFFFFD600),
                                  width: 2.0,
                                ),
                              ),
                              child: Icon(
                                _isMusicMuted
                                    ? Icons.volume_off_rounded
                                    : Icons.volume_up_rounded,
                                color: _isMusicMuted
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFFFFD600),
                                size: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: GestureDetector(
                              onTap: _handleFastSkipToRedCarpet,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xCC07090E),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: const Color(0x99F5DEB3),
                                    width: 1.6,
                                  ),
                                ),
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.bolt_rounded,
                                        color: Color(0xFFF5DEB3),
                                        size: 14,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'FAST-SKIP TO RED CARPET',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFF5DEB3),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Top-Right "SKIP TO SIGN IN" Glassmorphic Pill
                          GestureDetector(
                            onTap: _triggerChoreographedGlideToAuth,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 12,
                                  sigmaY: 12,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: <Color>[
                                        Color(0xEE520002),
                                        Color(0xEE07090E),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(0xFFFFD600),
                                      width: 2.2,
                                    ),
                                  ),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.skip_next_rounded,
                                          color: Color(0xFFFFD600),
                                          size: 15,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'SKIP TO SIGN IN',
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.6,
                                            color: Color(0xFFF5DEB3),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Lower-Third Signature Brand Logo Climax (t >= 1.2s)
                      AnimatedScale(
                        scale: _hasTriggeredLogoClimax ? 1.0 : 0.76,
                        duration: const Duration(milliseconds: 620),
                        curve: Curves.elasticOut,
                        child: AnimatedOpacity(
                          opacity: _hasTriggeredLogoClimax ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 340),
                          child: ActLikeItBrandLogo(
                            heroTag: kActLikeItBrandLogoHeroTag,
                            height: 158,
                            subtitle:
                                'OFFICIAL PREMIERE SOUNDSTAGE · TAP LOGO OR SIGN IN',
                            onTap: _triggerChoreographedGlideToAuth,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Compact 14-Character Red Carpet Spotlight Bar
                      GestureDetector(
                        onTap: () => showBoondocksCharacterSpotlightModal(
                          context,
                          activeArchetype,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xEB07090E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: activeArchetype.primaryInkColor,
                              width: 2.4,
                            ),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Color(0xFF05070B),
                                offset: Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              BoondocksCharacterRig(
                                archetype: activeArchetype,
                                size: 54,
                                isSelected: true,
                                externalPhase: walkProgress * math.pi * 4,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'CAST ${_spotlightArchetypeIndex + 1}/14 · ${activeArchetype.name.toUpperCase()}',
                                        style: GoogleFonts.bebasNeue(
                                          fontSize: 18,
                                          letterSpacing: 1.3,
                                          color: const Color(0xFFF5DEB3),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      activeArchetype.catchphrase,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFF5DEB3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE11342),
                                  foregroundColor: const Color(0xFFF5DEB3),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: Color(0xFFFFD600),
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                onPressed: _triggerChoreographedGlideToAuth,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'SIGN IN',
                                    style: GoogleFonts.bebasNeue(
                                      fontSize: 17,
                                      letterSpacing: 1.4,
                                      color: const Color(0xFFF5DEB3),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildRedCarpetAdvancingCharacterRigs(
    BuildContext context,
    double walkProgress,
  ) {
    final screenSize = MediaQuery.of(context).size;
    if (screenSize.width <= 0 || screenSize.height <= 0) {
      return const <Widget>[];
    }

    final centerX = screenSize.width * 0.5;
    final horizonY = screenSize.height * 0.34;
    final topHalfW = screenSize.width * 0.14;
    final botHalfW = screenSize.width * 0.46;
    final shift = (walkProgress * 3.0) % 1.0;

    final List<Widget> rigs = <Widget>[];
    const int pairs = 3;

    for (int i = 0; i < pairs; i++) {
      final rawT = ((i + shift) / pairs) % 1.0;
      final easedT = rawT * rawT;
      final y = horizonY + (screenSize.height * 0.66 - horizonY) * easedT;
      final halfW = topHalfW + (botHalfW - topHalfW) * easedT;
      final rigSize = 36.0 + easedT * 32.0;
      final opacity = (0.35 + easedT * 0.65).clamp(0.0, 1.0);

      final leftArch = kFourteenAvatarArchetypes[(i * 2) % 14];
      final rightArch = kFourteenAvatarArchetypes[(i * 2 + 1) % 14];

      rigs.add(
        Positioned(
          left: (centerX - halfW - rigSize * 0.85)
              .clamp(4.0, screenSize.width - rigSize),
          top: y - rigSize * 0.5,
          child: Opacity(
            opacity: opacity,
            child: BoondocksCharacterRig(
              archetype: leftArch,
              size: rigSize,
              externalPhase: walkProgress * math.pi * 4 + i,
              onTap: () =>
                  showBoondocksCharacterSpotlightModal(context, leftArch),
            ),
          ),
        ),
      );

      rigs.add(
        Positioned(
          left: (centerX + halfW - rigSize * 0.15)
              .clamp(4.0, screenSize.width - rigSize - 4.0),
          top: y - rigSize * 0.5,
          child: Opacity(
            opacity: opacity,
            child: BoondocksCharacterRig(
              archetype: rightArch,
              size: rigSize,
              externalPhase: walkProgress * math.pi * 4 + i + 0.5,
              onTap: () =>
                  showBoondocksCharacterSpotlightModal(context, rightArch),
            ),
          ),
        ),
      );
    }
    return rigs;
  }
}

class _ClapperGoldenShockwavePainter extends CustomPainter {
  final double progress;

  const _ClapperGoldenShockwavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress.clamp(0.0, 1.0);
    final center = Offset(size.width * 0.5, size.height * 0.62);
    final maxRadius = size.longestSide * 0.75;
    final radius = Curves.easeOutCubic.transform(p) * maxRadius;
    final alpha = (1.0 - p).clamp(0.0, 1.0);

    // Expanding golden ring shockwave
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFFFD600).withValues(alpha: alpha * 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0 * (1.0 - p * 0.6),
    );

    // Soft radial golden flash bloom
    canvas.drawCircle(
      center,
      radius * 0.85,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            const Color(0xFFFFF59D).withValues(alpha: alpha * 0.42),
            const Color(0xFFE11342).withValues(alpha: alpha * 0.18),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.85)),
    );
  }

  @override
  bool shouldRepaint(covariant _ClapperGoldenShockwavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _FirstPersonCellShadedCarpetWalkPainter extends CustomPainter {
  final double walkProgress;

  const _FirstPersonCellShadedCarpetWalkPainter({required this.walkProgress});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFF05070B),
          Color(0xFF220409),
          Color(0xFF07090E),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);

    final centerX = size.width * 0.5;
    final horizonY = size.height * 0.28;

    for (int i = 0; i < 3; i++) {
      final swing = math.sin(walkProgress * math.pi * 2 + i * 1.4) * 95.0;
      final beamPath = Path()
        ..moveTo(centerX + (i - 1) * 90, horizonY)
        ..lineTo(centerX + swing - 110, 0)
        ..lineTo(centerX + swing + 110, 0)
        ..close();
      canvas.drawPath(
        beamPath,
        Paint()
          ..color =
              (i == 1 ? const Color(0x33F5DEB3) : const Color(0x280CB6D4)),
      );
    }

    final topHalfW = size.width * 0.14;
    final botHalfW = size.width * 0.54;

    final carpetPath = Path()
      ..moveTo(centerX - topHalfW, horizonY)
      ..lineTo(centerX + topHalfW, horizonY)
      ..lineTo(centerX + botHalfW, size.height)
      ..lineTo(centerX - botHalfW, size.height)
      ..close();

    canvas.drawPath(
      carpetPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF3A0001),
            Color(0xFF520002),
            Color(0xFFE11342),
            Color(0xFF520002),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      carpetPath,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 4.5
        ..style = PaintingStyle.stroke,
    );

    final goldTrim = Paint()
      ..color = const Color(0xFFF5DEB3)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centerX - topHalfW + 6, horizonY),
      Offset(centerX - botHalfW + 18, size.height),
      goldTrim,
    );
    canvas.drawLine(
      Offset(centerX + topHalfW - 6, horizonY),
      Offset(centerX + botHalfW - 18, size.height),
      goldTrim,
    );
  }

  @override
  bool shouldRepaint(
    covariant _FirstPersonCellShadedCarpetWalkPainter oldDelegate,
  ) =>
      oldDelegate.walkProgress != walkProgress;
}
