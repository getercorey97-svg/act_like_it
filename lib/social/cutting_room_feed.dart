import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_service.dart';
import '../main.dart';
import '../offline_manager.dart';
import '../ui/game_app_bar.dart';
import '../ui/intro_cinematic.dart';

/// Immutable model representing an audition take in "The Cutting Room Floor"
/// vertical social feed.
class CuttingRoomAuditionTake {
  final String id;
  final String actorHandle;
  final String avatarArchetypeId;
  final String sceneTitle;
  final String filmOrSeries;
  final int releaseYear;
  final String scriptExcerpt;
  final String directorCommentStamp;
  final double aiTelemetricsScore;
  final double averageStarRating;
  final int totalRatingsCount;
  final int shareCount;
  final Color neonAccent;

  const CuttingRoomAuditionTake({
    required this.id,
    required this.actorHandle,
    required this.avatarArchetypeId,
    required this.sceneTitle,
    required this.filmOrSeries,
    required this.releaseYear,
    required this.scriptExcerpt,
    required this.directorCommentStamp,
    required this.aiTelemetricsScore,
    required this.averageStarRating,
    required this.totalRatingsCount,
    required this.shareCount,
    required this.neonAccent,
  });
}

const List<CuttingRoomAuditionTake> kDefaultCuttingRoomTakes =
    <CuttingRoomAuditionTake>[
  CuttingRoomAuditionTake(
    id: 'crf_take_01',
    actorHandle: '@METHOD_MAVERICK',
    avatarArchetypeId: 'the_method_actor',
    sceneTitle: 'THE ROOFTOP CONFESSION',
    filmOrSeries: 'NEON RAIN OVER MULHOLLAND',
    releaseYear: 1994,
    scriptExcerpt:
        '"You think the spotlight saves you? Out here on the ledge, the camera never blinks!"',
    directorCommentStamp: 'CERTIFIED RAW CONVICTION · ONE-TAKE WONDER',
    aiTelemetricsScore: 96.4,
    averageStarRating: 4.9,
    totalRatingsCount: 418,
    shareCount: 142,
    neonAccent: Color(0xFFA855F7),
  ),
  CuttingRoomAuditionTake(
    id: 'crf_take_02',
    actorHandle: '@VALENTINA_LUX',
    avatarArchetypeId: 'the_diva',
    sceneTitle: 'THE PENTHOUSE ULTIMATUM',
    filmOrSeries: 'CROWN OF GLASS',
    releaseYear: 2021,
    scriptExcerpt:
        '"I didn’t buy the studio to audition for you, darling. I bought it to fire the director."',
    directorCommentStamp: 'RAZOR-SHARP TIMING · SCENE STEALER',
    aiTelemetricsScore: 94.8,
    averageStarRating: 4.8,
    totalRatingsCount: 389,
    shareCount: 198,
    neonAccent: Color(0xFFEC4899),
  ),
  CuttingRoomAuditionTake(
    id: 'crf_take_03',
    actorHandle: '@DON_CORLEONE_JR',
    avatarArchetypeId: 'the_mob_boss',
    sceneTitle: 'VELVET ROPE SHAKEDOWN',
    filmOrSeries: 'MIDNIGHT SPEAKEASY',
    releaseYear: 1978,
    scriptExcerpt:
        '"Look me in the eye and tell me who leaked the call sheet before the cigar ash hits the floor."',
    directorCommentStamp: 'CHILLING CADENCE · STANDING OVATION',
    aiTelemetricsScore: 93.2,
    averageStarRating: 4.7,
    totalRatingsCount: 312,
    shareCount: 115,
    neonAccent: Color(0xFFE11D48),
  ),
  CuttingRoomAuditionTake(
    id: 'crf_take_04',
    actorHandle: '@FLASHBULB_FINN',
    avatarArchetypeId: 'the_paparazzi',
    sceneTitle: 'COURTROOM MELTDOWN (+5.0 TWIST)',
    filmOrSeries: 'THE VERDICT ON SUNSET',
    releaseYear: 2016,
    scriptExcerpt:
        '"Objection? I’ve got forty-two high-speed negatives that say your alibi is pure fiction!"',
    directorCommentStamp: 'IMPROV CURVEBALL NAILED · ELECTRIC PACE',
    aiTelemetricsScore: 95.1,
    averageStarRating: 4.9,
    totalRatingsCount: 520,
    shareCount: 264,
    neonAccent: Color(0xFF06B6D4),
  ),
];

/// MODULE 2: "The Cutting Room Floor" (`lib/social/cutting_room_feed.dart`).
/// Reached via the First-Person Silver Elevator transition on the Red Carpet.
/// Features:
/// - Vertical full-screen scrolling feed (`PageView.builder`) in 2.5D cell-shaded style
/// - 5-to-1 Golden Star Rating Box with optimistic local + additive Supabase sync
/// - Angled Director's Comment Stamp overlay on the performance frame
/// - Native Viral Share Trigger (`Share.share`)
class CuttingRoomFeedScreen extends StatefulWidget {
  const CuttingRoomFeedScreen({super.key});

  @override
  State<CuttingRoomFeedScreen> createState() => _CuttingRoomFeedScreenState();
}

class _CuttingRoomFeedScreenState extends State<CuttingRoomFeedScreen>
    with SingleTickerProviderStateMixin {
  static const String _kRatingsPrefsKey = 'act_like_it_cutting_room_ratings_v1';

  late final PageController _verticalPageController;
  late final AnimationController _reelLoopController;

  final List<CuttingRoomAuditionTake> _takes =
      List<CuttingRoomAuditionTake>.from(kDefaultCuttingRoomTakes);
  final Map<String, int> _userStarRatings = <String, int>{};
  final Map<String, String> _customDirectorStamps = <String, String>{};
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _verticalPageController = PageController();
    _reelLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _hydrateTakesAndSavedRatings();
  }

  Future<void> _hydrateTakesAndSavedRatings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kRatingsPrefsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          decoded.forEach((k, v) {
            final stars = int.tryParse('$v');
            if (stars != null && stars >= 1 && stars <= 5) {
              _userStarRatings[k.toString()] = stars;
            }
          });
        }
      }
    } catch (_) {}

    // Prepend any local Career Trophy Room takes so the player's own rounds
    // also appear on The Cutting Room Floor!
    final localHistory = OfflineManager.instance.matchHistoryLog;
    final profile = AuthService.instance.currentProfile;
    if (localHistory.isNotEmpty) {
      final rec = localHistory.first;
      final playerTake = CuttingRoomAuditionTake(
        id: 'crf_local_${rec.id}',
        actorHandle:
            '@${(profile?.username ?? "GALAXY_S26_ACTOR").toUpperCase()}',
        avatarArchetypeId: profile?.avatarArchetypeId ?? 'the_method_actor',
        sceneTitle: rec.sceneTitle.toUpperCase(),
        filmOrSeries: rec.filmOrSeries.toUpperCase(),
        releaseYear: 2025,
        scriptExcerpt:
            '"Live soundstage take recorded on Galaxy S26 Ultra — Composite Verdict ${rec.finalScore.toStringAsFixed(1)}/100!"',
        directorCommentStamp: rec.isWin
            ? 'STANDING OVATION · CERTIFIED TROPHY WIN'
            : 'OFFICIAL STUDIO SCREEN TEST',
        aiTelemetricsScore: rec.aiScore,
        averageStarRating: 5.0,
        totalRatingsCount: 24,
        shareCount: 9,
        neonAccent: const Color(0xFFFFD700),
      );
      if (!_takes.any((t) => t.id == playerTake.id)) {
        _takes.insert(0, playerTake);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _verticalPageController.dispose();
    _reelLoopController.dispose();
    super.dispose();
  }

  Future<void> _submitStarRating(CuttingRoomAuditionTake take, int stars) async {
    final clampedStars = stars.clamp(1, 5);
    HapticFeedback.heavyImpact();
    setState(() {
      _userStarRatings[take.id] = clampedStars;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kRatingsPrefsKey, jsonEncode(_userStarRatings));
    } catch (_) {}

    // Non-destructive additive upsert to Supabase if online and table exists
    final client = supabaseOrNull;
    if (client != null && OfflineManager.instance.isOnline) {
      try {
        await client.from('cutting_room_ratings').upsert(<String, dynamic>{
          'take_id': take.id,
          'voter_id':
              AuthService.instance.currentProfile?.userId ?? 'local-s26-actor',
          'stars': clampedStars,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).timeout(const Duration(seconds: 4));
      } catch (_) {
        // Safely ignore if optional additive table is not provisioned yet
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0B0E17),
        duration: const Duration(milliseconds: 1400),
        content: Text(
          'Stamped $clampedStars ★ Golden Rating for ${take.actorHandle}!',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w800,
            color: Color(0xFFFFD700),
          ),
        ),
      ),
    );
  }

  Future<void> _openDirectorStampModal(CuttingRoomAuditionTake take) async {
    HapticFeedback.mediumImpact();
    final ctrl = TextEditingController(
      text: _customDirectorStamps[take.id] ?? take.directorCommentStamp,
    );

    final stamped = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B0E17),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 22,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'STAMP DIRECTOR\'S CRITIQUE ON REEL',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ctrl,
                maxLength: 56,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., OSCAR-WORTHY BREAKDOWN · 10/10',
                  filled: true,
                  fillColor: const Color(0xFF07090E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
                icon: const Icon(Icons.approval_rounded),
                label: const Text(
                  'SLAM DIRECTOR\'S STAMP ON FRAME',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (stamped != null && stamped.isNotEmpty && mounted) {
      HapticFeedback.heavyImpact();
      setState(() {
        _customDirectorStamps[take.id] = stamped.toUpperCase();
      });
    }
  }

  Future<void> _triggerViralShare(CuttingRoomAuditionTake take) async {
    HapticFeedback.mediumImpact();
    final stars = _userStarRatings[take.id] ?? 5;
    final stamp = _customDirectorStamps[take.id] ?? take.directorCommentStamp;
    final payload = '''
🎬 THE CUTTING ROOM FLOOR — ACT LIKE IT 🎬
Actor: ${take.actorHandle}
Scene: "${take.sceneTitle}" (${take.filmOrSeries}, ${take.releaseYear})
AI Telemetrics: ${take.aiTelemetricsScore.toStringAsFixed(1)}/100 · Rated: ${'★' * stars} ($stars/5)
Director's Stamp: [$stamp]
${take.scriptExcerpt}
''';
    try {
      await SharePlus.instance.share(
        ShareParams(text: payload.trim()),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      appBar: GameAppBar(
        title: 'THE CUTTING ROOM FLOOR',
        subtitle:
            'REEL ${_activeIndex + 1} OF ${_takes.length} · SWIPE UP FOR NEXT TAKE',
      ),
      body: PageView.builder(
        controller: _verticalPageController,
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        itemCount: _takes.length,
        onPageChanged: (idx) {
          HapticFeedback.selectionClick();
          setState(() {
            _activeIndex = idx;
          });
        },
        itemBuilder: (context, index) {
          final take = _takes[index];
          return _buildFullScreenCellShadedReel(take);
        },
      ),
    );
  }

  Widget _buildFullScreenCellShadedReel(CuttingRoomAuditionTake take) {
    final archetype = resolveAvatarArchetype(take.avatarArchetypeId);
    final selectedStars = _userStarRatings[take.id];
    final activeStamp =
        _customDirectorStamps[take.id] ?? take.directorCommentStamp;

    return AnimatedBuilder(
      animation: _reelLoopController,
      builder: (context, _) {
        final phase = _reelLoopController.value * math.pi * 2;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0B0E17),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF05070B),
                width: 4.0,
              ),
              boxShadow: <BoxShadow>[
                const BoxShadow(
                  color: Color(0xFF05070B),
                  offset: Offset(6, 6),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: take.neonAccent.withValues(alpha: 0.26),
                  blurRadius: 24,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. 2.5D Cell-Shaded Looping Audition Stage Canvas
                CustomPaint(
                  painter: _CuttingRoomLoopStagePainter(
                    phase: phase,
                    neonAccent: take.neonAccent,
                  ),
                ),

                // 2. Center 2.5D Performer Avatar & Live Audio Wave
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BoondocksAvatarPortrait(
                        archetype: archetype,
                        size: 132,
                        isSelected: true,
                        animationPhase: phase,
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xE607090E),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: take.neonAccent,
                            width: 1.8,
                          ),
                        ),
                        child: Text(
                          'LOOPING AUDITION REEL · AI ${take.aiTelemetricsScore.toStringAsFixed(1)}/100',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: take.neonAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Angled "DIRECTOR'S COMMENT STAMP" Ink Overlay
                Positioned(
                  top: 18,
                  left: 16,
                  right: 88,
                  child: GestureDetector(
                    onTap: () => _openDirectorStampModal(take),
                    child: Transform.rotate(
                      angle: -0.055,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xE62B0610),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFFFD700),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.approval_rounded,
                              color: Color(0xFFFFD700),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'DIRECTOR STAMP: $activeStamp',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                  color: Color(0xFFFFD700),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 4. Right-Side Vertical Action Column: Viral Share & Stamp Trigger
                Positioned(
                  right: 14,
                  bottom: 188,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionOrb(
                        icon: Icons.approval_rounded,
                        label: 'STAMP',
                        accent: const Color(0xFFFFD700),
                        onTap: () => _openDirectorStampModal(take),
                      ),
                      const SizedBox(height: 14),
                      _buildActionOrb(
                        icon: Icons.ios_share_rounded,
                        label: '${take.shareCount}',
                        accent: const Color(0xFF06B6D4),
                        onTap: () => _triggerViralShare(take),
                      ),
                    ],
                  ),
                ),

                // 5. Bottom Metadata + 5-to-1 GOLDEN STAR RATING BOX
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xEB07090E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF05070B),
                            width: 3.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  take.actorHandle,
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 22,
                                    letterSpacing: 1.4,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: archetype.primaryInkColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    archetype.name,
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
                            const SizedBox(height: 2),
                            Text(
                              '${take.sceneTitle} · ${take.filmOrSeries} (${take.releaseYear})',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: take.neonAccent,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              take.scriptExcerpt,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFFE2E8F0),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 5-to-1 GOLDEN STAR RATING BOX
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xF20B0E17),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFFD700),
                            width: 2.2,
                          ),
                          boxShadow: const <BoxShadow>[
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
                                const Text(
                                  '5-TO-1 GOLDEN STAR RATING BOX',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFFFD700),
                                  ),
                                ),
                                Text(
                                  selectedStars != null
                                      ? 'YOUR VERDICT: $selectedStars ★'
                                      : 'AVG ${take.averageStarRating.toStringAsFixed(1)} ★ (${take.totalRatingsCount})',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Descending 5 -> 4 -> 3 -> 2 -> 1 Golden Star Buttons
                            Row(
                              children: [5, 4, 3, 2, 1].map((starValue) {
                                final isChosen = selectedStars == starValue;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    child: GestureDetector(
                                      onTap: () =>
                                          _submitStarRating(take, starValue),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 180),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isChosen
                                              ? const Color(0xFFFFD700)
                                              : const Color(0xFF141926),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isChosen
                                                ? const Color(0xFF05070B)
                                                : const Color(0xFF334155),
                                            width: isChosen ? 2.4 : 1.2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.star_rounded,
                                              size: 15,
                                              color: isChosen
                                                  ? const Color(0xFF05070B)
                                                  : const Color(0xFFFFD700),
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              '$starValue',
                                              style: TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w900,
                                                color: isChosen
                                                    ? const Color(0xFF05070B)
                                                    : Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionOrb({
    required IconData icon,
    required String label,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xEB07090E),
              shape: BoxShape.circle,
              border: Border.all(color: accent, width: 2.2),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0xFF05070B),
                  offset: Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CuttingRoomLoopStagePainter extends CustomPainter {
  final double phase;
  final Color neonAccent;

  const _CuttingRoomLoopStagePainter({
    required this.phase,
    required this.neonAccent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.42);

    // 1. Gritty 2.5D Soundstage Backdrop
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.2),
          radius: 0.95,
          colors: <Color>[
            neonAccent.withValues(alpha: 0.28),
            const Color(0xFF0B0E17),
            const Color(0xFF05070B),
          ],
        ).createShader(Offset.zero & size),
    );

    // 2. Kinetic Comic Action Lines radiating from the performer
    final linePaint = Paint()
      ..color = neonAccent.withValues(alpha: 0.22)
      ..strokeWidth = 2.0;

    for (int i = 0; i < 20; i++) {
      final angle = (i / 20.0) * math.pi * 2 + phase * 0.25;
      final r1 = 76.0 + (i.isEven ? 14.0 : 0.0);
      final r2 = size.longestSide * 0.7;
      canvas.drawLine(
        Offset(center.dx + math.cos(angle) * r1, center.dy + math.sin(angle) * r1),
        Offset(center.dx + math.cos(angle) * r2, center.dy + math.sin(angle) * r2),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CuttingRoomLoopStagePainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.neonAccent != neonAccent;
}
