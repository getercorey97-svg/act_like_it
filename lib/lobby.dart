import 'dart:async';
import 'dart:math';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter, MaskFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'webrtc_manager.dart';
import 'offline_manager.dart';
import 'late_night_vault.dart';
import 'match_history_screen.dart';
import 'ui/game_app_bar.dart';
import 'ui/tutorial_overlay.dart';
import 'ui/interactive_instructions.dart';
import 'ui/game_settings_modal.dart';
import 'ui/scene_vault_screen.dart';

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
    this.localDisplayName = 'Galaxy S26 Actor',
  }) : _localUserId = userId ??
            supabaseOrNull?.auth.currentUser?.id ??
            _generateEphemeralUuid();

  String get localUserId => _localUserId;
  LobbySession? get session => _session;
  List<LobbyPlayer> get players => List.unmodifiable(_players);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isHost => _session != null && _session!.hostId == _localUserId;
  bool get canStartMatch =>
      _players.length >= 2 &&
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

  void _notifySafely() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Ensures an authenticated Supabase user session and a corresponding row in
  /// `public.profiles` exist before inserting into `lobbies` or `lobby_players`
  /// (which enforce `auth.uid()` RLS policies and `references public.profiles(id)`).
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
          // Retry up to 3 times to prevent 6-digit room_code uniqueness collisions
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
            _setLoading(false);
            return;
          }
        }
      } catch (_) {
        // Fall through to standalone local lobby session
      }
    }

    // Standalone Instant Lobby Session (works immediately on S26 Ultra without cloud setup)
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

    // Also update Realtime Presence state so remote peers see ready toggle immediately
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

    // Broadcast full round & scene state to all connected peers in the lobby channel
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

  /// Merges Supabase Realtime Presence metadata (`display_name`, `is_ready`, `is_host`)
  /// into `_players` so live presence updates and custom stage names stay in sync.
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

  final TextEditingController _nameController =
      TextEditingController(text: 'Galaxy S26 Actor');
  final TextEditingController _codeController = TextEditingController();
  late SceneCategory _selectedCategory;
  late bool _isJoinMode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedCategory = widget.initialCategory;
    _isJoinMode = widget.startInJoinMode;
    _lobbyManager = LobbyRealtimeManager();
    _lobbyManager.addListener(_onLobbyStateChanged);

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
  }

  void _onParallaxScroll() {
    if (!mounted || !_parallaxScrollController.hasClients) return;
    final nextOffset = _parallaxScrollController.offset;
    final delta = (nextOffset - _scrollOffset).abs();

    // Subtle haptic tick as the player walks past each 3D gold brass stanchion post
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
    super.dispose();
  }

  Future<void> _openCallSheetAndExecute(
    VoidCallback onConfirmed, {
    String? modeTitle,
  }) async {
    HapticFeedback.mediumImpact();
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
                // Layer 1: 3D Perspective Red Carpet, Brass Stanchions & 42 Golden Bokeh Particles
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

                // Layer 2: Dynamic Paparazzi Crowd Silhouettes & 4-Point Star-Burst Lens Flashes
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

                // Layer 3: SafeArea Foreground Content
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
                const TutorialOverlay(
                  tutorialKey: 'lobby_room_code_v1',
                  badgeLabel: 'DIRECTOR\'S PREMIERE CUE',
                  title: 'Walk the Carpet or Step Into a Studio Door',
                  message:
                      'Tap the marquee for a paparazzi flash frenzy, tilt any studio door in 3D, or dial in your 6-digit soundstage credentials below.',
                  neonAccent: Color(0xFFF59E0B),
                  icon: Icons.camera_enhance_rounded,
                ),
                Interactive3DHolographicMarquee(
                  phase: phase,
                  onPaparazziFrenzy: _triggerPaparazziFrenzy,
                ),
                const SizedBox(height: 18),
                _buildStageCredentialsCard(),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              BespokePremiereDoorsList.buildSixDoors(
                context: context,
                scrollController: _parallaxScrollController,
                phase: phase,
                careerWins: OfflineManager.instance.totalCareerWins,
                averageScore: OfflineManager.instance.averageFinalScore,
                onPremiereDoorTap: () => _openCallSheetAndExecute(
                  () {
                    setState(() => _isJoinMode = false);
                    _lobbyManager.createLobby(
                      displayName: _nameController.text,
                      category: _selectedCategory,
                      preselectedPrompt: widget.initialPromptOverride,
                    );
                  },
                  modeTitle: 'PREMIERE SOUNDSTAGE',
                ),
                onAirlockJoinTap: () => _openCallSheetAndExecute(
                  () {
                    setState(() => _isJoinMode = true);
                    if (_codeController.text.trim().length == 6) {
                      _lobbyManager.joinLobbyByCode(
                        roomCode: _codeController.text,
                        displayName: _nameController.text,
                      );
                    }
                  },
                  modeTitle: 'SOUNDSTAGE AIRLOCK',
                ),
                onAfterHoursTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LateNightAfterHoursScreen(),
                    ),
                  );
                },
                onTrophyVaultTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MatchHistoryScreen(),
                    ),
                  );
                },
                onCameraViewfinderTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const InteractiveInstructionsScreen(),
                    ),
                  );
                },
                onBoxOfficeVaultTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SceneVaultScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStageCredentialsCard() {
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
                      label: const Text('Host New 6-Digit Room'),
                      selected: !_isJoinMode,
                      onSelected: (_) => setState(() => _isJoinMode = false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Join via 6-Digit Code'),
                      selected: _isJoinMode,
                      onSelected: (_) => setState(() => _isJoinMode = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Stage Display Name',
                  filled: true,
                  fillColor: Color(0xFF121722),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
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
                  style: const TextStyle(color: Color(0xFFE11D48), fontSize: 13),
                ),
              ],
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _lobbyManager.isLoading
                    ? null
                    : () => _openCallSheetAndExecute(
                          () {
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
                          modeTitle: _isJoinMode
                              ? 'SOUNDSTAGE AIRLOCK'
                              : 'PREMIERE SOUNDSTAGE',
                        ),
                icon: const Icon(Icons.videocam_rounded, size: 18),
                label: Text(
                  _lobbyManager.isLoading
                      ? 'Opening Soundstage Doors...'
                      : (_isJoinMode
                          ? 'Open Call Sheet & Step Onto Stage'
                          : 'Open Call Sheet & Generate 6-Digit Pass'),
                ),
              ),
            ],
          ),
        ),
      ),
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
                '6-DIGIT SOUNDSTAGE ACCESS CODE',
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
                'Reel: ${session.selectedCategory.label} · '
                'Cast: ${players.length}/${session.maxPlayers} Ensemble Actors',
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
        const Text(
          'Green Room Cast Roster (2–8 Ensemble Chairs)',
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

// ============================================================================
// INTERACTIVE 3D HOLOGRAPHIC MARQUEE ("ACT LIKE IT")
// ============================================================================

class Interactive3DHolographicMarquee extends StatefulWidget {
  final double phase;
  final VoidCallback onPaparazziFrenzy;
  final Widget? trailingControls;

  const Interactive3DHolographicMarquee({
    super.key,
    required this.phase,
    required this.onPaparazziFrenzy,
    this.trailingControls,
  });

  @override
  State<Interactive3DHolographicMarquee> createState() =>
      _Interactive3DHolographicMarqueeState();
}

class _Interactive3DHolographicMarqueeState
    extends State<Interactive3DHolographicMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleMarqueeTap() {
    widget.onPaparazziFrenzy();
    _bounceController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final sweep = (math.sin(widget.phase) + 1.0) * 0.5;

    return GestureDetector(
      onTap: _handleMarqueeTap,
      child: AnimatedBuilder(
        animation: _bounceController,
        builder: (context, _) {
          final t = _bounceController.value;
          final elasticScale = t == 0.0
              ? 1.0
              : 1.0 + math.sin(t * math.pi * 2.5) * 0.09 * (1.0 - t);
          final tiltX = t == 0.0 ? 0.0 : math.sin(t * math.pi * 2) * 0.16 * (1.0 - t);

          final matrix = Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateX(tiltX)
            ..scale(elasticScale, elasticScale, 1.0);

          return Transform(
            alignment: Alignment.center,
            transform: matrix,
            child: SizedBox(
              height: 132,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // a) Volumetric Dual Searchlights sweeping behind the marquee
                  RepaintBoundary(
                    child: CustomPaint(
                      painter: _VolumetricSearchlightsPainter(
                        phase: widget.phase,
                      ),
                    ),
                  ),

                  // b) Chaser border of warm-white filament bulbs + 3D glass housing
                  RepaintBoundary(
                    child: CustomPaint(
                      foregroundPainter: _MarqueeFilamentBulbsPainter(
                        phase: widget.phase,
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xE6170A12),
                              Color(0xF2080A12),
                              Color(0xE6191008),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFF59E0B),
                            width: 2.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE11D48).withValues(alpha: 0.42),
                              blurRadius: 32,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.28),
                              blurRadius: 20,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                        begin: Alignment(-1.2 + sweep * 2.4, -0.4),
                                        end: Alignment(-0.2 + sweep * 2.4, 0.6),
                                        colors: const [
                                          Color(0xFFFDE68A),
                                          Colors.white,
                                          Color(0xFFF59E0B),
                                          Color(0xFFE2E8F0),
                                          Color(0xFFFBBF24),
                                        ],
                                        stops: const [0.0, 0.28, 0.52, 0.76, 1.0],
                                      ).createShader(bounds);
                                    },
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'ACT LIKE IT',
                                        style: GoogleFonts.limelight(
                                          fontSize: 42,
                                          color: Colors.white,
                                          letterSpacing: 3.0,
                                          height: 1.05,
                                          shadows: const [
                                            Shadow(
                                              color: Color(0xFFE11D48),
                                              blurRadius: 24,
                                              offset: Offset(0, 4),
                                            ),
                                            Shadow(
                                              color: Color(0xCC000000),
                                              blurRadius: 10,
                                              offset: Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Grand Premiere Soundstage · Tap Marquee for Flash Frenzy',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.4,
                                      color: const Color(0xFFFDE68A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.trailingControls != null) ...[
                              const SizedBox(width: 8),
                              widget.trailingControls!,
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VolumetricSearchlightsPainter extends CustomPainter {
  final double phase;

  const _VolumetricSearchlightsPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final leftAngle = math.sin(phase * 0.85) * 0.42 + 0.35;
    final rightAngle = math.cos(phase * 0.95) * 0.42 - 0.35;

    _drawSearchlightCone(
      canvas,
      size,
      origin: Offset(size.width * 0.16, size.height),
      angle: leftAngle,
      color: const Color(0x55FDE68A),
    );
    _drawSearchlightCone(
      canvas,
      size,
      origin: Offset(size.width * 0.84, size.height),
      angle: rightAngle,
      color: const Color(0x4438BDF8),
    );
  }

  void _drawSearchlightCone(
    Canvas canvas,
    Size size, {
    required Offset origin,
    required double angle,
    required Color color,
  }) {
    final length = size.height * 1.65;
    final topCenter = Offset(
      origin.dx + math.sin(angle) * length,
      origin.dy - math.cos(angle) * length,
    );
    const spread = 44.0;
    final path = Path()
      ..moveTo(origin.dx - 6, origin.dy)
      ..lineTo(topCenter.dx - spread, topCenter.dy)
      ..lineTo(topCenter.dx + spread, topCenter.dy)
      ..lineTo(origin.dx + 6, origin.dy)
      ..close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          color,
          color.withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _VolumetricSearchlightsPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _MarqueeFilamentBulbsPainter extends CustomPainter {
  final double phase;

  const _MarqueeFilamentBulbsPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 16 || size.height <= 24) return;
    final rect = Rect.fromLTWH(6, 10, size.width - 12, size.height - 20);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(22));
    final metrics = (Path()..addRRect(rrect)).computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    const int bulbCount = 30;
    final chaserStep = ((phase / (2 * math.pi)) * bulbCount);

    for (int i = 0; i < bulbCount; i++) {
      final distance = (metric.length / bulbCount) * i;
      final tangent = metric.getTangentForOffset(distance);
      if (tangent == null) continue;

      final pos = tangent.position;
      final wave = (math.sin((i - chaserStep) * 0.65) + 1.0) * 0.5;
      final isHot = wave > 0.55;

      final glowPaint = Paint()
        ..color = (isHot ? const Color(0xFFFDE68A) : const Color(0xFFF59E0B))
            .withValues(alpha: 0.25 + 0.65 * wave)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(pos, isHot ? 4.8 : 3.2, glowPaint);

      final corePaint = Paint()
        ..color = isHot ? Colors.white : const Color(0xFFFBBF24);
      canvas.drawCircle(pos, isHot ? 2.3 : 1.6, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MarqueeFilamentBulbsPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

// ============================================================================
// 4. 3D TOUCH-TILT PHYSICS & MECHANICAL DOOR WRAPPER (`Interactive3DDoorCard`)
// ============================================================================

class Interactive3DDoorCard extends StatefulWidget {
  final ScrollController scrollController;
  final int index;
  final Color specularColor;
  final BorderRadius borderRadius;
  final CustomClipper<Path>? customClipper;
  final VoidCallback onTap;
  final Widget Function(BuildContext context, bool isPressed, double pressValue)
      builder;

  const Interactive3DDoorCard({
    super.key,
    required this.scrollController,
    required this.index,
    required this.specularColor,
    required this.onTap,
    required this.builder,
    this.borderRadius = const BorderRadius.all(Radius.circular(26)),
    this.customClipper,
  });

  @override
  State<Interactive3DDoorCard> createState() => _Interactive3DDoorCardState();
}

class _Interactive3DDoorCardState extends State<Interactive3DDoorCard>
    with SingleTickerProviderStateMixin {
  // Normalized touch coordinates in [-1.0, 1.0] for 12-degree (0.21 rad) 3D tilt
  Offset _normalizedTouch = Offset.zero;
  Alignment _specularAlignment = Alignment.topLeft;
  bool _isTouching = false;

  late final AnimationController _activationController;

  @override
  void initState() {
    super.initState();
    _activationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _activationController.dispose();
    super.dispose();
  }

  void _updateTouchTilt(Offset localPosition, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final nx = ((localPosition.dx / size.width) * 2.0 - 1.0).clamp(-1.0, 1.0);
    final ny = ((localPosition.dy / size.height) * 2.0 - 1.0).clamp(-1.0, 1.0);
    setState(() {
      _isTouching = true;
      _normalizedTouch = Offset(nx, ny);
      _specularAlignment = Alignment(nx, ny);
    });
  }

  void _resetTouchTilt() {
    if (!mounted) return;
    setState(() {
      _isTouching = false;
      _normalizedTouch = Offset.zero;
    });
  }

  Future<void> _handleDoorActivate() async {
    HapticFeedback.mediumImpact();
    setState(() => _isTouching = true);
    await _activationController.forward();
    await _activationController.reverse();
    if (!mounted) return;
    _resetTouchTilt();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.scrollController,
        _activationController,
      ]),
      builder: (context, _) {
        // Scroll-driven cylindrical reel 3D perspective
        double scrollCurveRotateX = 0.0;
        double scrollScale = 1.0;

        if (widget.scrollController.hasClients) {
          final scrollOffset = widget.scrollController.offset;
          final expectedItemTop = 210.0 + (widget.index * 195.0);
          final viewportCenter = scrollOffset + 340.0;
          final deltaFromCenter =
              ((expectedItemTop - viewportCenter) / 480.0).clamp(-1.0, 1.0);
          scrollCurveRotateX = deltaFromCenter * -0.09;
          scrollScale = 1.0 - (deltaFromCenter.abs() * 0.035);
        }

        // Responsive 12-degree (0.21 radians) 3D touch-tilt physics
        const double maxTiltRadians = 0.21;
        final double touchRotateX = -_normalizedTouch.dy * maxTiltRadians;
        final double touchRotateY = _normalizedTouch.dx * maxTiltRadians;
        final double pressScale =
            1.0 - (_activationController.value * 0.04) + (_isTouching ? 0.015 : 0.0);

        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..rotateX(scrollCurveRotateX + touchRotateX)
          ..rotateY(touchRotateY)
          ..scale(scrollScale * pressScale, scrollScale * pressScale, 1.0);

        return LayoutBuilder(
          builder: (context, constraints) {
            final safeWidth =
                constraints.maxWidth.isFinite ? constraints.maxWidth : 360.0;
            final cardSize = Size(safeWidth, 178);
            Widget cardBody = Stack(
              children: [
                widget.builder(
                  context,
                  _isTouching || _activationController.isAnimating,
                  _activationController.value,
                ),
                // Live Finger-Tracking Specular Spotlight Glare
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: _isTouching ? 1.0 : 0.32,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: widget.borderRadius,
                          gradient: RadialGradient(
                            center: _specularAlignment,
                            radius: 0.95,
                            colors: [
                              Colors.white.withValues(
                                alpha: _isTouching ? 0.24 : 0.08,
                              ),
                              widget.specularColor.withValues(
                                alpha: _isTouching ? 0.18 : 0.04,
                              ),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.42, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );

            if (widget.customClipper != null) {
              cardBody = ClipPath(
                clipper: widget.customClipper,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: cardBody,
                ),
              );
            } else {
              cardBody = ClipRRect(
                borderRadius: widget.borderRadius,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: cardBody,
                ),
              );
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanDown: (d) => _updateTouchTilt(d.localPosition, cardSize),
              onPanUpdate: (d) => _updateTouchTilt(d.localPosition, cardSize),
              onPanEnd: (_) => _resetTouchTilt(),
              onPanCancel: _resetTouchTilt,
              onTap: _handleDoorActivate,
              child: Transform(
                alignment: Alignment.center,
                transform: matrix,
                child: cardBody,
              ),
            );
          },
        );
      },
    );
  }
}

// ============================================================================
// 5. SIX BESPOKE ARCHITECTURAL DOORS (NO GENERIC BOXES)
// ============================================================================

class BespokePremiereDoorsList {
  static List<Widget> buildSixDoors({
    required BuildContext context,
    required ScrollController scrollController,
    required double phase,
    required int careerWins,
    required double averageScore,
    required VoidCallback onPremiereDoorTap,
    required VoidCallback onAirlockJoinTap,
    required VoidCallback onAfterHoursTap,
    required VoidCallback onTrophyVaultTap,
    required VoidCallback onCameraViewfinderTap,
    required VoidCallback onBoxOfficeVaultTap,
  }) {
    return [
      // 1. THE PREMIERE DOOR (Create Lobby / Quick Play)
      Interactive3DDoorCard(
        scrollController: scrollController,
        index: 0,
        specularColor: const Color(0xFFF59E0B),
        onTap: onPremiereDoorTap,
        builder: (context, isPressed, pressValue) => _buildPremiereClapperDoor(
          phase: phase,
          isPressed: isPressed,
          pressValue: pressValue,
        ),
      ),
      const SizedBox(height: 22),

      // 2. SOUNDSTAGE AIRLOCK DOOR (Join 6-Digit Room)
      Interactive3DDoorCard(
        scrollController: scrollController,
        index: 1,
        specularColor: const Color(0xFF06B6D4),
        onTap: onAirlockJoinTap,
        builder: (context, isPressed, pressValue) => _buildSoundstageAirlockDoor(
          phase: phase,
          isPressed: isPressed,
        ),
      ),
      const SizedBox(height: 22),

      // 3. VIP VELVET SPEAKEASY ENTRANCE (18+ After-Hours)
      Interactive3DDoorCard(
        scrollController: scrollController,
        index: 2,
        specularColor: const Color(0xFFEC4899),
        onTap: onAfterHoursTap,
        builder: (context, isPressed, pressValue) => _buildVelvetSpeakeasyDoor(
          phase: phase,
          isPressed: isPressed,
        ),
      ),
      const SizedBox(height: 22),

      // 4. ACADEMY TROPHY VAULT DOOR (Career Trophy Room)
      Interactive3DDoorCard(
        scrollController: scrollController,
        index: 3,
        specularColor: const Color(0xFFFBBF24),
        onTap: onTrophyVaultTap,
        builder: (context, isPressed, pressValue) => _buildAcademyTrophyVaultDoor(
          phase: phase,
          careerWins: careerWins,
          averageScore: averageScore,
        ),
      ),
      const SizedBox(height: 22),

      // 5. CINEMA CAMERA VIEWFINDER MONITOR (How to Play / Director's Guide)
      Interactive3DDoorCard(
        scrollController: scrollController,
        index: 4,
        specularColor: const Color(0xFFA855F7),
        onTap: onCameraViewfinderTap,
        builder: (context, isPressed, pressValue) => _buildCameraViewfinderDoor(
          phase: phase,
        ),
      ),
      const SizedBox(height: 22),

      // 6. VINTAGE BOX OFFICE WINDOW (The Scene Vault)
      Interactive3DDoorCard(
        scrollController: scrollController,
        index: 5,
        specularColor: const Color(0xFFF59E0B),
        customClipper: BoxOfficeTicketNotchClipper(),
        onTap: onBoxOfficeVaultTap,
        builder: (context, isPressed, pressValue) => _buildBoxOfficeVaultDoor(
          phase: phase,
        ),
      ),
    ];
  }

  /// DOOR A: The Premiere Door — Crowned with an interactive 3D Hollywood Clapperboard
  /// bar that snaps shut on tap, crimson & molten gold glassmorphism, and Bebas Neue type.
  static Widget _buildPremiereClapperDoor({
    required double phase,
    required bool isPressed,
    required double pressValue,
  }) {
    final openAngle = -0.14 * (1.0 - pressValue) * (isPressed ? 0.15 : 1.0);
    final pulse = 0.65 + 0.35 * math.sin(phase * 2.4);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xE6310916),
            Color(0xF2120810),
            Color(0xE6291507),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFF59E0B),
          width: 2.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE11D48).withValues(alpha: 0.38 * pulse),
            blurRadius: 28,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Hinged 3D Clapperboard Bar
          Transform.rotate(
            angle: openAngle,
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              height: 26,
              child: CustomPaint(
                painter: _HollywoodClapperboardBarPainter(
                  accentColor: const Color(0xFFF59E0B),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE11D48).withValues(alpha: 0.45),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.movie_filter_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF10B981),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: pulse),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'READY TO ROLL · STAGE A',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                              color: Color(0xFFFDE68A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CREATE LOBBY / QUICK PLAY',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 30,
                          color: Colors.white,
                          letterSpacing: 1.8,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Snap the clapperboard, dial in your Director\'s Call Sheet, and open a private soundstage for 2 to 8 stars.',
                        style: GoogleFonts.montserrat(
                          fontSize: 12.5,
                          height: 1.35,
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// DOOR B: Heavy Soundstage Airlock Door with metallic rivets, glowing 3D glass
  /// "ON AIR" capsule, and live 12-bar digital audio equalizer wave.
  static Widget _buildSoundstageAirlockDoor({
    required double phase,
    required bool isPressed,
  }) {
    final onAirPulse = (math.sin(phase * 3.0) + 1.0) * 0.5;
    final capsuleColor = Color.lerp(
      const Color(0xFF06B6D4),
      const Color(0xFFE11D48),
      onAirPulse,
    )!;

    return CustomPaint(
      foregroundPainter: _SoundstageAirlockPainter(phase: phase),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 26),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xF00B1926),
              Color(0xF5070C14),
            ],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color(0xFF06B6D4),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 3D Glass "ON AIR" Studio Capsule
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: capsuleColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: capsuleColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: capsuleColor.withValues(alpha: 0.45),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sensors_rounded, size: 15, color: capsuleColor),
                      const SizedBox(width: 6),
                      Text(
                        'ON AIR · LIVE ENSEMBLE',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.dialpad_rounded,
                  color: Color(0xFF06B6D4),
                  size: 26,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'JOIN 6-DIGIT ROOM',
              style: GoogleFonts.chakraPetch(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Punch in your castmate\'s 6-digit backstage pass and step directly under the live studio lights.',
              style: GoogleFonts.montserrat(
                fontSize: 12.5,
                height: 1.35,
                color: const Color(0xFFCBD5E1),
              ),
            ),
            const SizedBox(height: 16),
            // Live Animated 12-Bar Digital Audio Equalizer Wave
            SizedBox(
              height: 22,
              width: double.infinity,
              child: CustomPaint(
                painter: _AudioEqualizerWavePainter(phase: phase),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// DOOR C: VIP Velvet Speakeasy Entrance with draped crimson velvet curtain header,
  /// gold brass hook accents, and flickering neon plasma tubing.
  static Widget _buildVelvetSpeakeasyDoor({
    required double phase,
    required bool isPressed,
  }) {
    // Realistic neon plasma buzz/flicker math
    final flickerWave = math.sin(phase * 7.0) * math.cos(phase * 13.0);
    final neonOpacity = (0.82 + 0.18 * flickerWave).clamp(0.45, 1.0);
    final neonColor = const Color(0xFFEC4899).withValues(alpha: neonOpacity);

    return CustomPaint(
      foregroundPainter: _VelvetSpeakeasyCurtainPainter(phase: phase),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xF02B071E),
              Color(0xF50B0612),
            ],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: neonColor,
            width: 2.2,
          ),
          boxShadow: [
            BoxShadow(
              color: neonColor.withValues(alpha: 0.35),
              blurRadius: 26,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0x33EC4899),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.6),
              ),
              child: const Icon(
                Icons.nightlife_rounded,
                color: Color(0xFFF59E0B),
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Midnight Speakeasy Lounge',
                    style: GoogleFonts.satisfy(
                      fontSize: 22,
                      color: neonColor,
                      shadows: [
                        Shadow(
                          color: neonColor,
                          blurRadius: 14,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '18+ After-Hours',
                    style: GoogleFonts.montserrat(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Slip past the velvet rope for uncut late-night scripts and 15-second mid-scene curveballs.',
                    style: GoogleFonts.montserrat(
                      fontSize: 12.5,
                      height: 1.35,
                      color: const Color(0xFFE2E8F0),
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

  /// DOOR D: Prestigious Academy Vault Door with beveled 24k gold trim,
  /// rotating sunburst halo behind a golden statuette icon, and Cinzel typography.
  static Widget _buildAcademyTrophyVaultDoor({
    required double phase,
    required int careerWins,
    required double averageScore,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xF01C1608),
            Color(0xF5090D14),
            Color(0xF0071A14),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFFBBF24),
          width: 2.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            height: 68,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(68, 68),
                  painter: _RotatingSunburstHaloPainter(phase: phase),
                ),
                const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFFDE68A),
                  size: 36,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$careerWins STATUETTES · ${averageScore.toStringAsFixed(1)} CAREER RATING',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: Color(0xFFFBBF24),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Career Trophy Room',
                  style: GoogleFonts.cinzel(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Enter the Academy archive to review your Golden Statuettes, standing ovations, and critic verdicts.',
                  style: GoogleFonts.montserrat(
                    fontSize: 12.5,
                    height: 1.35,
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// DOOR E: Cinema Camera Viewfinder Monitor with [ ] autofocus brackets,
  /// blinking red REC timecode readout, ISO/battery HUD, and 35mm film sprockets.
  static Widget _buildCameraViewfinderDoor({required double phase}) {
    final recBlink = math.sin(phase * 4.0) > -0.2;
    final seconds = ((phase / (2 * math.pi)) * 59).floor().toString().padLeft(2, '0');

    return CustomPaint(
      foregroundPainter: _ViewfinderFilmSprocketsPainter(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xEB090C15),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color(0xFFA855F7),
            width: 1.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 120),
                      opacity: recBlink ? 1.0 : 0.2,
                      child: const Icon(
                        Icons.fiber_manual_record_rounded,
                        color: Color(0xFFE11D48),
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'REC 00:00:$seconds:18',
                      style: GoogleFonts.courierPrime(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE11D48),
                      ),
                    ),
                  ],
                ),
                Text(
                  'ISO 800 · 24FPS · BAT 99%',
                  style: GoogleFonts.courierPrime(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFA855F7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.center_focus_strong_rounded,
                  color: Color(0xFFA855F7),
                  size: 32,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '[ HOW TO PLAY / DIRECTOR\'S GUIDE ]',
                        style: GoogleFonts.courierPrime(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Interactive storyboards covering Pre-Roll, AI Telemetrics, Ensemble Voting, and Viral Encore reels.',
                        style: GoogleFonts.courierPrime(
                          fontSize: 12.5,
                          height: 1.35,
                          color: const Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// DOOR F: Vintage Box Office Window with carved ticket notches (`BoxOfficeTicketNotchClipper`),
  /// spinning film-reel dial, and gold Art Deco filigree corners.
  static Widget _buildBoxOfficeVaultDoor({required double phase}) {
    return CustomPaint(
      foregroundPainter: _ArtDecoFiligreePainter(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xF0241023),
              Color(0xF50B0D18),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFF59E0B),
            width: 2.0,
          ),
        ),
        child: Row(
          children: [
            Transform.rotate(
              angle: phase,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x26F59E0B),
                  border: Border.all(
                    color: const Color(0xFFF59E0B),
                    width: 2.0,
                  ),
                ),
                child: const Icon(
                  Icons.album_rounded,
                  color: Color(0xFFFDE68A),
                  size: 34,
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ADMIT ONE · VINTAGE BOX OFFICE ROTUNDA',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Color(0xFFFDE68A),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'The Scene Vault',
                    style: GoogleFonts.limelight(
                      fontSize: 25,
                      color: Colors.white,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Step up to the brass window and browse perforated reels from 1970–1999, 2000–2026, and Cult Classics.',
                    style: GoogleFonts.montserrat(
                      fontSize: 12.5,
                      height: 1.35,
                      color: const Color(0xFFE2E8F0),
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

/// CustomClipper that carves authentic vintage Box Office ticket semicircular notches
/// into the left and right edges of Door 5.
class BoxOfficeTicketNotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double r = 24.0;
    const double notchRadius = 15.0;
    final double midY = size.height * 0.5;

    return Path()
      ..moveTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..lineTo(size.width - r, 0)
      ..quadraticBezierTo(size.width, 0, size.width, r)
      ..lineTo(size.width, midY - notchRadius)
      ..arcToPoint(
        Offset(size.width, midY + notchRadius),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      )
      ..lineTo(size.width, size.height - r)
      ..quadraticBezierTo(size.width, size.height, size.width - r, size.height)
      ..lineTo(r, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - r)
      ..lineTo(0, midY + notchRadius)
      ..arcToPoint(
        Offset(0, midY - notchRadius),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      )
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _HollywoodClapperboardBarPainter extends CustomPainter {
  final Color accentColor;

  const _HollywoodClapperboardBarPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF090C14);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Offset.zero & size,
        topLeft: const Radius.circular(24),
        topRight: const Radius.circular(24),
      ),
      bgPaint,
    );

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndCorners(
        Offset.zero & size,
        topLeft: const Radius.circular(24),
        topRight: const Radius.circular(24),
      ),
    );

    final stripePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    const double stripeWidth = 22.0;
    for (double x = -size.height; x < size.width + size.height; x += stripeWidth * 2) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + stripeWidth, size.height)
        ..lineTo(x + stripeWidth + 16, 0)
        ..lineTo(x + 16, 0)
        ..close();
      canvas.drawPath(path, stripePaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HollywoodClapperboardBarPainter oldDelegate) =>
      false;
}

class _SoundstageAirlockPainter extends CustomPainter {
  final double phase;

  const _SoundstageAirlockPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final rivetPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.fill;

    const offsets = [
      Offset(12, 12),
      Offset(12, 48),
      Offset(12, 84),
    ];
    for (final o in offsets) {
      canvas.drawCircle(o, 2.4, rivetPaint);
      canvas.drawCircle(Offset(size.width - o.dx, o.dy), 2.4, rivetPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SoundstageAirlockPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _AudioEqualizerWavePainter extends CustomPainter {
  final double phase;

  const _AudioEqualizerWavePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    const int barCount = 12;
    const double spacing = 6.0;
    final double barWidth =
        ((size.width - (spacing * (barCount - 1))) / barCount)
            .clamp(2.0, size.width);

    for (int i = 0; i < barCount; i++) {
      final wave = (math.sin(phase * 3.2 + i * 0.75) + 1.0) * 0.5;
      final barHeight = (4.0 + wave * (size.height - 4.0)).clamp(4.0, size.height);
      final left = i * (barWidth + spacing);
      final top = size.height - barHeight;

      final paint = Paint()
        ..color = Color.lerp(
          const Color(0xFF06B6D4),
          const Color(0xFFE11D48),
          wave,
        )!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barWidth, barHeight),
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AudioEqualizerWavePainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _VelvetSpeakeasyCurtainPainter extends CustomPainter {
  final double phase;

  const _VelvetSpeakeasyCurtainPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final drapePaint = Paint()
      ..color = const Color(0x669F1239)
      ..style = PaintingStyle.fill;

    final path = Path()..moveTo(0, 0);
    const int scallops = 6;
    final double segW = size.width / scallops;
    for (int i = 0; i < scallops; i++) {
      final startX = i * segW;
      path.quadraticBezierTo(
        startX + segW * 0.5,
        18.0 + math.sin(phase + i) * 2.5,
        startX + segW,
        0,
      );
    }
    path.close();
    canvas.drawPath(path, drapePaint);

    final brassHookPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    for (int i = 1; i < scallops; i++) {
      canvas.drawCircle(Offset(i * segW, 4), 2.5, brassHookPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VelvetSpeakeasyCurtainPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _RotatingSunburstHaloPainter extends CustomPainter {
  final double phase;

  const _RotatingSunburstHaloPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final rayPaint = Paint()
      ..color = const Color(0x55FBBF24)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const int rays = 12;
    for (int i = 0; i < rays; i++) {
      final angle = phase + (i * (2 * math.pi / rays));
      final inner = Offset(
        center.dx + math.cos(angle) * 18,
        center.dy + math.sin(angle) * 18,
      );
      final outer = Offset(
        center.dx + math.cos(angle) * 32,
        center.dy + math.sin(angle) * 32,
      );
      canvas.drawLine(inner, outer, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RotatingSunburstHaloPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _ViewfinderFilmSprocketsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bracketPaint = Paint()
      ..color = const Color(0xFFA855F7)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    const double len = 16.0;
    const double pad = 10.0;
    // Top-left [
    canvas.drawLine(const Offset(pad, pad), const Offset(pad + len, pad), bracketPaint);
    canvas.drawLine(const Offset(pad, pad), const Offset(pad, pad + len), bracketPaint);
    // Top-right ]
    canvas.drawLine(
      Offset(size.width - pad, pad),
      Offset(size.width - pad - len, pad),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(size.width - pad, pad),
      Offset(size.width - pad, pad + len),
      bracketPaint,
    );
    // Bottom-left [
    canvas.drawLine(
      Offset(pad, size.height - pad),
      Offset(pad + len, size.height - pad),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(pad, size.height - pad),
      Offset(pad, size.height - pad - len),
      bracketPaint,
    );
    // Bottom-right ]
    canvas.drawLine(
      Offset(size.width - pad, size.height - pad),
      Offset(size.width - pad - len, size.height - pad),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(size.width - pad, size.height - pad),
      Offset(size.width - pad, size.height - pad - len),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArtDecoFiligreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x88F59E0B)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 6. UPGRADED HOLOGRAPHIC "LIVE WIRE" BROADCAST CHYRON
// ============================================================================

class HolographicLiveWireChyron extends StatelessWidget {
  final Animation<double> tickerAnimation;
  final List<String> feedItems;

  const HolographicLiveWireChyron({
    super.key,
    required this.tickerAnimation,
    required this.feedItems,
  });

  @override
  Widget build(BuildContext context) {
    final joinedFeed = feedItems.join('   ✦   ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xD9080B14),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.75),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: tickerAnimation,
                  builder: (context, _) {
                    final pulse =
                        0.45 + 0.55 * math.sin(tickerAnimation.value * math.pi * 8);
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE11D48),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE11D48).withValues(alpha: pulse),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'LIVE WIRE',
                  style: GoogleFonts.chakraPetch(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: const Color(0xFFFDE68A),
                  ),
                ),
                Container(
                  width: 1.2,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: const Color(0xFF334155),
                ),
                Expanded(
                  child: ClipRect(
                    child: AnimatedBuilder(
                      animation: tickerAnimation,
                      builder: (context, _) {
                        return FractionalTranslation(
                          translation: Offset(
                            1.0 - (tickerAnimation.value * 2.2),
                            0.0,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '$joinedFeed   ✦   $joinedFeed',
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.visible,
                              style: GoogleFonts.montserrat(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.4,
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
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 3. FIRST-PERSON 3D RED CARPET, BRASS STANCHIONS, 42 BOKEH & PAPARAZZI ENGINE
// ============================================================================

class PaparazziRedCarpetPainter extends CustomPainter {
  final double scrollOffset;
  final double phase;
  final double scrollVelocity;
  final Offset? touchPosition;

  const PaparazziRedCarpetPainter({
    required this.scrollOffset,
    this.phase = 0.0,
    this.scrollVelocity = 0.0,
    this.touchPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    // 1. Deep Obsidian Premiere Night Sky & Stage Horizon
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF04060A),
          Color(0xFF14070E),
          Color(0xFF05070B),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final vanishingY =
        (size.height * 0.10) - (scrollOffset * 0.06).clamp(-36.0, 36.0);
    final topHalfWidth = size.width * 0.19;
    final bottomHalfWidth = size.width * 0.49;
    final centerX = size.width * 0.5;

    // 2. 42 Floating Depth-of-Field Golden Bokeh Particles in 3D Space
    for (int i = 0; i < 42; i++) {
      final seedX = ((i * 73 + 19) % 100) / 100.0;
      final seedY = ((i * 41 + 7) % 100) / 100.0;
      final depth = 0.3 + ((i % 7) / 7.0) * 0.7;

      final driftX = math.sin(phase * 0.8 + i * 0.9) * 14.0 * depth;
      final rawY = (seedY * size.height) -
          (scrollOffset * 0.18 * depth) +
          math.cos(phase * 0.6 + i) * 10.0;
      final wrappedY = (rawY % size.height + size.height) % size.height;
      final px = (seedX * size.width + driftX).clamp(0.0, size.width);

      final radius = 1.6 + (depth * 4.2);
      final alpha = (0.14 + 0.36 * depth * ((math.sin(phase * 2 + i) + 1) * 0.5))
          .clamp(0.05, 0.55);

      final bokehPaint = Paint()
        ..color = (i.isEven ? const Color(0xFFFDE68A) : const Color(0xFFF59E0B))
            .withValues(alpha: alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, depth * 3.5);
      canvas.drawCircle(Offset(px, wrappedY), radius, bokehPaint);
    }

    // 3. 3D Royal Crimson Velvet Runner with Perspective Lighting
    final carpetPath = Path()
      ..moveTo(centerX - topHalfWidth, vanishingY)
      ..lineTo(centerX + topHalfWidth, vanishingY)
      ..lineTo(centerX + bottomHalfWidth, size.height)
      ..lineTo(centerX - bottomHalfWidth, size.height)
      ..close();

    final carpetPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF3B0414),
          Color(0xFF881337),
          Color(0xFFE11D48),
          Color(0xFF6B0F2B),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(carpetPath, carpetPaint);

    // 4. Perspective Velvet Tread Steps & Gold Trim Runners
    final goldTrimPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.78)
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(centerX - topHalfWidth, vanishingY),
      Offset(centerX - bottomHalfWidth, size.height),
      goldTrimPaint,
    );
    canvas.drawLine(
      Offset(centerX + topHalfWidth, vanishingY),
      Offset(centerX + bottomHalfWidth, size.height),
      goldTrimPaint,
    );

    // 5. 3D Gold Brass Stanchion Posts & Swinging Catenary Velvet Ropes
    const int stanchionPairs = 7;
    final normalizedShift = (scrollOffset * 0.0028) % (1.0 / stanchionPairs);
    final List<Offset> leftPosts = [];
    final List<Offset> rightPosts = [];
    final List<double> postScales = [];

    for (int i = 0; i < stanchionPairs; i++) {
      final rawT = ((i / stanchionPairs) + normalizedShift) % 1.0;
      final easedT = rawT * rawT;
      final y = vanishingY + (size.height - vanishingY) * easedT;
      final halfW = topHalfWidth + (bottomHalfWidth - topHalfWidth) * easedT;

      // Cross-step grid line on carpet
      final stepPaint = Paint()
        ..color = const Color(0xFFFDA4AF).withValues(alpha: 0.15 * easedT)
        ..strokeWidth = 1.0 + easedT * 1.4;
      canvas.drawLine(
        Offset(centerX - halfW, y),
        Offset(centerX + halfW, y),
        stepPaint,
      );

      final postHeight = 14.0 + easedT * 46.0;
      leftPosts.add(Offset(centerX - halfW, y - postHeight));
      rightPosts.add(Offset(centerX + halfW, y - postHeight));
      postScales.add(easedT);

      // Draw Left & Right 3D Brass Stanchion Posts
      _drawBrassStanchionPost(
        canvas,
        base: Offset(centerX - halfW, y),
        top: Offset(centerX - halfW, y - postHeight),
        scale: easedT,
      );
      _drawBrassStanchionPost(
        canvas,
        base: Offset(centerX + halfW, y),
        top: Offset(centerX + halfW, y - postHeight),
        scale: easedT,
      );
    }

    // Draw Swinging Catenary Velvet Ropes between adjacent stanchions
    final ropePaint = Paint()
      ..color = const Color(0xFFBE123C)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < leftPosts.length - 1; i++) {
      if (postScales[i + 1] < postScales[i]) continue;
      final swing = math.sin(phase * 2.2 + i) * 6.0 * postScales[i];
      final l1 = leftPosts[i];
      final l2 = leftPosts[i + 1];
      final leftRope = Path()
        ..moveTo(l1.dx, l1.dy + 4)
        ..quadraticBezierTo(
          (l1.dx + l2.dx) * 0.5 + swing,
          (l1.dy + l2.dy) * 0.5 + 14.0 * postScales[i],
          l2.dx,
          l2.dy + 4,
        );
      canvas.drawPath(leftRope, ropePaint);

      final r1 = rightPosts[i];
      final r2 = rightPosts[i + 1];
      final rightRope = Path()
        ..moveTo(r1.dx, r1.dy + 4)
        ..quadraticBezierTo(
          (r1.dx + r2.dx) * 0.5 - swing,
          (r1.dy + r2.dy) * 0.5 + 14.0 * postScales[i],
          r2.dx,
          r2.dy + 4,
        );
      canvas.drawPath(rightRope, ropePaint);
    }
  }

  void _drawBrassStanchionPost(
    Canvas canvas, {
    required Offset base,
    required Offset top,
    required double scale,
  }) {
    final postPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.35 + 0.65 * scale)
      ..strokeWidth = 2.0 + scale * 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base, top, postPaint);

    // Gold finial sphere on top of stanchion
    final finialPaint = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.45 + 0.55 * scale);
    canvas.drawCircle(top, 2.5 + scale * 3.8, finialPaint);
  }

  @override
  bool shouldRepaint(covariant PaparazziRedCarpetPainter oldDelegate) {
    return oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.phase != phase ||
        oldDelegate.scrollVelocity != scrollVelocity ||
        oldDelegate.touchPosition != touchPosition;
  }
}

/// Multi-Stage Paparazzi Crowd Silhouettes & 4-Point Star-Burst Camera Flash Painter
class PaparazziFlashOverlayPainter extends CustomPainter {
  final double progress;
  final double scrollVelocity;
  final double frenzyIntensity;

  const PaparazziFlashOverlayPainter({
    required this.progress,
    this.scrollVelocity = 0.0,
    this.frenzyIntensity = 0.0,
  });

  static const List<Offset> _flashAnchors = [
    Offset(0.09, 0.18),
    Offset(0.91, 0.21),
    Offset(0.06, 0.38),
    Offset(0.94, 0.42),
    Offset(0.11, 0.58),
    Offset(0.89, 0.62),
    Offset(0.08, 0.76),
    Offset(0.92, 0.74),
    Offset(0.22, 0.28),
    Offset(0.78, 0.31),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Subtle Photographer Crowd Silhouettes along left and right edges
    final silhouettePaint = Paint()
      ..color = const Color(0x8804060B)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final y = size.height * (0.18 + i * 0.13);
      // Left photographer silhouette head & camera lens barrel
      canvas.drawCircle(Offset(14, y), 11, silhouettePaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(2, y + 10, 24, 28),
          const Radius.circular(8),
        ),
        silhouettePaint,
      );
      // Right photographer silhouette
      canvas.drawCircle(Offset(size.width - 14, y + 8), 11, silhouettePaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width - 26, y + 18, 24, 28),
          const Radius.circular(8),
        ),
        silhouettePaint,
      );
    }

    // 2. Multi-Stage Lens Flashes (4-Point Star-Burst + Lens Core + Radial Bloom)
    final speedMultiplier = 1.0 + (scrollVelocity * 0.08).clamp(0.0, 2.5);
    final activeThreshold =
        (0.16 * speedMultiplier + frenzyIntensity * 0.75).clamp(0.16, 0.92);

    for (int i = 0; i < _flashAnchors.length; i++) {
      final phaseOffset = (i * 0.31) % 1.0;
      final localPhase = ((progress * speedMultiplier + phaseOffset) % 1.0);
      if (localPhase > activeThreshold && frenzyIntensity <= 0.01) continue;

      final rawIntensity = localPhase <= activeThreshold
          ? (1.0 - (localPhase / activeThreshold))
          : 0.0;
      final intensity =
          math.max(rawIntensity, frenzyIntensity).clamp(0.0, 1.0);
      if (intensity <= 0.02) continue;

      final anchor = _flashAnchors[i];
      final center = Offset(size.width * anchor.dx, size.height * anchor.dy);
      final bloomRadius = (85.0 + (i % 3) * 32.0) * (0.8 + 0.4 * intensity);

      // a) Soft Radial Screen Bloom with MaskFilter.blur
      final bloomPaint = Paint()
        ..color = const Color(0xFFFDE68A).withValues(alpha: 0.34 * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
      canvas.drawCircle(center, bloomRadius * 0.65, bloomPaint);

      // b) Sharp 4-Point Star-Burst Path
      final spikeLen = 36.0 + 48.0 * intensity;
      final spikeThickness = 3.2 * intensity;
      final starPath = Path()
        ..moveTo(center.dx - spikeLen, center.dy)
        ..lineTo(center.dx - spikeThickness, center.dy - spikeThickness)
        ..lineTo(center.dx, center.dy - spikeLen)
        ..lineTo(center.dx + spikeThickness, center.dy - spikeThickness)
        ..lineTo(center.dx + spikeLen, center.dy)
        ..lineTo(center.dx + spikeThickness, center.dy + spikeThickness)
        ..lineTo(center.dx, center.dy + spikeLen)
        ..lineTo(center.dx - spikeThickness, center.dy + spikeThickness)
        ..close();

      final starPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.92 * intensity)
        ..style = PaintingStyle.fill;
      canvas.drawPath(starPath, starPaint);

      // c) Bright Lens Flare Core
      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: intensity);
      canvas.drawCircle(center, 5.5 * intensity, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant PaparazziFlashOverlayPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.scrollVelocity != scrollVelocity ||
        oldDelegate.frenzyIntensity != frenzyIntensity;
  }
}

/// Backwards-compatible 3D Paparazzi Cinema Door Card widget
class PaparazziCinemaDoorCard extends StatelessWidget {
  final String doorBadge;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color neonAccent;
  final VoidCallback onTap;

  const PaparazziCinemaDoorCard({
    super.key,
    required this.doorBadge,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.neonAccent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xD90A0D16),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: neonAccent, width: 1.8),
          boxShadow: [
            BoxShadow(
              color: neonAccent.withValues(alpha: 0.28),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: neonAccent, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doorBadge,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: neonAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.limelight(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 12.5,
                      color: const Color(0xFFCBD5E1),
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


