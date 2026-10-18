import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'offline_manager.dart';
import 'ui/game_app_bar.dart';

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
      body: SafeArea(
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
                    (rec) => Container(
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
                          Text(
                            rec.finalScore.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFF59E0B),
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
}
