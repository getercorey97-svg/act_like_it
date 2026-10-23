import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/auth_service.dart';

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

  /// Canonical bundled asset path for this character's official illustration.
  String get assetPath => 'assets/characters/$id.jpg';
}

/// Master registry of all 14 persistent 2.5D Cell-Shaded Avatar Archetypes,
/// matching the official character artwork, neon rim lights, outfits, and props.
const List<BoondocksAvatarArchetype> kFourteenAvatarArchetypes =
    <BoondocksAvatarArchetype>[
  BoondocksAvatarArchetype(
    id: 'the_director',
    name: 'THE AUTEUR DIRECTOR',
    roleBadge: 'LENS COMMANDER',
    catchphrase: '"CUT! Do it again, and this time mean it!"',
    redCarpetActivity:
        'Black beret & gold aviators, barking cues through a brass megaphone with striped clapperboard',
    primaryInkColor: Color(0xFFFFB300),
    rimAccentColor: Color(0xFFFFE082),
    shadowBlockColor: Color(0xFF291504),
    signatureIcon: Icons.campaign_rounded,
    silhouetteStyle: 0,
  ),
  BoondocksAvatarArchetype(
    id: 'the_paparazzi',
    name: 'FLASHBULB FREDDIE',
    roleBadge: 'RELENTLESS PAPARAZZI',
    catchphrase: '"Look left! Give me scandal, baby!"',
    redCarpetActivity:
        'Dark fedora with cyan PRESS card & VIP PRESS lanyard, firing a 4-point cyan DSLR flash flare',
    primaryInkColor: Color(0xFF00E5FF),
    rimAccentColor: Color(0xFF84FFFF),
    shadowBlockColor: Color(0xFF042229),
    signatureIcon: Icons.camera_enhance_rounded,
    silhouetteStyle: 1,
  ),
  BoondocksAvatarArchetype(
    id: 'the_mob_boss',
    name: 'DON CORLEONE JR.',
    roleBadge: 'DOOR 2 ENFORCER',
    catchphrase: '"Nobody crosses the crimson rope without clearance."',
    redCarpetActivity:
        'Sharp pinstripe suit, crimson pocket square & gold pinky ring, puffing a glowing cigar',
    primaryInkColor: Color(0xFFFF1744),
    rimAccentColor: Color(0xFFFF8A80),
    shadowBlockColor: Color(0xFF2B0610),
    signatureIcon: Icons.smoking_rooms_rounded,
    silhouetteStyle: 2,
  ),
  BoondocksAvatarArchetype(
    id: 'the_method_actor',
    name: 'JULIAN VANE',
    roleBadge: 'METHOD CHAMELEON',
    catchphrase: '"I stayed in character for six months just for this lobby."',
    redCarpetActivity:
        'High-collared plum trench coat & tousled hair, holding twin golden Comedy & Tragedy masks',
    primaryInkColor: Color(0xFFAA00FF),
    rimAccentColor: Color(0xFFE040FB),
    shadowBlockColor: Color(0xFF1E0B30),
    signatureIcon: Icons.theater_comedy_rounded,
    silhouetteStyle: 3,
  ),
  BoondocksAvatarArchetype(
    id: 'the_diva',
    name: 'VALENTINA LUX',
    roleBadge: 'PRIMA DONNA DIVA',
    catchphrase: '"My close-up requires 24-karat lighting, darling."',
    redCarpetActivity:
        'Pink fur stole over silver sequined gown & diamond earrings, lowering cat-eye sunglasses',
    primaryInkColor: Color(0xFFF50057),
    rimAccentColor: Color(0xFFFF80AB),
    shadowBlockColor: Color(0xFF2E081E),
    signatureIcon: Icons.diamond_rounded,
    silhouetteStyle: 4,
  ),
  BoondocksAvatarArchetype(
    id: 'the_stunt_double',
    name: 'BLAZE MERCER',
    roleBadge: 'HIGH-WIRE STUNT PRO',
    catchphrase: '"One take, zero safety net, full send."',
    redCarpetActivity:
        'Orange/black armored moto jacket & visor goggles, giving a thumbs-up with a burning road flare',
    primaryInkColor: Color(0xFFFF6D00),
    rimAccentColor: Color(0xFFFFAB40),
    shadowBlockColor: Color(0xFF2B1104),
    signatureIcon: Icons.local_fire_department_rounded,
    silhouetteStyle: 5,
  ),
  BoondocksAvatarArchetype(
    id: 'the_indie_auteur',
    name: 'SUNDANCE SAGE',
    roleBadge: 'INDIE CINEMATOGRAPHER',
    catchphrase: '"It’s not a monologue, it’s a post-modern metaphor."',
    redCarpetActivity:
        'Charcoal beanie, locs & green wireframe glasses, framing a director’s L-square with both hands',
    primaryInkColor: Color(0xFF00E676),
    rimAccentColor: Color(0xFF69F0AE),
    shadowBlockColor: Color(0xFF042419),
    signatureIcon: Icons.movie_filter_rounded,
    silhouetteStyle: 6,
  ),
  BoondocksAvatarArchetype(
    id: 'the_nepo_baby',
    name: 'PRESTON STERLING III',
    roleBadge: 'THE STUDIO HEIR',
    catchphrase: '"My uncle owns Soundstage 4, let’s roll!"',
    redCarpetActivity:
        'Black-and-gold varsity jacket & Cuban chain, flashing a holographic ALL-ACCESS VIP pass',
    primaryInkColor: Color(0xFFFFD600),
    rimAccentColor: Color(0xFFFFFF8D),
    shadowBlockColor: Color(0xFF261C04),
    signatureIcon: Icons.verified_rounded,
    silhouetteStyle: 7,
  ),
  BoondocksAvatarArchetype(
    id: 'the_showrunner',
    name: 'SLOANE VANCE',
    roleBadge: 'STAGE MANAGER / SHOWRUNNER',
    catchphrase: '"We’re rewriting the third act live on air!"',
    redCarpetActivity:
        'Royal blue blazer & studio headset mic, checking wristwatch over a cyan holographic schedule tablet',
    primaryInkColor: Color(0xFF00B0FF),
    rimAccentColor: Color(0xFF80D8FF),
    shadowBlockColor: Color(0xFF07162E),
    signatureIcon: Icons.headset_mic_rounded,
    silhouetteStyle: 8,
  ),
  BoondocksAvatarArchetype(
    id: 'the_scream_queen',
    name: 'RAVENNA GRAVES',
    roleBadge: 'GOTHIC SCREAM QUEEN',
    catchphrase: '"Don’t look behind the soundstage curtain..."',
    redCarpetActivity:
        'Black Victorian lace gown & cameo choker, holding a silver candlestick with a glowing purple flame',
    primaryInkColor: Color(0xFFD500F9),
    rimAccentColor: Color(0xFFEA80FC),
    shadowBlockColor: Color(0xFF170B2E),
    signatureIcon: Icons.bolt_rounded,
    silhouetteStyle: 9,
  ),
  BoondocksAvatarArchetype(
    id: 'the_action_hero',
    name: 'REX TITAN',
    roleBadge: 'BLOCKBUSTER JUGGERNAUT',
    catchphrase: '"Explosions first, dialogue second."',
    redCarpetActivity:
        'Tactical premiere vest & mirrored shades, flexing while pyrotechnic sparks rain down',
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
    redCarpetActivity:
        'Teal velvet dinner jacket & satin bow tie, holding a vintage gold ribbon mic and blue cue cards',
    primaryInkColor: Color(0xFF14B8A6),
    rimAccentColor: Color(0xFF5EEAD4),
    shadowBlockColor: Color(0xFF04221F),
    signatureIcon: Icons.mic_external_on_rounded,
    silhouetteStyle: 11,
  ),
  BoondocksAvatarArchetype(
    id: 'the_critic',
    name: 'THE VETERAN FILM CRITIC',
    roleBadge: 'FRONT-ROW ARBITER',
    catchphrase: '"Astonishing audacity. Five golden statuettes!"',
    redCarpetActivity:
        'Maroon tweed blazer & gold silk cravat, writing with a gold fountain pen in a 5-STAR REVIEW book',
    primaryInkColor: Color(0xFFFFB300),
    rimAccentColor: Color(0xFFFFE082),
    shadowBlockColor: Color(0xFF241605),
    signatureIcon: Icons.rate_review_rounded,
    silhouetteStyle: 12,
  ),
  BoondocksAvatarArchetype(
    id: 'the_scene_stealer',
    name: 'THE ELECTRIC STAR',
    roleBadge: 'WILD-CARD IMPROVISER',
    catchphrase: '"Script? Where we’re going, we don’t need scripts!"',
    redCarpetActivity:
        'Exploding blue lightning Afro, star visor shades & iridescent jacket, flashing an electric peace sign',
    primaryInkColor: Color(0xFF00E5FF),
    rimAccentColor: Color(0xFF84FFFF),
    shadowBlockColor: Color(0xFF051E26),
    signatureIcon: Icons.auto_awesome_rounded,
    silhouetteStyle: 13,
  ),
];

/// Resolves any archetype ID, display name, or alias to its `BoondocksAvatarArchetype`.
BoondocksAvatarArchetype resolveAvatarArchetype(String? id) {
  if (id == null || id.trim().isEmpty) {
    return kFourteenAvatarArchetypes[3]; // Default: Julian Vane
  }
  final normalized = id.trim().toLowerCase();
  for (final arch in kFourteenAvatarArchetypes) {
    if (arch.id.toLowerCase() == normalized ||
        arch.name.toLowerCase() == normalized) {
      return arch;
    }
  }
  if (normalized.contains('paparazz') ||
      normalized.contains('freddie') ||
      normalized.contains('finn')) {
    return kFourteenAvatarArchetypes[1];
  }
  if (normalized.contains('director') || normalized.contains('auteur')) {
    return kFourteenAvatarArchetypes[0];
  }
  if (normalized.contains('mob') || normalized.contains('corleone')) {
    return kFourteenAvatarArchetypes[2];
  }
  if (normalized.contains('method') || normalized.contains('julian')) {
    return kFourteenAvatarArchetypes[3];
  }
  if (normalized.contains('diva') || normalized.contains('valentina')) {
    return kFourteenAvatarArchetypes[4];
  }
  if (normalized.contains('stunt') ||
      normalized.contains('blaze') ||
      normalized.contains('nitro')) {
    return kFourteenAvatarArchetypes[5];
  }
  if (normalized.contains('sundance') || normalized.contains('indie')) {
    return kFourteenAvatarArchetypes[6];
  }
  if (normalized.contains('preston') ||
      normalized.contains('nepo') ||
      normalized.contains('heir')) {
    return kFourteenAvatarArchetypes[7];
  }
  if (normalized.contains('sloane') ||
      normalized.contains('monica') ||
      normalized.contains('showrunner')) {
    return kFourteenAvatarArchetypes[8];
  }
  if (normalized.contains('raven') || normalized.contains('scream')) {
    return kFourteenAvatarArchetypes[9];
  }
  if (normalized.contains('rex') || normalized.contains('action')) {
    return kFourteenAvatarArchetypes[10];
  }
  if (normalized.contains('devon') || normalized.contains('host')) {
    return kFourteenAvatarArchetypes[11];
  }
  if (normalized.contains('critic') || normalized.contains('arthur')) {
    return kFourteenAvatarArchetypes[12];
  }
  if (normalized.contains('electric') ||
      normalized.contains('ziggy') ||
      normalized.contains('stealer')) {
    return kFourteenAvatarArchetypes[13];
  }
  return kFourteenAvatarArchetypes[3];
}

/// 60FPS "2.5D LIVING PORTRAIT & PROP ANIMATOR" (`BoondocksCharacterRig`).
/// Animates each character using a multi-layered 2.5D rig:
/// - Layer 1 (2.5D Breathing & Parallax Body): `math.sin(t * 2.4)` breathing bob,
///   head counter-tilt, dynamic `Matrix4` 3D perspective shift, loading
///   `assets/characters/<id>.jpg` with an automatic 2.5D custom-painted fallback.
/// - Layer 2 (Pulsing Neon Rim-Light Aura): Outer contour glow matching each
///   character's exact signature neon rim color.
/// - Layer 3 (Live Facial & Eyewear Animation): Periodic 140ms natural eye blink
///   every 3.2 seconds and a sharp diagonal white specular light sweep across glasses/eyes.
/// - Layer 4 (Character-Specific Animated Prop FX Overlay): Arcing lightning sparks
///   for The Electric Star, fountain pen writing & gold ink shimmer for The Veteran
///   Film Critic, 4-point cyan DSLR flare for Flashbulb Freddie, rising cigar smoke
///   for Don Corleone Jr., burning flare sparks for Blaze Mercer, holographic VIP pass
///   foil for Preston Sterling III, purple candle flame for Ravenna Graves, and more.
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

  Widget _buildLivingRigAtPhase(double phaseSec) {
    final seed = widget.archetype.silhouetteStyle * 0.65;
    final breathCycle = math.sin(phaseSec * 2.4 + seed);
    final swayCycle = math.cos(phaseSec * 1.7 + seed);
    final breathBobY = breathCycle * (widget.size * 0.022);
    final tiltX = breathCycle * 0.055;
    final tiltY = swayCycle * 0.075;
    final scalePulse = 1.0 + breathCycle * 0.018;

    final borderRadius = BorderRadius.circular(widget.size * 0.22);
    final rimPulse = 0.55 + 0.45 * math.sin(phaseSec * 3.2 + seed);

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0018)
      ..rotateX(tiltX)
      ..rotateY(tiltY)
      ..scale(scalePulse);

    return Transform(
      alignment: Alignment.center,
      transform: matrix,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: const Color(0xFF07090E),
          borderRadius: borderRadius,
          boxShadow: <BoxShadow>[
            const BoxShadow(
              color: Color(0xFF05070B),
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
            BoxShadow(
              color: widget.archetype.primaryInkColor.withValues(
                alpha: (widget.isSelected ? 0.52 : 0.28) * rimPulse,
              ),
              blurRadius: widget.isSelected ? 16 : 9,
              spreadRadius: widget.isSelected ? 1.5 : 0.5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // LAYER 1: 2.5D Breathing & Parallax Portrait (`assets/characters/<id>.jpg`
              // with automatic custom-painted 2.5D fallback so it never shows a broken icon)
              Transform.translate(
                offset: Offset(swayCycle * (widget.size * 0.012), breathBobY),
                child: Transform.scale(
                  scale: 1.06 + (breathCycle * 0.015),
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    widget.archetype.assetPath,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (context, error, stackTrace) {
                      return CustomPaint(
                        painter: _BoondocksCellShadedPortraitPainter(
                          archetype: widget.archetype,
                          isSelected: widget.isSelected,
                          phase: phaseSec,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // LAYER 2, 3 & 4: Pulsing Neon Rim-Light Aura + Live Eyewear Glint/Blink
              // + Character-Specific Animated Prop FX Overlay
              IgnorePointer(
                child: CustomPaint(
                  painter: _BoondocksAnimatedPropFxOverlayPainter(
                    archetype: widget.archetype,
                    isSelected: widget.isSelected,
                    phase: phaseSec,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = _rigController != null
        ? AnimatedBuilder(
            animation: _rigController!,
            builder: (context, _) {
              final elapsedSec = _rigController!.value * 6.4;
              return _buildLivingRigAtPhase(elapsedSec);
            },
          )
        : _buildLivingRigAtPhase(widget.externalPhase ?? 0.0);

    final rigBox = Opacity(
      opacity: widget.isMirroredReflection ? 0.54 : 1.0,
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
/// articulated puppet portrait of any of the 14 Avatar Archetypes.
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

/// Opens a full-card Spotlight Bio & Live 60fps 2.5D Living Portrait Preview Modal
/// when a player taps any character rig on the Red Carpet or beside a Soundstage Door.
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
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: archetype.primaryInkColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '2.5D LIVING PORTRAIT · ${archetype.roleBadge}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF05070B),
                          ),
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
                      size: 118,
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
                              fontSize: 28,
                              letterSpacing: 1.5,
                              color: const Color(0xFFF5DEB3),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            archetype.catchphrase,
                            style: const TextStyle(
                              fontSize: 12.5,
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
                                color: archetype.primaryInkColor
                                    .withValues(alpha: 0.45),
                              ),
                            ),
                            child: Text(
                              archetype.redCarpetActivity,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10.5,
                                color: archetype.rimAccentColor,
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
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      isAlreadyEquipped
                          ? 'CURRENTLY EQUIPPED ON STAGE PASS'
                          : 'EQUIP AS MY AVATAR · ${archetype.name.toUpperCase()}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
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

/// LAYER 2, 3 & 4 OVERLAY PAINTER:
/// Renders the Pulsing Neon Rim-Light Aura, Periodic Eye Blink & Diagonal Eyewear
/// Specular Sweep, and Character-Specific Animated Prop FX directly over each portrait.
class _BoondocksAnimatedPropFxOverlayPainter extends CustomPainter {
  final BoondocksAvatarArchetype archetype;
  final bool isSelected;
  final double phase;

  const _BoondocksAnimatedPropFxOverlayPainter({
    required this.archetype,
    required this.isSelected,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final w = size.width;
    final h = size.height;
    final t = phase;
    final seed = archetype.silhouetteStyle * 0.65;

    // -------------------------------------------------------------------------
    // LAYER 2: Pulsing Neon Rim-Light Aura & Top/Side Contour Glow
    // -------------------------------------------------------------------------
    final rimPulse = 0.55 + 0.45 * math.sin(t * 3.0 + seed);
    final rimShader = RadialGradient(
      center: const Alignment(0.0, -0.25),
      radius: 0.92,
      colors: <Color>[
        Colors.transparent,
        archetype.primaryInkColor.withValues(alpha: 0.08 * rimPulse),
        archetype.rimAccentColor.withValues(
          alpha: (isSelected ? 0.34 : 0.20) * rimPulse,
        ),
      ],
      stops: const <double>[0.55, 0.82, 1.0],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..shader = rimShader);

    // -------------------------------------------------------------------------
    // LAYER 3: Periodic 140ms Eye Blink & Diagonal White Specular Eyewear Sweep
    // -------------------------------------------------------------------------
    final cycleSec = (t + (archetype.silhouetteStyle * 0.23)) % 3.2;
    final isBlinking = cycleSec >= 2.95 && cycleSec <= 3.09;
    final eyeZoneY = h * 0.31;

    if (isBlinking) {
      final blinkPaint = Paint()
        ..color = const Color(0xFF07090E).withValues(alpha: 0.85)
        ..strokeWidth = (h * 0.026).clamp(1.5, 4.0)
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(w * 0.36, eyeZoneY),
        Offset(w * 0.46, eyeZoneY),
        blinkPaint,
      );
      canvas.drawLine(
        Offset(w * 0.54, eyeZoneY),
        Offset(w * 0.64, eyeZoneY),
        blinkPaint,
      );
    } else {
      // Diagonal white specular sweep across glasses/eyes
      final sweepCycle = ((t * 0.65 + seed) % 2.2);
      if (sweepCycle <= 1.0) {
        final sweepX = w * (0.28 + sweepCycle * 0.44);
        final glintPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.68 * (1.0 - (sweepCycle - 0.5).abs() * 1.8).clamp(0.0, 1.0))
          ..strokeWidth = (w * 0.028).clamp(1.4, 3.5)
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(sweepX - w * 0.04, eyeZoneY - h * 0.045),
          Offset(sweepX - w * 0.08, eyeZoneY + h * 0.045),
          glintPaint,
        );
      }
    }

    // -------------------------------------------------------------------------
    // LAYER 4: Character-Specific Animated Prop FX Overlay
    // -------------------------------------------------------------------------
    switch (archetype.id) {
      case 'the_scene_stealer': // THE ELECTRIC STAR: Lightning arcs in Afro & peace sign
        _paintElectricStarLightning(canvas, size, t);
        break;
      case 'the_critic': // THE VETERAN FILM CRITIC: Fountain pen writing & gold ink shimmer
        _paintCriticFountainPenShimmer(canvas, size, t);
        break;
      case 'the_paparazzi': // FLASHBULB FREDDIE: Blazing 4-point cyan DSLR flash flare
        _paintPaparazziFlashFlare(canvas, size, t);
        break;
      case 'the_director': // THE AUTEUR DIRECTOR: Brass megaphone soundwaves & clapper glint
        _paintDirectorMegaphoneWaves(canvas, size, t);
        break;
      case 'the_mob_boss': // DON CORLEONE JR.: Glowing orange cigar ember & rising smoke
        _paintMobBossCigarSmoke(canvas, size, t);
        break;
      case 'the_stunt_double': // BLAZE MERCER: Burning road flare flame, smoke & sparks
        _paintStuntRoadFlareSparks(canvas, size, t);
        break;
      case 'the_diva': // VALENTINA LUX: Diamond chandelier & sequin sparkles
        _paintDivaDiamondSparkles(canvas, size, t);
        break;
      case 'the_nepo_baby': // PRESTON STERLING III: Holographic VIP pass rainbow sweep
        _paintStudioHeirVipHoloFoil(canvas, size, t);
        break;
      case 'the_indie_auteur': // SUNDANCE SAGE: Emerald L-square viewfinder reticle
        _paintIndieViewfinderReticle(canvas, size, t);
        break;
      case 'the_showrunner': // SLOANE VANCE: Cyber blue holographic tablet scanlines
        _paintShowrunnerHoloTablet(canvas, size, t);
        break;
      case 'the_scream_queen': // RAVENNA GRAVES: Flickering gothic purple candle flame
        _paintScreamQueenPurpleCandle(canvas, size, t);
        break;
      case 'the_method_actor': // JULIAN VANE: Twin golden theater masks gleam
        _paintMethodActorMaskShimmer(canvas, size, t);
        break;
      default:
        _paintAmbientRimParticles(canvas, size, t);
        break;
    }

    // Crisp Outer Comic Panel Border + Signature Neon Rim Border
    final frameRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.shortestSide * 0.22),
    );
    canvas.drawRRect(
      frameRect,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 3.6
        ..style = PaintingStyle.stroke,
    );
    canvas.drawRRect(
      frameRect.deflate(1.6),
      Paint()
        ..color = (isSelected ? archetype.rimAccentColor : archetype.primaryInkColor)
            .withValues(alpha: 0.72 + 0.28 * rimPulse)
        ..strokeWidth = isSelected ? 2.4 : 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  void _paintElectricStarLightning(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;
    final arcPaint = Paint()
      ..color = const Color(0xFF84FFFF).withValues(alpha: 0.88)
      ..strokeWidth = (w * 0.022).clamp(1.2, 2.8)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Flickering electric arcs across the blue Afro hair & peace-sign fingers
    final anchors = <Offset>[
      Offset(w * 0.22, h * 0.56), // Peace sign fingers
      Offset(w * 0.28, h * 0.18), // Left Afro lightning
      Offset(w * 0.74, h * 0.20), // Right Afro lightning
    ];
    for (int i = 0; i < anchors.length; i++) {
      if (((t * 7.5 + i * 1.7).floor()).isEven) {
        final a = anchors[i];
        final jitter = math.sin(t * 14.0 + i) * (w * 0.04);
        final path = Path()
          ..moveTo(a.dx - w * 0.06, a.dy - h * 0.04)
          ..lineTo(a.dx + jitter, a.dy)
          ..lineTo(a.dx - jitter * 0.6, a.dy + h * 0.03)
          ..lineTo(a.dx + w * 0.05, a.dy + h * 0.07);
        canvas.drawPath(path, arcPaint);
      }
    }
  }

  void _paintCriticFountainPenShimmer(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;
    // Animated gold fountain pen nib writing across the "5-STAR REVIEW" book
    final writeX = w * 0.36 + math.sin(t * 5.2) * (w * 0.05);
    final writeY = h * 0.78 + math.cos(t * 10.4) * (h * 0.015);
    final nibGlow = Paint()
      ..color = const Color(0xFFFFD600).withValues(alpha: 0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(writeX, writeY), w * 0.035, nibGlow);
    canvas.drawCircle(
      Offset(writeX, writeY),
      w * 0.016,
      Paint()..color = Colors.white,
    );
  }

  void _paintPaparazziFlashFlare(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;
    final flareCenter = Offset(w * 0.73, h * 0.54);
    final pulse = 0.55 + 0.45 * math.sin(t * 6.0);
    final flareR = w * (0.14 + 0.10 * pulse);

    canvas.drawCircle(
      flareCenter,
      flareR * 0.55,
      Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.55 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    final starPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.92 * pulse)
      ..strokeWidth = (w * 0.024).clamp(1.2, 3.0)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(flareCenter.dx - flareR, flareCenter.dy - flareR * 0.6),
      Offset(flareCenter.dx + flareR, flareCenter.dy + flareR * 0.6),
      starPaint,
    );
    canvas.drawLine(
      Offset(flareCenter.dx + flareR * 0.8, flareCenter.dy - flareR),
      Offset(flareCenter.dx - flareR * 0.8, flareCenter.dy + flareR),
      starPaint,
    );
  }

  void _paintDirectorMegaphoneWaves(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;
    final mouthOrigin = Offset(w * 0.16, h * 0.24);
    for (int i = 0; i < 2; i++) {
      final waveT = ((t * 1.4 + i * 0.5) % 1.0);
      final r = w * (0.08 + waveT * 0.18);
      final paint = Paint()
        ..color = const Color(0xFFFFD600).withValues(alpha: (1.0 - waveT) * 0.75)
        ..strokeWidth = (w * 0.02).clamp(1.2, 2.5)
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCircle(center: mouthOrigin, radius: r),
        -math.pi * 0.85,
        math.pi * 0.65,
        false,
        paint,
      );
    }
  }

  void _paintMobBossCigarSmoke(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;
    final ashCenter = Offset(w * 0.19, h * 0.59);
    final emberPulse = 0.6 + 0.4 * math.sin(t * 4.5);

    // Glowing cigar ash ember
    canvas.drawCircle(
      ashCenter,
      w * 0.038,
      Paint()
        ..color = const Color(0xFFFF3D00).withValues(alpha: 0.75 * emberPulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Rising bezier smoke puffs
    for (int i = 0; i < 3; i++) {
      final puffT = ((t * 0.55 + i * 0.33) % 1.0);
      final py = ashCenter.dy - puffT * (h * 0.34);
      final px = ashCenter.dx + math.sin(puffT * math.pi * 2 + t) * (w * 0.045);
      canvas.drawCircle(
        Offset(px, py),
        w * (0.022 + puffT * 0.035),
        Paint()
          ..color = Colors.white.withValues(alpha: (1.0 - puffT) * 0.34),
      );
    }
  }

  void _paintStuntRoadFlareSparks(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;
    final flareTip = Offset(w * 0.76, h * 0.52);
    final flicker = 0.65 + 0.35 * math.sin(t * 9.0);

    canvas.drawCircle(
      flareTip,
      w * 0.08 * flicker,
      Paint()
        ..color = const Color(0xFFFF6D00).withValues(alpha: 0.65)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    for (int i = 0; i < 4; i++) {
      final sparkT = ((t * 1.8 + i * 0.25) % 1.0);
      final angle = -math.pi * 0.35 + (i - 1.5) * 0.32;
      final dist = w * (0.04 + sparkT * 0.22);
      final sx = flareTip.dx + math.cos(angle) * dist;
      final sy = flareTip.dy + math.sin(angle) * dist;
      canvas.drawCircle(
        Offset(sx, sy),
        w * 0.014,
        Paint()
          ..color = const Color(0xFFFFEA00).withValues(alpha: 1.0 - sparkT),
      );
    }
  }

  void _paintDivaDiamondSparkles(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;
    final pts = <Offset>[
      Offset(w * 0.63, h * 0.36), // Chandelier earring
      Offset(w * 0.45, h * 0.62), // Sequined gown
      Offset(w * 0.32, h * 0.80), // Diamond clutch
    ];
    for (int i = 0; i < pts.length; i++) {
      final twinkle = (math.sin(t * 5.0 + i * 2.1) + 1.0) * 0.5;
      if (twinkle > 0.35) {
        final c = pts[i];
        final r = w * 0.045 * twinkle;
        final p = Paint()
          ..color = Colors.white.withValues(alpha: 0.9 * twinkle)
          ..strokeWidth = 1.5;
        canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), p);
        canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), p);
      }
    }
  }

  void _paintStudioHeirVipHoloFoil(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.54, h * 0.78),
        width: w * 0.34,
        height: h * 0.26,
      ),
      Radius.circular(w * 0.03),
    );
    final sweep = (math.sin(t * 2.8) + 1.0) * 0.5;
    final holoShader = LinearGradient(
      begin: Alignment(-1.0 + sweep * 2.0, -1.0),
      end: Alignment(-0.2 + sweep * 2.0, 1.0),
      colors: <Color>[
        Colors.transparent,
        const Color(0xFF00E5FF).withValues(alpha: 0.38),
        const Color(0xFFFFD600).withValues(alpha: 0.42),
        Colors.transparent,
      ],
    ).createShader(cardRect.outerRect);
    canvas.drawRRect(cardRect, Paint()..shader = holoShader);
  }

  void _paintIndieViewfinderReticle(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;
    final pulse = 0.55 + 0.45 * math.sin(t * 3.5);
    final reticlePaint = Paint()
      ..color = const Color(0xFF00E676).withValues(alpha: 0.75 * pulse)
      ..strokeWidth = (w * 0.022).clamp(1.2, 2.6)
      ..style = PaintingStyle.stroke;

    // L-square framing corners between hands
    final leftTop = Offset(w * 0.24, h * 0.48);
    final rightBot = Offset(w * 0.66, h * 0.78);
    final len = w * 0.09;
    canvas.drawPath(
      Path()
        ..moveTo(leftTop.dx, leftTop.dy + len)
        ..lineTo(leftTop.dx, leftTop.dy)
        ..lineTo(leftTop.dx + len, leftTop.dy),
      reticlePaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rightBot.dx - len, rightBot.dy)
        ..lineTo(rightBot.dx, rightBot.dy)
        ..lineTo(rightBot.dx, rightBot.dy - len),
      reticlePaint,
    );
  }

  void _paintShowrunnerHoloTablet(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;
    final scanY = h * (0.66 + ((t * 0.45) % 1.0) * 0.16);
    final scanPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.75)
      ..strokeWidth = 1.8;
    canvas.drawLine(
      Offset(w * 0.54, scanY),
      Offset(w * 0.88, scanY - h * 0.03),
      scanPaint,
    );
  }

  void _paintScreamQueenPurpleCandle(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;
    final flamePos = Offset(w * 0.80, h * 0.44 + math.sin(t * 8.0) * (h * 0.01));
    final flicker = 0.7 + 0.3 * math.sin(t * 10.0);
    canvas.drawCircle(
      flamePos,
      w * 0.075 * flicker,
      Paint()
        ..color = const Color(0xFFD500F9).withValues(alpha: 0.62)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
      flamePos,
      w * 0.025,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  void _paintMethodActorMaskShimmer(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;
    final maskPos = Offset(w * 0.52 + math.sin(t * 2.5) * (w * 0.12), h * 0.62);
    canvas.drawCircle(
      maskPos,
      w * 0.06,
      Paint()
        ..color = const Color(0xFFFFD600).withValues(alpha: 0.42)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  void _paintAmbientRimParticles(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;
    for (int i = 0; i < 3; i++) {
      final pT = ((t * 0.4 + i * 0.33) % 1.0);
      final px = w * (0.25 + i * 0.25);
      final py = h * (0.85 - pT * 0.65);
      canvas.drawCircle(
        Offset(px, py),
        w * 0.016,
        Paint()
          ..color = archetype.rimAccentColor.withValues(alpha: (1.0 - pT) * 0.65),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BoondocksAnimatedPropFxOverlayPainter oldDelegate) {
    return oldDelegate.archetype.id != archetype.id ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.phase != phase;
  }
}

/// Automatic 2.5D custom-painted fallback portrait if `assets/characters/<id>.jpg`
/// is not yet bundled in the runtime asset bundle.
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

    final breathBob = math.sin(t * 2.4 + seed) * (radius * 0.045);
    final chestExpand = 1.0 + math.sin(t * 2.4 + seed) * 0.032;
    final headTiltAngle = math.sin(t * 1.8 + seed) * 0.065;

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
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Shoulders & Lapels
    final shoulderTopY = center.dy + radius * 0.25 + breathBob;
    final halfShoulderW = radius * 0.54 * chestExpand;
    final shoulderPath = Path()
      ..moveTo(center.dx - radius * 0.80 * chestExpand, size.height)
      ..lineTo(center.dx - halfShoulderW, shoulderTopY)
      ..lineTo(center.dx + halfShoulderW, shoulderTopY)
      ..lineTo(center.dx + radius * 0.80 * chestExpand, size.height)
      ..close();
    canvas.drawPath(shoulderPath, Paint()..color = const Color(0xFF111622));

    // Head & Jaw
    final headCenter = Offset(center.dx, center.dy - radius * 0.08 + breathBob * 0.85);
    final headW = radius * 0.72;
    final headH = radius * 0.80;

    canvas.save();
    canvas.translate(headCenter.dx, headCenter.dy);
    canvas.rotate(headTiltAngle);
    canvas.translate(-headCenter.dx, -headCenter.dy);

    final jawRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: headCenter, width: headW, height: headH),
      Radius.circular(headW * 0.32),
    );
    canvas.drawRRect(jawRect, Paint()..color = const Color(0xFFC68652));
    canvas.drawRRect(
      jawRect,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 2.8
        ..style = PaintingStyle.stroke,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BoondocksCellShadedPortraitPainter oldDelegate) {
    return oldDelegate.archetype.id != archetype.id ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.phase != phase;
  }
}
