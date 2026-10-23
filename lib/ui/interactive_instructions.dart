import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Data model for each Digital Clapperboard / Glowing Movie Ticket Story Slide
/// inside `InteractiveInstructionsScreen`.
class InstructionStorySlide {
  final String takeNumber;
  final String slateCode;
  final String badgeLabel;
  final String title;
  final String subtitle;
  final String weightBadge;
  final Color neonAccent;
  final IconData primaryIcon;
  final List<InstructionHighlightPoint> highlights;
  final String interactiveDemoCaption;

  const InstructionStorySlide({
    required this.takeNumber,
    required this.slateCode,
    required this.badgeLabel,
    required this.title,
    required this.subtitle,
    required this.weightBadge,
    required this.neonAccent,
    required this.primaryIcon,
    required this.highlights,
    required this.interactiveDemoCaption,
  });
}

class InstructionHighlightPoint {
  final IconData icon;
  final String heading;
  final String detail;

  const InstructionHighlightPoint({
    required this.icon,
    required this.heading,
    required this.detail,
  });
}

const List<InstructionStorySlide> kInstructionStorySlides = [
  InstructionStorySlide(
    takeNumber: 'SCENE 01 · TAKE 1',
    slateCode: 'STAGE · PRE-ROLL & TELEPROMPTER',
    badgeLabel: 'HOW TO PLAY',
    title: '10-Second Pre-Roll & Live Teleprompter',
    subtitle:
        'Step onto the digital soundstage, lock into character during the 10-second countdown, and deliver your lines as the neon teleprompter scrolls.',
    weightBadge: 'STAGE FLOW',
    neonAccent: Color(0xFFF59E0B), // 24K Spotlight Gold
    primaryIcon: Icons.videocam_rounded,
    highlights: [
      InstructionHighlightPoint(
        icon: Icons.timer_outlined,
        heading: '10-Second Director Pre-Roll',
        detail:
            'Use the 10-second slate countdown to frame your camera, read the Director Cue, and lock into your target emotion before recording starts.',
      ),
      InstructionHighlightPoint(
        icon: Icons.subtitles_outlined,
        heading: 'Synchronized Script Teleprompter',
        detail:
            'Your monologue or scene script scrolls smoothly over the camera viewfinder so you never break eye contact with the lens.',
      ),
      InstructionHighlightPoint(
        icon: Icons.sensors_rounded,
        heading: 'Live Ensemble Screening Room',
        detail:
            'Up to 8 ensemble co-stars spectate your take in real time in the Screening Room or pass the phone in Offline Party Mode.',
      ),
    ],
    interactiveDemoCaption: 'TAP SLATE TO TEST 10s PRE-ROLL CUE',
  ),
  InstructionStorySlide(
    takeNumber: 'SCENE 02 · TAKE 1',
    slateCode: 'MODALITY 01 · GEMINI MULTIMODAL',
    badgeLabel: 'AI TELEMETRICS JUDGING',
    title: 'Facial Micro-Expressions & Voice Prosody',
    subtitle:
        'Our AI Director analyzes sampled video frames and vocal decibel cadence against the scene\'s emotional target.',
    weightBadge: '45% SCORE WEIGHT',
    neonAccent: Color(0xFFE11D48), // Neon Crimson
    primaryIcon: Icons.psychology_alt_rounded,
    highlights: [
      InstructionHighlightPoint(
        icon: Icons.face_retouching_natural_rounded,
        heading: 'Facial Micro-Expression Scan',
        detail:
            'Evaluates eye intensity, brow tension, and emotional authenticity across keyframes sampled during your take.',
      ),
      InstructionHighlightPoint(
        icon: Icons.graphic_eq_rounded,
        heading: 'Vocal Prosody & Cadence',
        detail:
            'Measures vocal projection (dBFS), pacing, and dramatic pauses against the scripted beat.',
      ),
      InstructionHighlightPoint(
        icon: Icons.movie_filter_outlined,
        heading: 'Director Cue Fidelity',
        detail:
            'Generates an instant 0–100 AI Telemetrics breakdown plus a personalized Director Critique.',
      ),
    ],
    interactiveDemoCaption: 'LIVE TELEMETRY: FACIAL · VOCAL · CUE FIDELITY',
  ),
  InstructionStorySlide(
    takeNumber: 'SCENE 03 · TAKE 1',
    slateCode: 'MODALITY 02 · LOOP REPLAY',
    badgeLabel: 'PEER JUDGING',
    title: 'Swipe to Rate Remote Friends 1 to 10',
    subtitle:
        'Immediately after "Cut!", your performance loops continuously in the Screening Room while the ensemble scores your conviction.',
    weightBadge: '35% SCORE WEIGHT',
    neonAccent: Color(0xFFF59E0B), // Neon Amber
    primaryIcon: Icons.thumbs_up_down_rounded,
    highlights: [
      InstructionHighlightPoint(
        icon: Icons.loop_rounded,
        heading: 'Instant Continuous Video Loop',
        detail:
            'Every take auto-replays on an endless loop so spectators can savor the best dramatic beats while voting.',
      ),
      InstructionHighlightPoint(
        icon: Icons.swipe_rounded,
        heading: 'Interactive 1-to-10 Peer Rating',
        detail:
            'Slide or tap from 1 to 10 to lock in your peer verdict—rewarding fearless commitment or hilarious improvisation.',
      ),
      InstructionHighlightPoint(
        icon: Icons.bolt_rounded,
        heading: 'Realtime Lobby Aggregation',
        detail:
            'Votes synchronize live across all connected devices to compute the 35% Peer Judging pillar.',
      ),
    ],
    interactiveDemoCaption: 'DRAG THE PREVIEW SLIDER BELOW TO TEST PEER VOTING',
  ),
  InstructionStorySlide(
    takeNumber: 'SCENE 04 · TAKE 1',
    slateCode: 'MODALITY 03 · CROWD VERDICT',
    badgeLabel: 'SOCIAL MEDIA JUDGING',
    title: 'Export Clips for the Crowd Verdict',
    subtitle:
        'Share your looped performance reel to external social platforms and let external reactions & shares boost your composite score.',
    weightBadge: '20% SCORE WEIGHT',
    neonAccent: Color(0xFFA855F7), // Neon Purple
    primaryIcon: Icons.share_arrival_time_rounded,
    highlights: [
      InstructionHighlightPoint(
        icon: Icons.ios_share_rounded,
        heading: 'One-Tap Reel Export',
        detail:
            'Export your recorded MP4 take or public loop link directly to TikTok, Reels, Shorts, or group chats.',
      ),
      InstructionHighlightPoint(
        icon: Icons.favorite_border_rounded,
        heading: 'Logarithmic Crowd Boost',
        detail:
            'External shares, crowd reactions, and loop completions feed into the 20% Social Judging formula.',
      ),
      InstructionHighlightPoint(
        icon: Icons.emoji_events_outlined,
        heading: 'Composite Tri-Modal Crown',
        detail:
            'AI (45%) + Peer (35%) + Social (20%) combine into your final 0–100 Composite Score & Career Trophy Room record!',
      ),
    ],
    interactiveDemoCaption: 'COMPOSITE = 45% AI + 35% PEER + 20% SOCIAL',
  ),
];

/// Interactive, swipeable "Story Carousel" Instructions Screen styled with the
/// "Living Marquee" dark obsidian aesthetic (`#07090E`) and digital clapperboard
/// / glowing movie ticket cards.
class InteractiveInstructionsScreen extends StatefulWidget {
  const InteractiveInstructionsScreen({super.key});

  @override
  State<InteractiveInstructionsScreen> createState() =>
      _InteractiveInstructionsScreenState();
}

class _InteractiveInstructionsScreenState
    extends State<InteractiveInstructionsScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _spotlightController;

  int _currentIndex = 0;
  double _pageOffset = 0.0;
  double _demoPeerRating = 9.0;
  int _demoCountdown = 10;
  int _demoSocialReactions = 12;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _pageController.addListener(_onPageScroll);

    _spotlightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  void _onPageScroll() {
    if (!mounted || !_pageController.hasClients) return;
    setState(() {
      _pageOffset = _pageController.page ?? _currentIndex.toDouble();
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _spotlightController.dispose();
    super.dispose();
  }

  void _goToSlide(int index) {
    final target = index.clamp(0, kInstructionStorySlides.length - 1);
    HapticFeedback.selectionClick();
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  void _closeInstructionsBackToLobby() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentSlide = kInstructionStorySlides[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated Living Marquee neon spotlight backdrop
          AnimatedBuilder(
            animation: _spotlightController,
            builder: (context, _) {
              return CustomPaint(
                painter: _InstructionsMarqueeBackdropPainter(
                  progress: _spotlightController.value,
                  activeAccent: currentSlide.neonAccent,
                ),
              );
            },
          ),
          SafeArea(
            child: Column(
              children: [
                _buildStoryTopHeader(currentSlide),
                const SizedBox(height: 10),
                _buildStorySegmentedProgressBar(),
                const SizedBox(height: 14),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: kInstructionStorySlides.length,
                    onPageChanged: (index) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final slide = kInstructionStorySlides[index];
                      final delta = (_pageOffset - index).abs().clamp(0.0, 1.0);
                      final scale = 1.0 - (delta * 0.05);

                      return Transform.scale(
                        scale: scale,
                        child: _buildClapperboardTicketSlide(
                          slide: slide,
                          index: index,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _buildBottomStoryControls(currentSlide),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryTopHeader(InstructionStorySlide currentSlide) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      child: Row(
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: currentSlide.neonAccent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: currentSlide.neonAccent.withValues(alpha: 0.7),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.movie_creation_outlined,
                      size: 14,
                      color: currentSlide.neonAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'DIRECTOR\'S HANDBOOK · ${currentSlide.takeNumber}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: currentSlide.neonAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: _closeInstructionsBackToLobby,
            tooltip: 'Back to Lobby',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF121722),
              side: const BorderSide(color: Color(0xFF1E293B)),
            ),
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  /// Social-media "Story" style segmented top indicator + glowing progress bars.
  Widget _buildStorySegmentedProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: List.generate(kInstructionStorySlides.length, (index) {
          final slide = kInstructionStorySlides[index];
          final bool isCompleted = index < _currentIndex;
          final bool isCurrent = index == _currentIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => _goToSlide(index),
              child: Container(
                height: 6,
                margin: EdgeInsets.only(
                  right: index == kInstructionStorySlides.length - 1 ? 0 : 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF161D2B),
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: slide.neonAccent.withValues(alpha: 0.55),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                clipBehavior: Clip.antiAlias,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: isCompleted
                      ? 1.0
                      : (isCurrent ? 1.0 : 0.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? slide.neonAccent
                          : slide.neonAccent.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildClapperboardTicketSlide({
    required InstructionStorySlide slide,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xF507090E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: slide.neonAccent.withValues(alpha: 0.75),
                width: 1.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: slide.neonAccent.withValues(alpha: 0.22),
                  blurRadius: 24,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
          // Top Clapperboard Diagonal Stripes Bar
          SizedBox(
            height: 28,
            child: CustomPaint(
              painter: _ClapperStripeHeaderPainter(
                accentColor: slide.neonAccent,
              ),
            ),
          ),
          // Digital Slate Metadata Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF121826),
              border: Border(
                bottom: BorderSide(color: Color(0xFF1E293B), width: 1.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      slide.slateCode,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: slide.neonAccent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: slide.neonAccent, width: 1),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      slide.weightBadge,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: slide.neonAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Scrollable Ticket Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: slide.neonAccent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: slide.neonAccent.withValues(alpha: 0.8),
                            width: 1.4,
                          ),
                        ),
                        child: Icon(
                          slide.primaryIcon,
                          color: slide.neonAccent,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slide.badgeLabel,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.3,
                                color: slide.neonAccent,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              slide.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    slide.subtitle,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Perforated Movie Ticket Divider
                  _buildPerforatedTicketDivider(slide.neonAccent),
                  const SizedBox(height: 14),
                  // Highlight Cards
                  ...slide.highlights.map(
                    (point) => _buildHighlightRow(
                      point: point,
                      accent: slide.neonAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Interactive Mini Sandbox per Slide
                  _buildInteractiveSlideSandbox(index, slide),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
      ),
      ),
    );
  }

  Widget _buildPerforatedTicketDivider(Color accent) {
    return Row(
      children: List.generate(24, (i) {
        return Expanded(
          child: Container(
            height: 1.5,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            color: i.isEven
                ? accent.withValues(alpha: 0.45)
                : Colors.transparent,
          ),
        );
      }),
    );
  }

  Widget _buildHighlightRow({
    required InstructionHighlightPoint point,
    required Color accent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF131926),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(point.icon, size: 18, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.heading,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  point.detail,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.38,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Provides a tactile, interactive mini-widget on each slide so users can
  /// play with the concept instead of just reading text.
  Widget _buildInteractiveSlideSandbox(
    int index,
    InstructionStorySlide slide,
  ) {
    switch (index) {
      case 0:
        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            setState(() {
              _demoCountdown = _demoCountdown <= 1 ? 10 : _demoCountdown - 1;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF090D15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: slide.neonAccent.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: slide.neonAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '00:${_demoCountdown.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: slide.neonAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Teleprompter Preview: "All those moments will be lost in time, like tears in rain..." (Tap to step countdown)',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case 1:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF090D15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: slide.neonAccent.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniMetricPill('FACIAL', '94', slide.neonAccent),
              _buildMiniMetricPill('VOCAL dB', '91', const Color(0xFFF59E0B)),
              _buildMiniMetricPill('CUE FIT', '96', const Color(0xFF10B981)),
            ],
          ),
        );
      case 2:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF090D15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: slide.neonAccent.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TEST PEER RATING SLIDER (1–10)',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    '${_demoPeerRating.toStringAsFixed(0)} / 10 ★',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: slide.neonAccent,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _demoPeerRating,
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: slide.neonAccent,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  setState(() => _demoPeerRating = value);
                },
              ),
            ],
          ),
        );
      default:
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _demoSocialReactions += 5);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF090D15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: slide.neonAccent.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CROWD REACTIONS: $_demoSocialReactions FIRES 🔥',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: slide.neonAccent,
                  ),
                ),
                const Text(
                  'TAP TO BOOST +5',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildMiniMetricPill(String label, String score, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 9.5,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '$score/100',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomStoryControls(InstructionStorySlide currentSlide) {
    final bool isFinalSlide =
        _currentIndex == kInstructionStorySlides.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dot indicator row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(kInstructionStorySlides.length, (i) {
              final active = i == _currentIndex;
              final dotColor = kInstructionStorySlides[i].neonAccent;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 7,
                width: active ? 24 : 7,
                decoration: BoxDecoration(
                  color: active ? dotColor : const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_currentIndex > 0) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Color(0xFF334155)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onPressed: () => _goToSlide(_currentIndex - 1),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 15),
                  label: const Text('PREV'),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentSlide.neonAccent,
                    foregroundColor: const Color(0xFF07090E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isFinalSlide
                      ? _closeInstructionsBackToLobby
                      : () => _goToSlide(_currentIndex + 1),
                  icon: Icon(
                    isFinalSlide
                        ? Icons.curtains_closed_rounded
                        : Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      isFinalSlide
                          ? 'BACK TO RED CARPET'
                          : 'NEXT SLIDE (${_currentIndex + 1}/${kInstructionStorySlides.length})',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClapperStripeHeaderPainter extends CustomPainter {
  final Color accentColor;

  const _ClapperStripeHeaderPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF06080D);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final stripePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;

    const double stripeWidth = 22.0;
    const double slant = 14.0;
    for (double x = -size.height;
        x < size.width + size.height;
        x += stripeWidth * 2) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + stripeWidth, size.height)
        ..lineTo(x + stripeWidth + slant, 0)
        ..lineTo(x + slant, 0)
        ..close();
      canvas.drawPath(path, stripePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ClapperStripeHeaderPainter oldDelegate) =>
      oldDelegate.accentColor != accentColor;
}

class _InstructionsMarqueeBackdropPainter extends CustomPainter {
  final double progress;
  final Color activeAccent;

  const _InstructionsMarqueeBackdropPainter({
    required this.progress,
    required this.activeAccent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgRect = Offset.zero & size;
    final velvetPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.55),
        radius: 1.35,
        colors: [
          Color(0xFF520002),
          Color(0xFF1A050A),
          Color(0xFF07090E),
        ],
        stops: [0.0, 0.48, 1.0],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, velvetPaint);

    final angle = progress * 2 * math.pi;
    final primaryCenter = Offset(
      size.width * (0.5 + 0.25 * math.cos(angle)),
      size.height * (0.28 + 0.12 * math.sin(angle)),
    );
    final secondaryCenter = Offset(
      size.width * (0.5 - 0.28 * math.sin(angle)),
      size.height * (0.76 + 0.1 * math.cos(angle)),
    );

    final primaryPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF5DEB3).withValues(alpha: 0.20),
          activeAccent.withValues(alpha: 0.14),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: primaryCenter, radius: size.width * 0.65),
      );
    canvas.drawCircle(primaryCenter, size.width * 0.65, primaryPaint);

    final secondaryPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF520002).withValues(alpha: 0.35),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: secondaryCenter, radius: size.width * 0.55),
      );
    canvas.drawCircle(secondaryCenter, size.width * 0.55, secondaryPaint);
  }

  @override
  bool shouldRepaint(
          covariant _InstructionsMarqueeBackdropPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.activeAccent != activeAccent;
}
