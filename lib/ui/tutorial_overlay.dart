import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Neon-accented, dismissible contextual tutorial tooltip matching the
/// "Living Marquee" dark obsidian (`#07090E`) aesthetic.
///
/// Uses `shared_preferences` (`tutorial_seen_<tutorialKey>`) so each hint
/// only renders the first time a user reaches that specific screen or feature,
/// and includes an explicit "X" button to dismiss it immediately.
class TutorialOverlay extends StatefulWidget {
  final String tutorialKey;
  final String badgeLabel;
  final String title;
  final String message;
  final Color neonAccent;
  final IconData icon;
  final VoidCallback? onDismissed;

  const TutorialOverlay({
    super.key,
    required this.tutorialKey,
    required this.title,
    required this.message,
    this.badgeLabel = 'DIRECTOR TIP · FIRST-TIME CUE',
    this.neonAccent = const Color(0xFF06B6D4),
    this.icon = Icons.lightbulb_outline_rounded,
    this.onDismissed,
  });

  static String _storageKey(String key) => 'act_like_it.tutorial_seen_$key';

  /// Helper to check whether a specific tutorial tooltip has already been seen.
  static Future<bool> hasSeenTutorial(String tutorialKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_storageKey(tutorialKey)) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Marks a specific tutorial key as seen in `shared_preferences`.
  static Future<void> markTutorialSeen(String tutorialKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_storageKey(tutorialKey), true);
    } catch (_) {}
  }

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  bool _isVisible = false;
  bool _checkedPrefs = false;

  @override
  void initState() {
    super.initState();
    _checkFirstTimeStatus();
  }

  Future<void> _checkFirstTimeStatus() async {
    final alreadySeen =
        await TutorialOverlay.hasSeenTutorial(widget.tutorialKey);
    if (!mounted) return;
    setState(() {
      _checkedPrefs = true;
      _isVisible = !alreadySeen;
    });
  }

  Future<void> _dismissTooltip() async {
    HapticFeedback.lightImpact();
    setState(() {
      _isVisible = false;
    });
    await TutorialOverlay.markTutorialSeen(widget.tutorialKey);
    widget.onDismissed?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkedPrefs || !_isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0B0F19),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.neonAccent.withValues(alpha: 0.85),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.neonAccent.withValues(alpha: 0.2),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: widget.neonAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.icon,
                color: widget.neonAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.badgeLabel,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.9,
                      color: widget.neonAccent,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.message,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: _dismissTooltip,
              tooltip: 'Dismiss Tip',
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF161E2E),
                side: BorderSide(
                  color: widget.neonAccent.withValues(alpha: 0.45),
                ),
              ),
              icon: const Icon(
                Icons.close_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
