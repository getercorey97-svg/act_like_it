import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_service.dart';
import '../lobby.dart';
import '../main.dart';
import '../offline_manager.dart';
import '../ui/game_app_bar.dart';
import '../ui/intro_cinematic.dart';
import '../webrtc_manager.dart';

/// Immutable model representing an audition take in "The Cutting Room Floor"
/// vertical social feed.
class CuttingRoomAuditionTake {
  final String id;
  final String actorHandle;
  final String avatarArchetypeId;
  final String sceneTitle;
  final String filmOrSeries;
  final int releaseYear;
  final String scriptExcerpt;
  final String directorCommentStamp;
  final double aiTelemetricsScore;
  final double averageStarRating;
  final int totalRatingsCount;
  final int shareCount;
  final Color neonAccent;
  final String? videoUrl;

  const CuttingRoomAuditionTake({
    required this.id,
    required this.actorHandle,
    required this.avatarArchetypeId,
    required this.sceneTitle,
    required this.filmOrSeries,
    required this.releaseYear,
    required this.scriptExcerpt,
    required this.directorCommentStamp,
    required this.aiTelemetricsScore,
    required this.averageStarRating,
    required this.totalRatingsCount,
    required this.shareCount,
    required this.neonAccent,
    this.videoUrl,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'actorHandle': actorHandle,
        'avatarArchetypeId': avatarArchetypeId,
        'sceneTitle': sceneTitle,
        'filmOrSeries': filmOrSeries,
        'releaseYear': releaseYear,
        'scriptExcerpt': scriptExcerpt,
        'directorCommentStamp': directorCommentStamp,
        'aiTelemetricsScore': aiTelemetricsScore,
        'averageStarRating': averageStarRating,
        'totalRatingsCount': totalRatingsCount,
        'shareCount': shareCount,
        'neonAccent': neonAccent.toARGB32(),
        if (videoUrl != null) 'videoUrl': videoUrl,
      };

  factory CuttingRoomAuditionTake.fromJson(Map<String, dynamic> json) {
    final int colorVal =
        (json['neonAccent'] as num?)?.toInt() ?? 0xFFFFD700;
    return CuttingRoomAuditionTake(
      id: json['id']?.toString() ??
          'crf_${DateTime.now().millisecondsSinceEpoch}',
      actorHandle: json['actorHandle']?.toString() ?? '@STAGE_STAR',
      avatarArchetypeId:
          json['avatarArchetypeId']?.toString() ?? 'the_method_actor',
      sceneTitle: json['sceneTitle']?.toString() ?? 'SOUNDSTAGE TAKE',
      filmOrSeries: json['filmOrSeries']?.toString() ?? 'ACT LIKE IT',
      releaseYear: (json['releaseYear'] as num?)?.toInt() ?? 2025,
      scriptExcerpt: json['scriptExcerpt']?.toString() ??
          '"Live soundstage performance recorded in Act Like It!"',
      directorCommentStamp: json['directorCommentStamp']?.toString() ??
          'CERTIFIED SCREEN TEST · OFFICIAL VERDICT',
      aiTelemetricsScore:
          (json['aiTelemetricsScore'] as num?)?.toDouble() ?? 88.0,
      averageStarRating:
          (json['averageStarRating'] as num?)?.toDouble() ?? 4.9,
      totalRatingsCount:
          (json['totalRatingsCount'] as num?)?.toInt() ?? 12,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 4,
      neonAccent: Color(colorVal),
      videoUrl: json['videoUrl']?.toString(),
    );
  }
}

/// Persistent store & UGC Moderation Registry for "The Cutting Room Floor".
/// Auto-prepends newly completed player takes to position #1 and enforces
/// Google Play Store UGC Report / Block safety compliance.
class CuttingRoomFeedStore {
  static const String _kPublishedTakesKey =
      'act_like_it_published_cutting_room_takes_v1';
  static const String _kBlockedHandlesKey =
      'act_like_it_blocked_ugc_handles_v1';

  static final List<CuttingRoomAuditionTake> _runtimePublishedTakes =
      <CuttingRoomAuditionTake>[];
  static final Set<String> _blockedActorHandles = <String>{};

  static List<CuttingRoomAuditionTake> get runtimePublishedTakes =>
      List<CuttingRoomAuditionTake>.unmodifiable(_runtimePublishedTakes);

  static Set<String> get blockedActorHandles =>
      Set<String>.unmodifiable(_blockedActorHandles);

  static bool isActorBlocked(String handleOrName) {
    final normalized = _normalizeHandle(handleOrName);
    return _blockedActorHandles.contains(normalized);
  }

  static String _normalizeHandle(String raw) {
    final trimmed = raw.trim().toUpperCase();
    return trimmed.startsWith('@') ? trimmed : '@$trimmed';
  }

  static Future<void> hydrateFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blockedList = prefs.getStringList(_kBlockedHandlesKey) ?? <String>[];
      _blockedActorHandles
        ..clear()
        ..addAll(blockedList.map(_normalizeHandle));

      final rawTakes = prefs.getString(_kPublishedTakesKey);
      if (rawTakes != null && rawTakes.isNotEmpty) {
        final decoded = jsonDecode(rawTakes);
        if (decoded is List) {
          _runtimePublishedTakes.clear();
          for (final item in decoded) {
            if (item is Map) {
              _runtimePublishedTakes.add(
                CuttingRoomAuditionTake.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              );
            }
          }
        }
      }
    } catch (_) {}
  }

  static Future<void> reportAndBlockActor({
    required String actorHandleOrName,
    required String reason,
    String? takeId,
  }) async {
    final normalized = _normalizeHandle(actorHandleOrName);
    _blockedActorHandles.add(normalized);
    if (takeId != null) {
      _runtimePublishedTakes.removeWhere((t) => t.id == takeId);
    }
    _runtimePublishedTakes
        .removeWhere((t) => _normalizeHandle(t.actorHandle) == normalized);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _kBlockedHandlesKey,
        _blockedActorHandles.toList(),
      );
      await prefs.setString(
        _kPublishedTakesKey,
        jsonEncode(_runtimePublishedTakes.map((t) => t.toJson()).toList()),
      );
    } catch (_) {}

    final client = supabaseOrNull;
    if (client != null && OfflineManager.instance.isOnline) {
      try {
        await client.from('ugc_moderation_reports').insert(<String, dynamic>{
          'reported_handle': normalized,
          'take_id': takeId ?? 'lobby_report',
          'reason': reason,
          'reporter_id':
              AuthService.instance.currentProfile?.userId ?? 'local-actor',
          'created_at': DateTime.now().toUtc().toIso8601String(),
        }).timeout(const Duration(seconds: 3));
      } catch (_) {}
    }
  }

  /// Called automatically by `TriModalJudgingScreen` when a round completes so
  /// the player's own performance is immediately prepended to position `#1`
  /// on "The Cutting Room Floor".
  static Future<CuttingRoomAuditionTake> publishCompletedPerformance({
    required String takeId,
    required String actorHandle,
    required String avatarArchetypeId,
    required String sceneTitle,
    required String filmOrSeries,
    required int releaseYear,
    required String scriptExcerpt,
    required String directorCommentStamp,
    required double compositeScore,
    String? videoUrl,
  }) async {
    await hydrateFromPrefs();
    final cleanFilm = filmOrSeries
        .replaceAll(RegExp(r'\(\d{4}\)'), '')
        .trim()
        .toUpperCase();
    final take = CuttingRoomAuditionTake(
      id: takeId,
      actorHandle: _normalizeHandle(actorHandle),
      avatarArchetypeId: avatarArchetypeId,
      sceneTitle: sceneTitle.toUpperCase(),
      filmOrSeries: cleanFilm.isEmpty ? 'ACT LIKE IT' : cleanFilm,
      releaseYear: releaseYear,
      scriptExcerpt: scriptExcerpt,
      directorCommentStamp: directorCommentStamp,
      aiTelemetricsScore: compositeScore.clamp(0.0, 100.0),
      averageStarRating:
          compositeScore >= 85.0 ? 5.0 : (compositeScore >= 75.0 ? 4.8 : 4.4),
      totalRatingsCount: 1,
      shareCount: 1,
      neonAccent: compositeScore >= 85.0
          ? const Color(0xFFFFD700)
          : const Color(0xFF06B6D4),
      videoUrl: videoUrl,
    );

    _runtimePublishedTakes.removeWhere((t) => t.id == take.id);
    _runtimePublishedTakes.insert(0, take);
    if (_runtimePublishedTakes.length > 20) {
      _runtimePublishedTakes.removeRange(20, _runtimePublishedTakes.length);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kPublishedTakesKey,
        jsonEncode(_runtimePublishedTakes.map((t) => t.toJson()).toList()),
      );
    } catch (_) {}

    final client = supabaseOrNull;
    if (client != null && OfflineManager.instance.isOnline) {
      try {
        await client.from('cutting_room_takes').upsert(<String, dynamic>{
          'id': take.id,
          'actor_handle': take.actorHandle,
          'avatar_archetype_id': take.avatarArchetypeId,
          'scene_title': take.sceneTitle,
          'film_or_series': take.filmOrSeries,
          'release_year': take.releaseYear,
          'script_excerpt': take.scriptExcerpt,
          'director_comment_stamp': take.directorCommentStamp,
          'ai_telemetrics_score': take.aiTelemetricsScore,
          if (take.videoUrl != null) 'video_url': take.videoUrl,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).timeout(const Duration(seconds: 4));
      } catch (_) {}
    }

    return take;
  }
}

const List<CuttingRoomAuditionTake> kDefaultCuttingRoomTakes =
    <CuttingRoomAuditionTake>[
  CuttingRoomAuditionTake(
    id: 'crf_take_01',
    actorHandle: '@METHOD_MAVERICK',
    avatarArchetypeId: 'the_method_actor',
    sceneTitle: 'THE ROOFTOP CONFESSION',
    filmOrSeries: 'NEON RAIN OVER MULHOLLAND',
    releaseYear: 1994,
    scriptExcerpt:
        '"You think the spotlight saves you? Out here on the ledge, the camera never blinks!"',
    directorCommentStamp: 'CERTIFIED RAW CONVICTION · ONE-TAKE WONDER',
    aiTelemetricsScore: 96.4,
    averageStarRating: 4.9,
    totalRatingsCount: 418,
    shareCount: 142,
    neonAccent: Color(0xFFA855F7),
  ),
  CuttingRoomAuditionTake(
    id: 'crf_take_02',
    actorHandle: '@VALENTINA_LUX',
    avatarArchetypeId: 'the_diva',
    sceneTitle: 'THE PENTHOUSE ULTIMATUM',
    filmOrSeries: 'CROWN OF GLASS',
    releaseYear: 2021,
    scriptExcerpt:
        '"I didn’t buy the studio to audition for you, darling. I bought it to fire the director."',
    directorCommentStamp: 'RAZOR-SHARP TIMING · SCENE STEALER',
    aiTelemetricsScore: 94.8,
    averageStarRating: 4.8,
    totalRatingsCount: 389,
    shareCount: 198,
    neonAccent: Color(0xFFEC4899),
  ),
  CuttingRoomAuditionTake(
    id: 'crf_take_03',
    actorHandle: '@DON_CORLEONE_JR',
    avatarArchetypeId: 'the_mob_boss',
    sceneTitle: 'VELVET ROPE SHAKEDOWN',
    filmOrSeries: 'MIDNIGHT SPEAKEASY',
    releaseYear: 1978,
    scriptExcerpt:
        '"Look me in the eye and tell me who leaked the call sheet before the cigar ash hits the floor."',
    directorCommentStamp: 'CHILLING CADENCE · STANDING OVATION',
    aiTelemetricsScore: 93.2,
    averageStarRating: 4.7,
    totalRatingsCount: 312,
    shareCount: 115,
    neonAccent: Color(0xFFE11D48),
  ),
  CuttingRoomAuditionTake(
    id: 'crf_take_04',
    actorHandle: '@FLASHBULB_FINN',
    avatarArchetypeId: 'the_paparazzi',
    sceneTitle: 'COURTROOM MELTDOWN (+5.0 TWIST)',
    filmOrSeries: 'THE VERDICT ON SUNSET',
    releaseYear: 2016,
    scriptExcerpt:
        '"Objection? I’ve got forty-two high-speed negatives that say your alibi is pure fiction!"',
    directorCommentStamp: 'IMPROV CURVEBALL NAILED · ELECTRIC PACE',
    aiTelemetricsScore: 95.1,
    averageStarRating: 4.9,
    totalRatingsCount: 520,
    shareCount: 264,
    neonAccent: Color(0xFF06B6D4),
  ),
  CuttingRoomAuditionTake(
    id: 'duet_challenge_01',
    actorHandle: '@SCARLETT_VANE',
    avatarArchetypeId: 'the_femme_fatale',
    sceneTitle: 'THE PENTHOUSE ALIBI [OPEN CO-STAR AUDITION]',
    filmOrSeries: 'VELVET SHADOWS',
    releaseYear: 2024,
    scriptExcerpt:
        '[LEAD A RECORDED]: "Tell the detective we were drinking champagne on the terrace." · [CYAN LEAD B OPEN]',
    directorCommentStamp: 'OPEN CO-STAR AUDITION · LEAD B WANTED',
    aiTelemetricsScore: 95.6,
    averageStarRating: 5.0,
    totalRatingsCount: 284,
    shareCount: 164,
    neonAccent: Color(0xFF0CB6D4),
  ),
  CuttingRoomAuditionTake(
    id: 'life_improv_viral_01',
    actorHandle: '@UNDERCOVER_MAVERICK',
    avatarArchetypeId: 'the_method_actor',
    sceneTitle: '🕵️ [LIFE IS IMPROV] THE TIME-TRAVELER\'S RECEIPT',
    filmOrSeries: 'SPEAKEASY REAL-WORLD DARE',
    releaseYear: 2026,
    scriptExcerpt:
        '"Excuse me, what year is it right now? Oh thank God, we still have four minutes before the pigeons unionize."',
    directorCommentStamp: 'UNDERCOVER LEGEND · 1.50x FEARLESS IMPROV XP',
    aiTelemetricsScore: 97.2,
    averageStarRating: 5.0,
    totalRatingsCount: 612,
    shareCount: 410,
    neonAccent: Color(0xFFA55577),
  ),
];

/// MODULE 2: "The Cutting Room Floor" (`lib/social/cutting_room_feed.dart`).
/// Reached via the First-Person Silver Elevator transition on the Red Carpet.
class CuttingRoomFeedScreen extends StatefulWidget {
  const CuttingRoomFeedScreen({super.key});

  @override
  State<CuttingRoomFeedScreen> createState() => _CuttingRoomFeedScreenState();
}

class _CuttingRoomFeedScreenState extends State<CuttingRoomFeedScreen>
    with SingleTickerProviderStateMixin {
  static const String _kRatingsPrefsKey = 'act_like_it_cutting_room_ratings_v1';

  late final PageController _verticalPageController;
  late final AnimationController _reelLoopController;

  final List<CuttingRoomAuditionTake> _takes =
      List<CuttingRoomAuditionTake>.from(kDefaultCuttingRoomTakes);
  final Map<String, int> _userStarRatings = <String, int>{};
  final Map<String, String> _customDirectorStamps = <String, String>{};
  final Map<String, int> _roseHypeCounts = <String, int>{};
  final Map<String, String> _voiceRoastNotes = <String, String>{};
  int _activeIndex = 0;
  String _selectedFeedFilter = 'ALL'; // 'ALL', 'TOP10', 'COSTAR', 'LIFE_IMPROV'
  bool _showSundayBoxOfficeBanner = false;
  static bool _castingDutyRewardClaimedToday = false;

  @override
  void initState() {
    super.initState();
    _verticalPageController = PageController();
    _reelLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _hydrateTakesAndSavedRatings();
  }

  String _formatCleanFilmSubtitle(CuttingRoomAuditionTake take) {
    final cleanedFilm = take.filmOrSeries
        .replaceAll(RegExp(r'\(\d{4}\)'), '')
        .trim();
    return '${take.sceneTitle} · $cleanedFilm (${take.releaseYear})';
  }

  Future<void> _hydrateTakesAndSavedRatings() async {
    await CuttingRoomFeedStore.hydrateFromPrefs();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kRatingsPrefsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          decoded.forEach((k, v) {
            final stars = int.tryParse('$v');
            if (stars != null && stars >= 1 && stars <= 5) {
              _userStarRatings[k.toString()] = stars;
            }
          });
        }
      }
    } catch (_) {}

    final merged = <CuttingRoomAuditionTake>[];

    // 1. Prepend published takes from CuttingRoomFeedStore
    for (final pub in CuttingRoomFeedStore.runtimePublishedTakes) {
      if (!CuttingRoomFeedStore.isActorBlocked(pub.actorHandle) &&
          !merged.any((t) => t.id == pub.id)) {
        merged.add(pub);
      }
    }

    // 2. Also prepend latest local match history take if not already present
    final localHistory = OfflineManager.instance.matchHistoryLog;
    final profile = AuthService.instance.currentProfile;
    if (localHistory.isNotEmpty) {
      final rec = localHistory.first;
      final cleanFilm = rec.filmOrSeries
          .replaceAll(RegExp(r'\(\d{4}\)'), '')
          .trim()
          .toUpperCase();
      final yearMatch = RegExp(r'\((\d{4})\)').firstMatch(rec.filmOrSeries);
      final parsedYear =
          int.tryParse(yearMatch?.group(1) ?? '') ?? 2025;
      final playerTake = CuttingRoomAuditionTake(
        id: 'crf_local_${rec.id}',
        actorHandle:
            '@${(profile?.username ?? "GALAXY_S26_ACTOR").toUpperCase()}',
        avatarArchetypeId: profile?.avatarArchetypeId ?? 'the_method_actor',
        sceneTitle: rec.sceneTitle.toUpperCase(),
        filmOrSeries: cleanFilm.isEmpty ? 'ACT LIKE IT' : cleanFilm,
        releaseYear: parsedYear,
        scriptExcerpt:
            '"Live soundstage take — Composite Verdict ${rec.finalScore.toStringAsFixed(1)}/100!"',
        directorCommentStamp: rec.isWin
            ? 'STANDING OVATION · CERTIFIED TROPHY WIN'
            : 'OFFICIAL STUDIO SCREEN TEST',
        aiTelemetricsScore: rec.finalScore,
        averageStarRating: 5.0,
        totalRatingsCount: 24,
        shareCount: 9,
        neonAccent: const Color(0xFFFFD700),
      );
      if (!CuttingRoomFeedStore.isActorBlocked(playerTake.actorHandle) &&
          !merged.any((t) => t.id == playerTake.id)) {
        merged.add(playerTake);
      }
    }

    // 3. Append default takes that aren't blocked
    for (final def in kDefaultCuttingRoomTakes) {
      if (!CuttingRoomFeedStore.isActorBlocked(def.actorHandle) &&
          !merged.any((t) => t.id == def.id)) {
        merged.add(def);
      }
    }

    if (mounted) {
      setState(() {
        _takes
          ..clear()
          ..addAll(merged);
        if (_activeIndex >= _takes.length) {
          _activeIndex = 0;
        }
      });
    }
  }

  @override
  void dispose() {
    _verticalPageController.dispose();
    _reelLoopController.dispose();
    super.dispose();
  }

  Future<void> _submitStarRating(CuttingRoomAuditionTake take, int stars) async {
    final clampedStars = stars.clamp(1, 5);
    HapticFeedback.heavyImpact();
    setState(() {
      _userStarRatings[take.id] = clampedStars;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kRatingsPrefsKey, jsonEncode(_userStarRatings));
    } catch (_) {}

    final client = supabaseOrNull;
    if (client != null && OfflineManager.instance.isOnline) {
      try {
        await client.from('cutting_room_ratings').upsert(<String, dynamic>{
          'take_id': take.id,
          'voter_id':
              AuthService.instance.currentProfile?.userId ?? 'local-s26-actor',
          'stars': clampedStars,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).timeout(const Duration(seconds: 4));
      } catch (_) {}
    }

    if (!mounted) return;
    // Fixture #16: Casting Director Duty (Rate 5 Reels -> +2 Free AI Tokens once per 24h)
    final ratedCount = _userStarRatings.length.clamp(0, 5);
    if (ratedCount >= 5 && !_castingDutyRewardClaimedToday) {
      _castingDutyRewardClaimedToday = true;
      await AuthService.instance.addAiTokens(2);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF0B0E17),
          content: Text(
            '🎬 CASTING DIRECTOR DUTY COMPLETE (5/5)! +2 Free AI Tokens Credited!',
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w900,
              color: Color(0xFF10B981),
            ),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0B0E17),
        duration: const Duration(milliseconds: 1400),
        content: Text(
          'Stamped $clampedStars ★ Golden Rating for ${take.actorHandle}! (Casting Duty: $ratedCount/5)',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w800,
            color: Color(0xFFFFD700),
          ),
        ),
      ),
    );
  }

  List<CuttingRoomAuditionTake> get _filteredTakes {
    if (_selectedFeedFilter == 'TOP10') {
      final sorted = List<CuttingRoomAuditionTake>.from(_takes)
        ..sort((a, b) => b.aiTelemetricsScore.compareTo(a.aiTelemetricsScore));
      return sorted.take(10).toList();
    }
    if (_selectedFeedFilter == 'COSTAR') {
      final list = _takes
          .where((t) =>
              t.id.startsWith('duet_') ||
              t.sceneTitle.contains('CO-STAR') ||
              t.directorCommentStamp.contains('CO-STAR'))
          .toList();
      return list.isEmpty ? _takes : list;
    }
    if (_selectedFeedFilter == 'LIFE_IMPROV') {
      final list = _takes
          .where((t) =>
              t.id.startsWith('life_improv_') ||
              t.sceneTitle.contains('LIFE IS IMPROV') ||
              t.directorCommentStamp.contains('UNDERCOVER'))
          .toList();
      return list.isEmpty ? _takes : list;
    }
    return _takes;
  }

  /// Fixture #14: 5-Second Voice Roast & Heckle Audio Notes played through 2.5D Boondocks Avatar.
  Future<void> _openVoiceRoastModal(CuttingRoomAuditionTake take) async {
    HapticFeedback.mediumImpact();
    const roastPresets = <String>[
      '🎙️ "More passion from the diaphragm, darling! Take two!"',
      '🎙️ "Did you forget your cue or are you doing Method silence?!"',
      '🎙️ "Give this actor an Oscar and a stunt double immediately!"',
      '🎙️ "The camera loves you, even when you chew the scenery!"',
    ];
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF0B0E17),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        final myArchetype = resolveAvatarArchetype(
          AuthService.instance.currentProfile?.avatarArchetypeId,
        );
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    BoondocksCharacterRig(
                      archetype: myArchetype,
                      size: 52,
                      isSelected: true,
                      externalPhase: 0.65,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🎙️ 5s VOICE ROAST & HECKLE AUDIO NOTE',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFFD700),
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Plays through your 2.5D Avatar with animated talking jaw & waveform.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...roastPresets.map((preset) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF5DEB3),
                        side: const BorderSide(color: Color(0xFF0CB6D4)),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(preset),
                      icon: const Icon(
                        Icons.graphic_eq_rounded,
                        color: Color(0xFF0CB6D4),
                        size: 18,
                      ),
                      label: Text(
                        preset,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
    if (chosen != null && mounted) {
      HapticFeedback.heavyImpact();
      setState(() {
        _voiceRoastNotes[take.id] = chosen;
      });
    }
  }

  Future<void> _openReportAndBlockSheet(CuttingRoomAuditionTake take) async {
    HapticFeedback.heavyImpact();
    const reasons = <String>[
      'Inappropriate Audio / Language',
      'Harassment or Unsportsmanlike Conduct',
      'Spam / Off-Topic Audition Reel',
      'Block Actor from My Feed & Lobbies',
    ];

    final chosenReason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF0B0E17),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.flag_rounded,
                      color: Color(0xFFE11D48),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'REPORT OR BLOCK ${take.actorHandle}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFE11D48),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Flagged reels are immediately hidden from your feed and reported to Studio Moderation.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 12),
                ...reasons.map((r) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF334155)),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(r),
                      icon: const Icon(
                        Icons.shield_outlined,
                        color: Color(0xFFE11D48),
                        size: 18,
                      ),
                      label: Text(
                        r,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (chosenReason != null && mounted) {
      await CuttingRoomFeedStore.reportAndBlockActor(
        actorHandleOrName: take.actorHandle,
        reason: chosenReason,
        takeId: take.id,
      );
      await _hydrateTakesAndSavedRatings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF14080E),
          content: Text(
            'Reported & blocked ${take.actorHandle}. Reel removed from your feed.',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w800,
              color: Color(0xFFFFD700),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _openDirectorStampModal(CuttingRoomAuditionTake take) async {
    HapticFeedback.mediumImpact();
    final ctrl = TextEditingController(
      text: _customDirectorStamps[take.id] ?? take.directorCommentStamp,
    );

    const presets = <String>[
      'OSCAR-WORTHY · 10/10',
      'CHILLS ON SET 🔥',
      'PURE METHOD ACTING',
      'GIVE THEM THE STATUETTE',
    ];

    final stamped = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B0E17),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              18,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'STAMP DIRECTOR\'S CRITIQUE ON REEL',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: presets.map((preset) {
                    return ActionChip(
                      backgroundColor: const Color(0xFF141A29),
                      side: const BorderSide(color: Color(0xFFFFD700)),
                      label: Text(
                        preset,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFDE68A),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        ctrl.text = preset;
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  maxLength: 56,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g., OSCAR-WORTHY BREAKDOWN · 10/10',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF07090E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 14,
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
                  icon: const Icon(Icons.approval_rounded),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'SLAM DIRECTOR\'S STAMP ON FRAME',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (stamped != null && stamped.isNotEmpty && mounted) {
      HapticFeedback.heavyImpact();
      setState(() {
        _customDirectorStamps[take.id] = stamped.toUpperCase();
      });
    }
  }

  Future<void> _triggerViralShare(CuttingRoomAuditionTake take) async {
    HapticFeedback.mediumImpact();
    final stars = _userStarRatings[take.id] ?? 5;
    final stamp = _customDirectorStamps[take.id] ?? take.directorCommentStamp;
    final payload = '''
🎬 THE CUTTING ROOM FLOOR — ACT LIKE IT 🎬
Actor: ${take.actorHandle}
Scene: "${take.sceneTitle}" (${_formatCleanFilmSubtitle(take)})
AI Telemetrics: ${take.aiTelemetricsScore.toStringAsFixed(1)}/100 · Rated: ${'★' * stars} ($stars/5)
Director's Stamp: [$stamp]
${take.scriptExcerpt}
''';
    try {
      await SharePlus.instance.share(
        ShareParams(text: payload.trim()),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final activeTakes = _filteredTakes;
    final ratedCount = _userStarRatings.length.clamp(0, 5);

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      appBar: GameAppBar(
        title: 'THE CUTTING ROOM FLOOR',
        subtitle: activeTakes.isEmpty
            ? 'ALL REELS FILTERED'
            : 'REEL ${(_activeIndex + 1).clamp(1, activeTakes.length)} OF ${activeTakes.length} · SWIPE UP',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fixture #16: Casting Director Duty Progress Bar (+2 Free AI Tokens)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF0B0E17),
              border: Border(
                bottom: BorderSide(color: Color(0xFF1E293B)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _castingDutyRewardClaimedToday
                              ? '🎬 CASTING DUTY: 5/5 REELS JUDGED (+2 AI TOKENS CLAIMED)'
                              : '🎬 CASTING DUTY: $ratedCount/5 REELS JUDGED (EARN +2 FREE AI TOKENS)',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: _castingDutyRewardClaimedToday
                                ? const Color(0xFF10B981)
                                : const Color(0xFFFFD700),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _showSundayBoxOfficeBanner =
                              !_showSundayBoxOfficeBanner;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x26FFD700),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFFD700)),
                        ),
                        child: const Text(
                          '🏆 WEEKLY AWARDS',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFF5DEB3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Fixture #17: Collapsible Sunday Night Box Office Weekly Awards Banner
                if (_showSundayBoxOfficeBanner) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF140D1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFD700)),
                    ),
                    child: const Text(
                      '🏆 SUNDAY NIGHT BOX OFFICE AWARDS (7-DAY ROLLING LEADERS)\n'
                      '• Best Overall Actor: @METHOD_MAVERICK (96.4) · • Scene Stealer (Duet): @SCARLETT_VANE (95.6)\n'
                      '• Crowd Favorite: @FLASHBULB_FINN · • Fearless Real-World Daredevil: @UNDERCOVER_MAVERICK (97.2)',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9.5,
                        height: 1.35,
                        color: Color(0xFFF5DEB3),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                // Feed Category Filter Pills (Fixtures #1, #3, #15)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFeedFilterChip('ALL', '🎞️ All Reels'),
                      const SizedBox(width: 6),
                      _buildFeedFilterChip(
                        'TOP10',
                        '🏆 Today\'s Box Office Top 10',
                      ),
                      const SizedBox(width: 6),
                      _buildFeedFilterChip(
                        'COSTAR',
                        '🎬 Open Co-Star Auditions',
                      ),
                      const SizedBox(width: 6),
                      _buildFeedFilterChip(
                        'LIFE_IMPROV',
                        '🔥 Life Is Improv: Viral Dares',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: activeTakes.isEmpty
                ? const Center(
                    child: Text(
                      'No audition reels available.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : PageView.builder(
                    controller: _verticalPageController,
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    itemCount: activeTakes.length,
                    onPageChanged: (idx) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _activeIndex = idx;
                      });
                    },
                    itemBuilder: (context, index) {
                      final take = activeTakes[index];
                      return _buildFullScreenCellShadedReel(take);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedFilterChip(String key, String label) {
    final selected = _selectedFeedFilter == key;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedFeedFilter = key;
          _activeIndex = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE11342) : const Color(0xFF141926),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected ? const Color(0xFFFFD700) : const Color(0xFF334155),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 9.5,
            fontWeight: FontWeight.w900,
            color: selected ? Colors.white : const Color(0xFFCBD5E1),
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreenCellShadedReel(CuttingRoomAuditionTake take) {
    final archetype = resolveAvatarArchetype(take.avatarArchetypeId);
    final selectedStars = _userStarRatings[take.id];
    final activeStamp =
        _customDirectorStamps[take.id] ?? take.directorCommentStamp;
    final rosesCount = _roseHypeCounts[take.id] ?? 18;

    return AnimatedBuilder(
      animation: _reelLoopController,
      builder: (context, _) {
        final progress = _reelLoopController.value;
        final phase = progress * math.pi * 2;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0B0E17),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF05070B),
                width: 4.0,
              ),
              boxShadow: <BoxShadow>[
                const BoxShadow(
                  color: Color(0xFF05070B),
                  offset: Offset(6, 6),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: take.neonAccent.withValues(alpha: 0.26),
                  blurRadius: 24,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. 2.5D Cell-Shaded Looping Audition Stage Canvas
                CustomPaint(
                  painter: _CuttingRoomLoopStagePainter(
                    phase: phase,
                    neonAccent: take.neonAccent,
                  ),
                ),

                // 2. Live Audition Reel Viewport (Viewfinder HUD + Waveform + Scrubber + Character)
                Align(
                  alignment: const Alignment(0.0, -0.22),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 56, 74, 150),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xB307090E),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: take.neonAccent.withValues(alpha: 0.85),
                          width: 2.0,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Camera Viewfinder Header HUD
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: (progress * 10).floor().isEven
                                          ? const Color(0xFFFF1744)
                                          : const Color(0x55FF1744),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'PLAYBACK 00:0${(progress * 6).floor()} / 00:06',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'AI ${take.aiTelemetricsScore.toStringAsFixed(1)}/100',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: take.neonAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => showBoondocksCharacterSpotlightModal(
                              context,
                              archetype,
                            ),
                            child: BoondocksCharacterRig(
                              archetype: archetype,
                              size: 118,
                              isSelected: true,
                              externalPhase: phase,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Live Audio Waveform Bars
                          SizedBox(
                            height: 22,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(18, (barIdx) {
                                final h = 5.0 +
                                    15.0 *
                                        (0.5 +
                                            0.5 *
                                                math.sin(
                                                  phase * 2.0 + barIdx * 0.55,
                                                ));
                                return Container(
                                  width: 4,
                                  height: h,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: barIdx.isEven
                                        ? take.neonAccent
                                        : const Color(0xFFFFD700),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Timeline Scrubber Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 5,
                              backgroundColor: const Color(0xFF1E293B),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                take.neonAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Angled "DIRECTOR'S COMMENT STAMP" Ink Overlay
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: GestureDetector(
                    onTap: () => _openDirectorStampModal(take),
                    child: Transform.rotate(
                      angle: -0.025,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xE62B0610),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFFFD700),
                            width: 2.2,
                          ),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0xFF05070B),
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.approval_rounded,
                              color: Color(0xFFFFD700),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'DIRECTOR STAMP: $activeStamp',
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                    color: Color(0xFFFFD700),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 4. Right-Side Vertical Action Column (Stamp, Rose Hype, Share, UGC Report/Block)
                Positioned(
                  right: 12,
                  top: 68,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionOrb(
                        icon: Icons.approval_rounded,
                        label: 'STAMP',
                        accent: const Color(0xFFFFD700),
                        onTap: () => _openDirectorStampModal(take),
                      ),
                      const SizedBox(height: 10),
                      _buildActionOrb(
                        icon: Icons.local_florist_rounded,
                        label: '🌹 $rosesCount',
                        accent: const Color(0xFF10B981),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _roseHypeCounts[take.id] = rosesCount + 1;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildActionOrb(
                        icon: Icons.ios_share_rounded,
                        label: '${take.shareCount}',
                        accent: const Color(0xFF06B6D4),
                        onTap: () => _triggerViralShare(take),
                      ),
                      _buildActionOrb(
                        icon: Icons.mic_external_on_rounded,
                        label: '5s ROAST',
                        accent: const Color(0xFFA855F7),
                        onTap: () => _openVoiceRoastModal(take),
                      ),
                      const SizedBox(height: 10),
                      _buildActionOrb(
                        icon: Icons.flag_rounded,
                        label: 'REPORT',
                        accent: const Color(0xFFE11D48),
                        onTap: () => _openReportAndBlockSheet(take),
                      ),
                    ],
                  ),
                ),

                // 5. Bottom Metadata + 5-to-1 GOLDEN STAR RATING BOX
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xEB07090E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF05070B),
                            width: 3.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      take.actorHandle,
                                      style: GoogleFonts.bebasNeue(
                                        fontSize: 22,
                                        letterSpacing: 1.4,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: archetype.primaryInkColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    archetype.name,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF05070B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _formatCleanFilmSubtitle(take),
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: take.neonAccent,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              take.scriptExcerpt,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.2,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFFE2E8F0),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 5),
                            // Fixture #2: Millisecond AI Receipt Stamp on Feed Reel
                            Text(
                              '[00:01.18] 🔥 +8.5 PT VOCAL PEAK · AI ${take.aiTelemetricsScore.toStringAsFixed(1)}/100',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFD700),
                              ),
                            ),
                            if (_voiceRoastNotes[take.id] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _voiceRoastNotes[take.id]!,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0CB6D4),
                                ),
                              ),
                            ],
                            // Fixture #1: Accept Open Co-Star Audition Button
                            if (take.id.startsWith('duet_') ||
                                take.sceneTitle.contains('CO-STAR')) ...[
                              const SizedBox(height: 6),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0CB6D4),
                                    foregroundColor: const Color(0xFF05070B),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 10,
                                    ),
                                  ),
                                  onPressed: () {
                                    HapticFeedback.heavyImpact();
                                    final defaultScene = kBuiltInSceneVault[
                                            SceneCategory.era2000To2026]!
                                        .first;
                                    final session = LobbySession(
                                      id: 'duet_${take.id}',
                                      roomCode: 'DUET88',
                                      hostId: 'local-costar',
                                      selectedCategory:
                                          SceneCategory.era2000To2026,
                                      status: 'performing',
                                      roundNumber: 1,
                                      activeActorId: 'local-costar',
                                      activeScene: defaultScene,
                                      livekitRoomName: 'act_like_it_DUET88',
                                      players: const <LobbyPlayer>[],
                                    );
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => LiveKitSoundstageScreen(
                                          lobbySession: session,
                                          localUserId: 'local-costar',
                                          localDisplayName: AuthService.instance
                                                  .currentProfile?.displayName ??
                                              'Co-Star Lead B',
                                          openCoStarChallengeTakeId: take.id,
                                          openCoStarLeadAHandle:
                                              take.actorHandle,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.splitscreen_rounded,
                                    size: 16,
                                  ),
                                  label: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '🎬 ACCEPT CO-STAR AUDITION (RECORD CYAN LEAD B)',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 5-to-1 GOLDEN STAR RATING BOX
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xF20B0E17),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFFD700),
                            width: 2.2,
                          ),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0xFF05070B),
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '5-TO-1 GOLDEN STAR RATING BOX',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFFFD700),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      selectedStars != null
                                          ? 'YOUR VERDICT: $selectedStars ★'
                                          : 'AVG ${take.averageStarRating.toStringAsFixed(1)} ★ (${take.totalRatingsCount})',
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
                            const SizedBox(height: 7),
                            Row(
                              children: [5, 4, 3, 2, 1].map((starValue) {
                                final isChosen = selectedStars == starValue;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    child: GestureDetector(
                                      onTap: () =>
                                          _submitStarRating(take, starValue),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 180),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isChosen
                                              ? const Color(0xFFFFD700)
                                              : const Color(0xFF141926),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isChosen
                                                ? const Color(0xFF05070B)
                                                : const Color(0xFF334155),
                                            width: isChosen ? 2.4 : 1.2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.star_rounded,
                                              size: 15,
                                              color: isChosen
                                                  ? const Color(0xFF05070B)
                                                  : const Color(0xFFFFD700),
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              '$starValue',
                                              style: TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w900,
                                                color: isChosen
                                                    ? const Color(0xFF05070B)
                                                    : Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionOrb({
    required IconData icon,
    required String label,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xEB07090E),
              shape: BoxShape.circle,
              border: Border.all(color: accent, width: 2.0),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0xFF05070B),
                  offset: Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CuttingRoomLoopStagePainter extends CustomPainter {
  final double phase;
  final Color neonAccent;

  const _CuttingRoomLoopStagePainter({
    required this.phase,
    required this.neonAccent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.42);

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.2),
          radius: 0.95,
          colors: <Color>[
            neonAccent.withValues(alpha: 0.28),
            const Color(0xFF0B0E17),
            const Color(0xFF05070B),
          ],
        ).createShader(Offset.zero & size),
    );

    final linePaint = Paint()
      ..color = neonAccent.withValues(alpha: 0.22)
      ..strokeWidth = 2.0;

    for (int i = 0; i < 20; i++) {
      final angle = (i / 20.0) * math.pi * 2 + phase * 0.25;
      final r1 = 76.0 + (i.isEven ? 14.0 : 0.0);
      final r2 = size.longestSide * 0.7;
      canvas.drawLine(
        Offset(center.dx + math.cos(angle) * r1, center.dy + math.sin(angle) * r1),
        Offset(center.dx + math.cos(angle) * r2, center.dy + math.sin(angle) * r2),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CuttingRoomLoopStagePainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.neonAccent != neonAccent;
}
