import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Dynamic Feedback Engine providing 12 distinct director verdicts
/// (6 High-Score Variations and 6 Low-Score Variations) based on the
/// composite Tri-Modal Judging Score (AI 45% + Peer 35% + Social 20%).
class FeedbackEngine {
  static const double highScoreThreshold = 75.0;

  /// 6 High-Score Variations (Composite Score >= 75.0)
  static const List<String> highScoreVariations = [
    "Oscar-worthy! The telemetrics practically broke from that raw emotion.",
    "You just owned that scene. The AI is asking for your autograph.",
    "Flawless prosody! Meryl Streep is shaking right now.",
    "Absolute perfection. Your digital twin couldn't have done it better.",
    "Box office smash! The crowd and the algorithm are on their feet.",
    "Incredible micro-expressions. We felt every single frame of that.",
  ];

  /// 6 Low-Score Variations (Composite Score < 75.0)
  static const List<String> lowScoreVariations = [
    "Well... at least you remembered to hit record. Let's try some actual acting next time.",
    "The AI detected zero emotion. Are you sure you're not a robot?",
    "Box office bomb. Your peers have politely requested a recast.",
    "Yikes. The teleprompter had more emotional range than that delivery.",
    "We're going to need a stunt double for your face. Let's take it from the top.",
    "The algorithm is confused. Were you acting, or just reading a grocery list?",
  ];

  /// Returns a distinct feedback string based on [compositeScore].
  /// Uses an optional [seed] (or deterministic score bucket) so UI rebuilds
  /// keep a stable quote while changing whenever the score tier shifts.
  static String getFeedbackForScore(
    double compositeScore, {
    int? seed,
  }) {
    final bool isHighScore = compositeScore >= highScoreThreshold;
    final pool = isHighScore ? highScoreVariations : lowScoreVariations;
    final index = seed != null
        ? seed.abs() % pool.length
        : (compositeScore * 10).round().abs() % pool.length;
    return pool[index];
  }

  /// Returns a random variation from the appropriate pool.
  static String getRandomFeedbackForScore(double compositeScore) {
    final bool isHighScore = compositeScore >= highScoreThreshold;
    final pool = isHighScore ? highScoreVariations : lowScoreVariations;
    final randomIndex = math.Random().nextInt(pool.length);
    return pool[randomIndex];
  }
}

/// Neon-accented card widget displaying the dynamic feedback variation
/// inside `TriModalJudgingScreen`.
class DynamicFeedbackBanner extends StatelessWidget {
  final double compositeScore;
  final int? seed;

  const DynamicFeedbackBanner({
    super.key,
    required this.compositeScore,
    this.seed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHigh = compositeScore >= FeedbackEngine.highScoreThreshold;
    final Color accentColor =
        isHigh ? const Color(0xFF10B981) : const Color(0xFFE11D48);
    final String verdictText = FeedbackEngine.getFeedbackForScore(
      compositeScore,
      seed: seed,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D121C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isHigh
                  ? Icons.workspace_premium_rounded
                  : Icons.theater_comedy_outlined,
              color: accentColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHigh
                      ? 'DIRECTOR\'S VERDICT · STANDING OVATION'
                      : 'DIRECTOR\'S VERDICT · TOUGH CROWD',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '"$verdictText"',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
