import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/auth_service.dart';
import '../auth/login_screen.dart';
import '../dashboard_marquee.dart';
import 'boondocks_character_rig.dart';
import 'opening_maestro_hero.dart';

export 'boondocks_character_rig.dart';
export 'opening_maestro_hero.dart';

/// MODULE 1: Cell-Shaded Cinematic Opening (`lib/ui/intro_cinematic.dart`).
/// - Plays the uploaded Golden Cyber-Mask Maestro opening sequence + synthesized
///   Hollywood Premiere Fanfare music automatically on launch.
/// - Lines the Red Carpet with all 14 animated 2.5D characters scaling toward the camera.
/// - Includes a "FAST-SKIP TO RED CARPET" glass pill wrapped in `FittedBox` and a
///   live Music Mute/Unmute toggle.
class CellShadedIntroCinematicScreen extends StatefulWidget {
  const CellShadedIntroCinematicScreen({super.key});

  @override
  State<CellShadedIntroCinematicScreen> createState() =>
      _CellShadedIntroCinematicScreenState();
}

class _CellShadedIntroCinematicScreenState
    extends State<CellShadedIntroCinematicScreen>
    with TickerProviderStateMixin {
  late final AnimationController _walkController;
  late final AnimationController _clapperSmashController;
  late final AudioPlayer _openingAudioPlayer;
  Timer? _autoDirectorCutTimer;
  Timer? _spotlightCycleTimer;

  bool _isCuttingToAuth = false;
  bool _isMusicMuted = false;
  int _spotlightArchetypeIndex = 0;

  @override
  void initState() {
    super.initState();
    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _clapperSmashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );

    _openingAudioPlayer = AudioPlayer();
    _startOpeningMusic();

    _spotlightCycleTimer = Timer.periodic(
      const Duration(milliseconds: 2500),
      (_) {
        if (!mounted || _isCuttingToAuth) return;
        setState(() {
          _spotlightArchetypeIndex =
              (_spotlightArchetypeIndex + 1) % kFourteenAvatarArchetypes.length;
        });
      },
    );

    _autoDirectorCutTimer = Timer(const Duration(milliseconds: 18000), () {
      if (mounted && !_isCuttingToAuth) {
        _triggerDirectorCutToAuth();
      }
    });
  }

  Future<void> _startOpeningMusic() async {
    try {
      await _openingAudioPlayer.setReleaseMode(ReleaseMode.loop);
      await _openingAudioPlayer.setVolume(0.48);
      final wavBytes = OpeningPremiereMusicSynthesizer.buildOpeningFanfareWav();
      await _openingAudioPlayer.play(BytesSource(wavBytes));
    } catch (_) {
      try {
        await _openingAudioPlayer.play(
          UrlSource('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'),
        );
      } catch (_) {}
    }
  }

  Future<void> _toggleOpeningMusic() async {
    HapticFeedback.selectionClick();
    setState(() {
      _isMusicMuted = !_isMusicMuted;
    });
    try {
      await _openingAudioPlayer.setVolume(_isMusicMuted ? 0.0 : 0.48);
    } catch (_) {}
  }

  @override
  void dispose() {
    _autoDirectorCutTimer?.cancel();
    _spotlightCycleTimer?.cancel();
    _openingAudioPlayer.stop();
    _openingAudioPlayer.dispose();
    _walkController.dispose();
    _clapperSmashController.dispose();
    super.dispose();
  }

  Future<void> _handleFastSkipToRedCarpet() async {
    if (_isCuttingToAuth) return;
    _autoDirectorCutTimer?.cancel();
    HapticFeedback.heavyImpact();
    try {
      await _openingAudioPlayer.stop();
    } catch (_) {}

    await AuthService.instance.initialize();
    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, __, ___) => const LivingMarqueeDashboardScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  Future<void> _triggerDirectorCutToAuth() async {
    if (_isCuttingToAuth) return;
    _autoDirectorCutTimer?.cancel();
    HapticFeedback.heavyImpact();
    try {
      await _openingAudioPlayer.stop();
    } catch (_) {}

    setState(() {
      _isCuttingToAuth = true;
    });

    await _clapperSmashController.forward(from: 0.0);
    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, __, ___) => const LivingMarqueeLoginScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeArchetype =
        kFourteenAvatarArchetypes[_spotlightArchetypeIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _walkController,
          _clapperSmashController,
        ]),
        builder: (context, _) {
          final walkProgress = _walkController.value;
          final smashValue = _clapperSmashController.value;

          final stepBobY = math.sin(walkProgress * math.pi * 16) * 5.5;
          final stepSwayX = math.cos(walkProgress * math.pi * 8) * 4.0;

          return Stack(
            fit: StackFit.expand,
            children: [
              Transform.translate(
                offset: Offset(stepSwayX, stepBobY),
                child: CustomPaint(
                  painter: _FirstPersonCellShadedCarpetWalkPainter(
                    walkProgress: walkProgress,
                  ),
                ),
              ),
              ..._buildRedCarpetAdvancingCharacterRigs(context, walkProgress),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _toggleOpeningMusic,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xF207090E),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _isMusicMuted
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFFFFD600),
                                  width: 2.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isMusicMuted
                                        ? Icons.volume_off_rounded
                                        : Icons.music_note_rounded,
                                    color: _isMusicMuted
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFFFFD600),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _isMusicMuted
                                        ? 'MUSIC MUTED'
                                        : 'OPENING SCORE ON',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFF5DEB3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _handleFastSkipToRedCarpet,
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
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xE607090E),
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(
                                          color: const Color(0xFFF5DEB3),
                                          width: 2.2,
                                        ),
                                      ),
                                      child: const FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.fast_forward_rounded,
                                              color: Color(0xFFF5DEB3),
                                              size: 15,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              'FAST-SKIP TO RED CARPET',
                                              style: TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.5,
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
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ActLikeItBrandCenterpiece(
                        height: 198,
                        onTap: _triggerDirectorCutToAuth,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => showBoondocksCharacterSpotlightModal(
                          context,
                          activeArchetype,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xF207090E),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: activeArchetype.primaryInkColor,
                              width: 2.8,
                            ),
                            boxShadow: <BoxShadow>[
                              const BoxShadow(
                                color: Color(0xFF05070B),
                                offset: Offset(5, 5),
                                blurRadius: 0,
                              ),
                              BoxShadow(
                                color: activeArchetype.primaryInkColor
                                    .withValues(alpha: 0.34),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              BoondocksCharacterRig(
                                archetype: activeArchetype,
                                size: 68,
                                isSelected: true,
                                externalPhase: walkProgress * math.pi * 4,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: activeArchetype.primaryInkColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        'CAST ${_spotlightArchetypeIndex + 1}/14 · ${activeArchetype.roleBadge}',
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF05070B),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      activeArchetype.name,
                                      style: GoogleFonts.bebasNeue(
                                        fontSize: 22,
                                        letterSpacing: 1.4,
                                        color: const Color(0xFFF5DEB3),
                                      ),
                                    ),
                                    Text(
                                      activeArchetype.catchphrase,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFF5DEB3),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      activeArchetype.redCarpetActivity,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 9.5,
                                        color: activeArchetype.rimAccentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 60,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: kFourteenAvatarArchetypes.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final arch = kFourteenAvatarArchetypes[index];
                            final selected = index == _spotlightArchetypeIndex;
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _spotlightArchetypeIndex = index;
                                });
                              },
                              child: BoondocksCharacterRig(
                                archetype: arch,
                                size: selected ? 58 : 50,
                                isSelected: selected,
                                externalPhase:
                                    walkProgress * math.pi * 4 + index * 0.4,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11342),
                          foregroundColor: const Color(0xFFF5DEB3),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(
                              color: Color(0xFF05070B),
                              width: 3.2,
                            ),
                          ),
                        ),
                        onPressed: _triggerDirectorCutToAuth,
                        icon: const Icon(Icons.movie_creation_rounded, size: 20),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'STEP TO THE MIC · DIRECTOR\'S "CUT!" TO CASTING',
                            style: GoogleFonts.bebasNeue(
                              fontSize: 20,
                              letterSpacing: 1.6,
                              color: const Color(0xFFF5DEB3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isCuttingToAuth || smashValue > 0.0)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DirectorCutClapperSmashPainter(
                      progress: smashValue,
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
    if (screenSize.width <= 0 || screenSize.height <= 0) return const <Widget>[];

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
              onTap: () => showBoondocksCharacterSpotlightModal(context, leftArch),
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
              onTap: () => showBoondocksCharacterSpotlightModal(context, rightArch),
            ),
          ),
        ),
      );
    }
    return rigs;
  }
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
          ..color = (i == 1 ? const Color(0x33F5DEB3) : const Color(0x280CB6D4)),
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

    const int depthSlices = 6;
    final shift = (walkProgress * 4.0) % 1.0;

    for (int i = 0; i < depthSlices; i++) {
      final rawT = ((i + shift) / depthSlices) % 1.0;
      final easedT = rawT * rawT;
      final y = horizonY + (size.height - horizonY) * easedT;
      final halfW = topHalfW + (botHalfW - topHalfW) * easedT;

      canvas.drawLine(
        Offset(centerX - halfW, y),
        Offset(centerX + halfW, y),
        Paint()
          ..color = const Color(0xFF05070B).withValues(alpha: 0.65 * easedT)
          ..strokeWidth = 1.5 + easedT * 3.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FirstPersonCellShadedCarpetWalkPainter oldDelegate) =>
      oldDelegate.walkProgress != walkProgress;
}

class _DirectorCutClapperSmashPainter extends CustomPainter {
  final double progress;

  const _DirectorCutClapperSmashPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress.clamp(0.0, 1.0);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = const Color(0xFF05070B)
            .withValues(alpha: (p * 1.25).clamp(0.0, 1.0)),
    );

    final center = Offset(size.width * 0.5, size.height * 0.5);
    final scale = 0.55 + Curves.easeOutBack.transform(p) * 0.65;
    final slateW = size.width * 0.72 * scale;
    final slateH = slateW * 0.62;
    final slateRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: slateW, height: slateH),
      const Radius.circular(16),
    );

    canvas.drawRRect(slateRect, Paint()..color = const Color(0xFF0B0E17));
    canvas.drawRRect(
      slateRect,
      Paint()
        ..color = const Color(0xFFFFD600)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke,
    );

    final tp = TextPainter(
      text: const TextSpan(
        text: 'CUT! TO CASTING',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: Color(0xFFFFE082),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width * 0.5, center.dy - tp.height * 0.5),
    );
  }

  @override
  bool shouldRepaint(covariant _DirectorCutClapperSmashPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
