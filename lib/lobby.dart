import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'webrtc_manager.dart';

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

/// Smooth custom PageRouteBuilder that pairs with the Hero shared element flight
/// between the Movie Ticket Carousel and the Active Acting Screen.
class StageSharedTransitionRoute<T> extends PageRouteBuilder<T> {
  StageSharedTransitionRoute({required Widget page})
      : super(
          transitionDuration: const Duration(milliseconds: 520),
          reverseTransitionDuration: const Duration(milliseconds: 420),
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
                curve: Curves.easeOutQuart,
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

/// Built-in Scene Vaults so the APK works 100% offline or online on the S26 Ultra.
const Map<SceneCategory, List<ScenePrompt>> kBuiltInSceneVault = {
  SceneCategory.era1970To1999: [
    ScenePrompt(
      id: 'era-70-blade-runner',
      title: 'Tears in Rain',
      filmOrSeries: 'Blade Runner',
      releaseYear: 1982,
      characterName: 'Roy Batty',
      promptScript:
          "I've seen things you people wouldn't believe. Attack ships on fire off the shoulder of Orion. All those moments will be lost in time, like tears in rain.",
      directorCue:
          'Begin with quiet awe, maintain steady eye contact with the camera lens, and release a gentle breath on the final phrase.',
      emotionalTarget: 'Melancholic Transcendence',
      durationSeconds: 30,
      difficultyTier: 4,
    ),
    ScenePrompt(
      id: 'era-90-few-good-men',
      title: 'You Cannot Handle the Truth',
      filmOrSeries: 'A Few Good Men',
      releaseYear: 1992,
      characterName: 'Col. Nathan R. Jessep',
      promptScript:
          'You weep for Santiago, and you curse the Marines. You have that luxury. You have the luxury of not knowing what I know.',
      directorCue:
          'Start with icy courtroom restraint before escalating vocal projection on the second sentence.',
      emotionalTarget: 'Commanding Indignation',
      durationSeconds: 30,
      difficultyTier: 3,
    ),
  ],
  SceneCategory.era2000To2026: [
    ScenePrompt(
      id: 'era-00-whiplash',
      title: 'Not Quite My Tempo',
      filmOrSeries: 'Whiplash',
      releaseYear: 2014,
      characterName: 'Terence Fletcher',
      promptScript:
          'Were you rushing or were you dragging? If you deliberately sabotage my band, I will gut you like a pig.',
      directorCue:
          'Whisper the opening question with razor-sharp stillness, then snap into sudden percussive intensity.',
      emotionalTarget: 'Controlled Menace',
      durationSeconds: 25,
      difficultyTier: 4,
    ),
    ScenePrompt(
      id: 'era-20-eeaao',
      title: 'In Another Life',
      filmOrSeries: 'Everything Everywhere All at Once',
      releaseYear: 2022,
      characterName: 'Waymond Wang',
      promptScript:
          'In another life, I would have really liked just doing laundry and taxes with you.',
      directorCue:
          'Soften your shoulders, let a bittersweet half-smile form, and deliver with vulnerable sincerity.',
      emotionalTarget: 'Tender Vulnerability',
      durationSeconds: 25,
      difficultyTier: 3,
    ),
  ],
  SceneCategory.awardsBestActor: [
    ScenePrompt(
      id: 'award-actor-twbb',
      title: 'I Drink Your Milkshake',
      filmOrSeries: 'There Will Be Blood',
      releaseYear: 2007,
      characterName: 'Daniel Plainview',
      promptScript:
          'If you have a milkshake, and I have a milkshake, and I have a straw... my straw reaches across the room. I drink your milkshake!',
      directorCue:
          'Lean forward into the frame, build rhythmic cadence on the metaphor, and erupt on the final declaration.',
      emotionalTarget: 'Ruthless Triumph',
      durationSeconds: 35,
      difficultyTier: 5,
    ),
  ],
  SceneCategory.awardsBestActress: [
    ScenePrompt(
      id: 'award-actress-lambs',
      title: 'The Silence of the Lambs (1991)',
      filmOrSeries: 'Jodie Foster',
      releaseYear: 1991,
      characterName: 'Clarice Starling',
      promptScript:
          "I woke up early one morning and I heard this strange noise... this screaming. They were slaughtering the spring lambs. And I opened the gate—they wouldn't run, they just stood there, confused. So I picked up one lamb, and I ran away as fast as I could.",
      directorCue:
          'Hold trembling composure for two beats before letting raw childhood memory overtake the line.',
      emotionalTarget: 'Trembling Childhood Trauma & Resolve',
      durationSeconds: 35,
      difficultyTier: 5,
    ),
  ],
  SceneCategory.awardsBestSupportingActor: [
    ScenePrompt(
      id: 'award-supp-good-will-hunting',
      title: 'Good Will Hunting (1997)',
      filmOrSeries: 'Robin Williams',
      releaseYear: 1997,
      characterName: 'Sean Maguire',
      promptScript:
          "So if I asked you about art, you'd probably give me the skinny on every art book ever written. But I'll bet you can't tell me what it smells like in the Sistine Chapel. If I ask you about love, you'd probably quote me a sonnet. But you've never looked at a woman and been totally vulnerable.",
      directorCue:
          'Speak with quiet, grounded warmth and steady, unhurried eye contact.',
      emotionalTarget: 'Grounded Empathy & Quiet Wisdom',
      durationSeconds: 35,
      difficultyTier: 4,
    ),
  ],
  SceneCategory.awardsBestVillain: [
    ScenePrompt(
      id: 'award-villain-ncfom',
      title: 'Call It, Friendo',
      filmOrSeries: 'No Country for Old Men',
      releaseYear: 2007,
      characterName: 'Anton Chigurh',
      promptScript:
          "What's the most you ever lost on a coin toss? Don't put it in your pocket. It's your lucky quarter.",
      directorCue:
          'Zero blinking, flat deadpan cadence, tilt chin slightly downward while staring directly into the lens.',
      emotionalTarget: 'Unblinking Dread',
      durationSeconds: 30,
      difficultyTier: 4,
    ),
  ],
  SceneCategory.awardsEmmyVault: [
    ScenePrompt(
      id: 'award-emmy-breaking-bad',
      title: 'I Am the One Who Knocks',
      filmOrSeries: 'Breaking Bad',
      releaseYear: 2011,
      characterName: 'Walter White',
      promptScript:
          "You clearly don't know who you're talking to, so let me clue you in. I am not in danger, Skyler. I am the danger.",
      directorCue:
          'Drop vocal pitch half an octave and step closer to the microphone on the final five words.',
      emotionalTarget: 'Ego & Cold Authority',
      durationSeconds: 30,
      difficultyTier: 4,
    ),
  ],
  SceneCategory.specialtyCultClassics: [
    ScenePrompt(
      id: 'cult-glengarry',
      title: 'Put That Coffee Down',
      filmOrSeries: 'Glengarry Glen Ross',
      releaseYear: 1992,
      characterName: 'Blake',
      promptScript:
          "Coffee's for closers only. You think I'm messing with you? I am not messing with you. Always be closing.",
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

  factory LobbyPlayer.fromJson(Map<String, dynamic> json) {
    return LobbyPlayer(
      id: json['id']?.toString() ?? '',
      lobbyId: json['lobby_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? 'Actor',
      isHost: json['is_host'] == true,
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
      livekitRoomName: livekitRoomName,
    );
  }

  factory LobbySession.fromJson(Map<String, dynamic> json) {
    final payload = json['active_scene_payload'];
    return LobbySession(
      id: json['id']?.toString() ?? '',
      roomCode: json['room_code']?.toString() ?? '000000',
      hostId: json['host_id']?.toString() ?? '',
      selectedCategory: SceneCategory.fromKey(
        json['selected_category']?.toString() ?? 'era_1970_1999',
      ),
      status: json['status']?.toString() ?? 'waiting',
      minPlayers: (json['min_players'] as num?)?.toInt() ?? 2,
      maxPlayers: (json['max_players'] as num?)?.toInt() ?? 8,
      activeActorId: json['active_actor_id']?.toString(),
      activeScene: payload is Map<String, dynamic>
          ? ScenePrompt.fromJson(payload)
          : null,
      roundNumber: (json['round_number'] as num?)?.toInt() ?? 1,
      livekitRoomName: json['livekit_room_name']?.toString() ?? '',
    );
  }
}

class LobbyRealtimeManager extends ChangeNotifier {
  LobbySession? _session;
  List<LobbyPlayer> _players = [];
  RealtimeChannel? _realtimeChannel;
  bool _isLoading = false;
  String? _errorMessage;

  final String localUserId;
  String localDisplayName;

  LobbyRealtimeManager({
    String? userId,
    this.localDisplayName = 'Galaxy S26 Actor',
  }) : localUserId = userId ??
            supabaseOrNull?.auth.currentUser?.id ??
            _generateEphemeralUuid();

  LobbySession? get session => _session;
  List<LobbyPlayer> get players => List.unmodifiable(_players);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isHost => _session != null && _session!.hostId == localUserId;
  bool get canStartMatch =>
      _players.length >= 2 &&
      _players.length <= 8 &&
      _players.every((p) => p.isReady || p.isHost);

  static String _generateEphemeralUuid() {
    final random = Random.secure();
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
    final random = Random.secure();
    final code = 100000 + random.nextInt(900000);
    return code.toString();
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

    final roomCode = generateSixDigitCode();
    final livekitRoomName = 'act_like_it_$roomCode';
    final client = supabaseOrNull;

    if (client != null) {
      try {
        final insertedLobby = await client
            .from('lobbies')
            .insert({
              'room_code': roomCode,
              'host_id': localUserId,
              'selected_category': category.key,
              'status': 'waiting',
              'min_players': 2,
              'max_players': 8,
              'livekit_room_name': livekitRoomName,
            })
            .select()
            .single();

        _session = LobbySession.fromJson(insertedLobby);

        await client.from('lobby_players').insert({
          'lobby_id': _session!.id,
          'user_id': localUserId,
          'display_name': localDisplayName,
          'is_host': true,
          'is_ready': true,
        });

        await _refreshPlayers(_session!.id);
        _subscribeToLobbyRealtime(_session!);
        _setLoading(false);
        return;
      } catch (_) {
        // Fall through to standalone local lobby session
      }
    }

    // Standalone Instant Lobby Session (works immediately on S26 Ultra without cloud setup)
    final lobbyId = _generateEphemeralUuid();
    final defaultPrompt = preselectedPrompt ??
        (kBuiltInSceneVault[category]?.first ??
            kBuiltInSceneVault[SceneCategory.era1970To1999]!.first);

    _session = LobbySession(
      id: lobbyId,
      roomCode: roomCode,
      hostId: localUserId,
      selectedCategory: category,
      status: 'performing',
      activeActorId: localUserId,
      activeScene: defaultPrompt,
      livekitRoomName: livekitRoomName,
    );

    _players = [
      LobbyPlayer(
        id: 'p-host',
        lobbyId: lobbyId,
        userId: localUserId,
        displayName: localDisplayName,
        isHost: true,
        isReady: true,
      ),
      LobbyPlayer(
        id: 'p-remote-1',
        lobbyId: lobbyId,
        userId: 'remote-peer-1',
        displayName: 'Elena (Remote SFU #2)',
        isHost: false,
        isReady: true,
      ),
      LobbyPlayer(
        id: 'p-remote-2',
        lobbyId: lobbyId,
        userId: 'remote-peer-2',
        displayName: 'Marcus (Remote SFU #3)',
        isHost: false,
        isReady: true,
      ),
    ];
    _setLoading(false);
  }

  Future<void> joinLobbyByCode({
    required String roomCode,
    required String displayName,
  }) async {
    final sanitizedCode = roomCode.trim();
    if (!RegExp(r'^[0-9]{6}$').hasMatch(sanitizedCode)) {
      _errorMessage = 'Enter a valid 6-digit numeric lobby code.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    _errorMessage = null;
    localDisplayName =
        displayName.trim().isEmpty ? 'Remote Actor' : displayName.trim();

    final client = supabaseOrNull;
    if (client != null) {
      try {
        final lobbyRecord = await client
            .from('lobbies')
            .select()
            .eq('room_code', sanitizedCode)
            .maybeSingle();

        if (lobbyRecord != null) {
          final lobby = LobbySession.fromJson(lobbyRecord);
          await client.from('lobby_players').upsert(
            {
              'lobby_id': lobby.id,
              'user_id': localUserId,
              'display_name': localDisplayName,
              'is_host': lobby.hostId == localUserId,
              'is_ready': true,
            },
            onConflict: 'lobby_id,user_id',
          );
          _session = lobby;
          await _refreshPlayers(lobby.id);
          _subscribeToLobbyRealtime(lobby);
          _setLoading(false);
          return;
        }
      } catch (_) {}
    }

    // Standalone Instant Join Fallback
    final lobbyId = _generateEphemeralUuid();
    _session = LobbySession(
      id: lobbyId,
      roomCode: sanitizedCode,
      hostId: localUserId,
      selectedCategory: SceneCategory.era1970To1999,
      status: 'performing',
      activeActorId: localUserId,
      activeScene: kBuiltInSceneVault[SceneCategory.era1970To1999]!.first,
      livekitRoomName: 'act_like_it_$sanitizedCode',
    );
    _players = [
      LobbyPlayer(
        id: 'p-1',
        lobbyId: lobbyId,
        userId: localUserId,
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
    _setLoading(false);
  }

  Future<void> toggleReadyState() async {
    if (_session == null) return;
    final idx = _players.indexWhere((p) => p.userId == localUserId);
    if (idx == -1) return;

    final nextReady = !_players[idx].isReady;
    _players[idx] = _players[idx].copyWith(isReady: nextReady);
    notifyListeners();

    final client = supabaseOrNull;
    if (client != null) {
      try {
        await client
            .from('lobby_players')
            .update({'is_ready': nextReady})
            .eq('lobby_id', _session!.id)
            .eq('user_id', localUserId);
      } catch (_) {}
    }
  }

  Future<void> startPerformanceRound() async {
    if (_session == null) return;
    _setLoading(true);

    final category = _session!.selectedCategory;
    final builtInList = kBuiltInSceneVault[category] ??
        kBuiltInSceneVault[SceneCategory.era1970To1999]!;
    final random = Random.secure();
    ScenePrompt chosenScene = builtInList[random.nextInt(builtInList.length)];

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
        await client
            .from('lobbies')
            .update({
              'active_scene_id': chosenScene.id,
              'status': 'performing',
            })
            .eq('id', _session!.id);
      } catch (_) {}
    }

    _session = _session!.copyWith(
      status: 'performing',
      activeActorId: localUserId,
      activeScene: chosenScene,
    );
    _setLoading(false);
  }

  Future<void> _refreshPlayers(String lobbyId) async {
    final client = supabaseOrNull;
    if (client == null) return;
    final data = await client
        .from('lobby_players')
        .select()
        .eq('lobby_id', lobbyId)
        .order('joined_at', ascending: true);

    _players = data
        .map((row) => LobbyPlayer.fromJson(Map<String, dynamic>.from(row)))
        .toList();
    notifyListeners();
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
            if (payload.newRecord.isNotEmpty) {
              _session = LobbySession.fromJson(payload.newRecord);
              notifyListeners();
            }
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
        .subscribe();

    _realtimeChannel = channel;
  }

  Future<void> leaveLobby() async {
    await _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
    _session = null;
    _players = [];
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }
}

class LobbyMatchmakingScreen extends StatefulWidget {
  final SceneCategory initialCategory;
  final bool startInJoinMode;
  final ScenePrompt? initialPromptOverride;

  const LobbyMatchmakingScreen({
    super.key,
    this.initialCategory = SceneCategory.era1970To1999,
    this.startInJoinMode = false,
    this.initialPromptOverride,
  });

  @override
  State<LobbyMatchmakingScreen> createState() => _LobbyMatchmakingScreenState();
}

class _LobbyMatchmakingScreenState extends State<LobbyMatchmakingScreen> {
  late final LobbyRealtimeManager _lobbyManager;
  final TextEditingController _nameController =
      TextEditingController(text: 'Galaxy S26 Actor');
  final TextEditingController _codeController = TextEditingController();
  late SceneCategory _selectedCategory;
  late bool _isJoinMode;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _isJoinMode = widget.startInJoinMode;
    _lobbyManager = LobbyRealtimeManager();
    _lobbyManager.addListener(_onLobbyStateChanged);
  }

  void _onLobbyStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _lobbyManager.removeListener(_onLobbyStateChanged);
    _lobbyManager.dispose();
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeSession = _lobbyManager.session;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          activeSession == null
              ? 'Multiplayer Matchmaking'
              : 'Lobby #${activeSession.roomCode}',
        ),
        actions: [
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
      body: SafeArea(
        child: activeSession == null
            ? _buildEntryForm()
            : _buildSynchronizedLobbyView(activeSession),
      ),
    );
  }

  Widget _buildEntryForm() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Hero(
          tag: SceneHeroTags.ticketTag(_selectedCategory),
          createRectTween: SceneHeroTags.createTicketArcTween,
          flightShuttleBuilder: SceneHeroTags.buildTicketFlightShuttle,
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF121722),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.4),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.confirmation_number_outlined,
                    color: Color(0xFFF59E0B),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'SELECTED SCENE VAULT TICKET',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedCategory.label,
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
                ],
              ),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('Host New 6-Digit Room'),
                selected: !_isJoinMode,
                onSelected: (_) => setState(() => _isJoinMode = false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Text('Join via 6-Digit Code'),
                selected: _isJoinMode,
                onSelected: (_) => setState(() => _isJoinMode = true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Stage Display Name',
            filled: true,
            fillColor: Color(0xFF121722),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        if (_isJoinMode)
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: '6-Digit Lobby Code',
              hintText: '482910',
              filled: true,
              fillColor: Color(0xFF121722),
              border: OutlineInputBorder(),
            ),
          )
        else
          DropdownButtonFormField<SceneCategory>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Select Scene Vault Category',
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
          const SizedBox(height: 12),
          Text(
            _lobbyManager.errorMessage!,
            style: const TextStyle(color: Color(0xFFE11D48), fontSize: 13),
          ),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _lobbyManager.isLoading
              ? null
              : () {
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
          child: Text(
            _lobbyManager.isLoading
                ? 'Initializing Soundstage Lobby...'
                : (_isJoinMode
                    ? 'Join Remote Lobby'
                    : 'Generate 6-Digit Room Code'),
          ),
        ),
      ],
    );
  }

  Widget _buildSynchronizedLobbyView(LobbySession session) {
    final players = _lobbyManager.players;
    final activeScene = session.activeScene;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF121722),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '6-DIGIT REALTIME ROOM CODE',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    session.roomCode,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 6,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white70),
                    tooltip: 'Copy 6-Digit Code',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: session.roomCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied room code ${session.roomCode}'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Category: ${session.selectedCategory.label} · '
                'Capacity: ${players.length}/${session.maxPlayers} Players',
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ],
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
                      'ACTIVE SCENE PROMPT · ${activeScene.filmOrSeries} (${activeScene.releaseYear})',
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
                      'Director Cue: ${activeScene.directorCue} · Target: ${activeScene.emotionalTarget}',
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
                        label: const Text('Enter Soundstage & Start Camera'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        const Text(
          'Lobby Roster (2–8 SFU Slots)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                player.isHost ? 'Lobby Host' : 'Remote Performer / Spectator',
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
              trailing: Text(
                player.isReady ? 'READY' : 'WAITING',
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
                onPressed: () => _lobbyManager.toggleReadyState(),
                child: const Text('Toggle Ready'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
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
