import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Immutable configuration returned when the player taps "ROLL CAMERA"
/// inside `GameSettingsModal`.
class GameSettingsConfig {
  final bool aiTelemetricsEnabled;
  final bool peerJudgingEnabled;
  final bool socialJudgingEnabled;
  final bool improvRouletteWildcard;
  final bool screenTestDuetMode;

  const GameSettingsConfig({
    this.aiTelemetricsEnabled = true,
    this.peerJudgingEnabled = true,
    this.socialJudgingEnabled = true,
    this.improvRouletteWildcard = false,
    this.screenTestDuetMode = false,
  });
}

/// "The Call Sheet" Pre-Game Settings Modal designed for `showModalBottomSheet`.
/// Uses a zero-clutter dark obsidian aesthetic (`#07090E`), heavy padding
/// (`EdgeInsets.all(24.0)`), physical studio soundboard switches for Tri-Modal
/// Judging, an "Improv Roulette" Wildcard switch, and a massive neon-bordered
/// "ROLL CAMERA" CTA button.
class GameSettingsModal extends StatefulWidget {
  static GameSettingsConfig latestConfig = const GameSettingsConfig();

  final String? modeTitle;
  final VoidCallback? onRollCamera;

  const GameSettingsModal({
    super.key,
    this.modeTitle,
    this.onRollCamera,
  });

  @override
  State<GameSettingsModal> createState() => _GameSettingsModalState();
}

class _GameSettingsModalState extends State<GameSettingsModal> {
  bool _aiTelemetricsEnabled = GameSettingsModal.latestConfig.aiTelemetricsEnabled;
  bool _peerJudgingEnabled = GameSettingsModal.latestConfig.peerJudgingEnabled;
  bool _socialJudgingEnabled = GameSettingsModal.latestConfig.socialJudgingEnabled;
  bool _improvRouletteWildcard =
      GameSettingsModal.latestConfig.improvRouletteWildcard;
  bool _screenTestDuetMode = GameSettingsModal.latestConfig.screenTestDuetMode;

  void _handleRollCamera() {
    HapticFeedback.heavyImpact();
    final config = GameSettingsConfig(
      aiTelemetricsEnabled: _aiTelemetricsEnabled,
      peerJudgingEnabled: _peerJudgingEnabled,
      socialJudgingEnabled: _socialJudgingEnabled,
      improvRouletteWildcard: _improvRouletteWildcard,
      screenTestDuetMode: _screenTestDuetMode,
    );
    GameSettingsModal.latestConfig = config;
    Navigator.of(context).pop(config);
    widget.onRollCamera?.call();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.88,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF07090E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: const Border(
            top: BorderSide(color: Color(0xFFF59E0B), width: 2.0),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE11D48).withValues(alpha: 0.28),
              blurRadius: 36,
              spreadRadius: 2,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              24.0,
              24.0,
              24.0,
              24.0 + mediaQuery.viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Call Sheet Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0x26F59E0B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFF59E0B),
                        width: 1.4,
                      ),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Color(0xFFF59E0B),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DIRECTOR\'S CALL SHEET · PRE-GAME SETUP',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.modeTitle ?? 'STUDIO SOUNDBOARD',
                          style: GoogleFonts.limelight(
                            fontSize: 24,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Section Label: Studio Judging Faders
              const Text(
                'TRI-MODAL JUDGING SOUNDBOARD',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 16),

              // Studio Toggle 1: AI Telemetrics
              _buildStudioSoundboardToggle(
                channelCode: 'CH 01 · 45% WEIGHT',
                title: 'AI Telemetrics',
                subtitle: 'Gemini facial micro-expressions & vocal prosody scan',
                icon: Icons.psychology_alt_rounded,
                neonColor: const Color(0xFFE11D48),
                value: _aiTelemetricsEnabled,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  setState(() => _aiTelemetricsEnabled = val);
                },
              ),
              const SizedBox(height: 20),

              // Studio Toggle 2: Peer Judging
              _buildStudioSoundboardToggle(
                channelCode: 'CH 02 · 35% WEIGHT',
                title: 'Peer Judging',
                subtitle: 'Continuous Supabase loop replay & 1–10 spectator vote',
                icon: Icons.thumbs_up_down_rounded,
                neonColor: const Color(0xFF06B6D4),
                value: _peerJudgingEnabled,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  setState(() => _peerJudgingEnabled = val);
                },
              ),
              const SizedBox(height: 20),

              // Studio Toggle 3: Social Judging
              _buildStudioSoundboardToggle(
                channelCode: 'CH 03 · 20% WEIGHT',
                title: 'Social Judging',
                subtitle: 'External clip shares & crowd reaction multiplier',
                icon: Icons.share_arrival_time_rounded,
                neonColor: const Color(0xFFF59E0B),
                value: _socialJudgingEnabled,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  setState(() => _socialJudgingEnabled = val);
                },
              ),
              const SizedBox(height: 28),

              // Section Label: Improv Roulette Wildcard
              const Text(
                'STAGE MODIFIER · IMPROV ROULETTE',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 16),

              // Improv Roulette Wildcard Toggle
              _buildImprovWildcardCard(),
              const SizedBox(height: 18),

              // Screen Test Duet (2-Player Co-Star / Versus Mode) Toggle
              _buildStudioSoundboardToggle(
                channelCode: 'DUET MODE · +250 PTS SCENE STEALER BONUS',
                title: 'Screen Test Duet (2-Player Co-Star Mode)',
                subtitle:
                    'Splits the teleprompter into Lead A (Spotlight Gold) & Lead B (Soundstage Cyan) lines',
                icon: Icons.people_alt_rounded,
                neonColor: const Color(0xFF10B981),
                value: _screenTestDuetMode,
                onChanged: (val) {
                  HapticFeedback.mediumImpact();
                  setState(() => _screenTestDuetMode = val);
                },
              ),
              const SizedBox(height: 32),

              // Massive Neon-Bordered "ROLL CAMERA" Action Button
              GestureDetector(
                onTap: _handleRollCamera,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE11D48),
                        Color(0xFFB91C1C),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFF59E0B),
                      width: 2.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE11D48).withValues(alpha: 0.55),
                        blurRadius: 24,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.videocam_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'ROLL CAMERA',
                        style: GoogleFonts.limelight(
                          fontSize: 22,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudioSoundboardToggle({
    required String channelCode,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color neonColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF101624) : const Color(0xFF0B0E17),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: value ? neonColor : const Color(0xFF1E293B),
            width: value ? 1.8 : 1.2,
          ),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: neonColor.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : const [],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: value
                    ? neonColor.withValues(alpha: 0.18)
                    : const Color(0xFF151C2C),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: value
                      ? neonColor.withValues(alpha: 0.8)
                      : const Color(0xFF334155),
                ),
              ),
              child: Icon(
                icon,
                color: value ? neonColor : const Color(0xFF64748B),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channelCode,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: value ? neonColor : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch.adaptive(
              value: value,
              activeColor: neonColor,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImprovWildcardCard() {
    const wildcardColor = Color(0xFFA855F7);
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() => _improvRouletteWildcard = !_improvRouletteWildcard);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _improvRouletteWildcard
                ? const [
                    Color(0xFF1F1135),
                    Color(0xFF110C1D),
                  ]
                : const [
                    Color(0xFF0D111C),
                    Color(0xFF090C14),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _improvRouletteWildcard
                ? wildcardColor
                : const Color(0xFF334155),
            width: _improvRouletteWildcard ? 2.0 : 1.2,
          ),
          boxShadow: _improvRouletteWildcard
              ? [
                  BoxShadow(
                    color: wildcardColor.withValues(alpha: 0.35),
                    blurRadius: 22,
                    spreadRadius: 1,
                  ),
                ]
              : const [],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: wildcardColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: wildcardColor, width: 1.5),
              ),
              child: const Icon(
                Icons.casino_rounded,
                color: wildcardColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WILDCARD · IMPROV ROULETTE',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: wildcardColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Random Director Curveballs',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Injects surprise mid-scene emotional twists & genre modifiers for bonus multiplier points.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch.adaptive(
              value: _improvRouletteWildcard,
              activeColor: wildcardColor,
              onChanged: (val) {
                HapticFeedback.mediumImpact();
                setState(() => _improvRouletteWildcard = val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
