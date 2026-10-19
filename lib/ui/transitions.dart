import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../auth/auth_service.dart';
import 'intro_cinematic.dart';

/// Identifies which bespoke First-Person 2.5D Cell-Shaded transition sequence
/// plays before routing to a target destination from the Red Carpet.
enum BespokeTransitionType {
  /// Door 1 (Premiere Clapperboard): Heavy 2.5D cell-shaded clapperboard snaps
  /// shut directly in the camera lens with Limelight Gold impact rays.
  clapperboardSnap,

  /// Door 2 ("On Air" Stage Light / 6-Digit Room): Heavy soundstage door slams
  /// shut in the user's face and the crimson "ON AIR" light flares overhead.
  soundstageDoorSlam,

  /// Door 3 (Velvet Rope / 18+ After-Hours): The 2.5D cell-shaded "Mob Boss"
  /// unhooks the crimson velvet rope and exhales thick cigar smoke across the lens.
  mobBossCigarSmoke,

  /// Door 4 (Golden Statuette / Trophy Vault): Heavy Velvet Carpet Crimson
  /// stage curtains with Limelight Gold braided tassels draw open in POV.
  velvetCurtainDraw,

  /// Doors 5–6 (Director's Viewfinder & Vintage Box Office): A vintage press
  /// flashbulb pops directly in the camera lens with halftone rays.
  vintageFlashbulbPop,

  /// Silver Elevator ("The Cutting Room Floor"): Security guards press the
  /// elevator call button, unhook the red velvet rope, the camera walks inside
  /// in first-person POV, and the brushed-silver doors slide shut reflecting
  /// the player's chosen 2.5D cell-shaded avatar before opening to the feed.
  silverElevatorVelvetRope,
}

/// MODULE 3: Bespoke First-Person Transition Engine (`lib/ui/transitions.dart`).
/// Wraps route navigation in a high-contrast 2.5D cell-shaded first-person
/// sequence tailored to the specific Red Carpet door or portal tapped.
class BespokeTransitionEngine {
  static Future<T?> navigate<T>({
    required BuildContext context,
    required BespokeTransitionType type,
    required Widget destination,
  }) {
    HapticFeedback.heavyImpact();
    final activeArchetypeId =
        AuthService.instance.currentProfile?.avatarArchetypeId ??
            'the_method_actor';
    final chosenArchetype = resolveAvatarArchetype(activeArchetypeId);

    final duration = type == BespokeTransitionType.silverElevatorVelvetRope
        ? const Duration(milliseconds: 1180)
        : const Duration(milliseconds: 880);

    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        transitionDuration: duration,
        reverseTransitionDuration: const Duration(milliseconds: 340),
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return _BespokeFirstPersonTransitionStage(
            animation: animation,
            type: type,
            playerArchetype: chosenArchetype,
            child: child,
          );
        },
      ),
    );
  }
}

typedef BespokeTransitions = BespokeTransitionEngine;

class _BespokeFirstPersonTransitionStage extends StatelessWidget {
  final Animation<double> animation;
  final BespokeTransitionType type;
  final BoondocksAvatarArchetype playerArchetype;
  final Widget child;

  const _BespokeFirstPersonTransitionStage({
    required this.animation,
    required this.type,
    required this.playerArchetype,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value.clamp(0.0, 1.0);
        // Reveal destination page smoothly in the final third of the transition
        final childOpacity =
            t < 0.58 ? 0.0 : ((t - 0.58) / 0.42).clamp(0.0, 1.0);
        final overlayOpacity =
            t < 0.72 ? 1.0 : (1.0 - ((t - 0.72) / 0.28)).clamp(0.0, 1.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            if (childOpacity > 0.0)
              Opacity(
                opacity: childOpacity,
                child: child,
              ),
            if (overlayOpacity > 0.0)
              IgnorePointer(
                child: Opacity(
                  opacity: overlayOpacity,
                  child: _buildTransitionOverlay(t),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTransitionOverlay(double t) {
    switch (type) {
      case BespokeTransitionType.clapperboardSnap:
        return CustomPaint(
          painter: _ClapperboardSnapTransitionPainter(progress: t),
        );
      case BespokeTransitionType.soundstageDoorSlam:
        return CustomPaint(
          painter: _SoundstageDoorSlamTransitionPainter(progress: t),
        );
      case BespokeTransitionType.mobBossCigarSmoke:
        return CustomPaint(
          painter: _MobBossCigarSmokeTransitionPainter(progress: t),
        );
      case BespokeTransitionType.velvetCurtainDraw:
        return CustomPaint(
          painter: _VelvetCurtainDrawTransitionPainter(progress: t),
        );
      case BespokeTransitionType.vintageFlashbulbPop:
        return CustomPaint(
          painter: _VintageFlashbulbPopTransitionPainter(progress: t),
        );
      case BespokeTransitionType.silverElevatorVelvetRope:
        return _SilverElevatorFirstPersonOverlay(
          progress: t,
          playerArchetype: playerArchetype,
        );
    }
  }
}

/// 0. DOOR 1 (The Premiere Clapperboard): First-person 2.5D cell-shaded
/// clapperboard snaps shut right in front of the lens with Limelight Gold rays.
class _ClapperboardSnapTransitionPainter extends CustomPainter {
  final double progress;

  const _ClapperboardSnapTransitionPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF07090E),
    );

    final center = Offset(size.width * 0.5, size.height * 0.5);
    final snapT = Curves.easeInBack.transform((progress / 0.52).clamp(0.0, 1.0));
    final shockT = progress < 0.48
        ? 0.0
        : math.sin(((progress - 0.48) / 0.52).clamp(0.0, 1.0) * math.pi);

    // Radial 2.5D speed lines in Limelight Gold & Soundstage Cyan
    for (int i = 0; i < 20; i++) {
      final angle = (i / 20.0) * math.pi * 2;
      canvas.drawLine(
        Offset(center.dx + math.cos(angle) * 40, center.dy + math.sin(angle) * 40),
        Offset(
          center.dx + math.cos(angle) * size.longestSide * 0.7,
          center.dy + math.sin(angle) * size.longestSide * 0.7,
        ),
        Paint()
          ..color = (i.isEven ? const Color(0xFFF5DEB3) : const Color(0xFF0CB6D4))
              .withValues(alpha: 0.35 + 0.45 * shockT)
          ..strokeWidth = 3.0,
      );
    }

    final slateW = size.width * 0.78;
    final slateH = slateW * 0.62;
    final slateRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: slateW, height: slateH),
      const Radius.circular(18),
    );

    // Slate body in Deep Obsidian with heavy black ink border
    canvas.drawRRect(slateRect, Paint()..color = const Color(0xFF07090E));
    canvas.drawRRect(
      slateRect,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke,
    );
    canvas.drawRRect(
      slateRect.deflate(3.5),
      Paint()
        ..color = const Color(0xFFF5DEB3)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    // Hinged top clapper jaw snapping down
    final jawAngle = -0.46 * (1.0 - snapT.clamp(0.0, 1.0));
    canvas.save();
    canvas.translate(slateRect.left, slateRect.top);
    canvas.rotate(jawAngle);
    final stickRect = Rect.fromLTWH(0, -34, slateW, 34);
    canvas.drawRect(stickRect, Paint()..color = const Color(0xFFF5DEB3));
    for (double x = 0; x < slateW; x += 36) {
      final stripe = Path()
        ..moveTo(x, -34)
        ..lineTo(x + 18, -34)
        ..lineTo(x + 8, 0)
        ..lineTo(x - 10, 0)
        ..close();
      canvas.drawPath(stripe, Paint()..color = const Color(0xFF05070B));
    }
    canvas.drawRect(
      stickRect,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 4.5
        ..style = PaintingStyle.stroke,
    );
    canvas.restore();

    final tp = TextPainter(
      text: const TextSpan(
        text: 'ACTION!',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 44,
          fontWeight: FontWeight.w900,
          letterSpacing: 3.0,
          color: Color(0xFFE11342),
          shadows: <Shadow>[
            Shadow(
              color: Color(0xFFF5DEB3),
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
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
  bool shouldRepaint(covariant _ClapperboardSnapTransitionPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Velvet Curtain Draw Transition (Door 4: Academy Trophy Vault):
/// Lush Velvet Carpet Crimson (#520002 / #E11342) theater curtains with
/// Limelight Gold (#F5DEB3) tassels sweep across and part in first-person POV.
class _VelvetCurtainDrawTransitionPainter extends CustomPainter {
  final double progress;

  const _VelvetCurtainDrawTransitionPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF07090E),
    );

    // Curtains close (0.0 -> 0.45) then part dramatically (0.45 -> 1.0)
    final closeFactor = progress < 0.45
        ? Curves.easeOutCubic.transform((progress / 0.45).clamp(0.0, 1.0))
        : 1.0 - Curves.easeInOutCubic.transform(((progress - 0.45) / 0.55).clamp(0.0, 1.0));

    final panelW = (size.width * 0.54) * closeFactor;
    final leftCurtain = Rect.fromLTWH(0, 0, panelW, size.height);
    final rightCurtain =
        Rect.fromLTWH(size.width - panelW, 0, panelW, size.height);

    final velvetPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFF520002),
          Color(0xFFE11342),
          Color(0xFF520002),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(leftCurtain, velvetPaint);
    canvas.drawRect(rightCurtain, velvetPaint);

    // Heavy black comic ink borders & Limelight Gold trim along inner edges
    final inkPaint = Paint()
      ..color = const Color(0xFF05070B)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(leftCurtain, inkPaint);
    canvas.drawRect(rightCurtain, inkPaint);

    final goldRopePaint = Paint()
      ..color = const Color(0xFFF5DEB3)
      ..strokeWidth = 4.0;
    canvas.drawLine(
      Offset(leftCurtain.right - 8, 0),
      Offset(leftCurtain.right - 8, size.height),
      goldRopePaint,
    );
    canvas.drawLine(
      Offset(rightCurtain.left + 8, 0),
      Offset(rightCurtain.left + 8, size.height),
      goldRopePaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _VelvetCurtainDrawTransitionPainter oldDelegate,
  ) =>
      oldDelegate.progress != progress;
}

/// 1. DOOR 1 (6-Digit Room): Heavy soundstage door slams shut in the user's face
/// with comic impact lines, and the crimson "ON AIR" light flares overhead.
class _SoundstageDoorSlamTransitionPainter extends CustomPainter {
  final double progress;

  const _SoundstageDoorSlamTransitionPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 0.0 -> 0.48: Heavy left & right steel soundstage doors slam shut together
    // 0.48 -> 1.0: Overhead red "ON AIR" beacon flares brightly in the dark
    final slamT = Curves.easeInExpo.transform((progress / 0.48).clamp(0.0, 1.0));
    final flareT = progress < 0.42
        ? 0.0
        : math.sin(((progress - 0.42) / 0.58).clamp(0.0, 1.0) * math.pi);

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF07090E),
    );

    final halfW = size.width * 0.5;
    final leftDoorRight = halfW * slamT;
    final rightDoorLeft = size.width - (halfW * slamT);

    final doorPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFF1E293B),
          Color(0xFF0F172A),
          Color(0xFF07090E),
        ],
      ).createShader(Offset.zero & size);

    final leftRect = Rect.fromLTWH(0, 0, leftDoorRight, size.height);
    final rightRect =
        Rect.fromLTWH(rightDoorLeft, 0, halfW * slamT, size.height);

    canvas.drawRect(leftRect, doorPaint);
    canvas.drawRect(rightRect, doorPaint);

    // Heavy black comic ink outlines & hazard stripes along the door seam
    final inkPaint = Paint()
      ..color = const Color(0xFF05070B)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(leftRect, inkPaint);
    canvas.drawRect(rightRect, inkPaint);

    // Impact shock lines when the doors slam shut
    if (slamT >= 0.92) {
      final center = Offset(halfW, size.height * 0.5);
      final shockPaint = Paint()
        ..color = const Color(0xFFF5DEB3).withValues(alpha: 0.85)
        ..strokeWidth = 3.2;
      for (int i = 0; i < 16; i++) {
        final angle = (i / 16.0) * math.pi * 2;
        canvas.drawLine(
          Offset(center.dx + math.cos(angle) * 30, center.dy + math.sin(angle) * 30),
          Offset(center.dx + math.cos(angle) * 180, center.dy + math.sin(angle) * 180),
          shockPaint,
        );
      }
    }

    // Overhead crimson "ON AIR" studio sign flaring in the user's face
    final signRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(halfW, size.height * 0.28),
        width: size.width * 0.68,
        height: 76,
      ),
      const Radius.circular(16),
    );

    canvas.drawRRect(
      signRect,
      Paint()
        ..color = Color.lerp(
          const Color(0xFF520002),
          const Color(0xFFE11342),
          flareT,
        )!,
    );
    canvas.drawRRect(
      signRect,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 4.5
        ..style = PaintingStyle.stroke,
    );

    if (flareT > 0.05) {
      canvas.drawCircle(
        Offset(halfW, size.height * 0.28),
        size.width * 0.55 * flareT,
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[
              const Color(0xFFE11342).withValues(alpha: 0.65 * flareT),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(halfW, size.height * 0.28),
              radius: size.width * 0.55,
            ),
          ),
      );
    }

    final tp = TextPainter(
      text: const TextSpan(
        text: '● ON AIR · LOCKING STAGE',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(halfW - tp.width * 0.5, size.height * 0.28 - tp.height * 0.5),
    );
  }

  @override
  bool shouldRepaint(
    covariant _SoundstageDoorSlamTransitionPainter oldDelegate,
  ) =>
      oldDelegate.progress != progress;
}

/// 2. DOOR 2 (18+ After-Hours): The cell-shaded "Mob Boss" unhooks the crimson
/// velvet rope and blows thick cel-shaded cigar smoke across the camera lens.
class _MobBossCigarSmokeTransitionPainter extends CustomPainter {
  final double progress;

  const _MobBossCigarSmokeTransitionPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF07050A),
    );

    final center = Offset(size.width * 0.5, size.height * 0.44);

    // 1. Mob Boss Cell-Shaded Silhouette & Glowing Cigar Ember
    final bossScale = 1.0 + progress * 0.25;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(bossScale);

    // Pinstripe shoulders + fedora silhouette
    final suitPath = Path()
      ..moveTo(-130, 180)
      ..lineTo(-95, 20)
      ..lineTo(95, 20)
      ..lineTo(130, 180)
      ..close();
    canvas.drawPath(suitPath, Paint()..color = const Color(0xFF140A18));
    canvas.drawPath(
      suitPath,
      Paint()
        ..color = const Color(0xFFE11D48)
        ..strokeWidth = 3.2
        ..style = PaintingStyle.stroke,
    );

    // Fedora hat brim & crown
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, -56), width: 148, height: 22),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF05070B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, -82), width: 92, height: 42),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF05070B),
    );

    // Glowing cigar ember at the corner of the mouth
    canvas.drawCircle(
      const Offset(28, -8),
      6.5,
      Paint()..color = const Color(0xFFEF4444),
    );
    canvas.restore();

    // 2. Crimson Velvet Rope Unhooking & Dropping Away (0.0 -> 0.55)
    final ropeDropT = (progress / 0.55).clamp(0.0, 1.0);
    final leftHook = Offset(size.width * 0.14, size.height * 0.62);
    final rightHook = Offset(
      size.width * (0.86 - ropeDropT * 0.42),
      size.height * (0.62 + ropeDropT * 0.38),
    );
    final ropePath = Path()
      ..moveTo(leftHook.dx, leftHook.dy)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * (0.68 + ropeDropT * 0.35),
        rightHook.dx,
        rightHook.dy,
      );
    canvas.drawPath(
      ropePath,
      Paint()
        ..color = const Color(0xFFE11D48)
        ..strokeWidth = 10.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // 3. Thick Cel-Shaded Cigar Smoke Plumes Wiping Across the Screen
    final smokeT = ((progress - 0.18) / 0.82).clamp(0.0, 1.0);
    if (smokeT > 0.0) {
      for (int i = 0; i < 14; i++) {
        final angle = i * 0.85 + smokeT * 2.4;
        final dist = (i * 22.0 + smokeT * size.longestSide * 0.48);
        final puffCenter = Offset(
          center.dx + math.cos(angle) * dist * 0.45,
          center.dy + math.sin(angle) * dist * 0.35,
        );
        final puffRadius = 38.0 + (i * 12.0) + (smokeT * 140.0);

        // Cel-shaded smoke body + thick dark outline
        canvas.drawCircle(
          puffCenter,
          puffRadius,
          Paint()
            ..color = const Color(0xFF334155).withValues(
              alpha: (0.45 + 0.45 * smokeT).clamp(0.0, 0.92),
            ),
        );
        canvas.drawCircle(
          puffCenter,
          puffRadius,
          Paint()
            ..color = const Color(0xFF05070B).withValues(alpha: 0.75)
            ..strokeWidth = 3.5
            ..style = PaintingStyle.stroke,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MobBossCigarSmokeTransitionPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// 3. SCENE VAULT (Doors 3–6): Vintage press flashbulb pops directly in the
/// camera lens with comic halftone rays, leaving a white-out optical fade.
class _VintageFlashbulbPopTransitionPainter extends CustomPainter {
  final double progress;

  const _VintageFlashbulbPopTransitionPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final popIntensity = math.sin(progress * math.pi).clamp(0.0, 1.0);

    // Radial comic flashburst rays
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = Color.lerp(
          const Color(0xFF07090E),
          const Color(0xFFFFFBEB),
          popIntensity,
        )!,
    );

    final rayPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.85 * popIntensity)
      ..strokeWidth = 4.0;
    for (int i = 0; i < 28; i++) {
      final angle = (i / 28.0) * math.pi * 2 + progress * 0.5;
      canvas.drawLine(
        center,
        Offset(
          center.dx + math.cos(angle) * size.longestSide,
          center.dy + math.sin(angle) * size.longestSide,
        ),
        rayPaint,
      );
    }

    // Blinding white core expanding across the lens
    canvas.drawCircle(
      center,
      size.longestSide * 0.75 * popIntensity,
      Paint()..color = Colors.white.withValues(alpha: popIntensity),
    );
  }

  @override
  bool shouldRepaint(
    covariant _VintageFlashbulbPopTransitionPainter oldDelegate,
  ) =>
      oldDelegate.progress != progress;
}

/// 4. THE SILVER ELEVATOR TRANSITION ("THE CUTTING ROOM FLOOR"):
/// First-person POV scene:
/// - Club-like neon sign reading "THE CUTTING ROOM FLOOR" overhead
/// - Two 2.5D cell-shaded security guards standing outside the brushed-silver elevator
/// - Guards press the elevator call button and unhook the red velvet rope
/// - User walks forward in first-person POV through the elevator doors
/// - The brushed-silver doors slide shut, reflecting the user's chosen 2.5D
///   cell-shaded avatar in the polished chrome before opening to the feed.
class _SilverElevatorFirstPersonOverlay extends StatelessWidget {
  final double progress;
  final BoondocksAvatarArchetype playerArchetype;

  const _SilverElevatorFirstPersonOverlay({
    required this.progress,
    required this.playerArchetype,
  });

  @override
  Widget build(BuildContext context) {
    // Phase breakdown across progress (0.0 -> 1.0):
    // 0.00 -> 0.35: Guards press elevator call button & unhook the red velvet rope
    // 0.35 -> 0.72: First-person camera walks forward into the silver elevator
    // 0.72 -> 1.00: Brushed-silver doors slide closed reflecting the player's
    //               chosen 2.5D cell-shaded avatar, then fade into the feed.
    final ropeDropT = (progress / 0.38).clamp(0.0, 1.0);
    final walkInZoom = 1.0 + (((progress - 0.25) / 0.55).clamp(0.0, 1.0) * 0.52);
    final doorCloseT = ((progress - 0.46) / 0.36).clamp(0.0, 1.0);
    final stepBobY = math.sin(progress * math.pi * 10) * 5.0;

    return Container(
      color: const Color(0xFF05070B),
      child: Transform.translate(
        offset: Offset(0, stepBobY),
        child: Transform.scale(
          scale: walkInZoom,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Brushed-Silver Elevator Shaft, Neon Sign, Guards & Velvet Rope
              CustomPaint(
                painter: _SilverElevatorPortalPainter(
                  progress: progress,
                  ropeDropT: ropeDropT,
                  doorCloseT: doorCloseT,
                ),
              ),

              // 2. Player's Chosen 2.5D Cell-Shaded Avatar Reflected in the
              //    Polished Brushed-Silver Elevator Doors as they slide shut!
              if (doorCloseT > 0.22)
                Center(
                  child: Opacity(
                    opacity: ((doorCloseT - 0.22) / 0.78).clamp(0.0, 0.78),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xCC07090E),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: playerArchetype.primaryInkColor,
                            ),
                          ),
                          child: Text(
                            'CHROME REFLECTION · ${playerArchetype.name}',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: playerArchetype.rimAccentColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        BoondocksAvatarPortrait(
                          archetype: playerArchetype,
                          size: 138,
                          isSelected: true,
                          isMirroredReflection: true,
                          animationPhase: progress * math.pi * 2,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SilverElevatorPortalPainter extends CustomPainter {
  final double progress;
  final double ropeDropT;
  final double doorCloseT;

  const _SilverElevatorPortalPainter({
    required this.progress,
    required this.ropeDropT,
    required this.doorCloseT,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width * 0.5;
    final elevatorRect = Rect.fromCenter(
      center: Offset(centerX, size.height * 0.52),
      width: size.width * 0.64,
      height: size.height * 0.66,
    );

    // 1. Club-Like Neon Header Sign: "THE CUTTING ROOM FLOOR"
    final neonRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, elevatorRect.top - 36),
        width: size.width * 0.78,
        height: 48,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(neonRect, Paint()..color = const Color(0xFF0B0E17));
    canvas.drawRRect(
      neonRect,
      Paint()
        ..color = const Color(0xFFEC4899)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke,
    );

    final signTp = TextPainter(
      text: const TextSpan(
        text: '★ THE CUTTING ROOM FLOOR ★',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: Color(0xFFF9A8D4),
          shadows: <Shadow>[
            Shadow(color: Color(0xFFEC4899), blurRadius: 14),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    signTp.paint(
      canvas,
      Offset(centerX - signTp.width * 0.5, elevatorRect.top - 36 - signTp.height * 0.5),
    );

    // 2. Elevator Interior Frame + Sliding Brushed-Silver Doors
    canvas.drawRect(
      elevatorRect,
      Paint()..color = const Color(0xFF0F172A),
    );

    // Doors start open while walking in, then slide closed to reflect avatar
    final closedFactor = Curves.easeInOutCubic.transform(doorCloseT);
    final doorHalfW = (elevatorRect.width * 0.5) * (0.25 + 0.75 * closedFactor);

    final silverShader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color(0xFFE2E8F0),
        Color(0xFF94A3B8),
        Color(0xFFCBD5E1),
        Color(0xFF64748B),
      ],
    ).createShader(elevatorRect);

    final leftDoor = Rect.fromLTWH(
      elevatorRect.left,
      elevatorRect.top,
      doorHalfW,
      elevatorRect.height,
    );
    final rightDoor = Rect.fromLTWH(
      elevatorRect.right - doorHalfW,
      elevatorRect.top,
      doorHalfW,
      elevatorRect.height,
    );

    canvas.drawRect(leftDoor, Paint()..shader = silverShader);
    canvas.drawRect(rightDoor, Paint()..shader = silverShader);

    // Heavy 2.5D cell-shaded ink border on the silver elevator doors
    final inkBorder = Paint()
      ..color = const Color(0xFF05070B)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(leftDoor, inkBorder);
    canvas.drawRect(rightDoor, inkBorder);
    canvas.drawRect(elevatorRect, inkBorder);

    // Glowing Elevator Call Button on right frame (pressed by guard at t < 0.35)
    final buttonCenter = Offset(elevatorRect.right + 18, elevatorRect.center.dy);
    canvas.drawCircle(
      buttonCenter,
      9,
      Paint()
        ..color = progress > 0.08
            ? const Color(0xFF10B981)
            : const Color(0xFFF59E0B),
    );

    // 3. Two 2.5D Cell-Shaded Security Guards Standing Outside the Elevator
    final guardSpread = (progress * 90.0).clamp(0.0, 90.0);
    _drawCellShadedSecurityGuard(
      canvas,
      footAnchor: Offset(elevatorRect.left - 22 - guardSpread, elevatorRect.bottom),
      height: elevatorRect.height * 0.74,
    );
    _drawCellShadedSecurityGuard(
      canvas,
      footAnchor: Offset(elevatorRect.right + 22 + guardSpread, elevatorRect.bottom),
      height: elevatorRect.height * 0.74,
    );

    // 4. Red Velvet Rope in Front of the Silver Elevator Being Unhooked
    if (ropeDropT < 0.98) {
      final leftPost = Offset(elevatorRect.left - 8, elevatorRect.bottom - 95);
      final rightPost = Offset(
        elevatorRect.right + 8 - (ropeDropT * elevatorRect.width * 0.65),
        elevatorRect.bottom - 95 + (ropeDropT * 115),
      );
      final ropePath = Path()
        ..moveTo(leftPost.dx, leftPost.dy)
        ..quadraticBezierTo(
          centerX,
          elevatorRect.bottom - 65 + (ropeDropT * 130),
          rightPost.dx,
          rightPost.dy,
        );
      canvas.drawPath(
        ropePath,
        Paint()
          ..color = const Color(0xFFE11D48)
          ..strokeWidth = 8.5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }
  }

  void _drawCellShadedSecurityGuard(
    Canvas canvas, {
    required Offset footAnchor,
    required double height,
  }) {
    final torsoRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(footAnchor.dx, footAnchor.dy - height * 0.42),
        width: height * 0.36,
        height: height * 0.72,
      ),
      const Radius.circular(12),
    );
    final headCenter = Offset(footAnchor.dx, footAnchor.dy - height * 0.86);

    canvas.drawRRect(torsoRect, Paint()..color = const Color(0xFF0B0E17));
    canvas.drawRRect(
      torsoRect,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(headCenter, height * 0.11, Paint()..color = const Color(0xFF8D5524));
    // Dark security sunglasses
    canvas.drawRect(
      Rect.fromCenter(
        center: headCenter,
        width: height * 0.18,
        height: height * 0.05,
      ),
      Paint()..color = const Color(0xFF05070B),
    );
  }

  @override
  bool shouldRepaint(covariant _SilverElevatorPortalPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ropeDropT != ropeDropT ||
        oldDelegate.doorCloseT != doorCloseT;
  }
}
