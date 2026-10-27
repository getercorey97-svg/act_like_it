import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../daily_challenge/daily_cattle_call_card.dart';
import '../late_night_vault.dart';
import '../lobby.dart';
import '../social/cutting_room_feed.dart';
import 'game_settings_modal.dart';
import 'red_carpet_25d_parallax.dart';
import 'soundstage_audio_controller.dart';
import 'transitions.dart';

/// Preference key used to track whether the user has seen the onboarding
/// Story Reel at least once.
const String kHasSeenInteractiveInstructionsPrefKey =
    'act_like_it_seen_interactive_instructions_v2';

/// Structured highlight point inside a single Story Reel slide.
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

/// Structured table row for the Mode Rulebook & Scoring Breakdown tables.
class ModeRulebookTableRow {
  final String phaseOrMetric;
  final String mechanicsAndCue;
  final String multiplierOrWeight;

  const ModeRulebookTableRow({
    required this.phaseOrMetric,
    required this.mechanicsAndCue,
    required this.multiplierOrWeight,
  });
}

/// Immutable data model for each mode tab in the Director's Editing Bay & Rulebook.
class InstructionStorySlide {
  final int stepNumber;
  final String tabPillLabel;
  final String badgeLabel;
  final String title;
  final String subtitle;
  final IconData heroIcon;
  final Color neonAccent;
  final List<InstructionHighlightPoint> points;
  final List<ModeRulebookTableRow> rulesTable;
  final String interactiveTip;
  final String tryModeButtonLabel;

  const InstructionStorySlide({
    required this.stepNumber,
    this.tabPillLabel = '🎬 MODE',
    required this.badgeLabel,
    required this.title,
    required this.subtitle,
    required this.heroIcon,
    required this.neonAccent,
    required this.points,
    this.rulesTable = const <ModeRulebookTableRow>[],
    required this.interactiveTip,
    this.tryModeButtonLabel = '🚀 TRY THIS MODE NOW',
  });
}

/// Canonical 7-mode interactive rulebook for "ACT LIKE IT" (Director's Editing Bay).
const List<InstructionStorySlide> kInstructionStorySlides = [
  InstructionStorySlide(
    stepNumber: 1,
    tabPillLabel: '🎬 CORE SOUNDSTAGE',
    badgeLabel: 'MODE 01 · SOLO & MULTIPLAYER CORE LOOP',
    title: 'Core Soundstage & Tri-Modal Judging',
    subtitle:
        'Step onto the 35mm soundstage, study your script during the 10-second Pre-Roll, deliver a 30-second performance, and get scored by AI + Peers + Crowd.',
    heroIcon: Icons.movie_filter_rounded,
    neonAccent: Color(0xFFF59E0B),
    points: [
      InstructionHighlightPoint(
        icon: Icons.timer_outlined,
        heading: '10-Second Pre-Roll Slate & 30-Second Take',
        detail:
            'Camera & Mic permissions lock in before countdown starts. Read your Character, Emotional Target, and Director Cue while 80% of your viewfinder stays clear, or tap "SKIP & ROLL NOW".',
      ),
      InstructionHighlightPoint(
        icon: Icons.bolt_rounded,
        heading: '15-Second Director Curveball (+5.0 Bonus)',
        detail:
            'At 00:15, a high-contrast gold megaphone directive flashes across the top of the lens. Pivot your vocal delivery and emotion immediately to claim +5.0 Twist Bonus points.',
      ),
      InstructionHighlightPoint(
        icon: Icons.equalizer_rounded,
        heading: 'Normalized Tri-Modal Verdict (Always 100%)',
        detail:
            'Default blend: 45% Gemini 2.5 Flash AI Telemetrics (Facial + Vocal dB + Cue Fidelity) + 35% Live Peer Cast Sliders + 20% Social Crowd Hype.',
      ),
    ],
    rulesTable: [
      ModeRulebookTableRow(
        phaseOrMetric: 'Pre-Roll Slate (10s)',
        mechanicsAndCue: 'Study character, script & emotional target',
        multiplierOrWeight: 'Camera Ready',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: 'AI Telemetrics',
        mechanicsAndCue: 'Facial micro-expression + Vocal dB + Pace',
        multiplierOrWeight: '45% Weight',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: 'Live Peer Judging',
        mechanicsAndCue: '1–10 Star Cast Sliders during video replay',
        multiplierOrWeight: '35% Weight',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: 'Social Crowd Hype',
        mechanicsAndCue: 'Golden Roses, Ovations & Cutting Room Stars',
        multiplierOrWeight: '20% Weight',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: '15s Director Curveball',
        mechanicsAndCue: 'Mid-scene emotional/genre pivot at 00:15',
        multiplierOrWeight: '+5.0 Bonus Pts',
      ),
    ],
    interactiveTip:
        'Tap the live SMPTE clapperboard preview below to test the 10s Pre-Roll -> 15s Curveball -> 30s Cut & Judge loop.',
    tryModeButtonLabel: '🚀 TRY CORE SOUNDSTAGE NOW',
  ),
  InstructionStorySlide(
    stepNumber: 2,
    tabPillLabel: '🛋️ ENSEMBLE & PASS-AND-PLAY',
    badgeLabel: 'MODE 02 · COUCH PARTY & 6-DIGIT ROOMS',
    title: 'Ensemble Cast & Couch Pass-and-Play',
    subtitle:
        'Host up to 8 actors via a 6-digit VIP Set Pass over LiveKit WebRTC SFU, or pass one phone around the living room couch with "+ Pass & Play" & "+ AI Co-Star".',
    heroIcon: Icons.groups_3_rounded,
    neonAccent: Color(0xFF10B981),
    points: [
      InstructionHighlightPoint(
        icon: Icons.confirmation_number_rounded,
        heading: '6-Digit Room Code & Quick-Join Ensemble',
        detail:
            'Generate a 6-digit room code in the Green Room or tap "Quick-Join Public Ensemble" to jump straight into an active soundstage.',
      ),
      InstructionHighlightPoint(
        icon: Icons.couch_rounded,
        heading: '+ Pass & Play & + AI Co-Star Roster Buttons',
        detail:
            'Playing on one phone at a party? Tap "+ Pass & Play" to add local couch actors who take turns on camera, or "+ AI Co-Star" to fill the cast roster.',
      ),
      InstructionHighlightPoint(
        icon: Icons.local_florist_rounded,
        heading: 'Live Audience Hype Deck (Roses, Ovations & Tomatoes)',
        detail:
            'Spectators swipe to the "AUDIENCE" tab during any take to throw Golden Roses (+Hype), trigger Standing Ovations (1.15x Combo), or splat Rotten Tomatoes.',
      ),
    ],
    rulesTable: [
      ModeRulebookTableRow(
        phaseOrMetric: 'Remote SFU Cast',
        mechanicsAndCue: '2–8 players join via 6-digit Room Code',
        multiplierOrWeight: '720p30 / 1080p60',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: 'Couch Pass & Play',
        mechanicsAndCue: 'Sequential turns on a single device',
        multiplierOrWeight: '2–8 Local Actors',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: 'Standing Ovation Combo',
        mechanicsAndCue: '3+ Roses/Ovations within 8s of Curveball',
        multiplierOrWeight: '1.15x Score Boost',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: 'TV / DeX Host View',
        mechanicsAndCue: '3-panel Widescreen Studio Control Deck',
        multiplierOrWeight: 'HDMI / Screen Share',
      ),
    ],
    interactiveTip:
        'Test the live Peer Judging Slider below to see how ensemble cast votes scale from 10 to 100 points.',
    tryModeButtonLabel: '🚀 TRY ENSEMBLE GREEN ROOM NOW',
  ),
  InstructionStorySlide(
    stepNumber: 3,
    tabPillLabel: '🎭 SCREEN TEST DUET',
    badgeLabel: 'MODE 03 · 2-PLAYER SPLIT-SCREEN CO-STAR DUEL',
    title: 'Screen Test Duet (Lead A vs. Lead B)',
    subtitle:
        'Split the soundstage 50/50 between Lead A (Gold Script) and Lead B (Cyan Script) with live chemistry scoring, or act opposite an animated AI Co-Star with TTS voice lines!',
    heroIcon: Icons.splitscreen_rounded,
    neonAccent: Color(0xFF0CB6D4),
    points: [
      InstructionHighlightPoint(
        icon: Icons.contrast_rounded,
        heading: '50/50 Split-Screen Viewfinder (Gold vs. Cyan)',
        detail:
            'When Screen Test Duet is toggled ON, the camera splits into Lead A (Warm Champagne Gold cues) and Lead B (Electric Cyan cues) so both actors play off each other.',
      ),
      InstructionHighlightPoint(
        icon: Icons.record_voice_over_rounded,
        heading: 'Interactive AI Co-Star with Live Voice Delivery',
        detail:
            'Practicing solo? Add an AI Co-Star in the Green Room—during [LEAD B - CYAN] lines, the 2.5D co-star rig animates and speaks its dialogue out loud via synthesized voice!',
      ),
      InstructionHighlightPoint(
        icon: Icons.handshake_rounded,
        heading: 'Async Open Co-Star Challenges on Cutting Room Floor',
        detail:
            'Publish Lead A to The Cutting Room Floor as an "[OPEN CO-STAR AUDITION]" so any player worldwide can tap "ACCEPT CO-STAR AUDITION" and record Lead B alongside you.',
      ),
    ],
    rulesTable: [
      ModeRulebookTableRow(
        phaseOrMetric: 'Lead A (Gold Track)',
        mechanicsAndCue: 'Initiates scene tension & opening beat',
        multiplierOrWeight: 'Gold Teleprompter',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: 'Lead B (Cyan Track)',
        mechanicsAndCue: 'Counter-punch lines (Live Player or AI TTS)',
        multiplierOrWeight: 'Cyan Teleprompter',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: 'Co-Star Chemistry',
        mechanicsAndCue: 'Pacing sync & zero-dead-air handoffs',
        multiplierOrWeight: '+10% Duet Bonus',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: 'Scene Stealer Award',
        mechanicsAndCue: 'Highest individual emotional conviction',
        multiplierOrWeight: 'Trophy + +50 XP',
      ),
    ],
    interactiveTip:
        'Tap the Duet Rivals card below to preview Lead A (Gold) vs. Lead B (Cyan) cue handoffs.',
    tryModeButtonLabel: '🚀 TRY SCREEN TEST DUET NOW',
  ),
  InstructionStorySlide(
    stepNumber: 4,
    tabPillLabel: '😶 STONE-FACED HAZARD',
    badgeLabel: 'MODE 04 · DEADPAN NO-LAUGH CHALLENGE (1.20x)',
    title: 'Stone-Faced Method Mode (No-Laugh Hazard)',
    subtitle:
        'Deliver absurd melodrama with 100% deadpan conviction while spectators hurl Rotten Tomatoes and sirens try to make you crack a smile!',
    heroIcon: Icons.sentiment_neutral_rounded,
    neonAccent: Color(0xFFE11D48),
    points: [
      InstructionHighlightPoint(
        icon: Icons.psychology_alt_rounded,
        heading: '1.20x Method Acting Multiplier for Zero Smirks',
        detail:
            'Keep your face completely locked in character for the entire 30-second take to multiply your final composite score by 1.20x.',
      ),
      InstructionHighlightPoint(
        icon: Icons.warning_amber_rounded,
        heading: '🚨 CHARACTER BROKEN! (-15 PTS Smirk Penalty)',
        detail:
            'If AI facial telemetry or the audience catches you laughing or breaking character, a crimson siren flashes and deducts -15 points on the spot.',
      ),
      InstructionHighlightPoint(
        icon: Icons.local_play_rounded,
        heading: 'Spectator Heckle Barrage',
        detail:
            'Audience members can spam Rotten Tomatoes and Director Curveballs to test your composure under maximum comedic pressure.',
      ),
    ],
    rulesTable: [
      ModeRulebookTableRow(
        phaseOrMetric: 'Unbroken Deadpan Lock',
        mechanicsAndCue: 'Zero smiles or laughter for full 30s take',
        multiplierOrWeight: '1.20x Multiplier',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: '10s Vocal Streak',
        mechanicsAndCue: 'Sustained projection triggers Persona Cut-In',
        multiplierOrWeight: '+150 Streak XP',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: 'Character Broken Siren',
        mechanicsAndCue: 'Caught laughing/smirking on camera',
        multiplierOrWeight: '-15.0 Pts Penalty',
      ),
    ],
    interactiveTip:
        'Tap the hazard tester below to simulate a Tomato Splat vs. Unbroken Method Streak.',
    tryModeButtonLabel: '🚀 TRY STONE-FACED MODE NOW',
  ),
  InstructionStorySlide(
    stepNumber: 5,
    tabPillLabel: '🏆 3-ACT BLOCKBUSTER',
    badgeLabel: 'MODE 05 · ESCALATING 3-ROUND CHAMPIONSHIP ARC',
    title: 'The 3-Act Blockbuster Tournament',
    subtitle:
        'Compete across a structured 3-round feature-film arc—Act I: The Setup, Act II: The Plot Twist, and Act III: The Showstopper Climax (1.5x Weight) to crown the overall champion.',
    heroIcon: Icons.emoji_events_rounded,
    neonAccent: Color(0xFFFFD700),
    points: [
      InstructionHighlightPoint(
        icon: Icons.looks_one_rounded,
        heading: 'Act I (The Cold Open) & Act II (The Complication)',
        detail:
            'Act I establishes your baseline character score (1.0x). Act II automatically arms the 15-second Director Curveball (+5.0 Twist Bonus) to test your range.',
      ),
      InstructionHighlightPoint(
        icon: Icons.local_fire_department_rounded,
        heading: 'Act III: The Showstopper Climax (1.50x Score Weight)',
        detail:
            'Everything is on the line in Act III—scores are weighted at 1.50x so any actor can stage a legendary comeback on the final take.',
      ),
      InstructionHighlightPoint(
        icon: Icons.workspace_premium_rounded,
        heading: 'Official Playbill & Golden Statuette Ceremony',
        detail:
            'Completing all 3 acts awards a 1.25x Career XP bonus and engraves your composite record in the Career Trophy Room.',
      ),
    ],
    rulesTable: [
      ModeRulebookTableRow(
        phaseOrMetric: 'Act I · The Setup',
        mechanicsAndCue: 'Establish character & emotional baseline',
        multiplierOrWeight: '1.00x Weight',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: 'Act II · The Twist',
        mechanicsAndCue: 'Mandatory 15s Director Curveball pivot',
        multiplierOrWeight: '1.25x + +5.0 Twist',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: 'Act III · The Climax',
        mechanicsAndCue: 'High-intensity showstopper finale',
        multiplierOrWeight: '1.50x Weight',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: 'Tournament Wrap Bonus',
        mechanicsAndCue: 'Full 3-Act Playbill completion reward',
        multiplierOrWeight: '1.25x Career XP',
      ),
    ],
    interactiveTip:
        'Tap through the 3-Act Playbill preview below to see how cumulative tournament points scale.',
    tryModeButtonLabel: '🚀 TRY 3-ACT BLOCKBUSTER NOW',
  ),
  InstructionStorySlide(
    stepNumber: 6,
    tabPillLabel: '🔞 18+ SPEAKEASY & LIFE IS IMPROV',
    badgeLabel: 'MODE 06 · RATED-R / TV-MA VAULT & UNDERCOVER DARES',
    title: '18+ Midnight Speakeasy & "Life Is Improv"',
    subtitle:
        'Unlock 60 uncensored Rated-R / TV-MA comedy & drama scripts across 3 Spice Tiers (up to 1.35x), spin the Double-or-Nothing Dare Wheel, or take undercover dares into the real world!',
    heroIcon: Icons.nightlife_rounded,
    neonAccent: Color(0xFFA855F7),
    points: [
      InstructionHighlightPoint(
        icon: Icons.whatshot_rounded,
        heading: '60 Uncut Rated-R / TV-MA Scripts Across 3 Spice Tiers',
        detail:
            'Filter between 🔥 Tier 1: Messy Hookups & Raunchy Comedy [1.15x], 💋 Tier 2: Bedroom Walk-Ins & Seductive Noir [1.25x], and 🧨 Tier 3: Unhinged TV-MA Meltdowns & Filthy Roasts [1.35x].',
      ),
      InstructionHighlightPoint(
        icon: Icons.casino_rounded,
        heading: 'Speakeasy Dare Wheel (Double-or-Nothing Subtext)',
        detail:
            'Spin the neon wheel to pair a random 18+ script with a hilarious physical/vocal Subtext Dare (+1.25x bonus if nailed, -10 pts if you chicken out).',
      ),
      InstructionHighlightPoint(
        icon: Icons.visibility_off_rounded,
        heading: '🕵️ "Life Is Improv" Real-World Stealth / POV Mode (1.50x XP)',
        detail:
            'Tap The Undercover Speakeasy Improviser portrait to 3D-flip a Classified Secret Dare Dossier for a House Party, Coffee Shop, Elevator, or Couch Roast, then launch the dimmed Stealth / POV Camera!',
      ),
    ],
    rulesTable: [
      ModeRulebookTableRow(
        phaseOrMetric: '🔥 Spice Tier 1',
        mechanicsAndCue: 'Messy Hookups, Walk-Of-Shame & Raunchy Comedy',
        multiplierOrWeight: '1.15x Multiplier',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: '💋 Spice Tier 2',
        mechanicsAndCue: 'Bedroom Walk-Ins, Seductive Noir & Petty Exes',
        multiplierOrWeight: '1.25x Multiplier',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: '🧨 Spice Tier 3',
        mechanicsAndCue: 'Unhinged TV-MA Meltdowns & Filthy Roasts',
        multiplierOrWeight: '1.35x Multiplier',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: '🕵️ Life Is Improv',
        mechanicsAndCue: 'Real-world Stealth POV + 15s Haptic Escalation',
        multiplierOrWeight: '1.50x XP + 2 Tokens',
      ),
    ],
    interactiveTip:
        'Tap the Classified Speakeasy Dossier preview below to cycle Spice Tiers and Secret Dares.',
    tryModeButtonLabel: '🚀 ENTER 18+ MIDNIGHT SPEAKEASY',
  ),
  InstructionStorySlide(
    stepNumber: 7,
    tabPillLabel: '🌍 DAILY CATTLE CALL & CUTTING ROOM',
    badgeLabel: 'MODE 07 · GLOBAL DAILY SCENE & VIRAL REEL FEED',
    title: 'Daily Cattle Call & The Cutting Room Floor',
    subtitle:
        'Compete in Today\'s Global Scene for the Box Office Top 10, then swipe through The Cutting Room Floor to rate reels, drop 5s Voice Roasts, and earn free AI Tokens!',
    heroIcon: Icons.public_rounded,
    neonAccent: Color(0xFFE11342),
    points: [
      InstructionHighlightPoint(
        icon: Icons.wb_sunny_rounded,
        heading: 'Today\'s Global Scene (24-Hour Daily Cattle Call)',
        detail:
            'Every 24 hours, every actor worldwide gets the exact same Featured Script on the Main Dashboard. Audition to climb Today\'s Box Office Top 10.',
      ),
      InstructionHighlightPoint(
        icon: Icons.auto_awesome_motion_rounded,
        heading: 'The Cutting Room Floor (Auto-Prepends Your Latest Take)',
        detail:
            'Your completed soundstage takes automatically publish to Reel #1! Swipe vertically with snappy page physics, throw Golden Roses, or record a 5s Voice Roast.',
      ),
      InstructionHighlightPoint(
        icon: Icons.assignment_turned_in_rounded,
        heading: '🎬 Casting Director Duty (Judge 5 Reels = +2 Free AI Tokens)',
        detail:
            'Tap The Ruthless Casting Director card and stamp 1–5 ★ Golden Ratings on 5 community reels to claim +2 Free AI Telemetrics Tokens daily.',
      ),
    ],
    rulesTable: [
      ModeRulebookTableRow(
        phaseOrMetric: 'Daily Cattle Call',
        mechanicsAndCue: 'Global 24h scene challenge on Main Dashboard',
        multiplierOrWeight: 'Global Top 10 Badge',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: 'Casting Director Duty',
        mechanicsAndCue: 'Stamp 1–5 ★ ratings on 5 Cutting Room reels',
        multiplierOrWeight: '+2 Free AI Tokens',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: '5s Voice Roast & Stamp',
        mechanicsAndCue: 'Play roast through 2.5D avatar + Critic Stamp',
        multiplierOrWeight: 'Viral Crowd Hype',
      ),
      ModeRulebookTableRow(
        phaseOrMetric: 'Sunday Night Awards',
        mechanicsAndCue: '7-day rolling leaderboard across 4 categories',
        multiplierOrWeight: 'Walk of Fame Star',
      ),
    ],
    interactiveTip:
        'Tap the Casting Director Duty counter below to simulate stamping 5 reels for +2 AI Tokens.',
    tryModeButtonLabel: '🚀 OPEN THE CUTTING ROOM FLOOR',
  ),
];

/// Interactive 7-Mode Director's Editing Bay & Rulebook ("How to Play").
class InteractiveInstructionsScreen extends StatefulWidget {
  final VoidCallback? onCompleted;
  final int initialTabIndex;

  const InteractiveInstructionsScreen({
    super.key,
    this.onCompleted,
    this.initialTabIndex = 0,
  });

  /// Helper to open the interactive instructions from any AppBar or button.
  static Future<void> show(
    BuildContext context, {
    int initialTabIndex = 0,
  }) async {
    HapticFeedback.lightImpact();
    await Navigator.of(context).push(
      StageSharedTransitionRoute(
        page: InteractiveInstructionsScreen(initialTabIndex: initialTabIndex),
      ),
    );
  }

  /// Checks `SharedPreferences` and automatically launches the interactive
  /// Story Reel on first run if the player hasn't seen it yet.
  static Future<void> maybeShowOnFirstLaunch(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadySeen =
          prefs.getBool(kHasSeenInteractiveInstructionsPrefKey) ?? false;
      if (!alreadySeen && context.mounted) {
        await prefs.setBool(kHasSeenInteractiveInstructionsPrefKey, true);
        if (context.mounted) {
          await show(context);
        }
      }
    } catch (_) {}
  }

  @override
  State<InteractiveInstructionsScreen> createState() =>
      _InteractiveInstructionsScreenState();
}

class _InteractiveInstructionsScreenState
    extends State<InteractiveInstructionsScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final ScrollController _tabBarScrollController;
  late final AnimationController _pulseController;
  late int _currentIndex;

  // Interactive mini-sandbox state on each slide
  int _demoCountdown = 10;
  double _demoPeerRating = 9.0;
  int _demoSocialReactions = 12;
  bool _demoDuetLeadBActive = false;
  bool _demoStoneFacedIntact = true;
  int _demoBlockbusterAct = 1;
  int _demoSpeakeasySpiceTier = 3;

  @override
  void initState() {
    super.initState();
    _currentIndex =
        widget.initialTabIndex.clamp(0, kInstructionStorySlides.length - 1);
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 1.0,
    );
    _tabBarScrollController = ScrollController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabBarScrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _markSeenAndClose() async {
    HapticFeedback.mediumImpact();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kHasSeenInteractiveInstructionsPrefKey, true);
    } catch (_) {}
    if (widget.onCompleted != null) {
      widget.onCompleted!();
    }
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _goToSlide(int index) {
    final target = index.clamp(0, kInstructionStorySlides.length - 1);
    HapticFeedback.selectionClick();
    SoundstageAudioController.instance.playClapperboardSnap();
    setState(() => _currentIndex = target);
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  void _launchModeFromRulebook(int modeIndex) {
    HapticFeedback.heavyImpact();
    SoundstageAudioController.instance.playClapperboardSnap();
    final cfg = GameSettingsModal.latestConfig;

    switch (modeIndex) {
      case 0: // Core Soundstage
        GameSettingsModal.latestConfig = cfg.copyWith(
          screenTestDuetMode: false,
          stoneFacedNoLaughHazard: false,
          threeActBlockbusterTournament: false,
          lifeIsImprovMode: false,
        );
        Navigator.of(context).pushReplacement(
          StageSharedTransitionRoute(
            page: const LobbyMatchmakingScreen(startInJoinMode: false),
          ),
        );
        break;
      case 1: // Ensemble & Pass-and-Play
        Navigator.of(context).pushReplacement(
          StageSharedTransitionRoute(
            page: const LobbyMatchmakingScreen(startInJoinMode: false),
          ),
        );
        break;
      case 2: // Screen Test Duet
        GameSettingsModal.latestConfig = cfg.copyWith(
          screenTestDuetMode: true,
        );
        Navigator.of(context).pushReplacement(
          StageSharedTransitionRoute(
            page: const LobbyMatchmakingScreen(startInJoinMode: false),
          ),
        );
        break;
      case 3: // Stone-Faced Hazard
        GameSettingsModal.latestConfig = cfg.copyWith(
          stoneFacedNoLaughHazard: true,
        );
        Navigator.of(context).pushReplacement(
          StageSharedTransitionRoute(
            page: const LobbyMatchmakingScreen(startInJoinMode: false),
          ),
        );
        break;
      case 4: // 3-Act Blockbuster
        GameSettingsModal.latestConfig = cfg.copyWith(
          threeActBlockbusterTournament: true,
        );
        Navigator.of(context).pushReplacement(
          StageSharedTransitionRoute(
            page: const LobbyMatchmakingScreen(startInJoinMode: false),
          ),
        );
        break;
      case 5: // 18+ Speakeasy & Life Is Improv
        Navigator.of(context).pushReplacement(
          StageSharedTransitionRoute(
            page: const LateNightAfterHoursScreen(),
          ),
        );
        break;
      case 6: // Daily Cattle Call & Cutting Room
        Navigator.of(context).pushReplacement(
          StageSharedTransitionRoute(
            page: const CuttingRoomFeedScreen(),
          ),
        );
        break;
      default:
        _markSeenAndClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSlide = kInstructionStorySlides[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated 35mm spotlight backdrop
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return CustomPaint(
                painter: _InstructionsMarqueeBackdropPainter(
                  progress: _pulseController.value,
                  activeAccent: currentSlide.neonAccent,
                ),
              );
            },
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMoviolaSprocketHeader(currentSlide),
                _buildModeSelectorTabBar(),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const PageScrollPhysics(),
                    itemCount: kInstructionStorySlides.length,
                    onPageChanged: (idx) {
                      HapticFeedback.selectionClick();
                      setState(() => _currentIndex = idx);
                    },
                    itemBuilder: (context, index) {
                      final slide = kInstructionStorySlides[index];
                      return _buildScrollableModeRulebookPage(slide, index);
                    },
                  ),
                ),
                _buildBottomStoryControls(currentSlide),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoviolaSprocketHeader(InstructionStorySlide currentSlide) {
    final timecodeSec = ((_currentIndex + 1) * 12).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      decoration: const BoxDecoration(
        color: Color(0xEB07090E),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1E293B), width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 35mm Film Sprocket Strip
          Row(
            children: List.generate(14, (i) {
              return Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == (_currentIndex * 2)
                        ? currentSlide.neonAccent
                        : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: currentSlide.neonAccent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: currentSlide.neonAccent.withValues(alpha: 0.8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.movie_edit,
                      size: 14,
                      color: currentSlide.neonAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'MOVIOLA REEL 0${_currentIndex + 1}/0${kInstructionStorySlides.length} · TC 00:01:$timecodeSec:24',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: currentSlide.neonAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'DIRECTOR\'S EDITING BAY & RULEBOOK',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 20,
                      letterSpacing: 1.5,
                      color: const Color(0xFFF5DEB3),
                    ),
                  ),
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFF5DEB3),
                  backgroundColor: const Color(0xFF121826),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: const BorderSide(color: Color(0xFF334155)),
                  ),
                ),
                onPressed: _markSeenAndClose,
                icon: const Icon(Icons.close_rounded, size: 15),
                label: const Text(
                  'EXIT',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelectorTabBar() {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFF0B0E17),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1E293B), width: 1.2),
        ),
      ),
      child: ListView.separated(
        controller: _tabBarScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        itemCount: kInstructionStorySlides.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final slide = kInstructionStorySlides[index];
          final isSelected = index == _currentIndex;
          return GestureDetector(
            onTap: () => _goToSlide(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? slide.neonAccent.withValues(alpha: 0.22)
                    : const Color(0xFF121826),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected
                      ? slide.neonAccent
                      : const Color(0xFF334155),
                  width: isSelected ? 1.8 : 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                slide.tabPillLabel,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScrollableModeRulebookPage(
    InstructionStorySlide slide,
    int index,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF151C2C),
              Color(0xFF0B0E17),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: slide.neonAccent.withValues(alpha: 0.8),
            width: 2.0,
          ),
          boxShadow: [
            const BoxShadow(
              color: Color(0xFF05070B),
              offset: Offset(0, 8),
              blurRadius: 16,
            ),
            BoxShadow(
              color: slide.neonAccent.withValues(alpha: 0.16),
              blurRadius: 24,
              spreadRadius: 1,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Diagonal Hollywood Clapperboard Stripe Bar
            SizedBox(
              height: 18,
              child: CustomPaint(
                painter: _ClapperStripeHeaderPainter(
                  accentColor: slide.neonAccent,
                ),
              ),
            ),
            // 2.5D Animated Mode Banner Artwork
            _build25DModeArtworkBanner(index, slide),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top metadata row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: slide.neonAccent.withValues(alpha: 0.16),
                          border: Border.all(
                            color: slide.neonAccent,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          slide.heroIcon,
                          size: 22,
                          color: slide.neonAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slide.badgeLabel,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                                color: slide.neonAccent,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              slide.title,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    slide.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.42,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildPerforatedTicketDivider(slide.neonAccent),
                  const SizedBox(height: 14),

                  // Step-by-Step Highlight Cards
                  const Text(
                    '📋 STEP-BY-STEP SOUNDSTAGE PROTOCOL',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: Color(0xFFF5DEB3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...slide.points.map(
                    (pt) => _buildHighlightRow(
                      point: pt,
                      accent: slide.neonAccent,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Structured Rules & Multipliers Table
                  if (slide.rulesTable.isNotEmpty) ...[
                    const Text(
                      '📊 OFFICIAL RULES, WEIGHTS & MULTIPLIER TABLE',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: Color(0xFFF5DEB3),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStructuredRulesTable(slide),
                    const SizedBox(height: 14),
                  ],

                  // Interactive Mini-Sandbox
                  const Text(
                    '🎛️ INTERACTIVE EDITING BAY SANDBOX',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: Color(0xFF0CB6D4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInteractiveSlideSandbox(index, slide),
                  const SizedBox(height: 16),

                  // 🚀 TRY THIS MODE NOW Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: slide.neonAccent,
                        foregroundColor: const Color(0xFF07090E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _launchModeFromRulebook(index),
                      icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          slide.tryModeButtonLabel,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _build25DModeArtworkBanner(int index, InstructionStorySlide slide) {
    return Container(
      height: 118,
      decoration: BoxDecoration(
        color: const Color(0xFF07090E),
        border: Border(
          bottom: BorderSide(
            color: slide.neonAccent.withValues(alpha: 0.45),
            width: 1.2,
          ),
        ),
      ),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) {
          final phase = _pulseController.value * math.pi * 2;
          switch (index) {
            case 2: // Screen Test Duet
              return Row(
                children: [
                  SizedBox(
                    width: 150,
                    height: 118,
                    child: DuetRivalsSplitPortraitRig(phase: phase),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            '2.5D DUET RIVALS RIG · 60FPS',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0CB6D4),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Lead A (Gold) vs. Lead B (Cyan) Split-Screen Viewfinder + AI Co-Star TTS Voice Delivery.',
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.3,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            case 5: // 18+ Speakeasy & Life Is Improv
              return Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 118,
                    child: UndercoverSpeakeasyImproviserRig(phase: phase),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            '2.5D UNDERCOVER IMPROVISER RIG',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFA855F7),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '60 Uncensored Rated-R / TV-MA Scenes + 3D Matrix4 Confidential Dossier Flip.',
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.3,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            case 6: // Daily Cattle Call & Cutting Room
              return Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 118,
                    child: RuthlessCastingDirectorRig(phase: phase),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            '2.5D RUTHLESS CASTING DIRECTOR RIG',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFFD700),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Judge 5 Reels on The Cutting Room Floor for +2 Free AI Telemetrics Tokens daily.',
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.3,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            default:
              return Row(
                children: [
                  SizedBox(
                    width: 130,
                    height: 118,
                    child: index.isEven
                        ? LeftFlankPaparazziDuoRig(
                            phase: phase,
                            frenzyIntensity: 0.4,
                          )
                        : RightFlankVipEntourageRig(
                            phase: phase,
                            frenzyIntensity: 0.4,
                          ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'MOVIOLA 2.5D STAGE PREVIEW · MODE 0${index + 1}',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: slide.neonAccent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            slide.interactiveTip,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              height: 1.3,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }

  Widget _buildStructuredRulesTable(InstructionStorySlide slide) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080B12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: slide.neonAccent.withValues(alpha: 0.55),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: slide.neonAccent.withValues(alpha: 0.14),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'PHASE / METRIC',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: slide.neonAccent,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 5,
                  child: Text(
                    'MECHANICS & CUE',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFF5DEB3),
                    ),
                  ),
                ),
                const Expanded(
                  flex: 3,
                  child: Text(
                    'WEIGHT / BONUS',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0CB6D4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...slide.rulesTable.asMap().entries.map((entry) {
            final idx = entry.key;
            final row = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: idx.isEven
                    ? const Color(0xFF0B0F19)
                    : const Color(0xFF070A10),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.7),
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      row.phaseOrMetric,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 5,
                    child: Text(
                      row.mechanicsAndCue,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.3,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 3,
                    child: Text(
                      row.multiplierOrWeight,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: slide.neonAccent,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
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
                    '${_demoPeerRating.toStringAsFixed(0)} / 10 ★ (${(_demoPeerRating * 10).toStringAsFixed(0)} PTS)',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
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
      case 2:
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _demoDuetLeadBActive = !_demoDuetLeadBActive);
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
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: !_demoDuetLeadBActive
                          ? const Color(0x33F5DEB3)
                          : const Color(0xFF07090E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF5DEB3)),
                    ),
                    child: const Text(
                      'LEAD A (GOLD)\n"Swear to me you burned the call sheet!"',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: Color(0xFFF5DEB3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _demoDuetLeadBActive
                          ? const Color(0x330CB6D4)
                          : const Color(0xFF07090E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF0CB6D4)),
                    ),
                    child: const Text(
                      'LEAD B (CYAN · AI TTS)\n"I didn\'t burn it—I sold it to TMZ!"',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: Color(0xFF0CB6D4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case 3:
        return GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            setState(() => _demoStoneFacedIntact = !_demoStoneFacedIntact);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF090D15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _demoStoneFacedIntact
                    ? const Color(0xFF10B981)
                    : const Color(0xFFE11D48),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    _demoStoneFacedIntact
                        ? '🗿 DEADPAN LOCK INTACT · 1.20x MULTIPLIER ACTIVE'
                        : '🚨 CHARACTER BROKEN (-15 PTS SMIRK PENALTY)',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: _demoStoneFacedIntact
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE11D48),
                    ),
                  ),
                ),
                const Text(
                  'TAP TO TEST',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      case 4:
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _demoBlockbusterAct = (_demoBlockbusterAct % 3) + 1;
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniMetricPill(
                  'ACT I',
                  _demoBlockbusterAct == 1 ? 'ACTIVE (1.0x)' : '1.0x',
                  const Color(0xFF0CB6D4),
                ),
                _buildMiniMetricPill(
                  'ACT II',
                  _demoBlockbusterAct == 2 ? 'ACTIVE (+TWIST)' : '+5.0 TWIST',
                  const Color(0xFFF59E0B),
                ),
                _buildMiniMetricPill(
                  'ACT III',
                  _demoBlockbusterAct == 3 ? 'CLIMAX (1.5x)' : '1.5x CLIMAX',
                  const Color(0xFFFFD700),
                ),
              ],
            ),
          ),
        );
      case 5:
        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            setState(() {
              _demoSpeakeasySpiceTier = (_demoSpeakeasySpiceTier % 3) + 1;
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    _demoSpeakeasySpiceTier == 1
                        ? '🔥 TIER 1: MESSY HOOKUPS & RAUNCHY COMEDY [1.15x]'
                        : (_demoSpeakeasySpiceTier == 2
                            ? '💋 TIER 2: BEDROOM WALK-INS & NOIR [1.25x]'
                            : '🧨 TIER 3: UNHINGED TV-MA MELTDOWNS [1.35x]'),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: slide.neonAccent,
                    ),
                  ),
                ),
                const Text(
                  'TAP TIER',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
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
                  'CROWD REACTIONS: $_demoSocialReactions FIRES 🔥 (5/5 = +2 TOKENS)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: slide.neonAccent,
                  ),
                ),
                const Text(
                  'TAP +5',
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
          score,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
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

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: Color(0xF207090E),
        border: Border(
          top: BorderSide(color: Color(0xFF1E293B), width: 1.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dot indicator row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(kInstructionStorySlides.length, (i) {
              final active = i == _currentIndex;
              final dotColor = kInstructionStorySlides[i].neonAccent;
              return GestureDetector(
                onTap: () => _goToSlide(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 7,
                  width: active ? 24 : 7,
                  decoration: BoxDecoration(
                    color: active ? dotColor : const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (_currentIndex > 0) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Color(0xFF334155)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => _goToSlide(_currentIndex - 1),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                  label: const Text('PREV MODE'),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentSlide.neonAccent,
                    foregroundColor: const Color(0xFF07090E),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isFinalSlide
                      ? _markSeenAndClose
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
                          : 'NEXT MODE (${_currentIndex + 1}/${kInstructionStorySlides.length})',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12.5,
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
