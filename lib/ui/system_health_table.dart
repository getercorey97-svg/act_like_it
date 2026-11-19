import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/system_health_service.dart';

/// Compact Midnight Premiere & 24K Gold Top System Operational Status Table.
/// Displays a glowing Green (100%), Yellow (75%-99%), or Red (<75%) LED light
/// plus compact `DB/RT`, `WEBRTC`, `AI`, and `CACHE` cells with `FittedBox`
/// scaling so zero text truncates (`...`) or overflows on narrow screens.
class SystemHealthTable extends StatelessWidget {
  const SystemHealthTable({super.key});

  @override
  Widget build(BuildContext context) {
    final health = SystemHealthService.instance;
    return ListenableBuilder(
      listenable: health,
      builder: (context, _) {
        final Color ledColor = health.indicatorColor;
        final Color borderAccent = health.secondaryAccentColor;
        final int pct = health.healthPercent;
        final checks = health.checks;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            unawaited(showSystemHealthBreakdownSheet(context));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xF207090E),
                  Color(0xF215060C),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderAccent.withValues(alpha: 0.78),
                width: 1.4,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: ledColor.withValues(alpha: 0.22),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
                const BoxShadow(
                  color: Color(0xFF05070B),
                  offset: Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _GlowingLedBeacon(
                      color: ledColor,
                      size: 11,
                      isChecking: health.isChecking,
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      flex: 3,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'SYSTEM STATUS',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: Color(0xFFF5DEB3),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: ledColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: ledColor.withValues(alpha: 0.9),
                          width: 1.1,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          health.statusLabel,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                            color: ledColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.analytics_outlined,
                      size: 14,
                      color: const Color(0xFFF5DEB3).withValues(alpha: 0.8),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (int i = 0; i < checks.length; i++) ...[
                      if (i > 0) const SizedBox(width: 5),
                      Expanded(
                        child: _ServiceStatusCell(check: checks[i]),
                      ),
                    ],
                  ],
                ),
                if (pct < 100) ...[
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        health.statusSummary,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: ledColor.withValues(alpha: 0.92),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> showSystemHealthBreakdownSheet(
    BuildContext context,
  ) async {
    unawaited(SystemHealthService.instance.refreshHealthChecks());
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF07090E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Color(0xFFF5DEB3), width: 1.8),
      ),
      builder: (ctx) => const _SystemHealthBreakdownSheet(),
    );
  }
}

class _GlowingLedBeacon extends StatelessWidget {
  final Color color;
  final double size;
  final bool isChecking;

  const _GlowingLedBeacon({
    required this.color,
    required this.size,
    required this.isChecking,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: Colors.white.withValues(alpha: isChecking ? 0.9 : 0.45),
          width: 1.0,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.95),
            blurRadius: isChecking ? 16 : 11,
            spreadRadius: isChecking ? 3.0 : 2.0,
          ),
        ],
      ),
    );
  }
}

class _ServiceStatusCell extends StatelessWidget {
  final SystemServiceCheck check;

  const _ServiceStatusCell({required this.check});

  Color get _cellColor {
    switch (check.state) {
      case SystemServiceHealthState.healthy:
        return const Color(0xFF00FF88);
      case SystemServiceHealthState.degraded:
        return const Color(0xFFFFD60A);
      case SystemServiceHealthState.down:
        return const Color(0xFFFF2A55);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _cellColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0D111A),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: color.withValues(alpha: 0.55),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: color.withValues(alpha: 0.85),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${check.shortCode} ${check.score}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemHealthBreakdownSheet extends StatelessWidget {
  const _SystemHealthBreakdownSheet();

  Color _colorForState(SystemServiceHealthState state) {
    switch (state) {
      case SystemServiceHealthState.healthy:
        return const Color(0xFF00FF88);
      case SystemServiceHealthState.degraded:
        return const Color(0xFFFFD60A);
      case SystemServiceHealthState.down:
        return const Color(0xFFFF2A55);
    }
  }

  String _tagForState(SystemServiceHealthState state) {
    switch (state) {
      case SystemServiceHealthState.healthy:
        return 'ONLINE';
      case SystemServiceHealthState.degraded:
        return 'FALLBACK';
      case SystemServiceHealthState.down:
        return 'CHECK';
    }
  }

  @override
  Widget build(BuildContext context) {
    final health = SystemHealthService.instance;
    return ListenableBuilder(
      listenable: health,
      builder: (context, _) {
        final ledColor = health.indicatorColor;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _GlowingLedBeacon(
                      color: ledColor,
                      size: 14,
                      isChecking: health.isChecking,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SYSTEM OPERATIONAL DIAGNOSTICS · ${health.statusLabel}',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: ledColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            health.statusSummary,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFF5DEB3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final item in health.checks) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E131F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _colorForState(item.state).withValues(alpha: 0.7),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: _GlowingLedBeacon(
                            color: _colorForState(item.state),
                            size: 10,
                            isChecking: false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_tagForState(item.state)} · ${item.score}/${item.maxScore}',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                      color: _colorForState(item.state),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.detail,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10.5,
                                  color: Color(0xFFCBD5E1),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1019),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: const Text(
                          'GREEN 100%: All Live · YELLOW 75–99%: Fallback Active · RED <75%: Check Needed',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9.5,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5DEB3),
                    foregroundColor: const Color(0xFF07090E),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: health.isChecking
                      ? null
                      : () async {
                          HapticFeedback.mediumImpact();
                          await SystemHealthService.instance
                              .refreshHealthChecks();
                        },
                  icon: health.isChecking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF07090E),
                          ),
                        )
                      : const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    health.isChecking
                        ? 'CHECKING CORE SERVICES...'
                        : 'RE-CHECK SYSTEMS',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
