import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../offline_manager.dart';
import '../auth/auth_service.dart';
import 'intro_cinematic.dart';

enum SceneCategory {
  era1970To1999(
    key: 'era_1970_1999',
    label: 'Eras: 1970–1999',
    table: 'scenes',
    awardFilter: null,
  ),
  era2000To2026(
    key: 'era_2000_2026',
    label: 'Eras: 2000–2026',
    table: 'scenes',
    awardFilter: null,
  ),
  awardsBestActor(
    key: 'awards_best_actor',
    label: 'Awards: Best Actor',
    table: 'scenes',
    awardFilter: 'Best Actor',
  ),
  awardsBestActress(
    key: 'awards_best_actress',
    label: 'Awards: Best Actress',
    table: 'scenes',
    awardFilter: 'Best Actress',
  ),
  awardsBestSupportingActor(
    key: 'awards_best_supporting_actor',
    label: 'Awards: Best Supporting Actor',
    table: 'scenes',
    awardFilter: 'Best Supporting Actor',
  ),
  awardsBestVillain(
    key: 'awards_best_villain',
    label: 'Awards: Best Villain',
    table: 'scenes',
    awardFilter: 'Best Villain',
  ),
  awardsEmmyVault(
    key: 'awards_emmy_vault',
    label: 'Awards: Emmy Vault',
    table: 'scenes',
    awardFilter: 'Emmy Vault',
  ),
  specialtyCultClassics(
    key: 'specialty_cult_classics',
    label: 'Specialty: Cult Classics',
    table: 'scenes',
    awardFilter: null,
  );

  final String key;
  final String label;
  final String table;
  final String? awardFilter;

  const SceneCategory({
    required this.key,
    required this.label,
    required this.table,
    required this.awardFilter,
  });

  static SceneCategory fromKey(String key) {
    return SceneCategory.values.firstWhere(
      (c) => c.key == key || c.label == key,
      orElse: () => SceneCategory.era1970To1999,
    );
  }
}

/// Shared Element (Hero) tag registry and custom flight shuttle / route builder
/// connecting the Movie Ticket Carousel (`lib/dashboard_marquee.dart`),
/// Matchmaking Lobby (`lib/lobby.dart`), and Active Acting Screen (`lib/webrtc_manager.dart`).
class SceneHeroTags {
  static String ticketTag(SceneCategory category) =>
      'scene_vault_ticket_${category.key}';

  static RectTween createTicketArcTween(Rect? begin, Rect? end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  }

  static Widget buildTicketFlightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final Hero toHero = toHeroContext.widget as Hero;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) {
        return Material(
          type: MaterialType.transparency,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: toHero.child,
          ),
        );
      },
    );
  }
}

/// Smooth 300ms Hollywood shutter/fade-scale PageRouteBuilder that pairs with
/// the Hero shared element flight and door transitions.
class StageSharedTransitionRoute<T> extends PageRouteBuilder<T> {
  StageSharedTransitionRoute({required Widget page})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeCurve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            final scaleTween = Tween<double>(begin: 0.96, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );
            return FadeTransition(
              opacity: fadeCurve,
              child: ScaleTransition(
                scale: scaleTween,
                child: child,
              ),
            );
          },
        );
}

class ScenePrompt {
  final String id;
  final String title;
  final String filmOrSeries;
  final int releaseYear;
  final String characterName;
  final String promptScript;
  final String directorCue;
  final String emotionalTarget;
  final int durationSeconds;
  final int difficultyTier;

  const ScenePrompt({
    required this.id,
    required this.title,
    required this.filmOrSeries,
    required this.releaseYear,
    required this.characterName,
    required this.promptScript,
    required this.directorCue,
    required this.emotionalTarget,
    required this.durationSeconds,
    required this.difficultyTier,
  });

  factory ScenePrompt.fromJson(Map<String, dynamic> json) {
    final targetEmotion = (json['target_emotion'] ??
            json['emotional_target'] ??
            'Dramatic Intensity')
        .toString();
    return ScenePrompt(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Scene',
      filmOrSeries:
          (json['actor_name'] ?? json['film_or_series'] ?? 'Featured Actor')
              .toString(),
      releaseYear: (json['release_year'] as num?)?.toInt() ?? 2000,
      characterName: json['character_name']?.toString() ?? 'Lead Role',
      promptScript:
          (json['script_excerpt'] ?? json['prompt_script'] ?? '').toString(),
      directorCue: (json['director_cue'] ??
              'Deliver all 3–4 lines with full conviction toward $targetEmotion.')
          .toString(),
      emotionalTarget: targetEmotion,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 35,
      difficultyTier: (json['difficulty_tier'] as num?)?.toInt() ?? 4,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'film_or_series': filmOrSeries,
        'release_year': releaseYear,
        'character_name': characterName,
        'prompt_script': promptScript,
        'director_cue': directorCue,
        'emotional_target': emotionalTarget,
        'duration_seconds': durationSeconds,
        'difficulty_tier': difficultyTier,
      };
}

/// Built-in Scene Vaults with original Copyright-Safe Parody Scripts so the APK works 100% offline or online on the S26 Ultra.
const Map<SceneCategory, List<ScenePrompt>> kBuiltInSceneVault = {
  SceneCategory.era1970To1999: [
    ScenePrompt(
      id: 'era-70-neon-rain',
      title: 'Sparks in the Downpour',
      filmOrSeries: 'Neon Rain 1982 (Original Parody)',
      releaseYear: 1982,
      characterName: 'Commander Vance',
      promptScript:
          "I've watched neon starships burn above the rings of Saturn, flickering like fireflies in the dark. Every memory we built will vanish into the static, like sparks in a midnight downpour.",
      directorCue:
          'Begin with quiet awe, maintain steady eye contact with the camera lens, and release a gentle breath on the final phrase.',
      emotionalTarget: 'Melancholic Transcendence',
      durationSeconds: 30,
      difficultyTier: 4,
    ),
    ScenePrompt(
      id: 'era-90-courtroom-honor',
      title: 'The Verdict You Requested',
      filmOrSeries: 'Courtroom Honor (Original Parody)',
      releaseYear: 1992,
      characterName: 'General Sterling',
      promptScript:
          'You sit in the gallery and question the watchtower, because you enjoy the comfort of never holding the line. You demand the classified truth, yet your hands would tremble the moment I laid the ledger on that bench!',
      directorCue:
          'Start with icy courtroom restraint before escalating vocal projection on the second sentence.',
      emotionalTarget: 'Commanding Indignation',
      durationSeconds: 30,
      difficultyTier: 3,
    ),
  ],
  SceneCategory.era2000To2026: [
    ScenePrompt(
      id: 'era-00-tempo-obsession',
      title: 'Off My Metronome',
      filmOrSeries: 'Tempo Obsession (Original Parody)',
      releaseYear: 2014,
      characterName: 'Maestro Vance',
      promptScript:
          'Were you rushing the downbeat or dragging the brass? If you sabotage the rhythm of this conservatory stage on my watch, I will lock the rehearsal doors until sunrise.',
      directorCue:
          'Whisper the opening question with razor-sharp stillness, then snap into sudden percussive intensity.',
      emotionalTarget: 'Controlled Menace',
      durationSeconds: 25,
      difficultyTier: 4,
    ),
    ScenePrompt(
      id: 'era-20-parallel-laundromat',
      title: 'Quiet Universe',
      filmOrSeries: 'Parallel Laundromat (Original Parody)',
      releaseYear: 2022,
      characterName: 'Desmond',
      promptScript:
          'In another timeline, without the flashing cameras or the chaos, I think I would have loved just folding warm laundry and balancing receipts beside you.',
      directorCue:
          'Soften your shoulders, let a bittersweet half-smile form, and deliver with vulnerable sincerity.',
      emotionalTarget: 'Tender Vulnerability',
      durationSeconds: 25,
      difficultyTier: 3,
    ),
  ],
  SceneCategory.awardsBestActor: [
    ScenePrompt(
      id: 'award-actor-black-gold',
      title: 'The Pipeline Reaches',
      filmOrSeries: 'Black Gold Tycoon (Original Parody)',
      releaseYear: 2007,
      characterName: 'Harlan Vance',
      promptScript:
          'If your derrick sits on the ridge and my pipeline runs three miles deep, my siphon reaches clear across the valley floor. I drain the entire reservoir before your crew even turns the valve!',
      directorCue:
          'Lean forward into the frame, build rhythmic cadence on the metaphor, and erupt on the final declaration.',
      emotionalTarget: 'Ruthless Triumph',
      durationSeconds: 35,
      difficultyTier: 5,
    ),
  ],
  SceneCategory.awardsBestActress: [
    ScenePrompt(
      id: 'award-actress-midnight-ranch',
      title: 'The Open Pasture Gate',
      filmOrSeries: 'Midnight Ranch (Original Parody)',
      releaseYear: 1991,
      characterName: 'Agent Clara',
      promptScript:
          'I woke before dawn when the frost was still heavy on the fence, and I unlatched the wooden gate so the colts could run free. None of them moved—so I gathered the smallest one in my coat and walked into the fog.',
      directorCue:
          'Hold trembling composure for two beats before letting quiet resolve overtake the line.',
      emotionalTarget: 'Trembling Resolve',
      durationSeconds: 35,
      difficultyTier: 5,
    ),
  ],
  SceneCategory.awardsBestSupportingActor: [
    ScenePrompt(
      id: 'award-supp-river-bench',
      title: 'Beyond the Textbook',
      filmOrSeries: 'Charles River Bench (Original Parody)',
      releaseYear: 1997,
      characterName: 'Professor Callahan',
      promptScript:
          "You can recite every chapter ever printed on Renaissance brushwork, yet you have never stood beneath a cathedral dome and breathed in the turpentine and dust. Real life isn't footnotes—it's risking your heart in the open.",
      directorCue:
          'Speak with quiet, grounded warmth and steady, unhurried eye contact.',
      emotionalTarget: 'Grounded Empathy & Quiet Wisdom',
      durationSeconds: 35,
      difficultyTier: 4,
    ),
  ],
  SceneCategory.awardsBestVillain: [
    ScenePrompt(
      id: 'award-villain-coin-toss',
      title: 'Call It in the Dust',
      filmOrSeries: 'Desert Coin Toss (Original Parody)',
      releaseYear: 2007,
      characterName: 'The Collector',
      promptScript:
          "Tell me the highest stake you ever put on a single flip of silver. Don't slide that coin back into your register—it stopped being ordinary change the moment it left my palm.",
      directorCue:
          'Zero blinking, flat deadpan cadence, tilt chin slightly downward while staring directly into the lens.',
      emotionalTarget: 'Unblinking Dread',
      durationSeconds: 30,
      difficultyTier: 4,
    ),
  ],
  SceneCategory.awardsEmmyVault: [
    ScenePrompt(
      id: 'award-emmy-desert-chemistry',
      title: 'The Storm at the Gate',
      filmOrSeries: 'Desert Chemistry (Original Parody)',
      releaseYear: 2011,
      characterName: 'Professor Sterling',
      promptScript:
          'You still think we are waiting for someone to rescue this operation from the storm. Listen closely: I am not the one hiding behind the bolted door—I am the storm at the gate.',
      directorCue:
          'Drop vocal pitch half an octave and step closer to the microphone on the final five words.',
      emotionalTarget: 'Ego & Cold Authority',
      durationSeconds: 30,
      difficultyTier: 4,
    ),
  ],
  SceneCategory.specialtyCultClassics: [
    ScenePrompt(
      id: 'cult-espresso-closers',
      title: 'Espresso Is for Closers',
      filmOrSeries: 'Midnight Boardroom (Original Parody)',
      releaseYear: 1992,
      characterName: 'Vance Blake',
      promptScript:
          'Set that porcelain cup back on the saucer! Double-shot espresso is reserved for top producers who sign the gold leads before midnight. Always be closing the deal.',
      directorCue:
          'Snap fingers once, pace the frame slightly, and deliver with rapid-fire boardroom swagger.',
      emotionalTarget: 'Aggressive Salesmanship',
      durationSeconds: 30,
      difficultyTier: 3,
    ),
  ],
};

class LobbyPlayer {
  final String id;
  final String lobbyId;
  final String userId;
  final String displayName;
  final bool isHost;
  final bool isReady;
  final double aiTelemetricsScore;
  final double peerScore;
  final double socialScore;

  const LobbyPlayer({
    required this.id,
    required this.lobbyId,
    required this.userId,
    required this.displayName,
    required this.isHost,
    required this.isReady,
    this.aiTelemetricsScore = 0,
    this.peerScore = 0,
    this.socialScore = 0,
  });

  LobbyPlayer copyWith({
    bool? isReady,
    double? aiTelemetricsScore,
    double? peerScore,
    double? socialScore,
  }) {
    return LobbyPlayer(
      id: id,
      lobbyId: lobbyId,
      userId: userId,
      displayName: displayName,
      isHost: isHost,
      isReady: isReady ?? this.isReady,
      aiTelemetricsScore: aiTelemetricsScore ?? this.aiTelemetricsScore,
      peerScore: peerScore ?? this.peerScore,
      socialScore: socialScore ?? this.socialScore,
    );
  }

  factory LobbyPlayer.fromJson(
    Map<String, dynamic> json, {
    String? hostId,
  }) {
    final profileMap = json['profiles'] is Map
        ? Map<String, dynamic>.from(json['profiles'] as Map)
        : null;
    final resolvedUserId = json['user_id']?.toString() ?? '';
    final resolvedDisplayName = json['display_name']?.toString() ??
        profileMap?['username']?.toString() ??
        'Actor';
    final resolvedIsHost = json['is_host'] == true ||
        (hostId != null && hostId.isNotEmpty && resolvedUserId == hostId);

    return LobbyPlayer(
      id: json['id']?.toString() ?? '',
      lobbyId: json['lobby_id']?.toString() ?? '',
      userId: resolvedUserId,
      displayName: resolvedDisplayName,
      isHost: resolvedIsHost,
      isReady: json['is_ready'] == true,
      aiTelemetricsScore:
          (json['ai_telemetrics_score'] as num?)?.toDouble() ?? 0,
      peerScore: (json['peer_score'] as num?)?.toDouble() ?? 0,
      socialScore: (json['social_score'] as num?)?.toDouble() ?? 0,
    );
  }
}

class LobbySession {
  final String id;
  final String roomCode;
  final String hostId;
  final SceneCategory selectedCategory;
  final String status;
  final int minPlayers;
  final int maxPlayers;
  final String? activeActorId;
  final ScenePrompt? activeScene;
  final int roundNumber;
  final String livekitRoomName;

  const LobbySession({
    required this.id,
    required this.roomCode,
    required this.hostId,
    required this.selectedCategory,
    required this.status,
    this.minPlayers = 2,
    this.maxPlayers = 8,
    this.activeActorId,
    this.activeScene,
    this.roundNumber = 1,
    required this.livekitRoomName,
  });

  LobbySession copyWith({
    SceneCategory? selectedCategory,
    String? status,
    String? activeActorId,
    ScenePrompt? activeScene,
    int? roundNumber,
    String? livekitRoomName,
  }) {
    return LobbySession(
      id: id,
      roomCode: roomCode,
      hostId: hostId,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      status: status ?? this.status,
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
      activeActorId: activeActorId ?? this.activeActorId,
      activeScene: activeScene ?? this.activeScene,
      roundNumber: roundNumber ?? this.roundNumber,
      livekitRoomName: livekitRoomName ?? this.livekitRoomName,
    );
  }

  factory LobbySession.fromJson(
    Map<String, dynamic> json, {
    SceneCategory? fallbackCategory,
    ScenePrompt? fallbackScene,
    String? fallbackActorId,
  }) {
    final roomCode = json['room_code']?.toString() ?? '000000';
    final rawLiveKitRoom = json['livekit_room_name']?.toString() ?? '';
    final payload = json['active_scene_payload'] ?? json['scenes'];

    ScenePrompt? parsedScene = fallbackScene;
    if (payload is Map) {
      parsedScene = ScenePrompt.fromJson(Map<String, dynamic>.from(payload));
    }

    final rawCategory = json['selected_category']?.toString();
    final resolvedCategory = (rawCategory != null && rawCategory.isNotEmpty)
        ? SceneCategory.fromKey(rawCategory)
        : (fallbackCategory ?? SceneCategory.era1970To1999);

    return LobbySession(
      id: json['id']?.toString() ?? '',
      roomCode: roomCode,
      hostId: json['host_id']?.toString() ?? '',
      selectedCategory: resolvedCategory,
      status: json['status']?.toString() ?? 'waiting',
      minPlayers: (json['min_players'] as num?)?.toInt() ?? 2,
      maxPlayers: (json['max_players'] as num?)?.toInt() ?? 8,
      activeActorId: json['active_actor_id']?.toString() ??
          fallbackActorId ??
          json['host_id']?.toString(),
      activeScene: parsedScene,
      roundNumber: (json['round_number'] as num?)?.toInt() ?? 1,
      livekitRoomName: rawLiveKitRoom.isNotEmpty
          ? rawLiveKitRoom
          : 'act_like_it_$roomCode',
    );
  }
}

class LobbyRealtimeManager extends ChangeNotifier {
  LobbySession? _session;
  List<LobbyPlayer> _players = [];
  RealtimeChannel? _realtimeChannel;
  bool _isLoading = false;
  bool _isDisposed = false;
  String? _errorMessage;

  String _localUserId;
  String localDisplayName;

  LobbyRealtimeManager({
    String? userId,
    String? localDisplayName,
  })  : _localUserId = userId ??
            supabaseOrNull?.auth.currentUser?.id ??
            _generateEphemeralUuid(),
        localDisplayName = (localDisplayName != null &&
                localDisplayName.trim().isNotEmpty)
            ? localDisplayName.trim()
            : (AuthService.instance.currentProfile?.username.isNotEmpty == true
                ? AuthService.instance.currentProfile!.username
                : 'StageStar');

  String get localUserId => _localUserId;
  LobbySession? get session => _session;
  List<LobbyPlayer> get players => List.unmodifiable(_players);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isHost => _session != null && _session!.hostId == _localUserId;
  bool get canStartMatch =>
      _players.isNotEmpty &&
      _players.length <= 8 &&
      _players.every((p) => p.isReady || p.isHost);

  static Random _safeRandom() {
    try {
      return Random.secure();
    } catch (_) {
      return Random();
    }
  }

  static bool _isValidUuid(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value);
  }

  static String _generateEphemeralUuid() {
    final random = _safeRandom();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int byte) => byte.toRadixString(16).padLeft(2, '0');
    return '${hex(bytes[0])}${hex(bytes[1])}${hex(bytes[2])}${hex(bytes[3])}-'
        '${hex(bytes[4])}${hex(bytes[5])}-'
        '${hex(bytes[6])}${hex(bytes[7])}-'
        '${hex(bytes[8])}${hex(bytes[9])}-'
        '${hex(bytes[10])}${hex(bytes[11])}${hex(bytes[12])}${hex(bytes[13])}${hex(bytes[14])}${hex(bytes[15])}';
  }

  static String generateSixDigitCode() {
    final random = _safeRandom();
    final code = 100000 + random.nextInt(900000);
    return code.toString();
  }

  static const String _kActiveRoomCodePrefsKey = 'active_room_code';
  static const String _kTelemetricsTokensPrefsKey = 'telemetrics_tokens';

  static Future<void> saveActiveRoomSession(String roomCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kActiveRoomCodePrefsKey, roomCode.trim());
    } catch (_) {}
  }

  static Future<void> clearActiveRoomSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kActiveRoomCodePrefsKey);
    } catch (_) {}
  }

  static Future<String?> loadActiveRoomSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_kActiveRoomCodePrefsKey)?.trim();
      if (code != null && RegExp(r'^[0-9]{6}$').hasMatch(code)) {
        return code;
      }
    } catch (_) {}
    return null;
  }

  static Future<int> loadTelemetricsTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey(_kTelemetricsTokensPrefsKey)) {
        await prefs.setInt(_kTelemetricsTokensPrefsKey, 25);
        return 25;
      }
      return prefs.getInt(_kTelemetricsTokensPrefsKey) ?? 25;
    } catch (_) {
      return 25;
    }
  }

  static Future<int> consumeTelemetricsToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = await loadTelemetricsTokens();
      final next = current > 0 ? current - 1 : 0;
      await prefs.setInt(_kTelemetricsTokensPrefsKey, next);
      return next;
    } catch (_) {
      return 25;
    }
  }

  void _notifySafely() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<String?> _ensureAuthenticatedAndProfile(SupabaseClient client) async {
    try {
      var currentUser = client.auth.currentUser;
      if (currentUser == null) {
        final anonRes = await client.auth.signInAnonymously();
        currentUser = anonRes.user;
      }
      if (currentUser == null) return null;

      _localUserId = currentUser.id;
      final cleanHandle = localDisplayName
          .trim()
          .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
          .toLowerCase();
      final suffix = _localUserId.substring(0, 6);
      final uniqueUsername =
          '${cleanHandle.isEmpty ? 'actor' : cleanHandle}_$suffix';

      await client.from('profiles').upsert(
        {
          'id': _localUserId,
          'username': uniqueUsername,
          'birth_year': 1998,
        },
        onConflict: 'id',
      );
      return _localUserId;
    } catch (_) {
      return client.auth.currentUser?.id;
    }
  }

  Future<void> createLobby({
    required String displayName,
    required SceneCategory category,
    ScenePrompt? preselectedPrompt,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    localDisplayName =
        displayName.trim().isEmpty ? 'Galaxy S26 Host' : displayName.trim();

    String roomCode = generateSixDigitCode();
    final defaultPrompt = preselectedPrompt ??
        (kBuiltInSceneVault[category]?.first ??
            kBuiltInSceneVault[SceneCategory.era1970To1999]!.first);
    final client = supabaseOrNull;

    if (client != null) {
      try {
        final authedUserId = await _ensureAuthenticatedAndProfile(client);
        if (authedUserId != null) {
          Map<String, dynamic>? insertedLobby;
          for (int attempt = 0; attempt < 3; attempt++) {
            roomCode = generateSixDigitCode();
            try {
              insertedLobby = await client
                  .from('lobbies')
                  .insert({
                    'room_code': roomCode,
                    'host_id': authedUserId,
                    if (_isValidUuid(defaultPrompt.id))
                      'active_scene_id': defaultPrompt.id,
                    'status': 'waiting',
                  })
                  .select('*, scenes(*)')
                  .single();
              break;
            } catch (_) {
              if (attempt == 2) rethrow;
            }
          }

          if (insertedLobby != null) {
            _session = LobbySession.fromJson(
              insertedLobby,
              fallbackCategory: category,
              fallbackScene: defaultPrompt,
              fallbackActorId: authedUserId,
            );

            await client.from('lobby_players').upsert(
              {
                'lobby_id': _session!.id,
                'user_id': authedUserId,
                'is_ready': true,
              },
              onConflict: 'lobby_id,user_id',
            );

            await _refreshPlayers(_session!.id);
            _subscribeToLobbyRealtime(_session!);
            unawaited(saveActiveRoomSession(_session!.roomCode));
            _setLoading(false);
            return;
          }
        }
      } catch (_) {}
    }

    final livekitRoomName = 'act_like_it_$roomCode';
    final lobbyId = _generateEphemeralUuid();

    _session = LobbySession(
      id: lobbyId,
      roomCode: roomCode,
      hostId: _localUserId,
      selectedCategory: category,
      status: 'performing',
      activeActorId: _localUserId,
      activeScene: defaultPrompt,
      livekitRoomName: livekitRoomName,
    );

    _players = [
      LobbyPlayer(
        id: 'p-host',
        lobbyId: lobbyId,
        userId: _localUserId,
        displayName: localDisplayName,
        isHost: true,
        isReady: true,
      ),
    ];
    unawaited(saveActiveRoomSession(roomCode));
    _setLoading(false);
  }

  /// Adds 1 ready AI Co-Star per tap up to 8 total cast members in the Green Room.
  void addAiCoStar() {
    final currentSession = _session;
    if (currentSession == null) return;
    if (_players.length >= currentSession.maxPlayers) return;

    final nextIndex = _players.length;
    final archetype =
        kFourteenAvatarArchetypes[nextIndex % kFourteenAvatarArchetypes.length];
    final coStarName = '${archetype.name} (AI Co-Star)';

    _players = [
      ..._players,
      LobbyPlayer(
        id: 'p-ai-$nextIndex',
        lobbyId: currentSession.id,
        userId: 'ai-costar-$nextIndex',
        displayName: coStarName,
        isHost: false,
        isReady: true,
      ),
    ];
    _notifySafely();
  }

  Future<void> joinLobbyByCode({
    required String roomCode,
    required String displayName,
  }) async {
    final sanitizedCode = roomCode.trim();
    if (!RegExp(r'^[0-9]{6}$').hasMatch(sanitizedCode)) {
      _errorMessage = 'Enter a valid 6-digit numeric lobby code.';
      _notifySafely();
      return;
    }

    _setLoading(true);
    _errorMessage = null;
    localDisplayName =
        displayName.trim().isEmpty ? 'Remote Actor' : displayName.trim();

    final client = supabaseOrNull;
    if (client != null) {
      try {
        final authedUserId = await _ensureAuthenticatedAndProfile(client);
        final lobbyRecord = await client
            .from('lobbies')
            .select('*, scenes(*)')
            .eq('room_code', sanitizedCode)
            .maybeSingle();

        if (lobbyRecord != null && authedUserId != null) {
          final fallbackPrompt =
              kBuiltInSceneVault[SceneCategory.era1970To1999]!.first;
          final lobby = LobbySession.fromJson(
            Map<String, dynamic>.from(lobbyRecord as Map),
            fallbackCategory: SceneCategory.era1970To1999,
            fallbackScene: fallbackPrompt,
          );
          await client.from('lobby_players').upsert(
            {
              'lobby_id': lobby.id,
              'user_id': authedUserId,
              'is_ready': true,
            },
            onConflict: 'lobby_id,user_id',
          );
          _session = lobby;
          await _refreshPlayers(lobby.id);
          _subscribeToLobbyRealtime(lobby);
          unawaited(saveActiveRoomSession(sanitizedCode));
          _setLoading(false);
          return;
        }
      } catch (_) {}
    }

    final lobbyId = _generateEphemeralUuid();
    _session = LobbySession(
      id: lobbyId,
      roomCode: sanitizedCode,
      hostId: _localUserId,
      selectedCategory: SceneCategory.era1970To1999,
      status: 'performing',
      activeActorId: _localUserId,
      activeScene: kBuiltInSceneVault[SceneCategory.era1970To1999]!.first,
      livekitRoomName: 'act_like_it_$sanitizedCode',
    );
    _players = [
      LobbyPlayer(
        id: 'p-1',
        lobbyId: lobbyId,
        userId: _localUserId,
        displayName: localDisplayName,
        isHost: true,
        isReady: true,
      ),
      LobbyPlayer(
        id: 'p-2',
        lobbyId: lobbyId,
        userId: 'remote-peer-1',
        displayName: 'Host Stage Partner',
        isHost: false,
        isReady: true,
      ),
    ];
    unawaited(saveActiveRoomSession(sanitizedCode));
    _setLoading(false);
  }

  Future<void> toggleReadyState() async {
    if (_session == null) return;
    final idx = _players.indexWhere((p) => p.userId == _localUserId);
    if (idx == -1) return;

    final nextReady = !_players[idx].isReady;
    _players[idx] = _players[idx].copyWith(isReady: nextReady);
    _notifySafely();

    final client = supabaseOrNull;
    if (client != null) {
      try {
        await client
            .from('lobby_players')
            .update({'is_ready': nextReady})
            .eq('lobby_id', _session!.id)
            .eq('user_id', _localUserId);
      } catch (_) {}
    }

    final channel = _realtimeChannel;
    if (channel != null) {
      try {
        await channel.track({
          'user_id': _localUserId,
          'display_name': localDisplayName,
          'is_host': isHost,
          'is_ready': nextReady,
        });
      } catch (_) {}
    }
  }

  Future<void> startPerformanceRound() async {
    if (_session == null) return;
    _setLoading(true);

    final category = _session!.selectedCategory;
    await OfflineManager.instance.ensureInitialized();
    final cachedList =
        OfflineManager.instance.getCachedScenesForCategory(category);
    final random = _safeRandom();
    ScenePrompt chosenScene = cachedList.isNotEmpty
        ? cachedList[random.nextInt(cachedList.length)]
        : kBuiltInSceneVault[SceneCategory.era1970To1999]!.first;

    final client = supabaseOrNull;
    if (client != null) {
      try {
        final rows = await client
            .from('scenes')
            .select()
            .eq('category', category.label)
            .eq('is_late_night', false);
        if (rows.isNotEmpty) {
          chosenScene = ScenePrompt.fromJson(
            Map<String, dynamic>.from(rows[random.nextInt(rows.length)] as Map),
          );
        }

        final updatePayload = <String, dynamic>{
          'status': 'performing',
          if (_isValidUuid(chosenScene.id)) 'active_scene_id': chosenScene.id,
        };
        await client
            .from('lobbies')
            .update(updatePayload)
            .eq('id', _session!.id);
      } catch (_) {}
    }

    if (_session == null || _isDisposed) return;

    _session = _session!.copyWith(
      status: 'performing',
      activeActorId: _localUserId,
      activeScene: chosenScene,
    );

    final channel = _realtimeChannel;
    if (channel != null) {
      try {
        await channel.sendBroadcastMessage(
          event: 'lobby_state_sync',
          payload: {
            'lobby_id': _session!.id,
            'room_code': _session!.roomCode,
            'selected_category': _session!.selectedCategory.key,
            'status': 'performing',
            'active_actor_id': _localUserId,
            'active_scene_payload': chosenScene.toJson(),
            'livekit_room_name': _session!.livekitRoomName,
          },
        );
      } catch (_) {}
    }

    _setLoading(false);
  }

  Future<void> _refreshPlayers(String lobbyId) async {
    final client = supabaseOrNull;
    if (client == null || _isDisposed) return;
    try {
      final data = await client
          .from('lobby_players')
          .select('*, profiles(username)')
          .eq('lobby_id', lobbyId)
          .order('joined_at', ascending: true);

      if (_isDisposed) return;
      final hostId = _session?.hostId;
      final fetchedPlayers = data.map((row) {
        final map = Map<String, dynamic>.from(row as Map);
        if (map['user_id']?.toString() == _localUserId &&
            localDisplayName.isNotEmpty) {
          map['display_name'] = localDisplayName;
        }
        return LobbyPlayer.fromJson(map, hostId: hostId);
      }).toList();

      if (fetchedPlayers.isNotEmpty) {
        _players = fetchedPlayers;
        _mergeRealtimePresence();
        _notifySafely();
      }
    } catch (_) {}
  }

  void _mergeRealtimePresence() {
    final channel = _realtimeChannel;
    if (channel == null || _session == null) return;
    try {
      final presenceStates = channel.presenceState();
      final Map<String, Map<String, dynamic>> presenceByUser = {};
      for (final state in presenceStates) {
        for (final presence in state.presences) {
          final payload = Map<String, dynamic>.from(presence.payload);
          final uid = payload['user_id']?.toString() ?? '';
          if (uid.isNotEmpty) {
            presenceByUser[uid] = payload;
          }
        }
      }
      if (presenceByUser.isEmpty) return;

      for (int i = 0; i < _players.length; i++) {
        final existing = _players[i];
        final p = presenceByUser[existing.userId];
        if (p != null) {
          _players[i] = LobbyPlayer(
            id: existing.id,
            lobbyId: existing.lobbyId,
            userId: existing.userId,
            displayName: p['display_name']?.toString() ?? existing.displayName,
            isHost: p['is_host'] == true || existing.isHost,
            isReady: p['is_ready'] is bool
                ? p['is_ready'] as bool
                : existing.isReady,
            aiTelemetricsScore: existing.aiTelemetricsScore,
            peerScore: existing.peerScore,
            socialScore: existing.socialScore,
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _handleLobbyPostgresChange(
    Map<String, dynamic> newRecord,
  ) async {
    if (newRecord.isEmpty || _session == null || _isDisposed) return;

    final current = _session!;
    ScenePrompt? resolvedScene = current.activeScene;
    final newSceneId = newRecord['active_scene_id']?.toString();

    if (newSceneId != null &&
        newSceneId.isNotEmpty &&
        newSceneId != current.activeScene?.id) {
      final client = supabaseOrNull;
      if (client != null) {
        try {
          final sceneRow = await client
              .from('scenes')
              .select()
              .eq('id', newSceneId)
              .maybeSingle();
          if (sceneRow != null) {
            resolvedScene = ScenePrompt.fromJson(
              Map<String, dynamic>.from(sceneRow as Map),
            );
          }
        } catch (_) {}
      }
    }

    if (_isDisposed || _session == null) return;
    _session = LobbySession.fromJson(
      newRecord,
      fallbackCategory: current.selectedCategory,
      fallbackScene: resolvedScene,
      fallbackActorId: current.activeActorId,
    );
    _notifySafely();
  }

  void _subscribeToLobbyRealtime(LobbySession lobby) {
    final client = supabaseOrNull;
    if (client == null) return;
    _realtimeChannel?.unsubscribe();

    final channel = client.channel(
      'lobby:${lobby.roomCode}',
      opts: const RealtimeChannelConfig(ack: true),
    );

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'lobbies',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: lobby.id,
          ),
          callback: (payload) {
            _handleLobbyPostgresChange(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'lobby_players',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'lobby_id',
            value: lobby.id,
          ),
          callback: (_) {
            _refreshPlayers(lobby.id);
          },
        )
        .onBroadcast(
          event: 'lobby_state_sync',
          callback: (payload) {
            if (_session == null || _isDisposed) return;
            _session = LobbySession.fromJson(
              payload,
              fallbackCategory: _session!.selectedCategory,
              fallbackScene: _session!.activeScene,
              fallbackActorId: _session!.activeActorId,
            );
            _notifySafely();
          },
        )
        .onPresenceSync((_) {
          if (_isDisposed) return;
          _mergeRealtimePresence();
          _notifySafely();
        })
        .subscribe((status, [error]) async {
          if (status == RealtimeSubscribeStatus.subscribed && !_isDisposed) {
            try {
              await channel.track({
                'user_id': _localUserId,
                'display_name': localDisplayName,
                'is_host': isHost,
                'is_ready': true,
              });
            } catch (_) {}
          }
        });

    _realtimeChannel = channel;
  }

  Future<void> leaveLobby() async {
    final client = supabaseOrNull;
    final activeLobbyId = _session?.id;
    if (client != null && activeLobbyId != null && _isValidUuid(activeLobbyId)) {
      try {
        await client
            .from('lobby_players')
            .delete()
            .eq('lobby_id', activeLobbyId)
            .eq('user_id', _localUserId);
      } catch (_) {}
    }

    try {
      await _realtimeChannel?.untrack();
    } catch (_) {}
    await _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
    _session = null;
    _players = [];
    unawaited(clearActiveRoomSession());
    _notifySafely();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _notifySafely();
  }

  @override
  void dispose() {
    _isDisposed = true;
    final ch = _realtimeChannel;
    final activeLobbyId = _session?.id;
    _realtimeChannel = null;
    _session = null;
    _players = [];

    if (ch != null) {
      unawaited(() async {
        try {
          await ch.untrack();
        } catch (_) {}
        try {
          await ch.unsubscribe();
          await supabaseOrNull?.removeChannel(ch);
        } catch (_) {}
      }());
    }

    final client = supabaseOrNull;
    if (client != null && activeLobbyId != null && _isValidUuid(activeLobbyId)) {
      unawaited(
        client
            .from('lobby_players')
            .delete()
            .eq('lobby_id', activeLobbyId)
            .eq('user_id', _localUserId)
            .then((_) {}, onError: (_) {}),
      );
    }
    super.dispose();
  }
}
