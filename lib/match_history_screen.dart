import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'offline_manager.dart';
import 'ui/game_app_bar.dart';
import 'judging/feedback_engine.dart';

/// Career Trophy Room & Match History screen connected to `OfflineManager`
/// (`shared_preferences` + `public.match_history` in Supabase).
class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  @override
  void initState() {
    super.initState();
    OfflineManager.instance.ensureInitialized().then((_) {
      OfflineManager.instance.refreshMatchHistoryFromSupabase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      appBar: GameAppBar(
        title: 'Career Trophy Room',
        extraActions: [
          IconButton(
            tooltip: 'Sync with Supabase',
            onPressed: () {
              OfflineManager.instance.refreshMatchHistoryFromSupabase();
            },
            icon: const Icon(
              Icons.sync_rounded,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.6),
            radius: 1.35,
            colors: [
              Color(0xFF520002),
              Color(0xFF1A050A),
              Color(0xFF07090E),
            ],
            stops: [0.0, 0.48, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: OfflineManager.instance,
            builder: (context, _) {
              final mgr = OfflineManager.instance;
            final records = mgr.matchHistoryLog;
            final totalMatches = records.length;
            final totalWins = mgr.totalCareerWins;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'GOLDEN STATUETTE LEDGER',
                  style: GoogleFonts.limelight(
                    fontSize: 28,
                    color: Colors.white,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard(
                      label: 'CAREER WINS',
                      value: '$totalWins / $totalMatches',
                      accent: const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      label: 'AVG COMPOSITE',
                      value: mgr.averageFinalScore.toStringAsFixed(1),
                      accent: const Color(0xFFF59E0B),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (records.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B0E17),
                      borderRadius: BorderRadius.circular(18.0),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.45),
                        width: 1.4,
                      ),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          color: Color(0xFF10B981),
                          size: 48.0,
                        ),
                        SizedBox(height: 14.0),
                        Text(
                          'NO SOUNDSTAGE TAKES RECORDED YET',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Complete a take on the soundstage to log your AI Telemetrics, Peer, and Social judging scores here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.0,
                            color: Color(0xFF94A3B8),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...records.map(
                    (rec) => GestureDetector(
                      onTap: () => _showRecordDetailsModal(rec),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B0E17),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: rec.isWin
                                ? const Color(0xFF10B981)
                                : const Color(0xFF1E293B),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              rec.isWin
                                  ? Icons.emoji_events_rounded
                                  : Icons.movie_creation_outlined,
                              color: rec.isWin
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF06B6D4),
                              size: 28,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rec.sceneTitle,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'AI ${rec.aiScore.toStringAsFixed(0)} · Peer ${rec.peerScore.toStringAsFixed(0)} · Social ${rec.socialScore.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  rec.finalScore.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'VIEW CARD →',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF06B6D4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color accent,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B0E17),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecordDetailsModal(MatchHistoryRecord rec) {
    HapticFeedback.mediumImpact();
    final isStandingOvation = rec.isWin || rec.finalScore >= 85.0;
    final criticQuote = FeedbackEngine.getFeedbackForScore(
      rec.finalScore,
      seed: rec.sceneTitle.hashCode,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.only(top: 48),
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
        decoration: BoxDecoration(
          color: const Color(0xFF07090E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: const Border(
            top: BorderSide(color: Color(0xFFFFD700), width: 2.0),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.18),
              blurRadius: 36,
              spreadRadius: 2,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        "HOLLYWOOD CRITIC'S SCORECARD",
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isStandingOvation
                            ? const Color(0x2610B981)
                            : const Color(0x26F59E0B),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isStandingOvation
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                      ),
                      child: Text(
                        isStandingOvation ? 'STANDING OVATION' : 'CERTIFIED FRESH',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isStandingOvation
                              ? const Color(0xFF10B981)
                              : const Color(0xFFFFD700),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(
                    5,
                    (idx) => Icon(
                      idx < (rec.finalScore / 20.0).round()
                          ? Icons.star_rounded
                          : Icons.star_half_rounded,
                      size: 18,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // 3-Axis Custom Performance Painter
                SizedBox(
                  height: 96,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _HistoryThreeAxisPainter(
                      facialScore: rec.aiScore,
                      vocalScore: rec.peerScore,
                      cueScore: rec.socialScore,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1524),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"$criticQuote"',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontStyle: FontStyle.italic,
                          height: 1.45,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scene: ${rec.sceneTitle} · ${rec.filmOrSeries}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Tri-Modal Metric Breakdown Faders
                Row(
                  children: [
                    _buildMetricChip('AI (45%)', rec.aiScore, const Color(0xFFE11D48)),
                    const SizedBox(width: 8),
                    _buildMetricChip('PEER (35%)', rec.peerScore, const Color(0xFF06B6D4)),
                    const SizedBox(width: 8),
                    _buildMetricChip('SOCIAL (20%)', rec.socialScore, const Color(0xFFF59E0B)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: const Color(0xFF050508),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Clipboard.setData(
                        ClipboardData(
                          text: '🎬 ACT LIKE IT · SCORECARD\n'
                              'Scene: ${rec.sceneTitle}\n'
                              'Composite Score: ${rec.finalScore.toStringAsFixed(1)} / 100\n'
                              'Verdict: ${isStandingOvation ? "Standing Ovation" : "Certified Fresh"}\n'
                              '"$criticQuote"',
                        ),
                      );
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Scorecard copied to clipboard for export & sharing!',
                            style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700),
                          ),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text(
                      'EXPORT & SHARE CRITIC SCORECARD',
                      style: TextStyle(fontWeight: FontWeight.w900),
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

  Widget _buildMetricChip(String label, double score, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0B0E17),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              score.toStringAsFixed(1),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryThreeAxisPainter extends CustomPainter {
  final double facialScore;
  final double vocalScore;
  final double cueScore;

  const _HistoryThreeAxisPainter({
    required this.facialScore,
    required this.vocalScore,
    required this.cueScore,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final axes = <(String label, double value, Color color)>[
      ('FACIAL EMOTION', facialScore.clamp(0.0, 100.0), const Color(0xFFE11D48)),
      ('VOCAL CADENCE', vocalScore.clamp(0.0, 100.0), const Color(0xFF06B6D4)),
      ('CUE FIDELITY', cueScore.clamp(0.0, 100.0), const Color(0xFFFFD700)),
    ];

    final barHeight = 14.0;
    final spacing = (size.height - (axes.length * barHeight)) / (axes.length + 1);

    for (var i = 0; i < axes.length; i++) {
      final item = axes[i];
      final y = spacing + i * (barHeight + spacing);

      final bgPaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.fill;
      final bgRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, y, size.width, barHeight),
        const Radius.circular(6),
      );
      canvas.drawRRect(bgRRect, bgPaint);

      final fillWidth = (item.$2 / 100.0) * size.width;
      if (fillWidth > 0) {
        final fillPaint = Paint()
          ..color = item.$3
          ..style = PaintingStyle.fill;
        final fillRRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(0, y, fillWidth, barHeight),
          const Radius.circular(6),
        );
        canvas.drawRRect(fillRRect, fillPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HistoryThreeAxisPainter oldDelegate) {
    return oldDelegate.facialScore != facialScore ||
        oldDelegate.vocalScore != vocalScore ||
        oldDelegate.cueScore != cueScore;
  }
}
