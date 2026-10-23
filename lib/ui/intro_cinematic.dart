import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/auth_service.dart';
import '../auth/login_screen.dart';
import '../dashboard_marquee.dart';

/// Represents one of the 14 persistent 2.5D Cell-Shaded ("The Boondocks" inspired)
/// Avatar Archetypes that populate the First-Person POV ecosystem across the intro,
/// casting questionnaire, Red Carpet doors, and Silver Elevator reflection.
class BoondocksAvatarArchetype {
  final String id;
  final String name;
  final String roleBadge;
  final String catchphrase;
  final String redCarpetActivity;
  final Color primaryInkColor;
  final Color rimAccentColor;
  final Color shadowBlockColor;
  final IconData signatureIcon;
  final int silhouetteStyle; // 0..13 distinct head/accessory silhouettes

  const BoondocksAvatarArchetype({
    required this.id,
    required this.name,
    required this.roleBadge,
    required this.catchphrase,
    required this.redCarpetActivity,
    required this.primaryInkColor,
    required this.rimAccentColor,
    required this.shadowBlockColor,
    required this.signatureIcon,
    required this.silhouetteStyle,
  });
}

/// Master registry of all 14 persistent 2.5D Cell-Shaded Avatar Archetypes.
const List<BoondocksAvatarArchetype> kFourteenAvatarArchetypes =
    <BoondocksAvatarArchetype>[
  BoondocksAvatarArchetype(
    id: 'the_director',
    name: 'THE AUTEUR DIRECTOR',
    roleBadge: 'LENS COMMANDER',
    catchphrase: '"CUT! Do it again, and this time mean it!"',
    redCarpetActivity: 'Barking cues through a brass megaphone with clapperboard in hand',
    primaryInkColor: Color(0xFFF59E0B),
    rimAccentColor: Color(0xFFFFD700),
    shadowBlockColor: Color(0xFF291504),
    signatureIcon: Icons.campaign_rounded,
    silhouetteStyle: 0,
  ),
  BoondocksAvatarArchetype(
    id: 'the_paparazzi',
    name: 'FLASHBULB FINN',
    roleBadge: 'RELENTLESS PAPARAZZI',
    catchphrase: '"Look left! Give me scandal, baby!"',
    redCarpetActivity: 'Leaning over the velvet rope firing blinding 4-point flashbulbs',
    primaryInkColor: Color(0xFF06B6D4),
    rimAccentColor: Color(0xFF67E8F9),
    shadowBlockColor: Color(0xFF052029),
    signatureIcon: Icons.camera_enhance_rounded,
    silhouetteStyle: 1,
  ),
  BoondocksAvatarArchetype(
    id: 'the_mob_boss',
    name: 'DON CORLEONE JR.',
    roleBadge: 'DOOR 2 ENFORCER',
    catchphrase: '"Nobody crosses the crimson rope without clearance."',
    redCarpetActivity: 'Guarding the 18+ After-Hours speakeasy in a sharp pinstripe suit',
    primaryInkColor: Color(0xFFE11D48),
    rimAccentColor: Color(0xFFFDA4AF),
    shadowBlockColor: Color(0xFF2B0610),
    signatureIcon: Icons.smoking_rooms_rounded,
    silhouetteStyle: 2,
  ),
  BoondocksAvatarArchetype(
    id: 'the_method_actor',
    name: 'JULIAN VANE',
    roleBadge: 'METHOD CHAMELEON',
    catchphrase: '"I stayed in character for six months just for this lobby."',
    redCarpetActivity: 'Brooding intensely under a neon streetlamp muttering monologues',
    primaryInkColor: Color(0xFFA855F7),
    rimAccentColor: Color(0xFFD8B4FE),
    shadowBlockColor: Color(0xFF1E0B30),
    signatureIcon: Icons.theater_comedy_rounded,
    silhouetteStyle: 3,
  ),
  BoondocksAvatarArchetype(
    id: 'the_diva',
    name: 'VALENTINA LUX',
    roleBadge: 'HEADLINER DIVA',
    catchphrase: '"My close-up requires 24-karat lighting, darling."',
    redCarpetActivity: 'Adjusting oversized designer shades while tossing a faux-fur stole',
    primaryInkColor: Color(0xFFEC4899),
    rimAccentColor: Color(0xFFF9A8D4),
    shadowBlockColor: Color(0xFF2E081E),
    signatureIcon: Icons.diamond_rounded,
    silhouetteStyle: 4,
  ),
  BoondocksAvatarArchetype(
    id: 'the_stunt_double',
    name: 'NITRO KNOX',
    roleBadge: 'HIGH-WIRE STUNT PRO',
    catchphrase: '"One take, zero safety net, full send."',
    redCarpetActivity: 'Vaulting over a brass stanchion in a fireproof racing jacket',
    primaryInkColor: Color(0xFFF97316),
    rimAccentColor: Color(0xFFFDBA74),
    shadowBlockColor: Color(0xFF2B1104),
    signatureIcon: Icons.local_fire_department_rounded,
    silhouetteStyle: 5,
  ),
  BoondocksAvatarArchetype(
    id: 'the_indie_auteur',
    name: 'SUNDANCE SAGE',
    roleBadge: 'ART-HOUSE REBEL',
    catchphrase: '"It’s not a monologue, it’s a post-modern metaphor."',
    redCarpetActivity: 'Framing finger-squares at the crowd in a black turtleneck & beret',
    primaryInkColor: Color(0xFF10B981),
    rimAccentColor: Color(0xFF6EE7B7),
    shadowBlockColor: Color(0xFF042419),
    signatureIcon: Icons.movie_filter_rounded,
    silhouetteStyle: 6,
  ),
  BoondocksAvatarArchetype(
    id: 'the_nepo_baby',
    name: 'PRESTON STERLING III',
    roleBadge: 'VIP DYNASTY HEIR',
    catchphrase: '"My uncle owns Soundstage 4, let’s roll!"',
    redCarpetActivity: 'Flashing a platinum backstage lanyard to the security guards',
    primaryInkColor: Color(0xFFEAB308),
    rimAccentColor: Color(0xFFFEF08A),
    shadowBlockColor: Color(0xFF261C04),
    signatureIcon: Icons.verified_rounded,
    silhouetteStyle: 7,
  ),
  BoondocksAvatarArchetype(
    id: 'the_showrunner',
    name: 'MONICA VANCE',
    roleBadge: 'EXECUTIVE PRODUCER',
    catchphrase: '"We’re rewriting the third act live on air!"',
    redCarpetActivity: 'Simultaneously juggling two headsets and a glowing call sheet',
    primaryInkColor: Color(0xFF3B82F6),
    rimAccentColor: Color(0xFF93C5FD),
    shadowBlockColor: Color(0xFF07162E),
    signatureIcon: Icons.headset_mic_rounded,
    silhouetteStyle: 8,
  ),
  BoondocksAvatarArchetype(
    id: 'the_scream_queen',
    name: 'RAVEN BLACKWOOD',
    roleBadge: 'MIDNIGHT THRILLER STAR',
    catchphrase: '"Don’t look behind the soundstage curtain..."',
    redCarpetActivity: 'Casting dramatic noir shadows beside the Scene Vault rotunda',
    primaryInkColor: Color(0xFF8B5CF6),
    rimAccentColor: Color(0xFFC4B5FD),
    shadowBlockColor: Color(0xFF170B2E),
    signatureIcon: Icons.bolt_rounded,
    silhouetteStyle: 9,
  ),
  BoondocksAvatarArchetype(
    id: 'the_action_hero',
    name: 'REX TITAN',
    roleBadge: 'BLOCKBUSTER JUGGERNAUT',
    catchphrase: '"Explosions first, dialogue second."',
    redCarpetActivity: 'Flexing in a tactical vest while pyrotechnic sparks rain down',
    primaryInkColor: Color(0xFFEF4444),
    rimAccentColor: Color(0xFFFCA5A5),
    shadowBlockColor: Color(0xFF2B0707),
    signatureIcon: Icons.shield_rounded,
    silhouetteStyle: 10,
  ),
  BoondocksAvatarArchetype(
    id: 'the_late_night_host',
    name: 'DEVON MILES',
    roleBadge: 'AFTER-HOURS EMCEE',
    catchphrase: '"Welcome to the monologue that breaks the internet!"',
    redCarpetActivity: 'Tossing cue cards in the air with a gold vintage broadcast mic',
    primaryInkColor: Color(0xFF14B8A6),
    rimAccentColor: Color(0xFF5EEAD4),
    shadowBlockColor: Color(0xFF04221F),
    signatureIcon: Icons.mic_external_on_rounded,
    silhouetteStyle: 11,
  ),
  BoondocksAvatarArchetype(
    id: 'the_critic',
    name: 'ARTHUR PENDLETON',
    roleBadge: 'FRONT-ROW ARBITER',
    catchphrase: '"Astonishing audacity. Five golden statuettes!"',
    redCarpetActivity: 'Scribbling furious notes in a leather ledger through half-moon glasses',
    primaryInkColor: Color(0xFFF59E0B),
    rimAccentColor: Color(0xFFFDE68A),
    shadowBlockColor: Color(0xFF241605),
    signatureIcon: Icons.rate_review_rounded,
    silhouetteStyle: 12,
  ),
  BoondocksAvatarArchetype(
    id: 'the_scene_stealer',
    name: 'ZIGGY STARDUST',
    roleBadge: 'WILD-CARD IMPROVISER',
    catchphrase: '"Script? Where we’re going, we don’t need scripts!"',
    redCarpetActivity: 'Photobombing the VIP elevator with peace signs and electric grin',
    primaryInkColor: Color(0xFF06B6D4),
    rimAccentColor: Color(0xFFA5F3FC),
    shadowBlockColor: Color(0xFF051E26),
    signatureIcon: Icons.auto_awesome_rounded,
    silhouetteStyle: 13,
  ),
];

/// Helper to resolve any archetype ID to its `BoondocksAvatarArchetype` definition.
BoondocksAvatarArchetype resolveAvatarArchetype(String? id) {
  if (id == null || id.isEmpty) {
    return kFourteenAvatarArchetypes[3]; // Default: The Method Actor
  }
  for (final arch in kFourteenAvatarArchetypes) {
    if (arch.id == id) return arch;
  }
  return kFourteenAvatarArchetypes[3];
}

/// Renders a gritty, high-contrast 2.5D Cell-Shaded ("The Boondocks" style)
/// portrait of any of the 14 Avatar Archetypes using sharp black ink outlines,
/// hard cel-shaded shadow blocks, halftone speed lines, and urban-satirical flair.
/// Reusable 5-Layer 2.5D Articulated Puppet Rig ("The Boondocks" / comic-noir style).
/// Runs at 60fps with an internal continuous [AnimationController] when [externalPhase]
/// is not supplied, animating:
/// 1. Secondary Hair/Coat Silhouette (0.4rad phase delay)
/// 2. Breathing Torso & Shoulders (`math.sin(t * 2.5)`)
/// 3. Expressive Head & Jaw (dynamic head tilt + talking smirk lines)
/// 4. Natural Blinking Eyes & Specular Eyewear Sweep (140ms blink every 3.2s)
/// 5. Active Foreground Prop Hand (megaphone, camera flash, trophy, cigar, etc.)
class BoondocksCharacterRig extends StatefulWidget {
  final BoondocksAvatarArchetype archetype;
  final double size;
  final bool isSelected;
  final bool isMirroredReflection;
  final double? externalPhase;
  final VoidCallback? onTap;

  const BoondocksCharacterRig({
    super.key,
    required this.archetype,
    this.size = 76,
    this.isSelected = false,
    this.isMirroredReflection = false,
    this.externalPhase,
    this.onTap,
  });

  @override
  State<BoondocksCharacterRig> createState() => _BoondocksCharacterRigState();
}

class _BoondocksCharacterRigState extends State<BoondocksCharacterRig>
    with SingleTickerProviderStateMixin {
  AnimationController? _rigController;

  @override
  void initState() {
    super.initState();
    if (widget.externalPhase == null) {
      _rigController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 6400),
      )..repeat();
    }
  }

  @override
  void didUpdateWidget(covariant BoondocksCharacterRig oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.externalPhase == null && _rigController == null) {
      _rigController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 6400),
      )..repeat();
    } else if (widget.externalPhase != null && _rigController != null) {
      _rigController?.dispose();
      _rigController = null;
    }
  }

  @override
  void dispose() {
    _rigController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = _rigController != null
        ? AnimatedBuilder(
            animation: _rigController!,
            builder: (context, _) {
              final elapsedSec = _rigController!.value * 6.4;
              return CustomPaint(
                painter: _BoondocksCellShadedPortraitPainter(
                  archetype: widget.archetype,
                  isSelected: widget.isSelected,
                  phase: elapsedSec,
                ),
              );
            },
          )
        : CustomPaint(
            painter: _BoondocksCellShadedPortraitPainter(
              archetype: widget.archetype,
              isSelected: widget.isSelected,
              phase: widget.externalPhase ?? 0.0,
            ),
          );

    final rigBox = Opacity(
      opacity: widget.isMirroredReflection ? 0.52 : 1.0,
      child: Transform.scale(
        scaleX: widget.isMirroredReflection ? -1.0 : 1.0,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: child,
        ),
      ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: rigBox,
      );
    }
    return rigBox;
  }
}

/// Renders a gritty, high-contrast 2.5D Cell-Shaded ("The Boondocks" style)
/// articulated 5-layer puppet portrait of any of the 14 Avatar Archetypes.
class BoondocksAvatarPortrait extends StatelessWidget {
  final BoondocksAvatarArchetype archetype;
  final double size;
  final bool isSelected;
  final bool isMirroredReflection;
  final double animationPhase;
  final VoidCallback? onTap;

  const BoondocksAvatarPortrait({
    super.key,
    required this.archetype,
    this.size = 76,
    this.isSelected = false,
    this.isMirroredReflection = false,
    this.animationPhase = 0.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BoondocksCharacterRig(
      archetype: archetype,
      size: size,
      isSelected: isSelected,
      isMirroredReflection: isMirroredReflection,
      externalPhase: animationPhase != 0.0 ? animationPhase : null,
      onTap: onTap,
    );
  }
}

/// Opens a full-card Spotlight Bio & Live 5-Layer Puppet Preview Modal when a
/// player taps any 2.5D character rig on the Red Carpet or beside a Soundstage Door.
Future<void> showBoondocksCharacterSpotlightModal(
  BuildContext context,
  BoondocksAvatarArchetype archetype, {
  VoidCallback? onEquipped,
}) async {
  HapticFeedback.mediumImpact();
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (modalContext) {
      final currentId =
          AuthService.instance.currentProfile?.avatarArchetypeId ??
              'the_method_actor';
      final isAlreadyEquipped = currentId == archetype.id;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xF807090E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: archetype.primaryInkColor,
                width: 3.0,
              ),
              boxShadow: <BoxShadow>[
                const BoxShadow(
                  color: Color(0xFF05070B),
                  offset: Offset(6, 6),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: archetype.primaryInkColor.withValues(alpha: 0.35),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: archetype.primaryInkColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '2.5D PUPPET RIG · ${archetype.roleBadge}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF05070B),
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(modalContext).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFFF5DEB3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BoondocksCharacterRig(
                      archetype: archetype,
                      size: 112,
                      isSelected: true,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            archetype.name,
                            style: GoogleFonts.bebasNeue(
                              fontSize: 30,
                              letterSpacing: 1.5,
                              color: const Color(0xFFF5DEB3),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            archetype.catchphrase,
                            style: const TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFDE68A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B0E17),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            child: Text(
                              archetype.redCarpetActivity,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10.5,
                                color: Color(0xFF0CB6D4),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAlreadyEquipped
                        ? const Color(0xFF10B981)
                        : archetype.primaryInkColor,
                    foregroundColor: const Color(0xFF05070B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color(0xFF05070B),
                        width: 2.5,
                      ),
                    ),
                  ),
                  onPressed: () async {
                    HapticFeedback.heavyImpact();
                    await AuthService.instance
                        .updateAvatarArchetype(archetype.id);
                    onEquipped?.call();
                    if (modalContext.mounted) {
                      Navigator.of(modalContext).pop();
                      ScaffoldMessenger.of(modalContext).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF0B0E17),
                          content: Text(
                            'Equipped 2.5D Rig: ${archetype.name} (${archetype.roleBadge})',
                            style: const TextStyle(color: Color(0xFFF5DEB3)),
                          ),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    isAlreadyEquipped
                        ? Icons.verified_rounded
                        : Icons.stars_rounded,
                  ),
                  label: Text(
                    isAlreadyEquipped
                        ? 'CURRENTLY EQUIPPED ON STAGE PASS'
                        : 'EQUIP ${archetype.name.toUpperCase()} AS MY AVATAR',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _BoondocksCellShadedPortraitPainter extends CustomPainter {
  final BoondocksAvatarArchetype archetype;
  final bool isSelected;
  final double phase;

  const _BoondocksCellShadedPortraitPainter({
    required this.archetype,
    required this.isSelected,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radius = size.shortestSide * 0.46;
    final seed = archetype.silhouetteStyle * 0.65;
    final t = phase;

    // 5-Layer Articulated Kinematics
    final breathBob = math.sin(t * 2.5 + seed) * (radius * 0.045);
    final chestExpand = 1.0 + math.sin(t * 2.5 + seed) * 0.032;
    final secondaryHairOffset =
        math.sin(t * 2.5 + seed - 0.4) * (radius * 0.055);
    final headTiltAngle = math.sin(t * 1.8 + seed) * 0.065;
    final talkPulse = (math.sin(t * 6.2 + seed * 2.0) + 1.0) * 0.5;
    // Periodic 140ms natural eye blink every 3.2 seconds
    final cycleSec = (t + (archetype.silhouetteStyle * 0.23)) % 3.2;
    final isBlinking = cycleSec >= 2.95 && cycleSec <= 3.09;
    final lensSweepT = ((t * 0.55 + seed) % 1.6).clamp(0.0, 1.0);

    // 1. Comic Cell-Shaded Frame Background
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCircle(center: center, radius: radius),
      Radius.circular(size.shortestSide * 0.22),
    );

    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          archetype.shadowBlockColor,
          const Color(0xFF07090E),
          archetype.primaryInkColor.withValues(alpha: 0.35),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(bgRect, bgPaint);

    // Kinetic Anime Speed Lines inside the frame
    canvas.save();
    canvas.clipRRect(bgRect);
    final speedLinePaint = Paint()
      ..color =
          archetype.rimAccentColor.withValues(alpha: isSelected ? 0.42 : 0.22)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi / 5) + (t * 0.25);
      final innerR = radius * 0.52;
      final outerR = radius * 1.15;
      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * innerR,
          center.dy + math.sin(angle) * innerR,
        ),
        Offset(
          center.dx + math.cos(angle) * outerR,
          center.dy + math.sin(angle) * outerR,
        ),
        speedLinePaint,
      );
    }

    // =========================================================================
    // LAYER 1: Secondary Hair / Coat Collar Silhouette (0.4rad phase delay)
    // =========================================================================
    final capePath = Path()
      ..moveTo(
        center.dx - radius * 0.84 + secondaryHairOffset,
        size.height,
      )
      ..lineTo(
        center.dx - radius * 0.62 + secondaryHairOffset * 0.5,
        center.dy + radius * 0.14 + breathBob,
      )
      ..lineTo(
        center.dx + radius * 0.62 + secondaryHairOffset * 0.5,
        center.dy + radius * 0.14 + breathBob,
      )
      ..lineTo(
        center.dx + radius * 0.84 + secondaryHairOffset,
        size.height,
      )
      ..close();
    canvas.drawPath(
      capePath,
      Paint()..color = archetype.shadowBlockColor.withValues(alpha: 0.92),
    );

    // =========================================================================
    // LAYER 2: Breathing Torso & Shoulders (`math.sin(t * 2.5)`)
    // =========================================================================
    final shoulderTopY = center.dy + radius * 0.25 + breathBob;
    final halfShoulderW = radius * 0.54 * chestExpand;
    final shoulderPath = Path()
      ..moveTo(center.dx - radius * 0.80 * chestExpand, size.height)
      ..lineTo(center.dx - halfShoulderW, shoulderTopY)
      ..lineTo(center.dx + halfShoulderW, shoulderTopY)
      ..lineTo(center.dx + radius * 0.80 * chestExpand, size.height)
      ..close();

    final suitPaint = Paint()
      ..color = const Color(0xFF111622)
      ..style = PaintingStyle.fill;
    canvas.drawPath(shoulderPath, suitPaint);

    // Hard cel-shaded lapel highlight on left side
    final lapelHighlight = Path()
      ..moveTo(center.dx - halfShoulderW, shoulderTopY)
      ..lineTo(center.dx, center.dy + radius * 0.64 + breathBob)
      ..lineTo(center.dx - radius * 0.26, size.height)
      ..lineTo(center.dx - radius * 0.72, size.height)
      ..close();
    canvas.drawPath(
      lapelHighlight,
      Paint()..color = archetype.primaryInkColor.withValues(alpha: 0.78),
    );

    // Right lapel & tie accent
    final rightLapel = Path()
      ..moveTo(center.dx + halfShoulderW, shoulderTopY)
      ..lineTo(center.dx, center.dy + radius * 0.64 + breathBob)
      ..lineTo(center.dx + radius * 0.22, size.height)
      ..close();
    canvas.drawPath(
      rightLapel,
      Paint()..color = archetype.rimAccentColor.withValues(alpha: 0.45),
    );

    // =========================================================================
    // LAYER 3: Expressive Head & Jaw (Dynamic Head Tilt + Talking Mouth)
    // =========================================================================
    final headCenter = Offset(
      center.dx + secondaryHairOffset * 0.25,
      center.dy - radius * 0.08 + breathBob * 0.85,
    );
    final headW = radius * 0.72;
    final headH = radius * 0.80;

    canvas.save();
    canvas.translate(headCenter.dx, headCenter.dy);
    canvas.rotate(headTiltAngle);
    canvas.translate(-headCenter.dx, -headCenter.dy);

    final jawPath = Path()
      ..moveTo(headCenter.dx - headW * 0.5, headCenter.dy - headH * 0.25)
      ..lineTo(headCenter.dx - headW * 0.44, headCenter.dy + headH * 0.24)
      ..lineTo(headCenter.dx, headCenter.dy + headH * 0.52)
      ..lineTo(headCenter.dx + headW * 0.44, headCenter.dy + headH * 0.24)
      ..lineTo(headCenter.dx + headW * 0.5, headCenter.dy - headH * 0.25)
      ..arcToPoint(
        Offset(headCenter.dx - headW * 0.5, headCenter.dy - headH * 0.25),
        radius: Radius.circular(headW * 0.55),
        clockwise: false,
      )
      ..close();

    // Base warm cel-tone + hard right-half shadow block
    canvas.drawPath(
      jawPath,
      Paint()..color = const Color(0xFFC68652),
    );

    final shadowHalfPath = Path()
      ..moveTo(headCenter.dx, headCenter.dy - headH * 0.65)
      ..lineTo(headCenter.dx + headW * 0.6, headCenter.dy - headH * 0.65)
      ..lineTo(headCenter.dx + headW * 0.6, headCenter.dy + headH * 0.65)
      ..lineTo(headCenter.dx, headCenter.dy + headH * 0.65)
      ..close();
    canvas.save();
    canvas.clipPath(jawPath);
    canvas.drawPath(
      shadowHalfPath,
      Paint()..color = const Color(0xFF7C4722).withValues(alpha: 0.78),
    );
    canvas.restore();

    // Archetype-Specific Hair / Hat / Crown / Afro / Fedora Silhouette (with secondary sway)
    final hairPaint = Paint()
      ..color = const Color(0xFF07090E)
      ..style = PaintingStyle.fill;
    final styleIndex = archetype.silhouetteStyle % 5;

    if (styleIndex == 0 || styleIndex == 3) {
      final hairPath = Path();
      const int spikes = 7;
      for (int i = 0; i <= spikes; i++) {
        final frac = i / spikes;
        final angle = math.pi + (frac * math.pi);
        final rOuter = headW * (0.72 + (i.isEven ? 0.22 : 0.04));
        final px =
            headCenter.dx + secondaryHairOffset * 0.35 + math.cos(angle) * rOuter;
        final py = (headCenter.dy - headH * 0.18) + math.sin(angle) * rOuter;
        if (i == 0) {
          hairPath.moveTo(px, py);
        } else {
          hairPath.lineTo(px, py);
        }
      }
      hairPath.close();
      canvas.drawPath(hairPath, hairPaint);
    } else if (styleIndex == 1 || styleIndex == 2) {
      final brimRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(
            headCenter.dx + secondaryHairOffset * 0.25,
            headCenter.dy - headH * 0.34,
          ),
          width: headW * 1.38,
          height: headH * 0.18,
        ),
        const Radius.circular(4),
      );
      final crownRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(
            headCenter.dx + secondaryHairOffset * 0.25,
            headCenter.dy - headH * 0.56,
          ),
          width: headW * 0.88,
          height: headH * 0.38,
        ),
        const Radius.circular(6),
      );
      canvas.drawRRect(crownRect, hairPaint);
      canvas.drawRRect(brimRect, hairPaint);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(
            headCenter.dx + secondaryHairOffset * 0.25,
            headCenter.dy - headH * 0.42,
          ),
          width: headW * 0.88,
          height: 3.5,
        ),
        Paint()..color = archetype.rimAccentColor,
      );
    } else {
      canvas.drawCircle(
        Offset(
          headCenter.dx - headW * 0.26 + secondaryHairOffset * 0.3,
          headCenter.dy - headH * 0.38,
        ),
        headW * 0.36,
        hairPaint,
      );
      canvas.drawCircle(
        Offset(
          headCenter.dx + headW * 0.26 + secondaryHairOffset * 0.3,
          headCenter.dy - headH * 0.38,
        ),
        headW * 0.36,
        hairPaint,
      );
      canvas.drawCircle(
        Offset(
          headCenter.dx + secondaryHairOffset * 0.3,
          headCenter.dy - headH * 0.48,
        ),
        headW * 0.42,
        hairPaint,
      );
    }

    // =========================================================================
    // LAYER 4: Natural Blinking Eyes & Specular Eyewear Sweep
    // =========================================================================
    final eyeY = headCenter.dy - headH * 0.04;
    final browLift = math.sin(t * 2.8 + seed) * 1.6;
    final browPaint = Paint()
      ..color = const Color(0xFF05070B)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(
      Offset(headCenter.dx - headW * 0.34, eyeY - 6 - browLift),
      Offset(headCenter.dx - headW * 0.08, eyeY - 3 + browLift * 0.5),
      browPaint,
    );
    canvas.drawLine(
      Offset(headCenter.dx + headW * 0.34, eyeY - 6 - browLift),
      Offset(headCenter.dx + headW * 0.08, eyeY - 3 + browLift * 0.5),
      browPaint,
    );

    final lensHeight = isBlinking ? 2.2 : headH * 0.16;
    final leftLens = Rect.fromCenter(
      center: Offset(headCenter.dx - headW * 0.20, eyeY + 1),
      width: headW * 0.28,
      height: lensHeight,
    );
    final rightLens = Rect.fromCenter(
      center: Offset(headCenter.dx + headW * 0.20, eyeY + 1),
      width: headW * 0.28,
      height: lensHeight,
    );

    final lensFill = Paint()
      ..color = isBlinking
          ? const Color(0xFF05070B)
          : (archetype.silhouetteStyle.isEven
              ? const Color(0xFF07090E)
              : Colors.white);
    canvas.drawRect(leftLens, lensFill);
    canvas.drawRect(rightLens, lensFill);

    if (!isBlinking) {
      final sweepOffset = (lensSweepT - 0.5) * leftLens.width * 0.85;
      final glintPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..strokeWidth = 2.0;
      canvas.drawLine(
        Offset(leftLens.left + 2 + sweepOffset * 0.4, leftLens.top + 1),
        Offset(leftLens.right - 2 + sweepOffset * 0.4, leftLens.bottom - 1),
        glintPaint,
      );
      canvas.drawLine(
        Offset(rightLens.left + 2 + sweepOffset * 0.4, rightLens.top + 1),
        Offset(rightLens.right - 2 + sweepOffset * 0.4, rightLens.bottom - 1),
        glintPaint,
      );
    }

    // Expressive Animated Talking Mouth / Smirk Line
    final mouthY = headCenter.dy + headH * 0.26;
    if (talkPulse > 0.62 && isSelected) {
      final mouthRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(headCenter.dx + 1, mouthY),
          width: headW * 0.26,
          height: 3.5 + talkPulse * 2.5,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(mouthRect, Paint()..color = const Color(0xFF05070B));
      canvas.drawLine(
        Offset(mouthRect.left + 1.5, mouthRect.top + 1.5),
        Offset(mouthRect.right - 1.5, mouthRect.top + 1.5),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1.4,
      );
    } else {
      canvas.drawLine(
        Offset(headCenter.dx - headW * 0.16, mouthY),
        Offset(headCenter.dx + headW * 0.18, mouthY - 2 - talkPulse * 1.5),
        browPaint,
      );
    }

    final inkOutlinePaint = Paint()
      ..color = const Color(0xFF05070B)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.miter;
    canvas.drawPath(jawPath, inkOutlinePaint);
    canvas.restore(); // End head rotation

    canvas.drawPath(shoulderPath, inkOutlinePaint);

    // =========================================================================
    // LAYER 5: Active Foreground Prop Hand (Gesture & Prop Animation)
    // =========================================================================
    final propBobY = math.sin(t * 3.8 + seed) * (radius * 0.06);
    final handCenter = Offset(
      center.dx + radius * 0.46,
      center.dy + radius * 0.42 + propBobY,
    );

    canvas.drawCircle(
      handCenter,
      radius * 0.13,
      Paint()..color = const Color(0xFFC68652),
    );
    canvas.drawCircle(
      handCenter,
      radius * 0.13,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );

    if (archetype.id == 'the_director') {
      final cone = Path()
        ..moveTo(handCenter.dx - 2, handCenter.dy)
        ..lineTo(handCenter.dx - radius * 0.36, handCenter.dy - radius * 0.24)
        ..lineTo(handCenter.dx - radius * 0.36, handCenter.dy + radius * 0.06)
        ..close();
      canvas.drawPath(cone, Paint()..color = const Color(0xFFE11342));
      canvas.drawPath(
        cone,
        Paint()
          ..color = const Color(0xFF05070B)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );
    } else if (archetype.id == 'the_mob_boss') {
      final cigarRect = Rect.fromLTWH(
        headCenter.dx + headW * 0.06,
        headCenter.dy + headH * 0.22,
        headW * 0.38,
        4.5,
      );
      canvas.drawRect(cigarRect, Paint()..color = const Color(0xFF78350F));
      canvas.drawCircle(
        Offset(cigarRect.right, cigarRect.center.dy),
        2.8,
        Paint()..color = const Color(0xFFEF4444),
      );
      canvas.drawCircle(
        Offset(cigarRect.right + 4, cigarRect.top - 5 + propBobY),
        3.2,
        Paint()..color = Colors.white.withValues(alpha: 0.45),
      );
    } else if (archetype.id == 'the_paparazzo') {
      final camRect = Rect.fromCenter(
        center: Offset(handCenter.dx - radius * 0.12, handCenter.dy - 4),
        width: radius * 0.28,
        height: radius * 0.20,
      );
      canvas.drawRect(camRect, Paint()..color = const Color(0xFF05070B));
      if ((t * 2.5).floor().isEven) {
        canvas.drawCircle(
          camRect.center,
          radius * 0.18,
          Paint()..color = const Color(0xFFF5DEB3).withValues(alpha: 0.85),
        );
      }
    } else {
      canvas.drawCircle(
        Offset(handCenter.dx - radius * 0.10, handCenter.dy - radius * 0.12),
        radius * 0.11,
        Paint()..color = archetype.rimAccentColor,
      );
    }

    canvas.restore(); // End bgRect clip

    // Outer Comic Panel Border (Thick Ink + Neon Rim)
    canvas.drawRRect(
      bgRect,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 4.2
        ..style = PaintingStyle.stroke,
    );
    canvas.drawRRect(
      bgRect.deflate(1.6),
      Paint()
        ..color =
            isSelected ? archetype.rimAccentColor : archetype.primaryInkColor
        ..strokeWidth = isSelected ? 2.6 : 1.6
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _BoondocksCellShadedPortraitPainter oldDelegate) {
    return oldDelegate.archetype.id != archetype.id ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.phase != phase;
  }
}

/// Central interactive brand centerpiece built around `assets/app_logo.png`.
/// Features 2.5D cell-shaded spotlight sweeps, touch-reactive 3D tilt parallax,
/// comic speed-line bursts, and a seamless custom-painted cell-shaded crest
/// fallback if `assets/app_logo.png` is not yet bundled in the asset tree.
class ActLikeItBrandCenterpiece extends StatefulWidget {
  final double height;
  final bool compact;
  final VoidCallback? onTap;

  const ActLikeItBrandCenterpiece({
    super.key,
    this.height = 148,
    this.compact = false,
    this.onTap,
  });

  @override
  State<ActLikeItBrandCenterpiece> createState() =>
      _ActLikeItBrandCenterpieceState();
}

class _ActLikeItBrandCenterpieceState extends State<ActLikeItBrandCenterpiece>
    with SingleTickerProviderStateMixin {
  late final AnimationController _auraController;
  Offset _tiltOffset = Offset.zero;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _auraController.dispose();
    super.dispose();
  }

  void _updateTilt(Offset localPos, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final dx = ((localPos.dx / size.width) - 0.5) * 2.0;
    final dy = ((localPos.dy / size.height) - 0.5) * 2.0;
    setState(() {
      _tiltOffset = Offset(dx.clamp(-1.0, 1.0), dy.clamp(-1.0, 1.0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 320,
          widget.height,
        );
        return GestureDetector(
          onTapDown: (d) {
            HapticFeedback.lightImpact();
            setState(() => _isPressed = true);
            _updateTilt(d.localPosition, boxSize);
          },
          onPanUpdate: (d) => _updateTilt(d.localPosition, boxSize),
          onTapUp: (_) {
            setState(() {
              _isPressed = false;
              _tiltOffset = Offset.zero;
            });
            widget.onTap?.call();
          },
          onTapCancel: () {
            setState(() {
              _isPressed = false;
              _tiltOffset = Offset.zero;
            });
          },
          child: AnimatedBuilder(
            animation: _auraController,
            builder: (context, _) {
              final phase = _auraController.value * math.pi * 2;
              final matrix = Matrix4.identity()
                ..setEntry(3, 2, 0.0014)
                ..rotateX(-_tiltOffset.dy * 0.16)
                ..rotateY(_tiltOffset.dx * 0.18)
                ..scale(_isPressed ? 0.96 : 1.0);

              return Transform(
                alignment: Alignment.center,
                transform: matrix,
                child: SizedBox(
                  height: widget.height,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 1. Cell-Shaded Kinetic Speed Lines & Spotlight Halo
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _BrandCenterpieceAuraPainter(
                            phase: phase,
                            isPressed: _isPressed,
                          ),
                        ),
                      ),

                      // 2. Central `assets/app_logo.png` with Cell-Shaded Ink Rim & Fallback
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.compact ? 18 : 24,
                          vertical: widget.compact ? 10 : 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xF207090E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF05070B),
                            width: 3.8,
                          ),
                          boxShadow: <BoxShadow>[
                            const BoxShadow(
                              color: Color(0xFF05070B),
                              offset: Offset(6, 6),
                              blurRadius: 0,
                            ),
                            BoxShadow(
                              color: const Color(0xFFF5DEB3).withValues(
                                alpha: 0.32 + 0.18 * math.sin(phase * 2),
                              ),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFF5DEB3),
                              width: 2.2,
                            ),
                          ),
                          child: Image.asset(
                            'assets/app_logo.png',
                            height: widget.compact
                                ? widget.height * 0.54
                                : widget.height * 0.62,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildCellShadedCrestFallback(phase);
                            },
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
      },
    );
  }

  Widget _buildCellShadedCrestFallback(double phase) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: widget.compact ? 42 : 52,
          height: widget.compact ? 42 : 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF520002), Color(0xFFE11342)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF05070B), width: 3.2),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0xFF05070B),
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: const Icon(
            Icons.movie_filter_rounded,
            color: Color(0xFFF5DEB3),
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACT LIKE IT',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.bebasNeue(
                  fontSize: widget.compact ? 28 : 36,
                  letterSpacing: 2.6,
                  height: 0.98,
                  color: const Color(0xFFF5DEB3),
                  shadows: const <Shadow>[
                    Shadow(
                      color: Color(0xFF05070B),
                      offset: Offset(3.0, 3.0),
                      blurRadius: 0,
                    ),
                    Shadow(
                      color: Color(0xFFE11342),
                      offset: Offset(-1.5, -1.5),
                      blurRadius: 0,
                    ),
                  ],
                ),
              ),
              const Text(
                '2.5D PREMIERE SOUNDSTAGE · ROLL CAMERA',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: Color(0xFF0CB6D4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BrandCenterpieceAuraPainter extends CustomPainter {
  final double phase;
  final bool isPressed;

  const _BrandCenterpieceAuraPainter({
    required this.phase,
    required this.isPressed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final maxR = size.longestSide * 0.55;

    final rayPaint = Paint()
      ..color = const Color(0xFFF5DEB3).withValues(alpha: isPressed ? 0.45 : 0.24)
      ..strokeWidth = isPressed ? 2.4 : 1.5;

    const int rays = 18;
    for (int i = 0; i < rays; i++) {
      final angle = (i * (math.pi * 2 / rays)) + (phase * 0.35);
      final inner = 36.0 + (i.isEven ? 8.0 : 0.0);
      final outer = maxR * (i.isEven ? 0.95 : 0.68);
      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * inner,
          center.dy + math.sin(angle) * inner,
        ),
        Offset(
          center.dx + math.cos(angle) * outer,
          center.dy + math.sin(angle) * outer,
        ),
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BrandCenterpieceAuraPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.isPressed != isPressed;
}

/// MODULE 1: Cell-Shaded Cinematic Opening (`lib/ui/intro_cinematic.dart`).
/// - Plays automatically on launch with a high-contrast "FAST-SKIP TO RED CARPET"
///   glass pill for returning actors.
/// - Renders a 60fps first-person walk down a chaotic, 2.5D cell-shaded Red Carpet
///   populated by all 14 Avatar Archetypes.
/// - Features the central `assets/app_logo.png` interactive brand centerpiece.
/// - Transitions to Auth when the "Director" archetype yells "CUT!" and slaps a
///   heavy cell-shaded clapperboard directly into the camera lens, cutting to black.
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
  Timer? _autoDirectorCutTimer;
  Timer? _spotlightCycleTimer;

  bool _isCuttingToAuth = false;
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

    // Cycle featured foreground archetype callout every 2.5 seconds (readable pace)
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

    // Auto-trigger the Director's "CUT!" clapperboard smash after 18 seconds
    // if the player hasn't tapped Fast-Skip or Roll Camera yet.
    _autoDirectorCutTimer = Timer(const Duration(milliseconds: 18000), () {
      if (mounted && !_isCuttingToAuth) {
        _triggerDirectorCutToAuth();
      }
    });
  }

  @override
  void dispose() {
    _autoDirectorCutTimer?.cancel();
    _spotlightCycleTimer?.cancel();
    _walkController.dispose();
    _clapperSmashController.dispose();
    super.dispose();
  }

  /// Fast-Skip directly to the 3D/2.5D Red Carpet Dashboard for returning actors.
  Future<void> _handleFastSkipToRedCarpet() async {
    if (_isCuttingToAuth) return;
    _autoDirectorCutTimer?.cancel();
    HapticFeedback.heavyImpact();

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

  /// The "Director" character yells "CUT!", slapping a heavy 2.5D cell-shaded
  /// clapperboard directly into the camera lens, cutting hard to black, and
  /// opening the Dual-Track Auth screen.
  Future<void> _triggerDirectorCutToAuth() async {
    if (_isCuttingToAuth) return;
    _autoDirectorCutTimer?.cancel();
    HapticFeedback.heavyImpact();

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

          // First-person footstep head-bob math (60fps)
          final stepBobY = math.sin(walkProgress * math.pi * 16) * 6.5;
          final stepSwayX = math.cos(walkProgress * math.pi * 8) * 5.0;

          return Stack(
            fit: StackFit.expand,
            children: [
              // ---------------------------------------------------------------
              // 1. FIRST-PERSON 2.5D CELL-SHADED RED CARPET WALK & 14 ARCHETYPES
              // ---------------------------------------------------------------
              Transform.translate(
                offset: Offset(stepSwayX, stepBobY),
                child: CustomPaint(
                  painter: _FirstPersonCellShadedCarpetWalkPainter(
                    walkProgress: walkProgress,
                  ),
                ),
              ),

              // ---------------------------------------------------------------
              // 2. FOREGROUND UI: FAST-SKIP PILL, LOGO HERO & ARCHETYPE TICKER
              // ---------------------------------------------------------------
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Bar: POV Badge + "FAST-SKIP TO RED CARPET" Glass Pill
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xF207090E),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF05070B),
                                width: 2.8,
                              ),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                  color: Color(0xFF05070B),
                                  offset: Offset(3, 3),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.videocam_rounded,
                                  color: Color(0xFFE11342),
                                  size: 14,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'POV · 2.5D PREMIERE WALK',
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
                          const SizedBox(width: 8),
                          // High-contrast "FAST-SKIP TO RED CARPET" Glass Pill wrapped in Flexible + FittedBox
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
                                        boxShadow: const <BoxShadow>[
                                          BoxShadow(
                                            color: Color(0xFF05070B),
                                            offset: Offset(3, 3),
                                            blurRadius: 0,
                                          ),
                                        ],
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

                      const SizedBox(height: 16),

                      // Central `assets/app_logo.png` Brand Centerpiece
                      ActLikeItBrandCenterpiece(
                        height: 132,
                        onTap: _triggerDirectorCutToAuth,
                      ),

                      const Spacer(),

                      // Live 14-Archetype Cell-Shaded Encounter Callout Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xF207090E),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF05070B),
                            width: 3.5,
                          ),
                          boxShadow: <BoxShadow>[
                            const BoxShadow(
                              color: Color(0xFF05070B),
                              offset: Offset(5, 5),
                              blurRadius: 0,
                            ),
                            BoxShadow(
                              color: activeArchetype.primaryInkColor
                                  .withValues(alpha: 0.32),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            BoondocksAvatarPortrait(
                              archetype: activeArchetype,
                              size: 68,
                              isSelected: true,
                              animationPhase: walkProgress * math.pi * 2,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: activeArchetype.primaryInkColor,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          'ARCHETYPE ${_spotlightArchetypeIndex + 1}/14 · ${activeArchetype.roleBadge}',
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF05070B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
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
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFF5DEB3),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    activeArchetype.redCarpetActivity,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      color: Color(0xFF0CB6D4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Horizontal Strip of All 14 Cell-Shaded Archetypes on the Carpet
                      SizedBox(
                        height: 62,
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
                              child: BoondocksAvatarPortrait(
                                archetype: arch,
                                size: selected ? 60 : 52,
                                isSelected: selected,
                                animationPhase: walkProgress * math.pi * 2,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Primary CTA: Trigger Director "CUT!" Clapperboard Smash -> Auth
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11342),
                          foregroundColor: const Color(0xFFF5DEB3),
                          padding: const EdgeInsets.symmetric(vertical: 15),
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
                        label: Text(
                          'STEP TO THE MIC · DIRECTOR\'S "CUT!" TO CASTING',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 20,
                            letterSpacing: 1.6,
                            color: const Color(0xFFF5DEB3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------------------------------------------------------------
              // 3. THE DIRECTOR YELLS "CUT!" & SLAPS CLAPPERBOARD INTO LENS
              // ---------------------------------------------------------------
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
}

/// Paints the 60fps First-Person POV walk down a chaotic, 2.5D cell-shaded
/// Red Carpet with thick ink perspective lines, kinetic speed lines, paparazzi
/// flashes, and cell-shaded silhouettes of the 14 Archetypes lining the ropes.
class _FirstPersonCellShadedCarpetWalkPainter extends CustomPainter {
  final double walkProgress;

  const _FirstPersonCellShadedCarpetWalkPainter({required this.walkProgress});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Gritty Urban-Satirical Night Sky with Cell-Shaded Spotlight Cones
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
    final horizonY = size.height * 0.24;

    // Sweeping cel-shaded searchlights in Limelight Gold & Soundstage Cyan
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

    // 2. First-Person 2.5D Cell-Shaded Crimson Carpet Runner with Heavy Black Ink
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

    // Bold black comic ink edges on the Red Carpet
    final heavyInk = Paint()
      ..color = const Color(0xFF05070B)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(carpetPath, heavyInk);

    // Limelight Gold inner trim lines
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

    // 3. Advancing First-Person Carpet Treads & 14 Archetypes Along the Ropes
    const int depthSlices = 7;
    final shift = (walkProgress * 4.0) % 1.0;

    for (int i = 0; i < depthSlices; i++) {
      final rawT = ((i + shift) / depthSlices) % 1.0;
      final easedT = rawT * rawT;
      final y = horizonY + (size.height - horizonY) * easedT;
      final halfW = topHalfW + (botHalfW - topHalfW) * easedT;

      // Cel-shaded tread line
      canvas.drawLine(
        Offset(centerX - halfW, y),
        Offset(centerX + halfW, y),
        Paint()
          ..color = const Color(0xFF05070B).withValues(alpha: 0.65 * easedT)
          ..strokeWidth = 1.5 + easedT * 3.0,
      );

      // Left & Right 5-Layer 2.5D Archetype Puppets leaning over the velvet ropes
      final leftArch = kFourteenAvatarArchetypes[(i * 2) % 14];
      final rightArch = kFourteenAvatarArchetypes[(i * 2 + 1) % 14];
      final charScale = 22.0 + easedT * 48.0;

      _drawArticulatedRedCarpetPuppet(
        canvas,
        anchor: Offset(centerX - halfW - charScale * 0.45, y),
        scale: charScale,
        archetype: leftArch,
        walkProgress: walkProgress,
        isLeftSide: true,
        flashActive: (i + (walkProgress * 12).floor()) % 3 == 0,
      );
      _drawArticulatedRedCarpetPuppet(
        canvas,
        anchor: Offset(centerX + halfW + charScale * 0.45, y),
        scale: charScale,
        archetype: rightArch,
        walkProgress: walkProgress,
        isLeftSide: false,
        flashActive: (i + (walkProgress * 12).floor()) % 4 == 0,
      );
    }

    // 4. Peripheral Kinetic Anime Action Lines (First-Person Rush Effect)
    final actionLinePaint = Paint()
      ..color = const Color(0xFFF5DEB3).withValues(alpha: 0.16)
      ..strokeWidth = 2.0;
    for (int i = 0; i < 16; i++) {
      final angle = (i / 16.0) * math.pi * 2 + walkProgress * 0.8;
      final r1 = size.shortestSide * 0.38;
      final r2 = size.longestSide * 0.75;
      canvas.drawLine(
        Offset(centerX + math.cos(angle) * r1, horizonY + math.sin(angle) * r1),
        Offset(centerX + math.cos(angle) * r2, horizonY + math.sin(angle) * r2),
        actionLinePaint,
      );
    }
  }

  void _drawArticulatedRedCarpetPuppet(
    Canvas canvas, {
    required Offset anchor,
    required double scale,
    required BoondocksAvatarArchetype archetype,
    required double walkProgress,
    required bool isLeftSide,
    required bool flashActive,
  }) {
    final t = walkProgress * math.pi * 4 + archetype.silhouetteStyle * 0.7;
    final breathBob = math.sin(t) * (scale * 0.04);
    final hairLag = math.sin(t - 0.4) * (scale * 0.05);
    final headTilt = math.sin(t * 0.8) * 0.08 * (isLeftSide ? 1.0 : -1.0);
    final dirSign = isLeftSide ? 1.0 : -1.0;

    // 1. Secondary Coat/Cape Layer
    final capePath = Path()
      ..moveTo(anchor.dx - scale * 0.42 + hairLag, anchor.dy)
      ..lineTo(anchor.dx - scale * 0.30, anchor.dy - scale * 0.78 + breathBob)
      ..lineTo(anchor.dx + scale * 0.30, anchor.dy - scale * 0.78 + breathBob)
      ..lineTo(anchor.dx + scale * 0.42 + hairLag, anchor.dy)
      ..close();
    canvas.drawPath(
      capePath,
      Paint()..color = archetype.shadowBlockColor,
    );

    // 2. Breathing Torso & Cel-Shaded Lapels
    final torsoTop = anchor.dy - scale * 0.74 + breathBob;
    final torsoPath = Path()
      ..moveTo(anchor.dx - scale * 0.36, anchor.dy)
      ..lineTo(anchor.dx - scale * 0.28, torsoTop)
      ..lineTo(anchor.dx + scale * 0.28, torsoTop)
      ..lineTo(anchor.dx + scale * 0.36, anchor.dy)
      ..close();
    canvas.drawPath(torsoPath, Paint()..color = const Color(0xFF0E131F));

    final lapelPath = Path()
      ..moveTo(anchor.dx - scale * 0.24 * dirSign, torsoTop)
      ..lineTo(anchor.dx, torsoTop + scale * 0.34)
      ..lineTo(anchor.dx - scale * 0.14 * dirSign, anchor.dy)
      ..close();
    canvas.drawPath(
      lapelPath,
      Paint()..color = archetype.primaryInkColor.withValues(alpha: 0.85),
    );
    canvas.drawPath(
      torsoPath,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke,
    );

    // 3. Expressive Tilted Head & Angular Jaw
    final headCenter = Offset(
      anchor.dx + hairLag * 0.3,
      anchor.dy - scale * 1.02 + breathBob,
    );
    final headR = scale * 0.25;
    canvas.save();
    canvas.translate(headCenter.dx, headCenter.dy);
    canvas.rotate(headTilt);

    final jawRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: headR * 1.75,
        height: headR * 1.9,
      ),
      Radius.circular(headR * 0.45),
    );
    canvas.drawRRect(jawRect, Paint()..color = const Color(0xFFC68652));
    canvas.drawRRect(
      jawRect,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke,
    );

    // Hair / Fedora Crown
    final crownRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0, -headR * 0.85),
        width: headR * 2.1,
        height: headR * 0.65,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(crownRect, Paint()..color = const Color(0xFF05070B));

    // 4. Visor Shades & Glint
    final visorRect = Rect.fromCenter(
      center: Offset(headR * 0.15 * dirSign, -headR * 0.08),
      width: headR * 1.25,
      height: headR * 0.42,
    );
    canvas.drawRect(visorRect, Paint()..color = archetype.rimAccentColor);
    canvas.restore();

    // 5. Active Prop Hand Reaching Over the Velvet Rope
    final handPos = Offset(
      anchor.dx + dirSign * scale * 0.38,
      anchor.dy - scale * 0.56 + math.sin(t * 1.6) * (scale * 0.06),
    );
    canvas.drawCircle(
      handPos,
      scale * 0.09,
      Paint()..color = archetype.primaryInkColor,
    );
    canvas.drawCircle(
      handPos,
      scale * 0.09,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );

    if (flashActive) {
      final flashCenter = Offset(handPos.dx, handPos.dy - scale * 0.18);
      final r = scale * 0.55;
      final path = Path()
        ..moveTo(flashCenter.dx - r, flashCenter.dy)
        ..lineTo(flashCenter.dx - 3, flashCenter.dy - 3)
        ..lineTo(flashCenter.dx, flashCenter.dy - r)
        ..lineTo(flashCenter.dx + 3, flashCenter.dy - 3)
        ..lineTo(flashCenter.dx + r, flashCenter.dy)
        ..lineTo(flashCenter.dx + 3, flashCenter.dy + 3)
        ..lineTo(flashCenter.dx, flashCenter.dy + r)
        ..lineTo(flashCenter.dx - 3, flashCenter.dy + 3)
        ..close();
      canvas.drawPath(path, Paint()..color = const Color(0xFFF5DEB3));
    }
  }

  @override
  bool shouldRepaint(
    covariant _FirstPersonCellShadedCarpetWalkPainter oldDelegate,
  ) =>
      oldDelegate.walkProgress != walkProgress;
}

/// Paints the Director yelling "CUT!" and slamming a giant 2.5D cell-shaded
/// clapperboard directly into the first-person camera lens before cutting to black.
class _DirectorCutClapperSmashPainter extends CustomPainter {
  final double progress;

  const _DirectorCutClapperSmashPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final center = Offset(size.width * 0.5, size.height * 0.5);

    // Phase 1 (0.0 -> 0.65): Giant clapperboard rushes at lens & jaws snap shut
    // Phase 2 (0.65 -> 1.0): Hard cut to black with comic "CUT!" impact flash
    if (progress >= 0.78) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0xFF05070B),
      );
      return;
    }

    final rushT = (progress / 0.65).clamp(0.0, 1.0);
    final scale = 0.45 + rushT * 1.45;

    // Comic radial speed lines behind the clapperboard
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = const Color(0xFF07090E).withValues(alpha: 0.78 * rushT),
    );

    final speedPaint = Paint()
      ..color = const Color(0xFFF5DEB3).withValues(alpha: 0.65 * rushT)
      ..strokeWidth = 3.2;
    for (int i = 0; i < 24; i++) {
      final angle = (i / 24.0) * math.pi * 2;
      canvas.drawLine(
        Offset(center.dx + math.cos(angle) * 60, center.dy + math.sin(angle) * 60),
        Offset(
          center.dx + math.cos(angle) * size.longestSide,
          center.dy + math.sin(angle) * size.longestSide,
        ),
        speedPaint,
      );
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);

    final slateW = size.width * 0.76;
    final slateH = slateW * 0.66;
    final slateRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: slateW, height: slateH),
      const Radius.circular(16),
    );

    // Slate body
    canvas.drawRRect(slateRect, Paint()..color = const Color(0xFF07090E));
    canvas.drawRRect(
      slateRect,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke,
    );
    canvas.drawRRect(
      slateRect.deflate(3),
      Paint()
        ..color = const Color(0xFFF5DEB3)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    // Hinged top clapper stick slamming down as rushT approaches 1.0
    final jawAngle = -0.42 * (1.0 - rushT);
    canvas.save();
    canvas.translate(-slateW * 0.5, -slateH * 0.5);
    canvas.rotate(jawAngle);
    final stickRect = Rect.fromLTWH(0, -32, slateW, 32);
    canvas.drawRect(stickRect, Paint()..color = const Color(0xFFF5DEB3));
    canvas.drawRect(
      stickRect,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 4.5
        ..style = PaintingStyle.stroke,
    );
    canvas.restore();

    // Giant "CUT!" text painted on the clapperboard
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'CUT!',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 54,
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
    textPainter.paint(
      canvas,
      Offset(-textPainter.width * 0.5, -textPainter.height * 0.5),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DirectorCutClapperSmashPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
