import 'package:flutter/material.dart';

/// Stateless placeholder screen for the Career Trophy Room & Match History view.
/// Resolves the `match_history_screen.dart` import from `LivingMarqueeDashboardScreen`.
class MatchHistoryScreen extends StatelessWidget {
  const MatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E17),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Match History',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0E17),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.45),
                width: 1.2,
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
                SizedBox(height: 16.0),
                Text(
                  'MATCH HISTORY & CAREER TROPHY ROOM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Completed soundstage performances and Tri-Modal AI scores will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Color(0xFF94A3B8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
