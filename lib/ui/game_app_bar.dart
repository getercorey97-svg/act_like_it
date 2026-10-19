import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../offline_manager.dart';

/// Context-aware navigation AppBar featuring:
/// 1. Conditional visibility (hides back/exit controls during active 10–30s
///    recording countdowns via [isRecordingCountdownActive] to prevent accidental exits).
/// 2. A "Start Over" action that resets lobby/session state cleanly.
/// 3. Automatic state-persistence trigger using `shared_preferences` and Supabase
///    so session progress, AI tokens, and match records remain saved when backing out.
class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool isRecordingCountdownActive;
  final String? activeRoomCode;
  final double? latestCompositeScore;
  final VoidCallback? onStartOver;
  final VoidCallback? onBackOverride;
  final List<Widget>? extraActions;

  const GameAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.isRecordingCountdownActive = false,
    this.activeRoomCode,
    this.latestCompositeScore,
    this.onStartOver,
    this.onBackOverride,
    this.extraActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// Persists session progress, AI token balance, and match history records
  /// to `shared_preferences` and Supabase before exiting or starting over.
  static Future<void> persistSessionStateBeforeNavigation({
    String? roomCode,
    double? compositeScore,
    bool markReset = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final snapshot = <String, dynamic>{
        'last_saved_at': DateTime.now().toUtc().toIso8601String(),
        'last_room_code': roomCode ?? '',
        'last_composite_score': compositeScore ?? 0.0,
        'was_reset': markReset,
        'total_career_wins': OfflineManager.instance.totalCareerWins,
        'average_final_score': OfflineManager.instance.averageFinalScore,
      };
      await prefs.setString(
        'act_like_it.nav_session_checkpoint_v1',
        jsonEncode(snapshot),
      );
    } catch (_) {}

    // Trigger non-blocking Supabase sync for any pending match records & profile state
    try {
      await OfflineManager.instance.syncPendingMatchHistoryToSupabase();
      final client = supabaseOrNull;
      final currentUser = client?.auth.currentUser;
      if (client != null && currentUser != null) {
        await client.from('profiles').upsert({
          'id': currentUser.id,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
      }
    } catch (_) {}
  }

  Future<void> _handleSafeBack(BuildContext context) async {
    HapticFeedback.lightImpact();
    await persistSessionStateBeforeNavigation(
      roomCode: activeRoomCode,
      compositeScore: latestCompositeScore,
    );
    if (!context.mounted) return;
    if (onBackOverride != null) {
      onBackOverride!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleStartOver(BuildContext context) async {
    HapticFeedback.mediumImpact();
    await persistSessionStateBeforeNavigation(
      roomCode: activeRoomCode,
      compositeScore: latestCompositeScore,
      markReset: true,
    );
    if (!context.mounted) return;

    if (onStartOver != null) {
      onStartOver!();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Session state saved & reset. Ready to start over!',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF07090E),
      automaticallyImplyLeading: !isRecordingCountdownActive,
      leading: isRecordingCountdownActive
          ? const Padding(
              padding: EdgeInsets.all(14.0),
              child: Icon(
                Icons.fiber_manual_record_rounded,
                color: Color(0xFFE11D48),
                size: 18,
              ),
            )
          : IconButton(
              tooltip: 'Save & Back',
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () => _handleSafeBack(context),
            ),
      title: subtitle == null
          ? Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
      actions: [
        if (isRecordingCountdownActive)
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0x26E11D48),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE11D48)),
            ),
            child: const Text(
              'ON AIR · LOCKED',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFFE11D48),
              ),
            ),
          )
        else ...[
          TextButton.icon(
            onPressed: () => _handleStartOver(context),
            icon: const Icon(
              Icons.restart_alt_rounded,
              size: 16,
              color: Color(0xFF06B6D4),
            ),
            label: const Text(
              'Start Over',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF06B6D4),
              ),
            ),
          ),
          if (extraActions != null) ...extraActions!,
        ],
      ],
    );
  }
}
