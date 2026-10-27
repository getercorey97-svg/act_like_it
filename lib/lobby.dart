import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'webrtc_manager.dart';
import 'offline_manager.dart';
import 'match_history_screen.dart';
import 'ui/game_app_bar.dart';
import 'ui/tutorial_overlay.dart';
import 'ui/game_settings_modal.dart';
import 'ui/scene_vault_screen.dart';
import 'ui/lobby_models_and_realtime.dart';
import 'ui/premiere_doors_marquee.dart';
import 'ui/premiere_red_carpet_painters.dart';
import 'ui/parody_scenes_catalog.dart';
import 'ui/boondocks_character_rig.dart';
import 'ui/living_25d_animation_engine.dart';
import 'auth/auth_service.dart';

export 'ui/lobby_models_and_realtime.dart';
export 'ui/premiere_doors_marquee.dart';
export 'ui/premiere_red_carpet_painters.dart';
export 'ui/living_25d_animation_engine.dart';

class LobbyMatchmakingScreen extends StatefulWidget {
  final SceneCategory initialCategory;
  final bool startInJoinMode;
  final ScenePrompt? initialPromptOverride;
  final bool autoCreateOnInit;

  const LobbyMatchmakingScreen({
    super.key,
    this.initialCategory = SceneCategory.era1970To1999,
    this.startInJoinMode = false,
    this.initialPromptOverride,
    this.autoCreateOnInit = false,
  });

  @override
  State<LobbyMatchmakingScreen> createState() => _LobbyMatchmakingScreenState();
}

class _LobbyMatchmakingScreenState extends State<LobbyMatchmakingScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final LobbyRealtimeManager _lobbyManager;
  late final ScrollController _parallaxScrollController;
  late final AnimationController _paparazziFlashController;
  late final AnimationController _frenzyBurstController;

  double _scrollOffset = 0.0;
  double _scrollVelocity = 0.0;
  int _lastStanchionTickIndex = 0;
  Offset? _activeTouchPosition;

  late final TextEditingController _nameController = TextEditingController(
    text: AuthService.instance.currentProfile?.username.isNotEmpty == true
        ? AuthService.instance.currentProfile!.username
        : 'StageStar',
  );
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  late SceneCategory _selectedCategory;
  late bool _isJoinMode;
  String? _detectedClipboardCode;
  String? _savedActiveRoomCode;
  int _telemetricsTokens = 25;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedCategory = widget.initialCategory;
    _isJoinMode = widget.startInJoinMode;
    _lobbyManager = LobbyRealtimeManager(
      localDisplayName: _nameController.text,
    );
    _lobbyManager.addListener(_onLobbyStateChanged);
    _codeController.addListener(() {
      if (mounted) setState(() {});
    });

    _parallaxScrollController = ScrollController()
      ..addListener(_onParallaxScroll);

    _paparazziFlashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    _frenzyBurstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    OfflineManager.instance.ensureInitialized();
    _loadVipSessionAndClipboard();
  }

  Future<void> _loadVipSessionAndClipboard() async {
    final activeCode = await LobbyRealtimeManager.loadActiveRoomSession();
    final tokens = await LobbyRealtimeManager.loadTelemetricsTokens();
    final profileName = AuthService.instance.currentProfile?.username.trim();
    if (profileName != null && profileName.isNotEmpty && mounted) {
      _nameController.text = profileName;
    } else {
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedActor = prefs.getString('act_like_it_saved_actor_name');
        if (savedActor != null &&
            savedActor.trim().isNotEmpty &&
            savedActor.trim() != 'Galaxy S26 Actor' &&
            mounted) {
          _nameController.text = savedActor.trim();
        }
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _savedActiveRoomCode = activeCode;
        _telemetricsTokens = tokens;
      });
    }
    await _checkClipboardForSixDigitCode();
    if (mounted && widget.autoCreateOnInit && !widget.startInJoinMode) {
      await _lobbyManager.createLobby(
        displayName: _nameController.text,
        category: _selectedCategory,
        preselectedPrompt: widget.initialPromptOverride,
      );
    }
  }

  Future<void> _checkClipboardForSixDigitCode() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final raw = data?.text?.trim() ?? '';
      final match = RegExp(r'\b([0-9]{6})\b').firstMatch(raw);
      if (match != null && mounted) {
        setState(() {
          _detectedClipboardCode = match.group(1);
        });
      }
    } catch (_) {}
  }

  void _onParallaxScroll() {
    if (!mounted || !_parallaxScrollController.hasClients) return;
    final nextOffset = _parallaxScrollController.offset;
    final delta = (nextOffset - _scrollOffset).abs();

    final stanchionIndex = (nextOffset / 92.0).floor();
    if (stanchionIndex != _lastStanchionTickIndex && nextOffset > 0) {
      _lastStanchionTickIndex = stanchionIndex;
      HapticFeedback.selectionClick();
    }

    setState(() {
      _scrollVelocity = delta.clamp(0.0, 48.0);
      _scrollOffset = nextOffset;
    });
  }

  void _triggerPaparazziFrenzy() {
    HapticFeedback.heavyImpact();
    _frenzyBurstController.forward(from: 0.0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      _lobbyManager.leaveLobby();
    } else if (state == AppLifecycleState.resumed) {
      _checkClipboardForSixDigitCode();
    }
  }

  void _onLobbyStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _parallaxScrollController.removeListener(_onParallaxScroll);
    _parallaxScrollController.dispose();
    _paparazziFlashController.dispose();
    _frenzyBurstController.dispose();
    _lobbyManager.removeListener(_onLobbyStateChanged);
    _lobbyManager.dispose();
    _nameController.dispose();
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _openCallSheetAndExecute(
    VoidCallback onConfirmed, {
    String? modeTitle,
  }) async {
    HapticFeedback.lightImpact();
    final settings = await showModalBottomSheet<GameSettingsConfig>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GameSettingsModal(modeTitle: modeTitle),
    );
    if (settings != null && mounted) {
      onConfirmed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeSession = _lobbyManager.session;

    return Scaffold(
      backgroundColor: const Color(0xFF05070B),
      appBar: GameAppBar(
        title: activeSession == null
            ? 'Grand Premiere Soundstage'
            : 'GREEN ROOM · #${activeSession.roomCode}',
        activeRoomCode: activeSession?.roomCode,
        onStartOver: () => _lobbyManager.leaveLobby(),
        extraActions: [
          if (activeSession != null)
            TextButton(
              onPressed: () => _lobbyManager.leaveLobby(),
              child: const Text(
                'Leave Room',
                style: TextStyle(color: Color(0xFFE11D48)),
              ),
            ),
        ],
      ),
      body: Listener(
        onPointerDown: (e) {
          if (mounted) setState(() => _activeTouchPosition = e.localPosition);
        },
        onPointerMove: (e) {
          if (mounted) setState(() => _activeTouchPosition = e.localPosition);
        },
        onPointerUp: (_) {
          if (mounted) setState(() => _activeTouchPosition = null);
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _paparazziFlashController,
            _frenzyBurstController,
          ]),
          builder: (context, _) {
            final phase = _paparazziFlashController.value * 2 * math.pi;
            final frenzy = _frenzyBurstController.isAnimating
                ? (1.0 - _frenzyBurstController.value)
                : 0.0;

            return Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  child: RedCarpet25DParallaxEnvironment(
                    scrollOffset: _scrollOffset,
                    scrollVelocity: _scrollVelocity,
                    touchPosition: _activeTouchPosition,
                    extraFrenzyIntensity: frenzy,
                    showFlankCardsOverlay: true,
                  ),
                ),
                IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: PaparazziFlashOverlayPainter(
                        progress: _paparazziFlashController.value,
                        scrollVelocity: _scrollVelocity,
                        frenzyIntensity: frenzy,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: activeSession == null
                      ? _buildPaparazziCustomScrollView(phase)
                      : _buildSynchronizedLobbyView(activeSession),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaparazziCustomScrollView(double phase) {
    return CustomScrollView(
      controller: _parallaxScrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                VipCredentialHeaderBar(
                  actorHandle: _nameController.text.trim().isEmpty
                      ? '@STAGESTAR'
                      : '@${_nameController.text.trim().toUpperCase().replaceAll(' ', '_')}',
                  telemetricsTokens: _telemetricsTokens,
                  careerWins: OfflineManager.instance.totalCareerWins,
                  isOnline: OfflineManager.instance.isOnline,
                ),
                const SizedBox(height: 10),
                if (_savedActiveRoomCode != null) ...[
                  ActiveSetRejoinBanner(
                    roomCode: _savedActiveRoomCode!,
                    onRejoinTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _isJoinMode = true;
                        _codeController.text = _savedActiveRoomCode!;
                      });
                      _lobbyManager.joinLobbyByCode(
                        roomCode: _savedActiveRoomCode!,
                        displayName: _nameController.text,
                      );
                    },
                    onDismissTap: () {
                      LobbyRealtimeManager.clearActiveRoomSession();
                      setState(() => _savedActiveRoomCode = null);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                TutorialOverlay(
                  tutorialKey: 'lobby_room_code_v1',
                  badgeLabel: 'DIRECTOR\'S PREMIERE CUE',
                  title: 'Studio Green Room & Matchmaking Airlock',
                  message:
                      'Host a new 6-digit soundstage or dial in an invite code below to step onto the set with remote co-stars.',
                  neonAccent: const Color(0xFFF59E0B),
                  icon: Icons.camera_enhance_rounded,
                  onDismissed: () async {
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool(
                        'act_like_it_lobby_tooltip_dismissed',
                        true,
                      );
                    } catch (_) {}
                  },
                ),
                const SizedBox(height: 6),
                _buildStageCredentialsCard(),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
          sliver: SliverToBoxAdapter(
            child: _buildDedicatedStudioGreenRoom(),
          ),
        ),
      ],
    );
  }

  Widget _buildGreenRoomDuetRivalsCoStarCard({LobbySession? activeSession}) {
    final cfg = GameSettingsModal.latestConfig;
    final duetOn = cfg.screenTestDuetMode;
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        setState(() {
          GameSettingsModal.latestConfig = cfg.copyWith(
            screenTestDuetMode: !duetOn,
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xF20B0E17),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: duetOn ? const Color(0xFF0CB6D4) : const Color(0xFFF59E0B),
            width: 2.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 124,
              height: 98,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const DuetRivalsSplitPortraitRig(phase: 1.35),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: duetOn
                          ? const Color(0x330CB6D4)
                          : const Color(0x33F59E0B),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: duetOn
                            ? const Color(0xFF0CB6D4)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                    child: Text(
                      duetOn
                          ? 'DUET MODE ACTIVE · LEAD A (GOLD) VS LEAD B (CYAN)'
                          : 'GREEN ROOM CO-STAR DECK · TAP TO ENABLE DUET',
                      style: const TextStyle(
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    duetOn
                        ? '50/50 Split-Screen Viewfinder + AI Co-Star TTS Voice Lines enabled!'
                        : 'Tap to toggle 2-Player Duet Mode or pick an AI / Couch Co-Star below.',
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                  if (activeSession != null) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ActionChip(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: const Color(0xFF121826),
                          side: const BorderSide(color: Color(0xFFF59E0B)),
                          label: const Text(
                            '🤖 + AI Co-Star (TTS)',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFF5DEB3),
                            ),
                          ),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              GameSettingsModal.latestConfig =
                                  GameSettingsModal.latestConfig.copyWith(
                                screenTestDuetMode: true,
                              );
                            });
                            _lobbyManager.addAiCoStar();
                          },
                        ),
                        ActionChip(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: const Color(0xFF121826),
                          side: const BorderSide(color: Color(0xFF0CB6D4)),
                          label: const Text(
                            '🛋️ + Pass & Play Co-Star',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0CB6D4),
                            ),
                          ),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              GameSettingsModal.latestConfig =
                                  GameSettingsModal.latestConfig.copyWith(
                                screenTestDuetMode: true,
                              );
                            });
                            _lobbyManager.addLocalPassAndPlayPlayer();
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDedicatedStudioGreenRoom() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildGreenRoomDuetRivalsCoStarCard(),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF0B0E17)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0x2606B6D4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF06B6D4)),
                        ),
                        child: const Icon(
                          Icons.meeting_room_rounded,
                          color: Color(0xFF06B6D4),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'STUDIO GREEN ROOM',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Color(0xFF06B6D4),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x2610B981),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: const Text(
                      'STAGE READY · 1080p60',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Live Matchmaking Lounge & Soundstage Airlock',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Dial in your 6-digit room code above or generate a fresh set pass. Remote co-stars sync in real time with LiveKit WebRTC SFU video feeds and Gemini AI Telemetrics.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildGreenRoomSpecChip(
                    icon: Icons.speed_rounded,
                    label: 'SFU LOW LATENCY',
                    accent: const Color(0xFF06B6D4),
                  ),
                  const SizedBox(width: 8),
                  _buildGreenRoomSpecChip(
                    icon: Icons.psychology_rounded,
                    label: 'GEMINI 2.5 FLASH',
                    accent: const Color(0xFFE11D48),
                  ),
                  const SizedBox(width: 8),
                  _buildGreenRoomSpecChip(
                    icon: Icons.people_alt_rounded,
                    label: '2-8 CAST',
                    accent: const Color(0xFFF59E0B),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF59E0B),
                  side: const BorderSide(color: Color(0xFFF59E0B), width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: const Color(0x990B0E17),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    StageSharedTransitionRoute(
                      page: const SceneVaultScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.confirmation_number_rounded, size: 16),
                label: const Text(
                  'SCENE VAULT',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF10B981),
                  side: const BorderSide(color: Color(0xFF10B981), width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: const Color(0x990B0E17),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    StageSharedTransitionRoute(
                      page: const MatchHistoryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.emoji_events_rounded, size: 16),
                label: const Text(
                  'TROPHY ROOM',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGreenRoomSpecChip({
    required IconData icon,
    required String label,
    required Color accent,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF070A12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Icon(icon, color: accent, size: 16),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageCredentialsCard() {
    final digits = _codeController.text.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xD90A0D16),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
              width: 1.4,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0xAA000000),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Host 6-Digit Room'),
                      ),
                      selected: !_isJoinMode,
                      onSelected: (_) => setState(() => _isJoinMode = false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Join via 6-Digit Code'),
                      ),
                      selected: _isJoinMode,
                      onSelected: (_) {
                        setState(() => _isJoinMode = true);
                        _checkClipboardForSixDigitCode();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _nameController,
                onChanged: (val) {
                  setState(() {});
                  SharedPreferences.getInstance().then((p) {
                    p.setString('act_like_it_saved_actor_name', val.trim());
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Stage Display Name',
                  filled: true,
                  fillColor: Color(0xFF121722),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (_isJoinMode) ...[
                if (_detectedClipboardCode != null &&
                    _detectedClipboardCode != digits) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ActionChip(
                      avatar: const Icon(
                        Icons.content_paste_go_rounded,
                        size: 16,
                        color: Color(0xFF06B6D4),
                      ),
                      backgroundColor: const Color(0xFF0E1B2A),
                      side: const BorderSide(color: Color(0xFF06B6D4)),
                      label: Text(
                        'Paste Room Code #$_detectedClipboardCode',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _codeController.text = _detectedClipboardCode!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                GestureDetector(
                  onTap: () => _codeFocusNode.requestFocus(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (idx) {
                      final hasChar = idx < digits.length;
                      final isFocusedBox = idx == digits.length ||
                          (digits.length == 6 && idx == 5);
                      final char = hasChar ? digits[idx] : '·';
                      return Container(
                        width: 44,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: hasChar
                              ? const Color(0xFF111C2D)
                              : const Color(0xFF0B0E17),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasChar
                                ? const Color(0xFF06B6D4)
                                : (isFocusedBox
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF1E293B)),
                            width: hasChar || isFocusedBox ? 2.0 : 1.2,
                          ),
                          boxShadow: hasChar
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF06B6D4)
                                        .withValues(alpha: 0.25),
                                    blurRadius: 10,
                                  ),
                                ]
                              : const [],
                        ),
                        child: Text(
                          char,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: hasChar
                                ? Colors.white
                                : const Color(0xFF475569),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _codeController,
                  focusNode: _codeFocusNode,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (val) {
                    HapticFeedback.selectionClick();
                    setState(() {});
                    if (val.trim().length == 6) {
                      FocusScope.of(context).unfocus();
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: '6-Digit Lobby Code (Auto-Advances Above)',
                    hintText: '482910',
                    filled: true,
                    fillColor: Color(0xFF121722),
                    border: OutlineInputBorder(),
                  ),
                ),
              ] else
                DropdownButtonFormField<SceneCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Selected Scene Vault Category',
                    filled: true,
                    fillColor: Color(0xFF121722),
                    border: OutlineInputBorder(),
                  ),
                  items: SceneCategory.values
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat.label),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedCategory = val);
                    }
                  },
                ),
              if (_lobbyManager.errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _lobbyManager.errorMessage!,
                  style:
                      const TextStyle(color: Color(0xFFE11D48), fontSize: 13),
                ),
              ],
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _lobbyManager.isLoading
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        if (_isJoinMode) {
                          _lobbyManager.joinLobbyByCode(
                            roomCode: _codeController.text,
                            displayName: _nameController.text,
                          );
                        } else {
                          _lobbyManager.createLobby(
                            displayName: _nameController.text,
                            category: _selectedCategory,
                            preselectedPrompt: widget.initialPromptOverride,
                          );
                        }
                      },
                icon: const Icon(Icons.videocam_rounded, size: 18),
                label: Text(
                  _lobbyManager.isLoading
                      ? 'Opening Soundstage Doors...'
                      : (_isJoinMode
                          ? 'Step Onto Stage · Join 6-Digit Room'
                          : 'Generate 6-Digit Set Pass'),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0CB6D4),
                  side: const BorderSide(color: Color(0xFF0CB6D4), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _lobbyManager.isLoading
                    ? null
                    : () {
                        HapticFeedback.heavyImpact();
                        _lobbyManager.quickJoinPublicLobby(
                          displayName: _nameController.text,
                          fallbackCategory: _selectedCategory,
                        );
                      },
                icon: const Icon(Icons.public_rounded, size: 18),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '🌐 QUICK-JOIN PUBLIC ENSEMBLE',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareVipSetPass(LobbySession session) async {
    HapticFeedback.mediumImpact();
    final joinUrl =
        'https://act-like-it.vercel.app/join?room=${session.roomCode}';
    final passMessage = '🎬 VIP SET PASS · ACT LIKE IT\n'
        'Step onto my Hollywood Soundstage!\n'
        '6-Digit Room Code: ${session.roomCode}\n'
        'Featured Reel: ${session.selectedCategory.label}\n'
        'Join online or in-app: $joinUrl';
    await Clipboard.setData(ClipboardData(text: session.roomCode));
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: passMessage,
          subject: 'ACT LIKE IT · VIP Set Pass #${session.roomCode}',
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'VIP Set Pass #${session.roomCode} & Join URL copied to clipboard!',
          ),
        ),
      );
    }
  }

  Widget _buildSynchronizedLobbyView(LobbySession session) {
    final players = _lobbyManager.players;
    final activeScene = session.activeScene;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ClipPath(
          clipper: BoxOfficeTicketNotchClipper(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1F1124),
                  Color(0xFF0E131F),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFF59E0B), width: 2.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'ADMIT ONE · VIP SOUNDSTAGE SET PASS',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: Color(0xFFFDE68A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x2610B981),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF10B981)),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'STAGE LIVE',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      session.roomCode,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: Colors.white),
                      tooltip: 'Copy 6-Digit Code',
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Clipboard.setData(
                          ClipboardData(text: session.roomCode),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Copied room code ${session.roomCode}'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Reel: ${session.selectedCategory.label} · '
                  'Cast: ${players.length}/${session.maxPlayers} Ensemble Actors',
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: const Color(0xFF05070B),
                    ),
                    onPressed: () => _shareVipSetPass(session),
                    icon: const Icon(Icons.ios_share_rounded, size: 18),
                    label: const Text(
                      'SHARE VIP SET PASS',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (activeScene != null) ...[
          Hero(
            tag: SceneHeroTags.ticketTag(session.selectedCategory),
            createRectTween: SceneHeroTags.createTicketArcTween,
            flightShuttleBuilder: SceneHeroTags.buildTicketFlightShuttle,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE11D48)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'FEATURED SCRIPT · ${activeScene.title} (${activeScene.releaseYear})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFF5DEB3),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                          onPressed: () => _openGreenRoomSceneDrawer(session),
                          icon: const Icon(Icons.menu_book_rounded, size: 15),
                          label: Text(
                            'SCENE DRAWER ($totalGeneralSceneCount)',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${activeScene.characterName} — "${activeScene.promptScript}"',
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (GameSettingsModal.latestConfig.screenTestDuetMode &&
                        (activeScene.duetLeadA.isNotEmpty ||
                            activeScene.duetLeadB.isNotEmpty)) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0D16),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF0CB6D4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SCREEN TEST DUET · 2-PLAYER CO-STAR MODE ACTIVE',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0CB6D4),
                              ),
                            ),
                            if (activeScene.duetLeadA.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'LEAD A (GOLD): "${activeScene.duetLeadA}"',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.38,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF5DEB3),
                                ),
                              ),
                            ],
                            if (activeScene.duetLeadB.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'LEAD B (CYAN): "${activeScene.duetLeadB}"',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.38,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0CB6D4),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Director\'s Note: ${activeScene.directorCue} · Emotion: ${activeScene.emotionalTarget}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                    if (activeScene.improvTwist.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Improv Curveball: ${activeScene.improvTwist}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    // Fixtures #4, #8, #12: 1-Tap Green Room Mode Pills
                    Builder(
                      builder: (context) {
                        final cfg = GameSettingsModal.latestConfig;
                        final actIndex = ((session.roundNumber - 1) % 3) + 1;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                FilterChip(
                                  selected: cfg.stoneFacedNoLaughHazard,
                                  selectedColor: const Color(0x3310B981),
                                  checkmarkColor: const Color(0xFF10B981),
                                  label: const Text(
                                    '🗿 Stone-Faced Hazard (1.20x)',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  onSelected: (v) {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      GameSettingsModal.latestConfig = cfg
                                          .copyWith(stoneFacedNoLaughHazard: v);
                                    });
                                  },
                                ),
                                FilterChip(
                                  selected: cfg.threeActBlockbusterTournament,
                                  selectedColor: const Color(0x33FFD700),
                                  checkmarkColor: const Color(0xFFFFD700),
                                  label: const Text(
                                    '🎬 3-Act Blockbuster Arc',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  onSelected: (v) {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      GameSettingsModal.latestConfig =
                                          cfg.copyWith(
                                        threeActBlockbusterTournament: v,
                                      );
                                    });
                                  },
                                ),
                                FilterChip(
                                  selected: cfg.bigScreenPremiereHostView,
                                  selectedColor: const Color(0x330CB6D4),
                                  checkmarkColor: const Color(0xFF0CB6D4),
                                  label: const Text(
                                    '📺 TV / DeX Host View',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  onSelected: (v) {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      GameSettingsModal.latestConfig = cfg
                                          .copyWith(bigScreenPremiereHostView: v);
                                    });
                                  },
                                ),
                                FilterChip(
                                  selected: cfg.cleanBroadcastScreenShareMode,
                                  selectedColor: const Color(0x3310B981),
                                  checkmarkColor: const Color(0xFF10B981),
                                  label: const Text(
                                    '📡 Clean Broadcast',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  onSelected: (v) {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      GameSettingsModal.latestConfig =
                                          cfg.copyWith(
                                        cleanBroadcastScreenShareMode: v,
                                      );
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (cfg.threeActBlockbusterTournament) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0B0E17),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFFFD700),
                                  ),
                                ),
                                child: Text(
                                  '🎬 3-ACT BLOCKBUSTER ARC · CURRENT: ACT $actIndex OF 3\n'
                                  'Act I: The Setup (Era/Cult) → Act II: The Complication (+Curveball) → Act III: The Showstopper Climax (1.5x)',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 9.5,
                                    height: 1.35,
                                    color: Color(0xFFF5DEB3),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final syncedSession = session.copyWith(
                            players: players,
                            currentPlayerIndex: 0,
                            totalLocalPlayers: math.max(1, players.length),
                          );
                          Navigator.of(context).push(
                            StageSharedTransitionRoute(
                              page: LiveKitSoundstageScreen(
                                lobbySession: syncedSession,
                                localUserId: _lobbyManager.localUserId,
                                localDisplayName:
                                    _lobbyManager.localDisplayName,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.videocam, size: 18),
                        label: const Text('Step Onto Soundstage & Roll Camera'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        // Relocated Interactive 2.5D Card: Lead A & Lead B — Screen Test Rivals
        _buildGreenRoomDuetRivalsCoStarCard(activeSession: session),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xF20B0E17),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Green Room Cast Roster (${players.length}/${session.maxPlayers})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (players.length < session.maxPlayers)
                    Wrap(
                      spacing: 6,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B0E17),
                            foregroundColor: const Color(0xFF0CB6D4),
                            side: const BorderSide(
                              color: Color(0xFF0CB6D4),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _lobbyManager.addLocalPassAndPlayPlayer();
                          },
                          icon: const Icon(Icons.group_add_rounded, size: 15),
                          label: const Text(
                            '+ Pass & Play',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B0E17),
                            foregroundColor: const Color(0xFFF59E0B),
                            side: const BorderSide(
                              color: Color(0xFFF59E0B),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _lobbyManager.addAiCoStar();
                          },
                          icon: const Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 15,
                          ),
                          label: const Text(
                            '+ AI Co-Star',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 10),
              ...players.map(
                (player) {
                  final isLocalUser =
                      player.userId == _lobbyManager.localUserId;
                  final resolvedAvatarId = isLocalUser
                      ? AuthService.instance.currentUserAvatar
                      : player.avatarArchetypeId;
                  final playerArchetype =
                      resolveAvatarArchetype(resolvedAvatarId);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121722),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isLocalUser
                            ? playerArchetype.rimAccentColor
                                .withValues(alpha: 0.65)
                            : const Color(0xFF1E293B),
                      ),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: BoondocksAvatarPortrait(
                          archetype: playerArchetype,
                          size: 44,
                          isSelected: isLocalUser,
                          animationPhase: 0.0,
                        ),
                      ),
                      title: Text(
                        player.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${player.isHost ? 'Executive Producer' : 'Featured Ensemble Cast'} · ${playerArchetype.name}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            player.isReady ? 'ON SET' : 'STANDBY',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: player.isReady
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                          if (player.userId != _lobbyManager.localUserId) ...[
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(
                                Icons.flag_outlined,
                                size: 16,
                                color: Color(0xFF64748B),
                              ),
                              tooltip: 'Report or Block Actor',
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                _lobbyManager
                                    .blockAndRemovePlayer(player.userId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Reported & removed ${player.displayName} from your Green Room.',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xF20B0E17),
                        foregroundColor: const Color(0xFF06B6D4),
                        side: const BorderSide(
                          color: Color(0xFF06B6D4),
                          width: 1.8,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _lobbyManager.toggleReadyState(),
                      child: const Text(
                        'Toggle Ready',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _lobbyManager.startPerformanceRound(),
                      child: const Text('Draw New Scene'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openGreenRoomSceneDrawer(LobbySession session) async {
    HapticFeedback.selectionClick();
    SceneCategory activeCat = session.selectedCategory;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF07090E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final scripts = kBuiltInSceneVault[activeCat] ?? const [];
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.82,
              minChildSize: 0.55,
              maxChildSize: 0.94,
              builder: (_, scrollCtrl) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'GREEN ROOM SCENE DRAWER · $totalGeneralSceneCount GENERAL SCRIPTS',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFF5DEB3),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(sheetCtx).pop(),
                            icon: const Icon(Icons.close, color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<SceneCategory>(
                        value: activeCat,
                        decoration: const InputDecoration(
                          labelText: 'Scene Category (9 Categories × 10 Scripts)',
                          filled: true,
                          fillColor: Color(0xFF121722),
                          border: OutlineInputBorder(),
                        ),
                        items: SceneCategory.values
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat.label),
                              ),
                            )
                            .toList(),
                        onChanged: (nextCat) {
                          if (nextCat != null) {
                            setSheetState(() => activeCat = nextCat);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollCtrl,
                          itemCount: scripts.length,
                          itemBuilder: (_, idx) {
                            final item = scripts[idx];
                            final isCurrent =
                                session.activeScene?.id == item.id;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF121722),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCurrent
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFF1E293B),
                                  width: isCurrent ? 1.8 : 1.0,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${idx + 1}. ${item.title} (${item.releaseYear}) — ${item.characterName}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '"${item.promptScript}"',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: Color(0xFFF8FAFC),
                                    ),
                                  ),
                                  if (item.duetLeadA.isNotEmpty ||
                                      item.duetLeadB.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      'LEAD A (GOLD): "${item.duetLeadA}"',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        height: 1.35,
                                        color: Color(0xFFF5DEB3),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'LEAD B (CYAN): "${item.duetLeadB}"',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        height: 1.35,
                                        color: Color(0xFF0CB6D4),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Text(
                                    'Director\'s Note: ${item.directorCue} · Emotion: ${item.emotionalTarget}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _lobbyManager.selectSceneFromDrawer(
                                          category: activeCat,
                                          scene: item,
                                        );
                                        Navigator.of(sheetCtx).pop();
                                      },
                                      icon: const Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 16,
                                      ),
                                      label: const Text('Load Onto Teleprompter'),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
