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
import 'auth/auth_service.dart';

export 'ui/lobby_models_and_realtime.dart';
export 'ui/premiere_doors_marquee.dart';
export 'ui/premiere_red_carpet_painters.dart';

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
            : 'Soundstage #${activeSession.roomCode}',
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
                  child: CustomPaint(
                    painter: PaparazziRedCarpetPainter(
                      scrollOffset: _scrollOffset,
                      phase: phase,
                      scrollVelocity: _scrollVelocity,
                      touchPosition: _activeTouchPosition,
                    ),
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

  Widget _buildDedicatedStudioGreenRoom() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareVipSetPass(LobbySession session) async {
    HapticFeedback.mediumImpact();
    final passMessage = '🎬 VIP SET PASS · ACT LIKE IT\n'
        'Step onto my Hollywood Soundstage!\n'
        '6-Digit Room Code: ${session.roomCode}\n'
        'Featured Reel: ${session.selectedCategory.label}';
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
            'VIP Set Pass #${session.roomCode} copied to clipboard!',
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
                    Text(
                      'FEATURED SCRIPT · ${activeScene.filmOrSeries} (${activeScene.releaseYear})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${activeScene.characterName} — "${activeScene.promptScript}"',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Director\'s Note: ${activeScene.directorCue} · Emotion: ${activeScene.emotionalTarget}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            StageSharedTransitionRoute(
                              page: LiveKitSoundstageScreen(
                                lobbySession: session,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Green Room Cast Roster (${players.length}/${session.maxPlayers})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            if (players.length < session.maxPlayers)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF59E0B),
                  side: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _lobbyManager.addAiCoStar();
                },
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 15),
                label: const Text(
                  '+ Add AI Co-Star',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        ...players.map(
          (player) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF121722),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: ListTile(
              title: Text(
                player.displayName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                player.isHost ? 'Executive Producer' : 'Featured Ensemble Cast',
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
              trailing: Text(
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
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
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
    );
  }
}
