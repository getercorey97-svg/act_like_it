import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../auth/auth_service.dart';
import '../dashboard_marquee.dart';
import '../lobby.dart';
import '../main.dart';
import '../offline_manager.dart';
import 'boondocks_character_rig.dart';

/// PART 3: Match Finalization & Award Ceremony Engine
/// (`lib/ui/match_finalization_screen.dart`).
/// - Officially marks the room/match as `completed` in Supabase and SharedPreferences,
///   clearing the active room banner on the Main Dashboard.
/// - Renders the 2.5D Golden Statuette Award Ceremony for Solo and Multiplayer modes.
/// - Uses `Navigator.pushAndRemoveUntil` so pressing Back never traps the player
///   in the 10-second camera pre-roll countdown.
class MatchFinalizationScreen extends StatefulWidget {
  final LobbySession lobbySession;
  final String performerUserId;
  final String performerDisplayName;
  final String leadPerformerName;
  final ScenePrompt? scene;
  final double compositeScore;
  final double aiScore;
  final double peerScore;
  final double socialScore;
  final double improvBonus;
  final String showstopperTitle;
  final String criticQuote;

  const MatchFinalizationScreen({
    super.key,
    required this.lobbySession,
    this.performerUserId = 'local-s26-actor',
    this.performerDisplayName = '',
    this.leadPerformerName = 'StageStar',
    this.scene,
    required this.compositeScore,
    required this.aiScore,
    required this.peerScore,
    required this.socialScore,
    this.improvBonus = 0.0,
    this.showstopperTitle = 'THE METHOD MASTER',
    this.criticQuote =
        'Standing Ovation — Academy-caliber screen command and emotional conviction!',
  });

  String get resolvedPerformerName => performerDisplayName.trim().isNotEmpty
      ? performerDisplayName.trim()
      : (leadPerformerName.trim().isNotEmpty
          ? leadPerformerName.trim()
          : 'StageStar');

  ScenePrompt get resolvedScene =>
      scene ??
      lobbySession.activeScene ??
      kBuiltInSceneVault[SceneCategory.era1970To1999]!.first;

  @override
  State<MatchFinalizationScreen> createState() =>
      _MatchFinalizationScreenState();
}

class _MatchFinalizationScreenState extends State<MatchFinalizationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _statuetteGlowController;
  int _earnedXp = 250;

  @override
  void initState() {
    super.initState();
    _statuetteGlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _earnedXp = widget.compositeScore >= 85.0
        ? 350
        : (widget.compositeScore >= 75.0 ? 250 : 150);
    _finalizeMatchSessionAndAwardXp();
  }

  Future<void> _finalizeMatchSessionAndAwardXp() async {
    HapticFeedback.heavyImpact();
    // 1. Clear active room session from SharedPreferences so the Main Dashboard
    // never shows a stuck "ACTIVE SET IN PROGRESS — TAP TO REJOIN" banner!
    await LobbyRealtimeManager.clearActiveRoomSession();

    // 2. Mark the room as completed in Supabase `lobbies`
    final client = supabaseOrNull;
    if (client != null && OfflineManager.instance.isOnline) {
      try {
        await client
            .from('lobbies')
            .update({'status': 'completed'})
            .eq('room_code', widget.lobbySession.roomCode);
      } catch (_) {}
    }

    // 3. Award Career XP to the active profile
    await AuthService.instance.addCareerXp(_earnedXp);
  }

  @override
  void dispose() {
    _statuetteGlowController.dispose();
    super.dispose();
  }

  Future<void> _shareOfficialMatchScorecard() async {
    HapticFeedback.mediumImpact();
    final stars = (widget.compositeScore / 20.0).round().clamp(1, 5);
    final starIcons = '⭐' * stars;
    final activeScene = widget.resolvedScene;
    final actorName = widget.resolvedPerformerName;
    final payload = '''
🏆 ACT LIKE IT — OFFICIAL SOUNDSTAGE WRAP 🏆
Actor: $actorName (${widget.showstopperTitle})
Scene: "${activeScene.title}" — ${activeScene.filmOrSeries} (${activeScene.releaseYear})
Final Composite Score: ${widget.compositeScore.toStringAsFixed(1)} / 100 $starIcons
• AI Telemetrics: ${widget.aiScore.toStringAsFixed(1)}
• Peer Vote: ${widget.peerScore.toStringAsFixed(1)}
• Social Crowd: ${widget.socialScore.toStringAsFixed(1)}
Critic's Verdict: "${widget.criticQuote}"
Play Live: https://act-like-it.vercel.app
''';
    try {
      await SharePlus.instance.share(ShareParams(text: payload.trim()));
    } catch (_) {}
  }

  void _rollRematchInGreenRoom() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => LobbyMatchmakingScreen(
          initialCategory: widget.lobbySession.selectedCategory,
          startInJoinMode: false,
          autoCreateOnInit: true,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  void _returnToRedCarpetDashboard() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const LivingMarqueeDashboardScreen(),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = AuthService.instance.currentProfile;
    final actorArchetype =
        resolveAvatarArchetype(profile?.avatarArchetypeId);
    final isStatuetteWinner = widget.compositeScore >= 75.0;
    final starsCount = (widget.compositeScore / 20.0).round().clamp(1, 5);
    final totalWins = OfflineManager.instance.totalCareerWins;
    final totalMatches = OfflineManager.instance.matchHistoryLog.length;
    final players = widget.lobbySession.players;
    final isMultiplayer = players.length > 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _returnToRedCarpetDashboard();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF07090E),
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.45),
              radius: 1.3,
              colors: [
                Color(0xFF520002),
                Color(0xFF1A050A),
                Color(0xFF07090E),
              ],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
              children: [
                // Top Header Pill
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B0E17),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 2.0,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isMultiplayer
                            ? 'OFFICIAL ENSEMBLE AWARD CEREMONY · ROOM #${widget.lobbySession.roomCode}'
                            : 'OFFICIAL SOUNDSTAGE WRAP · SOLO SCREEN TEST',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Hero 2.5D Golden Statuette & Actor Showcase
                AnimatedBuilder(
                  animation: _statuetteGlowController,
                  builder: (context, _) {
                    final glow = 0.25 + _statuetteGlowController.value * 0.35;
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B0E17),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isStatuetteWinner
                              ? const Color(0xFFFFD700)
                              : const Color(0xFF06B6D4),
                          width: 3.0,
                        ),
                        boxShadow: [
                          const BoxShadow(
                            color: Color(0xFF05070B),
                            offset: Offset(6, 6),
                            blurRadius: 0,
                          ),
                          BoxShadow(
                            color: const Color(0xFFFFD700)
                                .withValues(alpha: glow),
                            blurRadius: 28,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BoondocksCharacterRig(
                                archetype: actorArchetype,
                                size: 92,
                                isSelected: true,
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0x26FFD700),
                                  border: Border.all(
                                    color: const Color(0xFFFFD700),
                                    width: 2.5,
                                  ),
                                ),
                                child: Icon(
                                  isStatuetteWinner
                                      ? Icons.emoji_events_rounded
                                      : Icons.movie_creation_rounded,
                                  color: const Color(0xFFFFD700),
                                  size: 44,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              isStatuetteWinner
                                  ? 'GOLDEN STATUETTE WINNER!'
                                  : 'OFFICIAL SOUNDSTAGE WRAP!',
                              style: GoogleFonts.bebasNeue(
                                fontSize: 34,
                                letterSpacing: 2.0,
                                color: const Color(0xFFFFD700),
                              ),
                            ),
                          ),
                          Text(
                            '${widget.resolvedPerformerName} · "${widget.resolvedScene.title}"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < starsCount
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: const Color(0xFFFFD700),
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${widget.compositeScore.toStringAsFixed(1)} / 100',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildRewardBadge(
                                '+$_earnedXp CAREER XP',
                                const Color(0xFF10B981),
                              ),
                              _buildRewardBadge(
                                'CAREER RECORD: $totalWins / $totalMatches WINS',
                                const Color(0xFF06B6D4),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Multiplayer Cast Podium & Special Categorized Awards
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0E17),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF1E293B), width: 1.6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          isMultiplayer
                              ? 'FINAL CAST PODIUM & SPECIAL SOUNDSTAGE AWARDS'
                              : 'SPECIAL CATEGORIZED SOUNDSTAGE HONORS',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (isMultiplayer) ...[
                        ..._buildPodiumRows(players),
                        const Divider(color: Color(0xFF1E293B), height: 20),
                      ],
                      _buildSpecialAwardRow(
                        icon: Icons.face_retouching_natural_rounded,
                        award: 'Best Facial Micro-Expressions',
                        winner: widget.resolvedPerformerName,
                        metric: 'AI ${widget.aiScore.toStringAsFixed(1)}/100',
                        accent: const Color(0xFFE11D48),
                      ),
                      const SizedBox(height: 8),
                      _buildSpecialAwardRow(
                        icon: Icons.groups_rounded,
                        award: 'Crowd Favorite Peer Vote',
                        winner: widget.resolvedPerformerName,
                        metric: 'PEER ${widget.peerScore.toStringAsFixed(1)}/100',
                        accent: const Color(0xFF10B981),
                      ),
                      const SizedBox(height: 8),
                      _buildSpecialAwardRow(
                        icon: Icons.bolt_rounded,
                        award: 'Scene Stealer Award',
                        winner: widget.resolvedPerformerName,
                        metric:
                            'COMPOSITE ${widget.compositeScore.toStringAsFixed(1)}',
                        accent: const Color(0xFFFFD700),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3 Clean Navigation Buttons (Zero Back-Navigation Pre-Roll Trap)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: const Color(0xFF05070B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _rollRematchInGreenRoom,
                  icon: const Icon(Icons.movie_creation_rounded, size: 20),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '🎬 ROLL REMATCH (NEW SCENE)',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFD700),
                    side: const BorderSide(
                      color: Color(0xFFFFD700),
                      width: 2.0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _shareOfficialMatchScorecard,
                  icon: const Icon(Icons.ios_share_rounded, size: 19),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '📤 EXPORT FULL MATCH SCORECARD',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11342),
                    foregroundColor: const Color(0xFFF5DEB3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(
                        color: Color(0xFFF5DEB3),
                        width: 2.0,
                      ),
                    ),
                  ),
                  onPressed: _returnToRedCarpetDashboard,
                  icon: const Icon(Icons.account_balance_rounded, size: 20),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '🏛️ RETURN TO RED CARPET DASHBOARD',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
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

  List<Widget> _buildPodiumRows(List<LobbyPlayer> players) {
    final sorted = List<LobbyPlayer>.from(players)
      ..sort((a, b) => b.compositeScore.compareTo(a.compositeScore));
    final medals = <String>['🥇 1ST GOLD', '🥈 2ND SILVER', '🥉 3RD BRONZE'];
    return List<Widget>.generate(sorted.length.clamp(0, 3), (idx) {
      final p = sorted[idx];
      final score = idx == 0 && p.userId == widget.performerUserId
          ? widget.compositeScore
          : p.compositeScore;
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${medals[idx]} · ${p.displayName}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              '${score.toStringAsFixed(1)} PTS',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
                color: Color(0xFFFFD700),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRewardBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSpecialAwardRow({
    required IconData icon,
    required String award,
    required String winner,
    required String metric,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF07090E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  award,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Awarded to $winner',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Text(
            metric,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
