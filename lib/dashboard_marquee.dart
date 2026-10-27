import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'lobby.dart';
import 'webrtc_manager.dart';
import 'late_night_vault.dart';
import 'offline_manager.dart';
import 'match_history_screen.dart';
import 'ui/lobby_models_and_realtime.dart';
import 'ui/premiere_doors_marquee.dart';
import 'ui/premiere_red_carpet_painters.dart';
import 'ui/interactive_instructions.dart';
import 'ui/game_settings_modal.dart';
import 'ui/scene_vault_screen.dart';
import 'ui/transitions.dart';
import 'ui/intro_cinematic.dart';
import 'ui/brand_logo.dart';
import 'ui/living_25d_animation_engine.dart';
import 'ui/parody_scenes_catalog.dart';
import 'ui/soundstage_audio_controller.dart';
import 'social/cutting_room_feed.dart';
import 'auth/auth_service.dart';
import 'auth/nda_tester_gate.dart';
import 'profile/actor_profile_screen.dart';
import 'monetization/payment_dashboard_screen.dart';

export 'ui/brand_logo.dart';
export 'ui/living_25d_animation_engine.dart';

/// Represents a neon movie ticket entry inside the horizontally scrolling
/// Scene Vault carousel on "The Living Marquee & Neon Backstage" dashboard.
class MarqueeTicketSpec {
  final SceneCategory category;
  final String ticketCode;
  final String title;
  final String subtitle;
  final String spotlightFilm;
  final Color neonColor;
  final IconData icon;

  const MarqueeTicketSpec({
    required this.category,
    required this.ticketCode,
    required this.title,
    required this.subtitle,
    required this.spotlightFilm,
    required this.neonColor,
    required this.icon,
  });
}

const List<MarqueeTicketSpec> kSceneVaultTickets = [
  MarqueeTicketSpec(
    category: SceneCategory.era1970To1999,
    ticketCode: 'REEL 70–99',
    title: 'Eras: 1970–1999',
    subtitle: 'New Hollywood & Silver Screen Icons',
    spotlightFilm: 'The Godfather · Taxi Driver · Pulp Fiction',
    neonColor: Color(0xFFF59E0B),
    icon: Icons.movie_filter_outlined,
  ),
  MarqueeTicketSpec(
    category: SceneCategory.era2000To2026,
    ticketCode: 'REEL 00–26',
    title: 'Eras: 2000–2026',
    subtitle: 'Modern Prestige & High-Voltage Cinema',
    spotlightFilm: 'The Dark Knight · Whiplash · Hidden Figures',
    neonColor: Color(0xFF06B6D4),
    icon: Icons.auto_awesome_motion_outlined,
  ),
  MarqueeTicketSpec(
    category: SceneCategory.awardsBestActor,
    ticketCode: 'OSCAR · LEAD',
    title: 'Awards: Best Actor',
    subtitle: 'Tour-de-Force Leading Monologues',
    spotlightFilm: 'There Will Be Blood · Training Day · Oppenheimer',
    neonColor: Color(0xFFA855F7),
    icon: Icons.emoji_events_outlined,
  ),
  MarqueeTicketSpec(
    category: SceneCategory.awardsBestActress,
    ticketCode: 'OSCAR · ICON',
    title: 'Awards: Best Actress',
    subtitle: 'Raw Psychological Power & Precision',
    spotlightFilm: 'Silence of the Lambs · Misery · Black Swan',
    neonColor: Color(0xFFEC4899),
    icon: Icons.stars_outlined,
  ),
  MarqueeTicketSpec(
    category: SceneCategory.awardsBestSupportingActor,
    ticketCode: 'SCENE STEALER',
    title: 'Awards: Best Supporting',
    subtitle: 'Unforgettable High-Impact Turns',
    spotlightFilm: 'Good Will Hunting · Glengarry Glen Ross · Django',
    neonColor: Color(0xFF22D3EE),
    icon: Icons.theater_comedy_outlined,
  ),
  MarqueeTicketSpec(
    category: SceneCategory.awardsBestVillain,
    ticketCode: 'ANTAGONIST',
    title: 'Awards: Best Villain',
    subtitle: 'Cold Fatalism & Commanding Menace',
    spotlightFilm: 'No Country for Old Men · Wall Street · Few Good Men',
    neonColor: Color(0xFFF43F5E),
    icon: Icons.whatshot_outlined,
  ),
  MarqueeTicketSpec(
    category: SceneCategory.awardsEmmyVault,
    ticketCode: 'PRESTIGE TV',
    title: 'Awards: Emmy Vault',
    subtitle: 'Peak Television Finale Showdowns',
    spotlightFilm: 'Breaking Bad · Succession · The Bear · The Sopranos',
    neonColor: Color(0xFFFBBF24),
    icon: Icons.live_tv_outlined,
  ),
  MarqueeTicketSpec(
    category: SceneCategory.specialtyCultClassics,
    ticketCode: 'MIDNIGHT REEL',
    title: 'Specialty: Cult Classics',
    subtitle: 'Late-Show Quotables & Underground Legends',
    spotlightFilm: 'Rocky Horror · The Big Lebowski · Fight Club',
    neonColor: Color(0xFFC084FC),
    icon: Icons.bolt_outlined,
  ),
];

/// "The Living Marquee & Neon Backstage" — Primary Gamified Home Dashboard.
/// Built 100% in pure Flutter code with zero static image assets.
class LivingMarqueeDashboardScreen extends StatefulWidget {
  const LivingMarqueeDashboardScreen({super.key});

  @override
  State<LivingMarqueeDashboardScreen> createState() =>
      _LivingMarqueeDashboardScreenState();
}

class _LivingMarqueeDashboardScreenState
    extends State<LivingMarqueeDashboardScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _spotlightController;
  late final AnimationController _frenzyBurstController;
  late final AnimationController _clapperController;
  bool _isClappingShut = false;

  late final PageController _ticketPageController;
  late final ScrollController _redCarpetScrollController;
  double _redCarpetScrollOffset = 0.0;
  double _redCarpetScrollVelocity = 0.0;
  int _lastStanchionTickIndex = 0;
  Offset? _activeTouchPosition;
  double _currentTicketPage = 0.0;
  int _focusedTicketIndex = 0;
  String? _savedActiveRoomCode;
  String? _detectedClipboardCode;
  int _telemetricsTokens = 25;

  late final AnimationController _marqueeTickerController;

  late final AudioPlayer _audioPlayer;
  bool _isMusicPlaying = true;
  bool _userManuallyMutedMusic = false;
  static const String _gameShowSoundtrackUrl =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  static const List<String> _liveMarqueeFeedItems = [
    'STAGE LIVE · ROOM #482910 PERFORMING "THE GOTHAM INTERROGATION" — FULL ENSEMBLE ON SET',
    'HIGH SCORE · @NAOMI_V HIT 98.4 COMPOSITE TRI-MODAL SCORE ON "WHIPLASH"',
    'AI TELEMETRICS · GEMINI 2.5 FLASH EVALUATED 1,420 MICRO-EXPRESSION FRAMES THIS HOUR',
    'VIRAL LOOP · @MARCUS_S26 HIT +410 SOCIAL SHARES IN SPECIALTY: CULT CLASSICS',
    'AFTER-HOURS 18+ VAULT · 15s MID-TAKE IMPROVISATION TWIST ACTIVE IN 19 LOBBIES',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _spotlightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _frenzyBurstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _clapperController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );

    _ticketPageController = PageController(
      viewportFraction: 0.78,
      initialPage: 0,
    )..addListener(_onTicketScroll);

    _redCarpetScrollController = ScrollController()
      ..addListener(_onRedCarpetScroll);

    _marqueeTickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    _audioPlayer = AudioPlayer();
    GameSettingsModal.volumeNotifier.addListener(_onMasterVolumeChanged);
    _initGameShowMusicLoop();

    OfflineManager.instance.ensureInitialized().then((_) {
      if (mounted) setState(() {});
    });
    _refreshVipHudState();
  }

  void _onMasterVolumeChanged() {
    _audioPlayer.setVolume(GameSettingsModal.volumeNotifier.value);
  }

  Future<void> _refreshVipHudState() async {
    final activeCode = await LobbyRealtimeManager.loadActiveRoomSession();
    final tokens = await LobbyRealtimeManager.loadTelemetricsTokens();
    String? clipCode;
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final raw = data?.text?.trim() ?? '';
      final match = RegExp(r'\b([0-9]{6})\b').firstMatch(raw);
      if (match != null) {
        clipCode = match.group(1);
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _savedActiveRoomCode = activeCode;
        _detectedClipboardCode = clipCode;
        _telemetricsTokens = tokens;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      if (_isMusicPlaying) {
        _audioPlayer.pause();
        if (mounted) {
          setState(() => _isMusicPlaying = false);
        }
      }
    } else if (state == AppLifecycleState.resumed) {
      _refreshVipHudState();
      if (!_userManuallyMutedMusic && !_isMusicPlaying) {
        _audioPlayer.resume();
        if (mounted) {
          setState(() => _isMusicPlaying = true);
        }
      }
    }
  }

  void _onRedCarpetScroll() {
    if (!mounted || !_redCarpetScrollController.hasClients) return;
    final nextOffset = _redCarpetScrollController.offset;
    final delta = (nextOffset - _redCarpetScrollOffset).abs();

    final stanchionIndex = (nextOffset / 92.0).floor();
    if (stanchionIndex != _lastStanchionTickIndex && nextOffset > 0) {
      _lastStanchionTickIndex = stanchionIndex;
      HapticFeedback.selectionClick();
    }

    setState(() {
      _redCarpetScrollVelocity = delta.clamp(0.0, 48.0);
      _redCarpetScrollOffset = nextOffset;
    });
  }

  void _triggerPaparazziFrenzy() {
    HapticFeedback.heavyImpact();
    unawaited(
      SoundstageAudioController.instance.playSfx(
        SoundstageSfx.paparazziShutterFlash,
      ),
    );
    _frenzyBurstController.forward(from: 0.0);
  }

  Future<void> _initGameShowMusicLoop() async {
    SoundstageAudioController.instance.onPaparazziFlashVisual = () {
      if (mounted && !_frenzyBurstController.isAnimating) {
        _frenzyBurstController.forward(from: 0.0);
      }
    };
    await SoundstageAudioController.instance.enterZone(
      SoundstageZone.redCarpetDashboard,
    );
    if (mounted) {
      setState(() {
        _isMusicPlaying = SoundstageAudioController.instance.masterEnabled &&
            SoundstageAudioController.instance.musicEnabled;
      });
    }
  }

  Future<void> _toggleBackgroundMusic() async {
    try {
      await SoundstageAudioController.instance.toggleMusicEnabled();
      if (mounted) {
        setState(() {
          _isMusicPlaying = SoundstageAudioController.instance.masterEnabled &&
              SoundstageAudioController.instance.musicEnabled;
          _userManuallyMutedMusic = !_isMusicPlaying;
        });
      }
    } catch (_) {}
  }

  Future<void> _pauseMusicBeforeNavigation() async {
    if (_isMusicPlaying) {
      try {
        await _audioPlayer.pause();
      } catch (_) {}
      if (mounted) {
        setState(() {
          _isMusicPlaying = false;
        });
      }
    }
  }

  void _onTicketScroll() {
    if (!mounted || !_ticketPageController.hasClients) return;
    setState(() {
      _currentTicketPage = _ticketPageController.page ?? 0.0;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    GameSettingsModal.volumeNotifier.removeListener(_onMasterVolumeChanged);
    _redCarpetScrollController.removeListener(_onRedCarpetScroll);
    _redCarpetScrollController.dispose();
    _ticketPageController.removeListener(_onTicketScroll);
    _ticketPageController.dispose();
    _spotlightController.dispose();
    _frenzyBurstController.dispose();
    _clapperController.dispose();
    _marqueeTickerController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _openCallSheetAndNavigate({
    required String modeTitle,
    required bool joinMode,
  }) async {
    HapticFeedback.mediumImpact();
    final selectedTicket = kSceneVaultTickets[_focusedTicketIndex];

    if (joinMode) {
      await _pauseMusicBeforeNavigation();
      if (!mounted) return;
      await BespokeTransitionEngine.navigate(
        context: context,
        type: BespokeTransitionType.soundstageDoorSlam,
        destination: LobbyMatchmakingScreen(
          initialCategory: selectedTicket.category,
          startInJoinMode: true,
        ),
      );
      return;
    }

    final settings = await showModalBottomSheet<GameSettingsConfig>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GameSettingsModal(modeTitle: modeTitle),
    );
    if (settings == null || !mounted) return;

    await _pauseMusicBeforeNavigation();
    if (!mounted) return;

    await BespokeTransitionEngine.navigate(
      context: context,
      type: BespokeTransitionType.clapperboardSnap,
      destination: LobbyMatchmakingScreen(
        initialCategory: selectedTicket.category,
        startInJoinMode: false,
        autoCreateOnInit: true,
      ),
    );
  }

  Future<void> _triggerClapperboardAction() async {
    if (_isClappingShut) return;
    HapticFeedback.heavyImpact();

    setState(() {
      _isClappingShut = true;
    });

    await _clapperController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 110));
    await _clapperController.reverse();

    if (!mounted) return;
    setState(() {
      _isClappingShut = false;
    });

    await _pauseMusicBeforeNavigation();
    if (!mounted) return;

    final selectedTicket = kSceneVaultTickets[_focusedTicketIndex];
    await Navigator.of(context).push(
      StageSharedTransitionRoute(
        page: LobbyMatchmakingScreen(
          initialCategory: selectedTicket.category,
          startInJoinMode: false,
        ),
      ),
    );
  }

  Future<void> _launchDirectActingStage(MarqueeTicketSpec ticket) async {
    HapticFeedback.mediumImpact();
    await _pauseMusicBeforeNavigation();
    if (!mounted) return;

    final roomCode = LobbyRealtimeManager.generateSixDigitCode();
    final defaultPrompt = (kBuiltInSceneVault[ticket.category]?.first ??
        kBuiltInSceneVault[SceneCategory.era1970To1999]!.first);

    final directSession = LobbySession(
      id: 'stage-${ticket.category.key}-$roomCode',
      roomCode: roomCode,
      hostId: 'local-s26-actor',
      selectedCategory: ticket.category,
      status: 'performing',
      activeActorId: 'local-s26-actor',
      activeScene: defaultPrompt,
      livekitRoomName: 'act_like_it_$roomCode',
    );

    await Navigator.of(context).push(
      StageSharedTransitionRoute(
        page: LiveKitSoundstageScreen(
          lobbySession: directSession,
          localUserId: 'local-s26-actor',
          localDisplayName: 'Galaxy S26 Actor',
        ),
      ),
    );
  }

  void _openCloudConfigBottomSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const GameSettingsModal(isGeneralSettings: true),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _openActorProfileScreen() async {
    HapticFeedback.mediumImpact();
    await _pauseMusicBeforeNavigation();
    if (!mounted) return;
    await Navigator.of(context).push(
      StageSharedTransitionRoute(
        page: const ActorProfileScreen(),
      ),
    );
    _refreshVipHudState();
  }

  Future<void> _openPaymentDashboard({String? highlightProductKey}) async {
    HapticFeedback.mediumImpact();
    await _pauseMusicBeforeNavigation();
    if (!mounted) return;
    await Navigator.of(context).push(
      StageSharedTransitionRoute(
        page: PaymentDashboardScreen(highlightProductKey: highlightProductKey),
      ),
    );
    _refreshVipHudState();
  }

  @override
  Widget build(BuildContext context) {
    if (!OfficialClosedAlphaNdaGateWrapper.isSessionUnlockedSync()) {
      return const OfficialClosedAlphaNdaGateWrapper(
        child: LivingMarqueeDashboardScreen(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
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
            _spotlightController,
            _frenzyBurstController,
          ]),
          builder: (context, _) {
            final phase = _spotlightController.value * 2 * math.pi;
            final frenzy = _frenzyBurstController.isAnimating
                ? (1.0 - _frenzyBurstController.value)
                : 0.0;
            final povStepSwayX =
                math.sin(_redCarpetScrollOffset * 0.025 + phase * 0.5) *
                    (1.2 + (_redCarpetScrollVelocity * 0.08).clamp(0.0, 3.5));
            final povStepBobY =
                math.cos(_redCarpetScrollOffset * 0.05 + phase) *
                    (1.5 + (_redCarpetScrollVelocity * 0.10).clamp(0.0, 4.0));

            return Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  child: Transform.translate(
                    offset: Offset(povStepSwayX, povStepBobY),
                    child: RedCarpet25DParallaxEnvironment(
                      scrollOffset: _redCarpetScrollOffset,
                      scrollVelocity: _redCarpetScrollVelocity,
                      touchPosition: _activeTouchPosition,
                      extraFrenzyIntensity: frenzy,
                      showFlankCardsOverlay: true,
                    ),
                  ),
                ),
                IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: PaparazziFlashOverlayPainter(
                        progress: _spotlightController.value,
                        scrollVelocity: _redCarpetScrollVelocity,
                        frenzyIntensity: frenzy,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: CustomScrollView(
                          controller: _redCarpetScrollController,
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverPadding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 14, 20, 12),
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    VipCredentialHeaderBar(
                                      actorHandle: AuthService.instance
                                                  .currentProfile?.username
                                                  .isNotEmpty ==
                                              true
                                          ? '@${AuthService.instance.currentProfile!.username.toUpperCase()}'
                                          : '@GALAXY_S26_ACTOR',
                                      telemetricsTokens: _telemetricsTokens,
                                      careerWins: OfflineManager
                                          .instance.totalCareerWins,
                                      isOnline:
                                          OfflineManager.instance.isOnline,
                                      onProfileTap: _openActorProfileScreen,
                                      onTokensTap: () => _openPaymentDashboard(
                                        highlightProductKey: 'tokens_100',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  const Color(0xFFF5DEB3),
                                              side: const BorderSide(
                                                color: Color(0xFFF5DEB3),
                                                width: 1.3,
                                              ),
                                              backgroundColor:
                                                  const Color(0xCC07090E),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 9,
                                                horizontal: 8,
                                              ),
                                            ),
                                            onPressed: _openActorProfileScreen,
                                            icon: const Icon(
                                              Icons.person_pin_rounded,
                                              size: 15,
                                            ),
                                            label: const FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                '🎭 DRESSING ROOM / PROFILE',
                                                style: TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  const Color(0xFF0CB6D4),
                                              side: const BorderSide(
                                                color: Color(0xFF0CB6D4),
                                                width: 1.3,
                                              ),
                                              backgroundColor:
                                                  const Color(0xCC07090E),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 9,
                                                horizontal: 8,
                                              ),
                                            ),
                                            onPressed: () =>
                                                _openPaymentDashboard(),
                                            icon: const Icon(
                                              Icons.workspace_premium_rounded,
                                              size: 15,
                                            ),
                                            label: const FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                '💳 VIP BOX OFFICE',
                                                style: TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const SoundstageAudioConsoleBar(
                                      zone: SoundstageZone.redCarpetDashboard,
                                      compact: true,
                                    ),
                                    const SizedBox(height: 10),
                                    if (_detectedClipboardCode != null &&
                                        _detectedClipboardCode !=
                                            _savedActiveRoomCode) ...[
                                      GestureDetector(
                                        onTap: () async {
                                          HapticFeedback.heavyImpact();
                                          await _pauseMusicBeforeNavigation();
                                          if (!mounted) return;
                                          final selectedTicket =
                                              kSceneVaultTickets[
                                                  _focusedTicketIndex];
                                          await Navigator.of(context).push(
                                            StageSharedTransitionRoute(
                                              page: LobbyMatchmakingScreen(
                                                initialCategory:
                                                    selectedTicket.category,
                                                startInJoinMode: true,
                                              ),
                                            ),
                                          );
                                          _refreshVipHudState();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xE60B1926),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                              color: const Color(0xFF0CB6D4),
                                              width: 1.6,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.confirmation_num_rounded,
                                                color: Color(0xFF0CB6D4),
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '🎟️ Backstage Pass #$_detectedClipboardCode detected on clipboard — TAP TO JOIN INSTANTLY',
                                                  style: const TextStyle(
                                                    fontFamily: 'monospace',
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                    if (_savedActiveRoomCode != null) ...[
                                      ActiveSetRejoinBanner(
                                        roomCode: _savedActiveRoomCode!,
                                        onRejoinTap: () async {
                                          HapticFeedback.mediumImpact();
                                          await _pauseMusicBeforeNavigation();
                                          if (!mounted) return;
                                          final selectedTicket =
                                              kSceneVaultTickets[
                                                  _focusedTicketIndex];
                                          await Navigator.of(context).push(
                                            StageSharedTransitionRoute(
                                              page: LobbyMatchmakingScreen(
                                                initialCategory:
                                                    selectedTicket.category,
                                                startInJoinMode: true,
                                              ),
                                            ),
                                          );
                                          _refreshVipHudState();
                                        },
                                        onDismissTap: () {
                                          LobbyRealtimeManager
                                              .clearActiveRoomSession();
                                          setState(
                                            () => _savedActiveRoomCode = null,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                    Interactive3DHolographicMarquee(
                                      phase: phase,
                                      onPaparazziFrenzy:
                                          _triggerPaparazziFrenzy,
                                      trailingControls:
                                          _buildPaparazziPremiereHeader(),
                                    ),
                                    const SizedBox(height: 12),
                                    // Fixture #3: Daily Cattle Call — Global 24-Hour Challenge Banner
                                    _buildDailyCattleCallCard(),
                                    const SizedBox(height: 10),
                                    // Fixture #10: First-Person Walk of Fame Brass Star Plaque on the Red Carpet
                                    _buildWalkOfFameBrassStarPlaque(),
                                  ],
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 8, 20, 96),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate(
                                  BespokePremiereDoorsList.buildSixDoors(
                                    context: context,
                                    scrollController:
                                        _redCarpetScrollController,
                                    phase: phase,
                                    careerWins:
                                        OfflineManager.instance.totalCareerWins,
                                    averageScore: OfflineManager
                                        .instance.averageFinalScore,
                                    onPremiereDoorTap: () =>
                                        _openCallSheetAndNavigate(
                                      modeTitle: 'PREMIERE SOUNDSTAGE',
                                      joinMode: false,
                                    ),
                                    onAirlockJoinTap: () =>
                                        _openCallSheetAndNavigate(
                                      modeTitle: 'SOUNDSTAGE AIRLOCK',
                                      joinMode: true,
                                    ),
                                    onAfterHoursTap: () async {
                                      HapticFeedback.lightImpact();
                                      await _pauseMusicBeforeNavigation();
                                      if (!mounted) return;
                                      BespokeTransitionEngine.navigate(
                                        context: context,
                                        type: BespokeTransitionType
                                            .mobBossCigarSmoke,
                                        destination:
                                            const LateNightAfterHoursScreen(),
                                      );
                                    },
                                    onCuttingRoomElevatorTap: () async {
                                      HapticFeedback.heavyImpact();
                                      await _pauseMusicBeforeNavigation();
                                      if (!mounted) return;
                                      BespokeTransitionEngine.navigate(
                                        context: context,
                                        type: BespokeTransitionType
                                            .silverElevatorVelvetRope,
                                        destination:
                                            const CuttingRoomFeedScreen(),
                                      );
                                    },
                                    onTrophyVaultTap: () async {
                                      HapticFeedback.lightImpact();
                                      await _pauseMusicBeforeNavigation();
                                      if (!mounted) return;
                                      BespokeTransitionEngine.navigate(
                                        context: context,
                                        type: BespokeTransitionType
                                            .velvetCurtainDraw,
                                        destination: const MatchHistoryScreen(),
                                      );
                                    },
                                    onCameraViewfinderTap: () async {
                                      HapticFeedback.lightImpact();
                                      await _pauseMusicBeforeNavigation();
                                      if (!mounted) return;
                                      BespokeTransitionEngine.navigate(
                                        context: context,
                                        type: BespokeTransitionType
                                            .vintageFlashbulbPop,
                                        destination:
                                            const InteractiveInstructionsScreen(),
                                      );
                                    },
                                    onBoxOfficeVaultTap: () async {
                                      HapticFeedback.lightImpact();
                                      await _pauseMusicBeforeNavigation();
                                      if (!mounted) return;
                                      BespokeTransitionEngine.navigate(
                                        context: context,
                                        type: BespokeTransitionType
                                            .vintageFlashbulbPop,
                                        destination: const SceneVaultScreen(),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      HolographicLiveWireChyron(
                        tickerAnimation: _marqueeTickerController,
                        feedItems: _liveMarqueeFeedItems,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaparazziPremiereHeader() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _toggleBackgroundMusic,
          tooltip: _isMusicPlaying ? 'Mute Stage Music' : 'Unmute Stage Music',
          icon: Icon(
            _isMusicPlaying ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            color: _isMusicPlaying
                ? const Color(0xFFF59E0B)
                : const Color(0xFF64748B),
            size: 22,
          ),
        ),
        IconButton(
          onPressed: _openCloudConfigBottomSheet,
          tooltip: 'Cloud API Settings',
          icon: const Icon(
            Icons.tune_rounded,
            color: Color(0xFF06B6D4),
            size: 22,
          ),
        ),
      ],
    );
  }

  /// Fixture #3: Daily Cattle Call — Global 24-Hour Challenge Card (0 AI Tokens for first daily attempt).
  Widget _buildDailyCattleCallCard() {
    final challenge = getTodaysDailyCattleCallChallenge();
    final nowUtc = DateTime.now().toUtc();
    final hoursLeft = (23 - nowUtc.hour).clamp(1, 24);
    final minsLeft = (59 - nowUtc.minute).clamp(0, 59);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xEB1B0A12), Color(0xEB0B0F1A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700), width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF05070B),
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '🎬 DAILY CATTLE CALL · GLOBAL 24H CHALLENGE',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0x3310B981),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Text(
                  'RESETS IN ${hoursLeft}h ${minsLeft}m · 0 TOKENS',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Today\'s Global Scene (#${challenge.sceneNumberOf90}/90): "${challenge.scene.title}" — ${challenge.scene.characterName} (${challenge.scene.releaseYear})',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Daily Curveball: ${challenge.dailyCurveball}',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10.5,
              color: Color(0xFF0CB6D4),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF05070B),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              onPressed: () async {
                HapticFeedback.heavyImpact();
                await _pauseMusicBeforeNavigation();
                if (!mounted) return;
                final roomCode = LobbyRealtimeManager.generateSixDigitCode();
                final prompt = ScenePrompt(
                  id: challenge.scene.id,
                  category: SceneCategory.era1970To1999,
                  title: challenge.scene.title,
                  filmOrSeries: 'Daily Cattle Call (${challenge.dateKeyUtc})',
                  releaseYear: challenge.scene.releaseYear,
                  characterName: challenge.scene.characterName,
                  promptScript: challenge.scene.script,
                  directorCue: challenge.scene.directorNote,
                  emotionalTarget: challenge.scene.targetEmotion,
                  duetLeadA: challenge.scene.duetLeadA,
                  duetLeadB: challenge.scene.duetLeadB,
                  improvTwist: challenge.dailyCurveball,
                );
                final directSession = LobbySession(
                  id: 'cattle_call_${challenge.dateKeyUtc}',
                  roomCode: roomCode,
                  hostId: 'local-s26-actor',
                  selectedCategory: SceneCategory.era1970To1999,
                  status: 'performing',
                  activeActorId: 'local-s26-actor',
                  activeScene: prompt,
                  livekitRoomName: 'act_like_it_$roomCode',
                );
                await Navigator.of(context).push(
                  StageSharedTransitionRoute(
                    page: LiveKitSoundstageScreen(
                      lobbySession: directSession,
                      localUserId: 'local-s26-actor',
                      localDisplayName: AuthService
                              .instance.currentProfile?.displayName ??
                          'Galaxy S26 Actor',
                    ),
                  ),
                );
                _refreshVipHudState();
              },
              icon: const Icon(Icons.campaign_rounded, size: 18),
              label: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '🎬 AUDITION TODAY\'S CATTLE CALL (FREE DAILY ENTRY · TOP 10 REEL)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Fixture #10: First-Person Walk of Fame Brass Star embedded in the Red Carpet floor.
  Widget _buildWalkOfFameBrassStarPlaque() {
    final profile = AuthService.instance.currentProfile;
    final handle = profile?.username.isNotEmpty == true
        ? '@${profile!.username.toUpperCase()}'
        : '@GALAXY_S26_ACTOR';
    final wins = OfflineManager.instance.totalCareerWins;
    final avg = OfflineManager.instance.averageFinalScore;
    final bestScore = math.max(96.4, avg);

    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        await _pauseMusicBeforeNavigation();
        if (!mounted) return;
        await Navigator.of(context).push(
          StageSharedTransitionRoute(
            page: const MatchHistoryScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xD9120D16),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF5DEB3), width: 1.6),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.stars_rounded,
              color: Color(0xFFFFD700),
              size: 26,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⭐ HOLLYWOOD WALK OF FAME BRASS STAR · $handle',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Highest Verdict: ${bestScore.toStringAsFixed(1)}/100 · Academy Wins: $wins · Signature Era: 1970–1999',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9.5,
                      color: Color(0xFFF5DEB3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
