import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Unified 4-Tier Dynamic Feedback Engine used by both the top
/// "DIRECTOR'S VERDICT" banner and the bottom "HOLLYWOOD CRITIC'S SCORECARD"
/// so the two cards NEVER contradict each other:
/// - `>= 85.0`: STANDING OVATION (Emerald / Gold)
/// - `75.0 – 84.9`: CERTIFIED FRESH (Cyan / Gold)
/// - `60.0 – 74.9`: MIXED REVIEWS (Amber)
/// - `< 60.0`: TOUGH CROWD (Crimson Roast)
class FeedbackEngine {
  static const double standingOvationThreshold = 85.0;
  static const double highScoreThreshold = 75.0;
  static const double mixedReviewsThreshold = 60.0;

  /// Tier 1 (`>= 85.0`): Standing Ovation
  static const List<String> standingOvationVariations = [
    "Oscar-worthy! The telemetrics practically broke from that raw emotion.",
    "You just owned that scene. The AI is asking for your autograph.",
    "Flawless prosody! Meryl Streep is shaking right now.",
    "Absolute perfection. Your digital twin couldn't have done it better.",
    "Box office smash! The crowd and the algorithm are on their feet.",
    "Incredible micro-expressions. We felt every single frame of that.",
  ];

  /// Tier 2 (`75.0 – 84.9`): Certified Fresh
  static const List<String> certifiedFreshVariations = [
    "Certified Fresh! Magnetic screen presence with commanding vocal pacing.",
    "Strong callback energy! The Casting Director just circled your name in gold ink.",
    "Dialed-in emotional beats and sharp eye-line discipline—ready for prime time.",
    "Critics agree: a gripping take that held the room from the opening line.",
    "Solid box-office contender! You nailed the dramatic shift right on cue.",
    "Great instincts on camera. One more polish and the Academy will be calling.",
  ];

  /// Tier 3 (`60.0 – 74.9`): Mixed Reviews
  static const List<String> mixedReviewsVariations = [
    "Promising flashes of brilliance, though the middle beats needed more fire.",
    "The camera loved the intensity, but the vocal cadence drifted off script.",
    "A respectable rehearsal take—push the emotional stakes higher on Take 2!",
    "Critics are split: solid presence, but the climax could hit much harder.",
  ];

  /// Tier 4 (`< 60.0`): Tough Crowd (Roast)
  static const List<String> lowScoreVariations = [
    "Well... at least you remembered to hit record. Let's try some actual acting next time.",
    "The AI detected zero emotion. Are you sure you're not a robot?",
    "Box office bomb. Your peers have politely requested a recast.",
    "Yikes. The teleprompter had more emotional range than that delivery.",
    "We're going to need a stunt double for your face. Let's take it from the top.",
    "The algorithm is confused. Were you acting, or just reading a grocery list?",
  ];

  /// Legacy alias kept for compatibility.
  static const List<String> highScoreVariations = standingOvationVariations;

  /// Returns the exact 4-tier verdict label for [compositeScore].
  static String getTierLabelForScore(double compositeScore) {
    if (compositeScore >= standingOvationThreshold) {
      return 'DIRECTOR\'S VERDICT · STANDING OVATION';
    } else if (compositeScore >= highScoreThreshold) {
      return 'DIRECTOR\'S VERDICT · CERTIFIED FRESH';
    } else if (compositeScore >= mixedReviewsThreshold) {
      return 'DIRECTOR\'S VERDICT · MIXED REVIEWS';
    } else {
      return 'DIRECTOR\'S VERDICT · TOUGH CROWD';
    }
  }

  /// Returns the tier badge color for [compositeScore].
  static Color getTierColorForScore(double compositeScore) {
    if (compositeScore >= standingOvationThreshold) {
      return const Color(0xFF10B981); // Emerald
    } else if (compositeScore >= highScoreThreshold) {
      return const Color(0xFF0CB6D4); // Soundstage Cyan
    } else if (compositeScore >= mixedReviewsThreshold) {
      return const Color(0xFFF59E0B); // Amber
    } else {
      return const Color(0xFFE11D48); // Crimson
    }
  }

  static List<String> _poolForScore(double compositeScore) {
    if (compositeScore >= standingOvationThreshold) {
      return standingOvationVariations;
    } else if (compositeScore >= highScoreThreshold) {
      return certifiedFreshVariations;
    } else if (compositeScore >= mixedReviewsThreshold) {
      return mixedReviewsVariations;
    } else {
      return lowScoreVariations;
    }
  }

  /// Returns a deterministic feedback string synchronized to the exact 4-tier
  /// [compositeScore] so top and bottom verdict cards always match.
  static String getFeedbackForScore(
    double compositeScore, {
    int? seed,
  }) {
    final pool = _poolForScore(compositeScore);
    final index = seed != null
        ? seed.abs() % pool.length
        : (compositeScore * 10).round().abs() % pool.length;
    return pool[index];
  }

  /// Returns a random variation from the exact tier pool for [compositeScore].
  static String getRandomFeedbackForScore(double compositeScore) {
    final pool = _poolForScore(compositeScore);
    final randomIndex = math.Random().nextInt(pool.length);
    return pool[randomIndex];
  }

  /// Alias for getFeedbackForScore matching PerformanceFeedbackEngine signature.
  static String selectFeedback(double compositeScore, {int? seed}) =>
      getFeedbackForScore(compositeScore, seed: seed);
}

/// Backward-compatibility alias for PerformanceFeedbackEngine
typedef PerformanceFeedbackEngine = FeedbackEngine;

/// Neon-accented card widget displaying the dynamic 4-tier feedback variation
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
    final Color accentColor = FeedbackEngine.getTierColorForScore(compositeScore);
    final String tierLabel = FeedbackEngine.getTierLabelForScore(compositeScore);
    final String verdictText = FeedbackEngine.getFeedbackForScore(
      compositeScore,
      seed: seed,
    );
    final bool isPositive = compositeScore >= FeedbackEngine.highScoreThreshold;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D121C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.85),
          width: 1.6,
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
              isPositive
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    tierLabel,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.9,
                      color: accentColor,
                    ),
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
