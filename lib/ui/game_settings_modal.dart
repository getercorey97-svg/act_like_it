import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import 'living_25d_animation_engine.dart';
import 'soundstage_audio_controller.dart';

/// Immutable configuration returned when the player taps "ROLL CAMERA"
/// inside `GameSettingsModal`.
class GameSettingsConfig {
  final bool aiTelemetricsEnabled;
  final bool peerJudgingEnabled;
  final bool socialJudgingEnabled;
  final bool improvRouletteWildcard;
  final bool screenTestDuetMode;
  final bool stoneFacedNoLaughHazard;
  final bool threeActBlockbusterTournament;
  final bool bigScreenPremiereHostView;
  final bool cleanBroadcastScreenShareMode;
  final bool lifeIsImprovMode;
  final bool speakeasyDoubleOrNothingSubtext;
  final int roundsCount;
  final String turnMode; // 'pass_and_play' | 'cross_internet_live'

  const GameSettingsConfig({
    this.aiTelemetricsEnabled = true,
    this.peerJudgingEnabled = true,
    this.socialJudgingEnabled = true,
    this.improvRouletteWildcard = false,
    this.screenTestDuetMode = false,
    this.stoneFacedNoLaughHazard = false,
    this.threeActBlockbusterTournament = false,
    this.bigScreenPremiereHostView = false,
    this.cleanBroadcastScreenShareMode = false,
    this.lifeIsImprovMode = false,
    this.speakeasyDoubleOrNothingSubtext = false,
    this.roundsCount = 3,
    this.turnMode = 'cross_internet_live',
  });

  GameSettingsConfig copyWith({
    bool? aiTelemetricsEnabled,
    bool? peerJudgingEnabled,
    bool? socialJudgingEnabled,
    bool? improvRouletteWildcard,
    bool? screenTestDuetMode,
    bool? stoneFacedNoLaughHazard,
    bool? threeActBlockbusterTournament,
    bool? bigScreenPremiereHostView,
    bool? cleanBroadcastScreenShareMode,
    bool? lifeIsImprovMode,
    bool? speakeasyDoubleOrNothingSubtext,
    int? roundsCount,
    String? turnMode,
  }) {
    return GameSettingsConfig(
      aiTelemetricsEnabled: aiTelemetricsEnabled ?? this.aiTelemetricsEnabled,
      peerJudgingEnabled: peerJudgingEnabled ?? this.peerJudgingEnabled,
      socialJudgingEnabled: socialJudgingEnabled ?? this.socialJudgingEnabled,
      improvRouletteWildcard:
          improvRouletteWildcard ?? this.improvRouletteWildcard,
      screenTestDuetMode: screenTestDuetMode ?? this.screenTestDuetMode,
      stoneFacedNoLaughHazard:
          stoneFacedNoLaughHazard ?? this.stoneFacedNoLaughHazard,
      threeActBlockbusterTournament:
          threeActBlockbusterTournament ?? this.threeActBlockbusterTournament,
      bigScreenPremiereHostView:
          bigScreenPremiereHostView ?? this.bigScreenPremiereHostView,
      cleanBroadcastScreenShareMode:
          cleanBroadcastScreenShareMode ?? this.cleanBroadcastScreenShareMode,
      lifeIsImprovMode: lifeIsImprovMode ?? this.lifeIsImprovMode,
      speakeasyDoubleOrNothingSubtext:
          speakeasyDoubleOrNothingSubtext ?? this.speakeasyDoubleOrNothingSubtext,
      roundsCount: roundsCount ?? this.roundsCount,
      turnMode: turnMode ?? this.turnMode,
    );
  }

  /// Dynamic Judging Weight Normalization:
  /// Base weights: AI = 45, Peer = 35, Social = 20.
  int get enabledWeightSum {
    final sum = (aiTelemetricsEnabled ? 45 : 0) +
        (peerJudgingEnabled ? 35 : 0) +
        (socialJudgingEnabled ? 20 : 0);
    return sum <= 0 ? 45 : sum;
  }

  double get actualAiWeight =>
      aiTelemetricsEnabled ? (45.0 / enabledWeightSum) * 100.0 : 0.0;

  double get actualPeerWeight =>
      peerJudgingEnabled ? (35.0 / enabledWeightSum) * 100.0 : 0.0;

  double get actualSocialWeight =>
      socialJudgingEnabled ? (20.0 / enabledWeightSum) * 100.0 : 0.0;
}

/// "The Call Sheet" Pre-Game Settings Modal designed for `showModalBottomSheet`.
/// Uses a zero-clutter dark obsidian aesthetic (`#07090E`), heavy padding
/// (`EdgeInsets.all(24.0)`), physical studio soundboard switches for Tri-Modal
/// Judging, an "Improv Roulette" Wildcard switch, and a massive neon-bordered
/// "ROLL CAMERA" CTA button. Also supports General Studio Console mode
/// (`isGeneralSettings: true`) for configuring audio volume, haptics, camera resolution,
/// and runtime Cloud API credentials.
class GameSettingsModal extends StatefulWidget {
  static GameSettingsConfig latestConfig = const GameSettingsConfig();
  static double masterAudioVolume = 0.35;
  static final ValueNotifier<double> volumeNotifier =
      ValueNotifier<double>(0.35);

  final String? modeTitle;
  final VoidCallback? onRollCamera;
  final int? totalCastCount;
  final bool isGeneralSettings;

  const GameSettingsModal({
    super.key,
    this.modeTitle,
    this.onRollCamera,
    this.totalCastCount,
    this.isGeneralSettings = false,
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
  bool _stoneFacedNoLaughHazard =
      GameSettingsModal.latestConfig.stoneFacedNoLaughHazard;
  bool _threeActBlockbusterTournament =
      GameSettingsModal.latestConfig.threeActBlockbusterTournament;
  bool _bigScreenPremiereHostView =
      GameSettingsModal.latestConfig.bigScreenPremiereHostView;
  bool _cleanBroadcastScreenShareMode =
      GameSettingsModal.latestConfig.cleanBroadcastScreenShareMode;
  int _roundsCount = GameSettingsModal.latestConfig.roundsCount;
  String _turnMode = GameSettingsModal.latestConfig.turnMode;

  late final TextEditingController _geminiCtrl;
  late final TextEditingController _supaUrlCtrl;
  late final TextEditingController _supaKeyCtrl;
  late final TextEditingController _liveKitCtrl;
  double _audioVolume = GameSettingsModal.masterAudioVolume;
  bool _hapticsEnabled = true;
  String _cameraResolution = '1080p60 Cinematic';
  bool _hasSavedCredentials = false;
  bool _showDeveloperDiagnostics = false;

  int get _enabledWeightSum {
    final isAiEnabled = _aiTelemetricsEnabled;
    final isPeerEnabled = _peerJudgingEnabled;
    final isSocialEnabled = _socialJudgingEnabled;
    final enabledWeightSum = (isAiEnabled ? 45 : 0) +
        (isPeerEnabled ? 35 : 0) +
        (isSocialEnabled ? 20 : 0);
    return enabledWeightSum <= 0 ? 45 : enabledWeightSum;
  }

  double get _actualAiWeight => !_aiTelemetricsEnabled &&
          !_peerJudgingEnabled &&
          !_socialJudgingEnabled
      ? 100.0
      : (_aiTelemetricsEnabled ? (45.0 / _enabledWeightSum) * 100.0 : 0.0);

  double get _actualPeerWeight =>
      _peerJudgingEnabled ? (35.0 / _enabledWeightSum) * 100.0 : 0.0;

  double get _actualSocialWeight =>
      _socialJudgingEnabled ? (20.0 / _enabledWeightSum) * 100.0 : 0.0;

  @override
  void initState() {
    super.initState();
    _geminiCtrl = TextEditingController(text: AppConfig.geminiApiKey);
    _supaUrlCtrl = TextEditingController(text: AppConfig.supabaseUrl);
    _supaKeyCtrl = TextEditingController(text: AppConfig.supabaseAnonKey);
    _liveKitCtrl = TextEditingController(text: AppConfig.liveKitUrl);
  }

  @override
  void dispose() {
    _geminiCtrl.dispose();
    _supaUrlCtrl.dispose();
    _supaKeyCtrl.dispose();
    _liveKitCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveCloudCredentials() async {
    HapticFeedback.mediumImpact();
    await AppConfig.saveRuntimeConfig(
      geminiKey: _geminiCtrl.text,
      supabaseProjectUrl: _supaUrlCtrl.text,
      supabaseKey: _supaKeyCtrl.text,
      liveKitServerUrl: _liveKitCtrl.text,
    );
    if (!mounted) return;
    setState(() => _hasSavedCredentials = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Runtime Cloud Credentials saved successfully to S26 Ultra Vault!',
          style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700),
        ),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _handleRollCamera() {
    HapticFeedback.heavyImpact();
    if (!_aiTelemetricsEnabled &&
        !_peerJudgingEnabled &&
        !_socialJudgingEnabled) {
      _aiTelemetricsEnabled = true;
    }
    final config = GameSettingsConfig(
      aiTelemetricsEnabled: _aiTelemetricsEnabled,
      peerJudgingEnabled: _peerJudgingEnabled,
      socialJudgingEnabled: _socialJudgingEnabled,
      improvRouletteWildcard: _improvRouletteWildcard,
      screenTestDuetMode: _screenTestDuetMode,
      stoneFacedNoLaughHazard: _stoneFacedNoLaughHazard,
      threeActBlockbusterTournament: _threeActBlockbusterTournament,
      bigScreenPremiereHostView: _bigScreenPremiereHostView,
      cleanBroadcastScreenShareMode: _cleanBroadcastScreenShareMode,
      lifeIsImprovMode: GameSettingsModal.latestConfig.lifeIsImprovMode,
      speakeasyDoubleOrNothingSubtext:
          GameSettingsModal.latestConfig.speakeasyDoubleOrNothingSubtext,
      roundsCount: _threeActBlockbusterTournament ? 3 : _roundsCount,
      turnMode: _turnMode,
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
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xF807090E),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: const Border(
                top: BorderSide(color: Color(0xFFF5DEB3), width: 3.0),
              ),
              boxShadow: [
                const BoxShadow(
                  color: Color(0xFF05070B),
                  offset: Offset(0, -6),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: const Color(0xFFE11342).withValues(alpha: 0.32),
                  blurRadius: 36,
                  spreadRadius: 2,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        24.0,
                        20.0,
                        24.0,
                        widget.isGeneralSettings
                            ? 24.0 + mediaQuery.viewInsets.bottom
                            : 12.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag Handle
                          Center(
                            child: Container(
                              width: 52,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5DEB3),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                  color: const Color(0xFF05070B),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (widget.isGeneralSettings) ...[
                            _buildGeneralSettingsConsole(),
                          ] else ...[
                            // Call Sheet Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF520002),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFF5DEB3),
                                      width: 2.2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFF05070B),
                                        offset: Offset(4, 4),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.tune_rounded,
                                    color: Color(0xFFF5DEB3),
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DIRECTOR\'S CALL SHEET · TOTAL CAST: ${widget.totalCastCount ?? 1} ${(widget.totalCastCount ?? 1) == 1 ? "PLAYER" : "PLAYERS"}',
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.2,
                                          color: Color(0xFFF5DEB3),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.modeTitle ?? 'STUDIO SOUNDBOARD',
                                        style: GoogleFonts.limelight(
                                          fontSize: 24,
                                          color: Colors.white,
                                          letterSpacing: 1.0,
                                          shadows: const [
                                            Shadow(
                                              color: Color(0xFFE11342),
                                              offset: Offset(2, 2),
                                              blurRadius: 0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
              const SizedBox(height: 28),

              // Section Label: Studio Judging Faders
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'TRI-MODAL JUDGING SOUNDBOARD',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: Color(0xFFF5DEB3),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x2610B981),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: Text(
                      'NORMALIZED: ${(_actualAiWeight + _actualPeerWeight + _actualSocialWeight).round()}% TOTAL',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Studio Toggle 1: AI Telemetrics
              _buildStudioSoundboardToggle(
                channelCode: _aiTelemetricsEnabled
                    ? 'CH 01 · ${_actualAiWeight.toStringAsFixed(1)}% NORMALIZED WEIGHT (BASE 45%)'
                    : 'CH 01 · 0.0% WEIGHT (BYPASSED)',
                title: 'AI Telemetrics (${_actualAiWeight.round()}%)',
                subtitle: 'Gemini facial micro-expressions & vocal prosody scan',
                icon: Icons.psychology_alt_rounded,
                neonColor: const Color(0xFFE11342),
                value: _aiTelemetricsEnabled,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _aiTelemetricsEnabled = val;
                    if (!_aiTelemetricsEnabled &&
                        !_peerJudgingEnabled &&
                        !_socialJudgingEnabled) {
                      _aiTelemetricsEnabled = true;
                    }
                  });
                },
              ),
              const SizedBox(height: 20),

              // Studio Toggle 2: Peer Judging
              _buildStudioSoundboardToggle(
                channelCode: _peerJudgingEnabled
                    ? 'CH 02 · ${_actualPeerWeight.toStringAsFixed(1)}% NORMALIZED WEIGHT (BASE 35%)'
                    : 'CH 02 · 0.0% WEIGHT (BYPASSED)',
                title: 'Peer Judging (${_actualPeerWeight.round()}%)',
                subtitle: 'Screening Room loop replay & 1–10 ensemble vote',
                icon: Icons.thumbs_up_down_rounded,
                neonColor: const Color(0xFF0CB6D4),
                value: _peerJudgingEnabled,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _peerJudgingEnabled = val;
                    if (!_aiTelemetricsEnabled &&
                        !_peerJudgingEnabled &&
                        !_socialJudgingEnabled) {
                      _aiTelemetricsEnabled = true;
                    }
                  });
                },
              ),
              const SizedBox(height: 20),

              // Studio Toggle 3: Social Judging
              _buildStudioSoundboardToggle(
                channelCode: _socialJudgingEnabled
                    ? 'CH 03 · ${_actualSocialWeight.toStringAsFixed(1)}% NORMALIZED WEIGHT (BASE 20%)'
                    : 'CH 03 · 0.0% WEIGHT (BYPASSED)',
                title: 'Social Judging (${_actualSocialWeight.round()}%)',
                subtitle: 'External clip shares & crowd reaction multiplier',
                icon: Icons.share_arrival_time_rounded,
                neonColor: const Color(0xFFF5DEB3),
                value: _socialJudgingEnabled,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _socialJudgingEnabled = val;
                    if (!_aiTelemetricsEnabled &&
                        !_peerJudgingEnabled &&
                        !_socialJudgingEnabled) {
                      _aiTelemetricsEnabled = true;
                    }
                  });
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
                  color: Color(0xFFF5DEB3),
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
                    'Splits the teleprompter into Lead A (Limelight Gold) & Lead B (Soundstage Cyan) lines',
                icon: Icons.people_alt_rounded,
                neonColor: const Color(0xFF0CB6D4),
                value: _screenTestDuetMode,
                onChanged: (val) {
                  HapticFeedback.mediumImpact();
                  setState(() => _screenTestDuetMode = val);
                },
              ),
              const SizedBox(height: 18),

              // Fixture #4: Break Character / No-Laugh Hazard Setting
              _buildStudioSoundboardToggle(
                channelCode: 'HAZARD · 1.20x STONE-FACED BONUS / -15 PT BREAK',
                title: 'Stone-Faced Method Mode (No-Laugh Hazard)',
                subtitle:
                    'Stay deadpan while spectators hurl tomatoes & roses! Cracking a laugh triggers a -15 pt siren; surviving awards 1.20x!',
                icon: Icons.sentiment_neutral_rounded,
                neonColor: const Color(0xFFE11342),
                value: _stoneFacedNoLaughHazard,
                onChanged: (val) {
                  HapticFeedback.mediumImpact();
                  setState(() => _stoneFacedNoLaughHazard = val);
                },
              ),
              const SizedBox(height: 18),

              // Fixture #8: The 3-Act Blockbuster Tournament Mode
              _buildStudioSoundboardToggle(
                channelCode: 'TOURNAMENT · ACT I CATTLE CALL → ACT II DUET → ACT III 1.25x FINALE',
                title: 'The 3-Act Blockbuster Tournament',
                subtitle:
                    'Structured 3-Act arc: Act I Solo Warm-Up, Act II Chemistry Read Duets, and Act III Director\'s Cut Finale (1.25x Weight + Double Curveballs)',
                icon: Icons.emoji_events_rounded,
                neonColor: const Color(0xFFF5DEB3),
                value: _threeActBlockbusterTournament,
                onChanged: (val) {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _threeActBlockbusterTournament = val;
                    if (val) _roundsCount = 3;
                  });
                },
              ),
              const SizedBox(height: 18),

              // Fixture #12: Big Screen Premiere Mode (TV / Laptop / Samsung DeX / Screen-Share)
              _buildStudioSoundboardToggle(
                channelCode: 'BIG SCREEN · TV / SAMSUNG DeX / SCREEN-SHARE HOST VIEW',
                title: '📺 TV / DeX / Screen-Share Host View',
                subtitle:
                    '3-pane Studio Control Deck on wide displays + keyboard shortcuts (Spacebar = Roll/Cut, 1–0 = Peer Score)',
                icon: Icons.tv_rounded,
                neonColor: const Color(0xFF0CB6D4),
                value: _bigScreenPremiereHostView,
                onChanged: (val) {
                  HapticFeedback.mediumImpact();
                  setState(() => _bigScreenPremiereHostView = val);
                },
              ),
              const SizedBox(height: 14),
              _buildStudioSoundboardToggle(
                channelCode: 'STREAM SAFE · ZOOM / DISCORD / TWITCH / SMART VIEW',
                title: '📡 Clean Broadcast / Screen-Share Mode',
                subtitle:
                    'Locks high-contrast 16:9 framing, hides floating debug/QA chrome & routes echo-free IN_COMMUNICATION audio',
                icon: Icons.cast_connected_rounded,
                neonColor: const Color(0xFF10B981),
                value: _cleanBroadcastScreenShareMode,
                onChanged: (val) {
                  HapticFeedback.mediumImpact();
                  setState(() => _cleanBroadcastScreenShareMode = val);
                },
              ),
              const SizedBox(height: 22),

              // Section Label: Match Structure & Multiplayer Rules
              const Text(
                'MATCH LENGTH & ENSEMBLE TURN MODE',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: Color(0xFFF5DEB3),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D111C),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF1E293B),
                    width: 2.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OFFICIAL ROUNDS PER MATCH',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [1, 3, 5].map((int r) {
                        final bool selected = _roundsCount == r;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: r == 5 ? 0 : 8),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _roundsCount = r);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0x28F59E0B)
                                      : const Color(0xFF07090E),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selected
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFF1E293B),
                                    width: 1.6,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  r == 1
                                      ? '1 ROUND (QUICK)'
                                      : '$r ROUNDS',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    color: selected
                                        ? const Color(0xFFF5DEB3)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'MULTIPLAYER TURN SYNCHRONIZATION',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(
                                () => _turnMode = 'cross_internet_live',
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _turnMode == 'cross_internet_live'
                                    ? const Color(0x260CB6D4)
                                    : const Color(0xFF07090E),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _turnMode == 'cross_internet_live'
                                      ? const Color(0xFF0CB6D4)
                                      : const Color(0xFF1E293B),
                                  width: 1.6,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '🌐 CROSS-INTERNET LIVE',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _turnMode = 'pass_and_play');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _turnMode == 'pass_and_play'
                                    ? const Color(0x26E11342)
                                    : const Color(0xFF07090E),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _turnMode == 'pass_and_play'
                                      ? const Color(0xFFE11342)
                                      : const Color(0xFF1E293B),
                                  width: 1.6,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '📱 COUCH PASS & PLAY',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ],
            ],
            ),
          ),
        ),
        if (!widget.isGeneralSettings)
          Container(
            padding: EdgeInsets.fromLTRB(
              24.0,
              10.0,
              24.0,
              18.0 + mediaQuery.viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFA07090E),
              border: Border(
                top: BorderSide(color: Color(0xFF1E293B), width: 1.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'SCROLL FOR MORE STUDIO FADERS ↑↓',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _handleRollCamera,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE11342),
                          Color(0xFF520002),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFF5DEB3),
                        width: 2.8,
                      ),
                      boxShadow: [
                        const BoxShadow(
                          color: Color(0xFF05070B),
                          offset: Offset(6, 6),
                          blurRadius: 0,
                        ),
                        BoxShadow(
                          color:
                              const Color(0xFFE11342).withValues(alpha: 0.55),
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
                          color: Color(0xFFF5DEB3),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'ROLL CAMERA',
                          style: GoogleFonts.limelight(
                            fontSize: 22,
                            color: Colors.white,
                            letterSpacing: 2.0,
                            shadows: const [
                              Shadow(
                                color: Color(0xFF05070B),
                                offset: Offset(2.5, 2.5),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  ),
),
),
),
    );
  }

  Widget _buildGeneralSettingsConsole() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // General Settings Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x2606B6D4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF06B6D4),
                  width: 1.4,
                ),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Color(0xFF06B6D4),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DIRECTOR\'S STUDIO CONSOLE · S26 ULTRA',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Color(0xFF06B6D4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'STUDIO HARDWARE & KEYS',
                    style: GoogleFonts.limelight(
                      fontSize: 22,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Section 1: Audio Volume & Haptics
        const Text(
          'STUDIO AUDIO & HAPTICS',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0E17),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Soundstage Master Volume',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${(_audioVolume * 100).round()}%',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
              Slider(
                value: _audioVolume,
                activeColor: const Color(0xFFF59E0B),
                inactiveColor: const Color(0xFF1E293B),
                onChanged: (v) {
                  setState(() => _audioVolume = v);
                  GameSettingsModal.masterAudioVolume = v;
                  GameSettingsModal.volumeNotifier.value = v;
                  SoundstageAudioController.instance.setMasterVolume(v);
                },
              ),
              const SizedBox(height: 8),
              SoundstageAudioConsoleBar(
                zone: SoundstageAudioController.instance.activeZone,
                compact: true,
              ),
              const Divider(color: Color(0xFF1E293B), height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paparazzi Touch Haptics',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'S26 Ultra tactile kick on stanchions & rolls',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: _hapticsEnabled,
                    activeColor: const Color(0xFF06B6D4),
                    onChanged: (v) {
                      HapticFeedback.mediumImpact();
                      setState(() => _hapticsEnabled = v);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section 2: Camera Hardware Profile
        const Text(
          'CAMERA HARDWARE PROFILE',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('1080p60 Cinema'),
                selected: _cameraResolution == '1080p60 Cinematic',
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  setState(() => _cameraResolution = '1080p60 Cinematic');
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChoiceChip(
                label: const Text('720p30 Rapid SFU'),
                selected: _cameraResolution == '720p30 Rapid SFU',
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  setState(() => _cameraResolution = '720p30 Rapid SFU');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Section 3: Collapsed Developer Diagnostics Accordion (Locked by Default)
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0B0E17),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _showDeveloperDiagnostics
                  ? const Color(0xFF06B6D4)
                  : const Color(0xFF1E293B),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _showDeveloperDiagnostics = !_showDeveloperDiagnostics;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _showDeveloperDiagnostics
                            ? Icons.lock_open_rounded
                            : Icons.lock_outline_rounded,
                        size: 18,
                        color: const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'DEVELOPER DIAGNOSTICS (LOCKED)',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      Icon(
                        _showDeveloperDiagnostics
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showDeveloperDiagnostics)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _geminiCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'GEMINI_API_KEY (AI Telemetrics)',
                          filled: true,
                          fillColor: Color(0xFF07090E),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _supaUrlCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'SUPABASE_URL (https://xxx.supabase.co)',
                          filled: true,
                          fillColor: Color(0xFF07090E),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _supaKeyCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'SUPABASE_ANON_KEY',
                          filled: true,
                          fillColor: Color(0xFF07090E),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _liveKitCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'LIVEKIT_URL (wss://xxx.livekit.cloud)',
                          filled: true,
                          fillColor: Color(0xFF07090E),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF06B6D4),
                          foregroundColor: const Color(0xFF07090E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _saveCloudCredentials,
                        icon: Icon(
                          _hasSavedCredentials
                              ? Icons.check_circle_rounded
                              : Icons.save_rounded,
                          size: 18,
                        ),
                        label: Text(
                          _hasSavedCredentials
                              ? 'CREDENTIALS SAVED TO VAULT'
                              : 'SAVE RUNTIME CLOUD CREDENTIALS',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  String _duetCoStarPreference = 'ai_costar_tts';
  String _stoneFacedTomatoSensitivity = 'standard_15pt';
  int _blockbusterPreviewAct = 1;

  Widget _buildCallSheet25DHeaderBanner({
    required String title,
    required Color neonColor,
    required bool isEnabled,
  }) {
    final lower = title.toLowerCase();
    if (lower.contains('screen test duet')) {
      return Container(
        height: 112,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF07090E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isEnabled ? neonColor : const Color(0xFF1E293B),
            width: 1.6,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            const SizedBox(
              width: 148,
              height: 112,
              child: DuetRivalsSplitPortraitRig(phase: 1.25),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x260CB6D4),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF0CB6D4)),
                      ),
                      child: const Text(
                        'LEAD A (GOLD) VS. LEAD B (CYAN)',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFF5DEB3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Lead A & Lead B — Screen Test Rivals',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _duetCoStarPreference == 'ai_costar_tts'
                          ? 'Sub-Mode: AI Co-Star with TTS Voice Lines'
                          : 'Sub-Mode: Live 2-Player Split-Screen Co-Star',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9.5,
                        color: Color(0xFF0CB6D4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    String bannerBadge = '2.5D SOUNDSTAGE TELEMETRY DECK';
    String bannerGraphicTitle = 'Real-Time 60fps Studio Rig';
    IconData primaryGraphicIcon = Icons.graphic_eq_rounded;
    IconData secondaryGraphicIcon = Icons.auto_awesome_rounded;

    if (lower.contains('stone-faced')) {
      bannerBadge = '2.5D DEADPAN STARE VS. FLYING TOMATOES & SIREN';
      bannerGraphicTitle = 'Zero-Smirk Facial Lock (1.20x) · -15 Pt Siren';
      primaryGraphicIcon = Icons.sentiment_neutral_rounded;
      secondaryGraphicIcon = Icons.crisis_alert_rounded;
    } else if (lower.contains('3-act blockbuster')) {
      bannerBadge = '2.5D 24K GOLDEN STATUETTE & 3-ACT FILM REEL';
      bannerGraphicTitle = 'Act I Setup → Act II Twist → Act III 1.50x Climax';
      primaryGraphicIcon = Icons.emoji_events_rounded;
      secondaryGraphicIcon = Icons.movie_filter_rounded;
    } else if (lower.contains('tv / dex') || lower.contains('clean broadcast')) {
      bannerBadge = '2.5D 3-MONITOR STUDIO CONTROL DECK';
      bannerGraphicTitle = '16:9 Widescreen HDMI / DeX / Stream-Safe Output';
      primaryGraphicIcon = Icons.desktop_windows_rounded;
      secondaryGraphicIcon = Icons.cast_connected_rounded;
    } else if (lower.contains('ai telemetrics')) {
      bannerBadge = '2.5D GEMINI 2.5 FLASH TELEMETRY WAVEFORM';
      bannerGraphicTitle =
          'Normalized Weight: ${_actualAiWeight.toStringAsFixed(1)}% (Total 100%)';
      primaryGraphicIcon = Icons.psychology_alt_rounded;
      secondaryGraphicIcon = Icons.multitrack_audio_rounded;
    } else if (lower.contains('peer judging')) {
      bannerBadge = '2.5D ENSEMBLE SCREENING ROOM SPOTLIGHT';
      bannerGraphicTitle =
          'Normalized Weight: ${_actualPeerWeight.toStringAsFixed(1)}% (Total 100%)';
      primaryGraphicIcon = Icons.thumbs_up_down_rounded;
      secondaryGraphicIcon = Icons.groups_3_rounded;
    } else if (lower.contains('social judging')) {
      bannerBadge = '2.5D CUTTING ROOM VIRAL REEL METER';
      bannerGraphicTitle =
          'Normalized Weight: ${_actualSocialWeight.toStringAsFixed(1)}% (Total 100%)';
      primaryGraphicIcon = Icons.local_fire_department_rounded;
      secondaryGraphicIcon = Icons.share_arrival_time_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            neonColor.withValues(alpha: isEnabled ? 0.22 : 0.08),
            const Color(0xFF07090E),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled
              ? neonColor.withValues(alpha: 0.75)
              : const Color(0xFF1E293B),
          width: 1.4,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF07090E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: neonColor, width: 1.5),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(primaryGraphicIcon, color: neonColor, size: 22),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Icon(
                    secondaryGraphicIcon,
                    color: const Color(0xFFF5DEB3),
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bannerBadge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: neonColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bannerGraphicTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
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

  Future<void> _openDedicatedModeSubPage({
    required String title,
    required String channelCode,
    required String subtitle,
    required Color neonColor,
    required bool currentValue,
    required ValueChanged<bool> onChanged,
  }) async {
    HapticFeedback.mediumImpact();
    SoundstageAudioController.instance.playClapperboardSnap();
    final lower = title.toLowerCase();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF07090E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        bool sheetToggleVal = currentValue;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '📖 DEDICATED MODE PAGE & OFFICIAL RULES',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: neonColor,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(sheetCtx).pop(),
                            icon: const Icon(Icons.close, color: Colors.white70),
                          ),
                        ],
                      ),
                      _buildCallSheet25DHeaderBanner(
                        title: title,
                        neonColor: neonColor,
                        isEnabled: sheetToggleVal,
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Scoring & Rules Breakdown Table
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1320),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: neonColor.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📊 SCORING MULTIPLIERS, RULES & WEIGHTS',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: neonColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildModeRuleRow(
                              'Channel Spec',
                              channelCode,
                              neonColor,
                            ),
                            _buildModeRuleRow(
                              'Normalized Blend',
                              'AI ${_actualAiWeight.round()}% · Peer ${_actualPeerWeight.round()}% · Social ${_actualSocialWeight.round()}% (Total 100%)',
                              const Color(0xFFF5DEB3),
                            ),
                            if (lower.contains('screen test duet'))
                              _buildModeRuleRow(
                                'Duet Split & Bonus',
                                '50/50 Lead A (Gold) vs Lead B (Cyan) · +250 Scene Stealer XP',
                                const Color(0xFF0CB6D4),
                              ),
                            if (lower.contains('stone-faced'))
                              _buildModeRuleRow(
                                'Hazard Multiplier',
                                '1.20x Unbroken Deadpan Bonus · -15.0 Pts Smirk Siren',
                                const Color(0xFFE11342),
                              ),
                            if (lower.contains('3-act blockbuster'))
                              _buildModeRuleRow(
                                '3-Act Arc Weights',
                                'Act I (1.0x) → Act II (+5.0 Twist) → Act III Climax (1.50x)',
                                const Color(0xFFFFD700),
                              ),
                            if (lower.contains('curveball'))
                              _buildModeRuleRow(
                                '15s Director Twist',
                                'Fires at 00:15 into 30s take · +5.0 Bonus Points',
                                const Color(0xFFE11342),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Mode-Specific Interactive Sub-Options
                      if (lower.contains('screen test duet')) ...[
                        const Text(
                          '🎭 DUET CO-STAR CONFIGURATION:',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFF5DEB3),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text(
                                '🤖 AI Co-Star with Live TTS Voice',
                              ),
                              selected:
                                  _duetCoStarPreference == 'ai_costar_tts',
                              onSelected: (_) {
                                setState(() {
                                  _duetCoStarPreference = 'ai_costar_tts';
                                });
                                setSheetState(() {});
                              },
                            ),
                            ChoiceChip(
                              label: const Text(
                                '👥 Live 2-Player Co-Star (SFU / Couch)',
                              ),
                              selected: _duetCoStarPreference == 'live_costar',
                              onSelected: (_) {
                                setState(() {
                                  _duetCoStarPreference = 'live_costar';
                                });
                                setSheetState(() {});
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (lower.contains('stone-faced')) ...[
                        const Text(
                          '🍅 TOMATO HECKLE & SMIRK SENSITIVITY:',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFF5DEB3),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Standard (-15 Pts on Smirk)'),
                              selected: _stoneFacedTomatoSensitivity ==
                                  'standard_15pt',
                              onSelected: (_) {
                                setState(() {
                                  _stoneFacedTomatoSensitivity =
                                      'standard_15pt';
                                });
                                setSheetState(() {});
                              },
                            ),
                            ChoiceChip(
                              label: const Text(
                                'Hardcore Method (-25 Pts / 1.30x)',
                              ),
                              selected: _stoneFacedTomatoSensitivity ==
                                  'hardcore_25pt',
                              onSelected: (_) {
                                setState(() {
                                  _stoneFacedTomatoSensitivity =
                                      'hardcore_25pt';
                                });
                                setSheetState(() {});
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (lower.contains('3-act blockbuster')) ...[
                        const Text(
                          '🎬 PREVIEW 3-ACT TOURNAMENT STRUCTURE:',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFF5DEB3),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [1, 2, 3].map((act) {
                            return ChoiceChip(
                              label: Text(
                                act == 1
                                    ? 'Act I: Cold Open (1.0x)'
                                    : (act == 2
                                        ? 'Act II: Plot Twist (+5.0)'
                                        : 'Act III: Climax (1.50x)'),
                              ),
                              selected: _blockbusterPreviewAct == act,
                              onSelected: (_) {
                                setState(() => _blockbusterPreviewAct = act);
                                setSheetState(() {});
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                      ],
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: neonColor,
                          foregroundColor: const Color(0xFF07090E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          final nextVal = !sheetToggleVal;
                          sheetToggleVal = nextVal;
                          onChanged(nextVal);
                          setSheetState(() {});
                          Navigator.of(sheetCtx).pop();
                        },
                        icon: Icon(
                          sheetToggleVal
                              ? Icons.toggle_off_rounded
                              : Icons.check_circle_rounded,
                        ),
                        label: Text(
                          sheetToggleVal
                              ? 'TURN MODE OFF & RETURN TO CALL SHEET'
                              : 'ENABLE MODE ON CALL SHEET',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModeRuleRow(String label, String val, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              val,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: accent,
              ),
            ),
          ),
        ],
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: value ? const Color(0xFF101624) : const Color(0xFF07090E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: value ? neonColor : const Color(0xFF1E293B),
          width: value ? 2.2 : 2.0,
        ),
        boxShadow: [
          const BoxShadow(
            color: Color(0xFF05070B),
            offset: Offset(5, 5),
            blurRadius: 0,
          ),
          if (value)
            BoxShadow(
              color: neonColor.withValues(alpha: 0.24),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openDedicatedModeSubPage(
              title: title,
              channelCode: channelCode,
              subtitle: subtitle,
              neonColor: neonColor,
              currentValue: value,
              onChanged: onChanged,
            ),
            child: _buildCallSheet25DHeaderBanner(
              title: title,
              neonColor: neonColor,
              isEnabled: value,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => _openDedicatedModeSubPage(
                  title: title,
                  channelCode: channelCode,
                  subtitle: subtitle,
                  neonColor: neonColor,
                  currentValue: value,
                  onChanged: onChanged,
                ),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: value
                        ? neonColor.withValues(alpha: 0.18)
                        : const Color(0xFF151C2C),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: value
                          ? neonColor.withValues(alpha: 0.9)
                          : const Color(0xFF05070B),
                      width: 2.0,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: value ? neonColor : const Color(0xFF64748B),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openDedicatedModeSubPage(
                    title: title,
                    channelCode: channelCode,
                    subtitle: subtitle,
                    neonColor: neonColor,
                    currentValue: value,
                    onChanged: onChanged,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        channelCode,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.9,
                          color: value ? neonColor : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: neonColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: neonColor.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Text(
                          '📖 Mode Page & Rules >',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: neonColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Switch.adaptive(
                value: value,
                activeColor: neonColor,
                onChanged: onChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImprovWildcardCard() {
    const wildcardColor = Color(0xFFE11342);
    return _buildStudioSoundboardToggle(
      channelCode: 'WILDCARD · IMPROV ROULETTE (+5.0 TWIST BONUS)',
      title: 'Random Director Curveballs',
      subtitle:
          'Injects surprise mid-scene emotional twists & genre modifiers at 00:15 for +5.0 bonus multiplier points.',
      icon: Icons.casino_rounded,
      neonColor: wildcardColor,
      value: _improvRouletteWildcard,
      onChanged: (val) {
        HapticFeedback.mediumImpact();
        setState(() => _improvRouletteWildcard = val);
      },
    );
  }
}
