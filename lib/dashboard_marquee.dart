import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter, MaskFilter;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';
import 'lobby.dart';
import 'webrtc_manager.dart';
import 'late_night_vault.dart';
import 'offline_manager.dart';
import 'match_history_screen.dart';
import 'ui/interactive_instructions.dart';
import 'ui/game_settings_modal.dart';
import 'ui/scene_vault_screen.dart';

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
    neonColor: Color(0xFFF59E0B), // Neon Amber
    icon: Icons.movie_filter_outlined,
  ),
  MarqueeTicketSpec(
    category: SceneCategory.era2000To2026,
    ticketCode: 'REEL 00–26',
    title: 'Eras: 2000–2026',
    subtitle: 'Modern Prestige & High-Voltage Cinema',
    spotlightFilm: 'The Dark Knight · Whiplash · Hidden Figures',
    neonColor: Color(0xFF06B6D4), // Neon Cyan
    icon: Icons.auto_awesome_motion_outlined,
  ),
  MarqueeTicketSpec(
    category: SceneCategory.awardsBestActor,
    ticketCode: 'OSCAR · LEAD',
    title: 'Awards: Best Actor',
    subtitle: 'Tour-de-Force Leading Monologues',
    spotlightFilm: 'There Will Be Blood · Training Day · Oppenheimer',
    neonColor: Color(0xFFA855F7), // Neon Purple
    icon: Icons.emoji_events_outlined,
  ),
  MarqueeTicketSpec(
    category: SceneCategory.awardsBestActress,
    ticketCode: 'OSCAR · ICON',
    title: 'Awards: Best Actress',
    subtitle: 'Raw Psychological Power & Precision',
    spotlightFilm: 'Silence of the Lambs · Misery · Black Swan',
    neonColor: Color(0xFFEC4899), // Neon Magenta
    icon: Icons.stars_outlined,
  ),
  MarqueeTicketSpec(
    category: SceneCategory.awardsBestSupportingActor,
    ticketCode: 'SCENE STEALER',
    title: 'Awards: Best Supporting',
    subtitle: 'Unforgettable High-Impact Turns',
    spotlightFilm: 'Good Will Hunting · Glengarry Glen Ross · Django',
    neonColor: Color(0xFF22D3EE), // Electric Cyan
    icon: Icons.theater_comedy_outlined,
  ),
  MarqueeTicketSpec(
    category: SceneCategory.awardsBestVillain,
    ticketCode: 'ANTAGONIST',
    title: 'Awards: Best Villain',
    subtitle: 'Cold Fatalism & Commanding Menace',
    spotlightFilm: 'No Country for Old Men · Wall Street · Few Good Men',
    neonColor: Color(0xFFF43F5E), // Neon Crimson
    icon: Icons.whatshot_outlined,
  ),
  MarqueeTicketSpec(
    category: SceneCategory.awardsEmmyVault,
    ticketCode: 'PRESTIGE TV',
    title: 'Awards: Emmy Vault',
    subtitle: 'Peak Television Finale Showdowns',
    spotlightFilm: 'Breaking Bad · Succession · The Bear · The Sopranos',
    neonColor: Color(0xFFFBBF24), // Marquee Gold
    icon: Icons.live_tv_outlined,
  ),
  MarqueeTicketSpec(
    category: SceneCategory.specialtyCultClassics,
    ticketCode: 'MIDNIGHT REEL',
    title: 'Specialty: Cult Classics',
    subtitle: 'Late-Show Quotables & Underground Legends',
    spotlightFilm: 'Rocky Horror · The Big Lebowski · Fight Club',
    neonColor: Color(0xFFC084FC), // Violet Glow
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
    extends State<LivingMarqueeDashboardScreen> with TickerProviderStateMixin {
  // 1. Continuous Stage Spotlight & Backstage Pulse Controller
  late final AnimationController _spotlightController;
  late final AnimationController _frenzyBurstController;

  // 2. Action Clapperboard Physical Snap Controller
  late final AnimationController _clapperController;
  bool _isClappingShut = false;

  // 3. Horizontally Scrolling Glowing Movie Ticket Carousel Controller
  late final PageController _ticketPageController;
  late final ScrollController _redCarpetScrollController;
  double _redCarpetScrollOffset = 0.0;
  double _redCarpetScrollVelocity = 0.0;
  int _lastStanchionTickIndex = 0;
  Offset? _activeTouchPosition;
  double _currentTicketPage = 0.0;
  int _focusedTicketIndex = 0;

  // 4. Global Marquee Continuous Live Ticker Controller
  late final AnimationController _marqueeTickerController;

  // 5. Game Show Background Music Loop Controller
  late final AudioPlayer _audioPlayer;
  bool _isMusicPlaying = true;
  static const String _gameShowSoundtrackUrl =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  static const List<String> _liveMarqueeFeedItems = [
    'STAGE LIVE · ROOM #482910 PERFORMING "THE DARK KNIGHT (2008)" — 7 SPECTATORS ON SFU',
    'HIGH SCORE · @NAOMI_V HIT 98.4 COMPOSITE TRI-MODAL SCORE ON "WHIPLASH"',
    'AI TELEMETRICS · GEMINI 2.5 FLASH EVALUATED 1,420 MICRO-EXPRESSION FRAMES THIS HOUR',
    'VIRAL LOOP · @MARCUS_S26 HIT +410 SOCIAL SHARES IN SPECIALTY: CULT CLASSICS',
    'AFTER-HOURS 18+ VAULT · 15s MID-TAKE IMPROVISATION TWIST ACTIVE IN 19 LOBBIES',
  ];

  @override
  void initState() {
    super.initState();

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
    _initGameShowMusicLoop();

    OfflineManager.instance.ensureInitialized().then((_) {
      if (mounted) setState(() {});
    });
  }

  void _onRedCarpetScroll() {
    if (!mounted || !_redCarpetScrollController.hasClients) return;
    final nextOffset = _redCarpetScrollController.offset;
    final delta = (nextOffset - _redCarpetScrollOffset).abs();

    // Subtle haptic tick as the player walks past each 3D gold brass stanchion post
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
      await _audioPlayer.play(
        UrlSource(_gameShowSoundtrackUrl),
      );
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

  Future<void> _toggleBackgroundMusic() async {
    try {
      if (_isMusicPlaying) {
        await _audioPlayer.pause();
        if (mounted) {
          setState(() {
            _isMusicPlaying = false;
          });
        }
      } else {
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
    final settings = await showModalBottomSheet<GameSettingsConfig>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GameSettingsModal(modeTitle: modeTitle),
    );
    if (settings == null || !mounted) return;

    await _pauseMusicBeforeNavigation();
    if (!mounted) return;

    final selectedTicket = kSceneVaultTickets[_focusedTicketIndex];
    await Navigator.of(context).push(
      StageSharedTransitionRoute(
        page: LobbyMatchmakingScreen(
          initialCategory: selectedTicket.category,
          startInJoinMode: joinMode,
        ),
      ),
    );
  }

  /// Triggers the physical clapperboard "clap" shut animation before navigating
  /// to the 6-digit matchmaking lobby with the currently focused ticket category.
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

  /// Launches the Active Acting Screen (`LiveKitSoundstageScreen`) directly from
  /// the focused Movie Ticket in the carousel using a Shared Element (`Hero`)
  /// arc flight (`SceneHeroTags.ticketTag` + `StageSharedTransitionRoute`).
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
    final geminiCtrl = TextEditingController(text: AppConfig.geminiApiKey);
    final supaUrlCtrl = TextEditingController(text: AppConfig.supabaseUrl);
    final supaKeyCtrl = TextEditingController(text: AppConfig.supabaseAnonKey);
    final liveKitCtrl = TextEditingController(text: AppConfig.liveKitUrl);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0E121D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEON BACKSTAGE · CLOUD API CREDENTIALS',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF06B6D4),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Galaxy S26 Ultra Runtime Vault',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: geminiCtrl,
                  decoration: const InputDecoration(
                    labelText: 'GEMINI_API_KEY (AI Telemetrics)',
                    filled: true,
                    fillColor: Color(0xFF06080E),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: supaUrlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'SUPABASE_URL (https://xxx.supabase.co)',
                    filled: true,
                    fillColor: Color(0xFF06080E),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: supaKeyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'SUPABASE_ANON_KEY',
                    filled: true,
                    fillColor: Color(0xFF06080E),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: liveKitCtrl,
                  decoration: const InputDecoration(
                    labelText: 'LIVEKIT_URL (wss://xxx.livekit.cloud)',
                    filled: true,
                    fillColor: Color(0xFF06080E),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await AppConfig.saveRuntimeConfig(
                        geminiKey: geminiCtrl.text,
                        supabaseProjectUrl: supaUrlCtrl.text,
                        supabaseKey: supaKeyCtrl.text,
                        liveKitServerUrl: liveKitCtrl.text,
                      );
                      if (!mounted) return;
                      Navigator.of(ctx).pop();
                      setState(() {});
                    },
                    child: const Text('Save Runtime Cloud Credentials'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070B),
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

            return Stack(
              fit: StackFit.expand,
              children: [
                // --------------------------------------------------------------
                // 1. BASE LAYER: 3D Perspective Red Carpet, Brass Stanchions & 42 Bokeh
                // --------------------------------------------------------------
                RepaintBoundary(
                  child: CustomPaint(
                    painter: PaparazziRedCarpetPainter(
                      scrollOffset: _redCarpetScrollOffset,
                      phase: phase,
                      scrollVelocity: _redCarpetScrollVelocity,
                      touchPosition: _activeTouchPosition,
                    ),
                  ),
                ),

                // --------------------------------------------------------------
                // 2. OVERLAY LAYER: Paparazzi Silhouettes & 4-Point Star-Burst Flashes
                // --------------------------------------------------------------
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

                // --------------------------------------------------------------
                // 3. FOREGROUND: 3D Holographic Marquee + 6 Bespoke Doors + Chyron
                // --------------------------------------------------------------
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
                              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                              sliver: SliverToBoxAdapter(
                                child: Interactive3DHolographicMarquee(
                                  phase: phase,
                                  onPaparazziFrenzy: _triggerPaparazziFrenzy,
                                  trailingControls:
                                      _buildPaparazziPremiereHeader(),
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
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
                                      await _pauseMusicBeforeNavigation();
                                      if (!mounted) return;
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const LateNightAfterHoursScreen(),
                                        ),
                                      );
                                    },
                                    onTrophyVaultTap: () async {
                                      await _pauseMusicBeforeNavigation();
                                      if (!mounted) return;
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const MatchHistoryScreen(),
                                        ),
                                      );
                                    },
                                    onCameraViewfinderTap: () async {
                                      await _pauseMusicBeforeNavigation();
                                      if (!mounted) return;
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const InteractiveInstructionsScreen(),
                                        ),
                                      );
                                    },
                                    onBoxOfficeVaultTap: () async {
                                      await _pauseMusicBeforeNavigation();
                                      if (!mounted) return;
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const SceneVaultScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Floating Holographic "LIVE WIRE" Broadcast Chyron at Bottom
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

  // --------------------------------------------------------------------------
  // 2. THE TELEMETRICS HUD (Animated Circular Progress Gauges in Top Corners)
  // --------------------------------------------------------------------------
  Widget _buildTelemetricsHud(double phase) {
    final glowPulse = 0.65 + 0.35 * math.sin(phase * 1.5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xCC0B0E17),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color.lerp(
            const Color(0xFF6D28D9),
            const Color(0xFF06B6D4),
            (math.sin(phase) + 1) * 0.5,
          )!,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withOpacity(0.18 * glowPulse),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top-Left Corner: AI Telemetrics & Peer Gauges
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAnimatedHudGauge(
                label: 'AI',
                targetScore: 94.0,
                neonColor: const Color(0xFFA855F7),
                phase: phase,
              ),
              const SizedBox(width: 10),
              _buildAnimatedHudGauge(
                label: 'PEER',
                targetScore: 89.0,
                neonColor: const Color(0xFF06B6D4),
                phase: phase + 1.2,
              ),
            ],
          ),

          // Center Stage Identity & Cloud Config Trigger
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF10B981),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981)
                                .withOpacity(0.8 * glowPulse),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Flexible(
                      child: Text(
                        'ACT LIKE IT',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                GestureDetector(
                  onTap: _openCloudConfigBottomSheet,
                  child: Text(
                    AppConfig.hasCloudSupabase
                        ? 'CLOUD SFU SYNCED · CONFIG'
                        : 'S26 ULTRA STAGE · KEYS',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Top-Right Corner: Social Gauge + Composite Rank
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAnimatedHudGauge(
                label: 'SOCIAL',
                targetScore: 92.0,
                neonColor: const Color(0xFFF59E0B),
                phase: phase + 2.4,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHudGauge({
    required String label,
    required double targetScore,
    required Color neonColor,
    required double phase,
  }) {
    final pulse = 0.7 + 0.3 * math.sin(phase * 2.0);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: targetScore / 100.0),
      duration: const Duration(milliseconds: 1700),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) {
        final displayValue = (progress * 100).round();
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: neonColor.withOpacity(0.28 * pulse),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4.0,
                    backgroundColor: const Color(0xFF1E293B),
                    valueColor: AlwaysStoppedAnimation<Color>(neonColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$displayValue',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: neonColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLivingMarqueeHeader(double phase) {
    final activeTicket = kSceneVaultTickets[_focusedTicketIndex];
    final shimmer = (math.sin(phase * 2) + 1) * 0.5;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THE LIVING MARQUEE · NEON BACKSTAGE',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Color.lerp(
                    const Color(0xFF06B6D4),
                    const Color(0xFFF59E0B),
                    shimmer,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'LOADED REEL: ${activeTicket.title.toUpperCase()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _toggleBackgroundMusic,
          tooltip: _isMusicPlaying ? 'Mute Stage Music' : 'Unmute Stage Music',
          icon: Icon(
            _isMusicPlaying ? Icons.volume_up : Icons.volume_off,
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

  // --------------------------------------------------------------------------
  // 3. THE "ACTION" CLAPPERBOARD (Code-Drawn Movie Clapperboard Primary CTA)
  // --------------------------------------------------------------------------
  Widget _buildActionClapperboard(double phase) {
    final activeTicket = kSceneVaultTickets[_focusedTicketIndex];
    final idleBreathingAngle = -0.26 - 0.04 * math.sin(phase * 2.2);

    return GestureDetector(
      onTap: _triggerClapperboardAction,
      child: AnimatedBuilder(
        animation: _clapperController,
        builder: (context, _) {
          // Interpolate from open angled position (-0.28 rad) to snapped shut (0.0 rad)
          final currentAngle =
              idleBreathingAngle * (1.0 - _clapperController.value);
          final isSnapped = _clapperController.value > 0.75;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hinged Top Clapper Stick
              Transform.rotate(
                angle: currentAngle,
                alignment: Alignment.bottomLeft,
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0E17),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    border: Border.all(
                      color: isSnapped
                          ? const Color(0xFFF59E0B)
                          : activeTicket.neonColor,
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: activeTicket.neonColor.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CustomPaint(
                    painter: _ClapperZebraStripesPainter(
                      stripeColor: isSnapped
                          ? const Color(0xFFF59E0B)
                          : activeTicket.neonColor,
                    ),
                  ),
                ),
              ),

              // Lower Clapperboard Slate Body
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xEB0A0D16),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(14),
                    top: Radius.circular(4),
                  ),
                  border: Border.all(
                    color: isSnapped
                        ? const Color(0xFFF59E0B)
                        : activeTicket.neonColor,
                    width: isSnapped ? 2.6 : 1.6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isSnapped
                              ? const Color(0xFFF59E0B)
                              : activeTicket.neonColor)
                          .withOpacity(isSnapped ? 0.55 : 0.25),
                      blurRadius: isSnapped ? 26 : 16,
                      spreadRadius: isSnapped ? 2 : 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Clapperboard Slate Metadata Grid
                    Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF1E293B),
                            width: 1.2,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildSlateCell(
                            label: 'PROD.',
                            value: 'ACT LIKE IT',
                            accent: Colors.white,
                          ),
                          _buildSlateDivider(),
                          _buildSlateCell(
                            label: 'REEL',
                            value: activeTicket.ticketCode,
                            accent: activeTicket.neonColor,
                          ),
                          _buildSlateDivider(),
                          _buildSlateCell(
                            label: 'TAKE',
                            value: isSnapped ? 'ACTION!' : '01 · LIVE',
                            accent: const Color(0xFFF59E0B),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Primary Clapperboard Call-To-Action Row
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: activeTicket.neonColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: activeTicket.neonColor,
                              width: 1.4,
                            ),
                          ),
                          child: Icon(
                            Icons.movie_creation_outlined,
                            color: activeTicket.neonColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CREATE LOBBY / QUICK PLAY',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tap Clapperboard to Snap Shut & Launch ${activeTicket.title}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: Color(0xFFCBD5E1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: activeTicket.neonColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'CLAP',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF05060A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSlateCell({
    required String label,
    required String value,
    required Color accent,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlateDivider() {
    return Container(
      width: 1.2,
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: const Color(0xFF1E293B),
    );
  }

  Widget _buildBackstageQuickBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF06B6D4),
                  side: const BorderSide(color: Color(0xFF06B6D4), width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: const Color(0x990B0E17),
                ),
                onPressed: () async {
                  await _pauseMusicBeforeNavigation();
                  if (!mounted) return;
                  Navigator.of(context).push(
                    StageSharedTransitionRoute(
                      page: LobbyMatchmakingScreen(
                        initialCategory:
                            kSceneVaultTickets[_focusedTicketIndex].category,
                        startInJoinMode: true,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.dialpad_rounded, size: 16),
                label: const Text(
                  'JOIN 6-DIGIT ROOM',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF59E0B),
                  side: const BorderSide(color: Color(0xFFF59E0B), width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: const Color(0x990B0E17),
                ),
                onPressed: () async {
                  await _pauseMusicBeforeNavigation();
                  if (!mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LateNightAfterHoursScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.lock_outline_rounded, size: 16),
                label: const Text(
                  '18+ AFTER-HOURS',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF10B981),
            side: const BorderSide(color: Color(0xFF10B981), width: 1.2),
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
            backgroundColor: const Color(0x990B0E17),
          ),
          onPressed: () async {
            await _pauseMusicBeforeNavigation();
            if (!mounted) return;
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const MatchHistoryScreen(),
              ),
            );
          },
          icon: const Icon(Icons.emoji_events_outlined, size: 16),
          label: Text(
            'CAREER TROPHY ROOM · ${OfflineManager.instance.totalCareerWins} WINS · AVG ${OfflineManager.instance.averageFinalScore.toStringAsFixed(1)}',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFA855F7),
            side: const BorderSide(color: Color(0xFFA855F7), width: 1.2),
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
            backgroundColor: const Color(0x990B0E17),
          ),
          onPressed: () async {
            await _pauseMusicBeforeNavigation();
            if (!mounted) return;
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const InteractiveInstructionsScreen(),
              ),
            );
          },
          icon: const Icon(Icons.auto_stories_rounded, size: 16),
          label: const Text(
            'HOW TO PLAY · STORY CAROUSEL GUIDE',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  /// Career Trophy Room Drawer / Modal Sheet injected into the Living Marquee
  /// dashboard without altering existing spotlight or ticket animations.
  Future<void> _openCareerTrophyRoomDrawer() async {
    HapticFeedback.mediumImpact();
    await _pauseMusicBeforeNavigation();
    await OfflineManager.instance.refreshMatchHistoryFromSupabase();
    if (!mounted) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0D16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.78,
          minChildSize: 0.50,
          maxChildSize: 0.94,
          builder: (context, scrollController) {
            return AnimatedBuilder(
              animation: OfflineManager.instance,
              builder: (context, _) {
                final mgr = OfflineManager.instance;
                final records = mgr.matchHistoryLog;
                final totalMatches = records.length;
                final totalWins = mgr.totalCareerWins;
                final winRate = totalMatches == 0
                    ? 0.0
                    : (totalWins / totalMatches) * 100.0;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CAREER TROPHY ROOM · MATCH HISTORY',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Win Tracking & Tri-Modal Ledger',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF10B981),
                              side: const BorderSide(color: Color(0xFF10B981)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                            ),
                            onPressed: () async {
                              await mgr.refreshMatchHistoryFromSupabase();
                            },
                            icon: const Icon(Icons.sync_rounded, size: 15),
                            label: Text(
                              mgr.pendingMatchHistorySyncCount > 0
                                  ? 'SYNC (${mgr.pendingMatchHistorySyncCount})'
                                  : 'SYNCED',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildTrophyStatTile(
                            label: 'TOTAL WINS',
                            value: '$totalWins / $totalMatches',
                            sublabel: '${winRate.toStringAsFixed(0)}% WIN RATE',
                            accent: const Color(0xFF10B981),
                          ),
                          const SizedBox(width: 10),
                          _buildTrophyStatTile(
                            label: 'AVG FINAL',
                            value: mgr.averageFinalScore.toStringAsFixed(1),
                            sublabel: 'COMPOSITE / 100',
                            accent: const Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 10),
                          _buildTrophyStatTile(
                            label: 'AVG AI / PEER',
                            value:
                                '${mgr.averageAiScore.toStringAsFixed(0)} / ${mgr.averagePeerScore.toStringAsFixed(0)}',
                            sublabel: 'GEMINI · ROOM',
                            accent: const Color(0xFFA855F7),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'PAST MATCH LOG (SUPABASE PUBLIC.MATCH_HISTORY)',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.9,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: records.isEmpty
                            ? const Center(
                                child: Text(
                                  'No matches recorded yet. Complete a stage round to populate your Trophy Room!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: records.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, idx) {
                                  final rec = records[idx];
                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF111624),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: rec.isWin
                                            ? const Color(0x6610B981)
                                            : const Color(0xFF1E293B),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                rec.sceneTitle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: rec.isWin
                                                    ? const Color(0x2610B981)
                                                    : const Color(0x2664748B),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                rec.isWin
                                                    ? 'TROPHY WIN'
                                                    : 'COMPLETED',
                                                style: TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: rec.isWin
                                                      ? const Color(0xFF10B981)
                                                      : const Color(0xFF94A3B8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${rec.filmOrSeries} · ${rec.syncedToSupabase ? "Synced to Supabase" : "Queued Offline"}',
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 11,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'AI: ${rec.aiScore.toStringAsFixed(1)} · PEER: ${rec.peerScore.toStringAsFixed(1)} · SOCIAL: ${rec.socialScore.toStringAsFixed(1)}',
                                              style: const TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 11,
                                                color: Color(0xFF06B6D4),
                                              ),
                                            ),
                                            Text(
                                              'FINAL: ${rec.finalScore.toStringAsFixed(1)}',
                                              style: const TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFFF59E0B),
                                              ),
                                            ),
                                          ],
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

  Widget _buildTrophyStatTile({
    required String label,
    required String value,
    required String sublabel,
    required Color accent,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF111624),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withOpacity(0.45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 8,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 4. THE SCENE VAULT (Horizontally Scrolling Glowing Movie Tickets Carousel)
  // --------------------------------------------------------------------------
  Widget _buildSceneVaultTicketSection(double phase) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'THE SCENE VAULT · SWIPE MOVIE TICKETS',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: Color(0xFFE2E8F0),
                ),
              ),
              Text(
                'TICKET 0${_focusedTicketIndex + 1} / 0${kSceneVaultTickets.length}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 215,
          child: PageView.builder(
            controller: _ticketPageController,
            itemCount: kSceneVaultTickets.length,
            onPageChanged: (idx) {
              HapticFeedback.selectionClick();
              setState(() {
                _focusedTicketIndex = idx;
              });
            },
            itemBuilder: (context, index) {
              final ticket = kSceneVaultTickets[index];
              final distance = (_currentTicketPage - index).abs().clamp(0.0, 1.0);
              final focusFactor = 1.0 - distance;

              // Transform.scale expands the ticket in center focus
              final scale = 0.86 + (0.14 * focusFactor);
              final floatOffsetY =
                  math.sin(phase * 2.0 + index) * 4.0 * focusFactor;

              return Transform.translate(
                offset: Offset(0, floatOffsetY),
                child: Transform.scale(
                  scale: scale,
                  child: GestureDetector(
                    onTap: () {
                      if (_focusedTicketIndex != index) {
                        _ticketPageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                        );
                      } else {
                        _triggerClapperboardAction();
                      }
                    },
                    child: Hero(
                      tag: SceneHeroTags.ticketTag(ticket.category),
                      createRectTween: SceneHeroTags.createTicketArcTween,
                      flightShuttleBuilder:
                          SceneHeroTags.buildTicketFlightShuttle,
                      child: Material(
                        type: MaterialType.transparency,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: ticket.neonColor.withOpacity(
                                  0.10 + (0.38 * focusFactor),
                                ),
                                blurRadius: 12 + (18 * focusFactor),
                                spreadRadius: 1 + (2 * focusFactor),
                              ),
                            ],
                          ),
                          child: ClipPath(
                            clipper: _MovieTicketStubClipper(),
                            child: CustomPaint(
                              foregroundPainter: _MovieTicketBorderPainter(
                                neonColor: ticket.neonColor,
                                focusFactor: focusFactor,
                              ),
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(22, 16, 22, 16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color.lerp(
                                        const Color(0xFF0D111C),
                                        ticket.neonColor,
                                        0.18 * focusFactor,
                                      )!,
                                      const Color(0xFF080A12),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Ticket Header Stub Row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ticket.neonColor
                                                .withOpacity(0.18),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: ticket.neonColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            'ADMIT ONE · ${ticket.ticketCode}',
                                            style: TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: ticket.neonColor,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          ticket.icon,
                                          color: ticket.neonColor,
                                          size: 20,
                                        ),
                                      ],
                                    ),

                                    // Ticket Category Title & Subtitle
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ticket.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          ticket.subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFCBD5E1),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Perforated Tear-Line + Featured Reels
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            ticket.spotlightFilm,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: ticket.neonColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () =>
                                              _launchDirectActingStage(ticket),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: focusFactor > 0.65
                                                  ? ticket.neonColor
                                                      .withOpacity(0.22)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: ticket.neonColor
                                                    .withOpacity(
                                                        0.4 + 0.6 * focusFactor),
                                              ),
                                            ),
                                            child: Text(
                                              focusFactor > 0.65
                                                  ? 'STAGE TAKE →'
                                                  : 'SWIPE',
                                              style: const TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // 5. THE GLOBAL MARQUEE (Continuous Scrolling Theater Ticker at Bottom)
  // --------------------------------------------------------------------------
  Widget _buildGlobalMarqueeTicker(double phase) {
    final fullTickerText = _liveMarqueeFeedItems.join('   ★   ');

    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFF080B12),
        border: Border(
          top: BorderSide(color: Color(0xFFF59E0B), width: 1.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: double.infinity,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFF59E0B),
            ),
            child: const Text(
              'LIVE WIRE',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF05060A),
              ),
            ),
          ),
          Expanded(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _marqueeTickerController,
                builder: (context, _) {
                  return FractionalTranslation(
                    translation: Offset(
                      1.0 - (_marqueeTickerController.value * 2.2),
                      0.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$fullTickerText   ★   $fullTickerText',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFDE68A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws subtle animated neon backstage light cones & stage floor perspective lines.
class _NeonBackstageBeamsPainter extends CustomPainter {
  final double phase;

  const _NeonBackstageBeamsPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final beamPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0x18FFFFFF);

    // Subtle moving backstage rigging beams
    for (int i = 0; i < 5; i++) {
      final swing = math.sin(phase + i * 0.9) * 60.0;
      final topX = (size.width / 4) * i;
      final bottomX = topX + swing;
      canvas.drawLine(
        Offset(topX, 0),
        Offset(bottomX, size.height),
        beamPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NeonBackstageBeamsPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

/// Draws the angled diagonal clapperboard zebra stripes on the top hinged stick.
class _ClapperZebraStripesPainter extends CustomPainter {
  final Color stripeColor;

  const _ClapperZebraStripesPainter({required this.stripeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = stripeColor
      ..style = PaintingStyle.fill;

    const stripeWidth = 24.0;
    for (double x = -size.height; x < size.width + size.height; x += stripeWidth * 2) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + stripeWidth, size.height)
        ..lineTo(x + stripeWidth + 18, 0)
        ..lineTo(x + 18, 0)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ClapperZebraStripesPainter oldDelegate) =>
      oldDelegate.stripeColor != stripeColor;
}

/// Clips a card into an authentic theater movie ticket with semicircular side notches.
class _MovieTicketStubClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const cornerRadius = 16.0;
    const notchRadius = 12.0;
    final notchCenterY = size.height * 0.72;

    final path = Path()
      ..moveTo(0, cornerRadius)
      ..quadraticBezierTo(0, 0, cornerRadius, 0)
      ..lineTo(size.width - cornerRadius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, cornerRadius)
      ..lineTo(size.width, notchCenterY - notchRadius)
      ..arcToPoint(
        Offset(size.width, notchCenterY + notchRadius),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      )
      ..lineTo(size.width, size.height - cornerRadius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - cornerRadius,
        size.height,
      )
      ..lineTo(cornerRadius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - cornerRadius)
      ..lineTo(0, notchCenterY + notchRadius)
      ..arcToPoint(
        Offset(0, notchCenterY - notchRadius),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      )
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Paints the glowing neon border and perforated stub tear-line across each Movie Ticket.
class _MovieTicketBorderPainter extends CustomPainter {
  final Color neonColor;
  final double focusFactor;

  const _MovieTicketBorderPainter({
    required this.neonColor,
    required this.focusFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final clipPath = _MovieTicketStubClipper().getClip(size);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 + (1.4 * focusFactor)
      ..color = neonColor.withOpacity(0.45 + (0.55 * focusFactor));

    canvas.drawPath(clipPath, borderPaint);

    // Draw dashed perforation line between the side notches
    final notchY = size.height * 0.72;
    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = neonColor.withOpacity(0.35 + 0.35 * focusFactor);

    const dashWidth = 6.0;
    const dashSpace = 5.0;
    double startX = 16.0;
    while (startX < size.width - 16.0) {
      canvas.drawLine(
        Offset(startX, notchY),
        Offset(math.min(startX + dashWidth, size.width - 16.0), notchY),
        dashPaint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _MovieTicketBorderPainter oldDelegate) =>
      oldDelegate.neonColor != neonColor ||
      oldDelegate.focusFactor != focusFactor;
}
