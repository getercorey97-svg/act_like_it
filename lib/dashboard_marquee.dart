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
import 'social/cutting_room_feed.dart';
import 'auth/auth_service.dart';

export 'ui/brand_logo.dart';

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
    if (mounted) {
      setState(() {
        _savedActiveRoomCode = activeCode;
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
    _frenzyBurstController.forward(from: 0.0);
  }

  Future<void> _initGameShowMusicLoop() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(GameSettingsModal.masterAudioVolume);
      final wavBytes = OpeningPremiereMusicSynthesizer.buildOpeningFanfareWav();
      await _audioPlayer.play(BytesSource(wavBytes));
      if (mounted) {
        setState(() {
          _isMusicPlaying = true;
        });
      }
    } catch (_) {
      try {
        await _audioPlayer.play(UrlSource(_gameShowSoundtrackUrl));
        if (mounted) {
          setState(() {
            _isMusicPlaying = true;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isMusicPlaying = false;
          });
        }
      }
    }
  }

  Future<void> _toggleBackgroundMusic() async {
    try {
      if (_isMusicPlaying) {
        _userManuallyMutedMusic = true;
        await _audioPlayer.pause();
        if (mounted) {
          setState(() {
            _isMusicPlaying = false;
          });
        }
      } else {
        _userManuallyMutedMusic = false;
        await _audioPlayer.resume();
        if (mounted) {
          setState(() {
            _isMusicPlaying = true;
          });
        }
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

  @override
  Widget build(BuildContext context) {
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
                    child: CustomPaint(
                      painter: PaparazziRedCarpetPainter(
                        scrollOffset: _redCarpetScrollOffset,
                        phase: phase,
                        scrollVelocity: _redCarpetScrollVelocity,
                        touchPosition: _activeTouchPosition,
                      ),
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
                                    ),
                                    const SizedBox(height: 10),
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
}
