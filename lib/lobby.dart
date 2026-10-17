import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

/// Enumerates all non-hidden Supabase Scene Categories defined in Part 2.
/// (The hidden Late-Night After-Hours table is unlocked separately in Part 5.)
enum SceneCategory {
  era1970To1999(
    key: 'era_1970_1999',
    label: 'Eras: 1970–1999',
    table: 'scenes_era_1970_1999',
    awardFilter: null,
  ),
  era2000To2026(
    key: 'era_2000_2026',
    label: 'Eras: 2000–2026',
    table: 'scenes_era_2000_2026',
    awardFilter: null,
  ),
  awardsBestActor(
    key: 'awards_best_actor',
    label: 'Awards: Best Actor',
    table: 'scenes_awards_vault',
    awardFilter: 'Best Actor',
  ),
  awardsBestActress(
    key: 'awards_best_actress',
    label: 'Awards: Best Actress',
    table: 'scenes_awards_vault',
    awardFilter: 'Best Actress',
  ),
  awardsBestVillain(
    key: 'awards_best_villain',
    label: 'Awards: Best Villain',
    table: 'scenes_awards_vault',
    awardFilter: 'Best Villain',
  ),
  awardsEmmyVault(
    key: 'awards_emmy_vault',
    label: 'Awards: Emmy Vault',
    table: 'scenes_awards_vault',
    awardFilter: 'Emmy Vault',
  ),
  specialtyCultClassics(
    key: 'specialty_cult_classics',
    label: 'Specialty: Cult Classics',
    table: 'scenes_cult_classics',
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
      (c) => c.key == key,
      orElse: () => SceneCategory.era1970To1999,
    );
  }
}

/// Model representing a single acting prompt fetched from Supabase.
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
    return ScenePrompt(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Scene',
      filmOrSeries: json['film_or_series']?.toString() ?? 'Unknown Production',
      releaseYear: (json['release_year'] as num?)?.toInt() ?? 2000,
      characterName: json['character_name']?.toString() ?? 'Lead Role',
      promptScript: json['prompt_script']?.toString() ?? '',
      directorCue: json['director_cue']?.toString() ?? '',
      emotionalTarget: json['emotional_target']?.toString() ?? 'Dramatic',
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 30,
      difficultyTier: (json['difficulty_tier'] as num?)?.toInt() ?? 2,
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

/// Model representing a remote participant inside a 2–8 player lobby.
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

  factory LobbyPlayer.fromJson(Map<String, dynamic> json) {
    return LobbyPlayer(
      id: json['id']?.toString() ?? '',
      lobbyId: json['lobby_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? 'Actor',
      isHost: json['is_host'] == true,
      isReady: json['is_ready'] == true,
      aiTelemetricsScore: (json['ai_telemetrics_score'] as num?)?.toDouble() ?? 0,
      peerScore: (json['peer_score'] as num?)?.toDouble() ?? 0,
      socialScore: (json['social_score'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Model representing the synchronized state of a 6-digit multiplayer lobby.
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

/// Matchmaking & Supabase Realtime Controller.
/// Handles 6-digit lobby creation, player join validation (2–8 players),
/// Postgres Change listeners, and low-latency Broadcast events.
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
    this.localDisplayName = 'Stage Actor',
  }) : localUserId =
            userId ?? supabase.auth.currentUser?.id ?? _generateEphemeralUuid();

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

  /// Generates a cryptographically random 6-digit numeric lobby code (100000–999999).
  static String generateSixDigitCode() {
    final random = Random.secure();
    final code = 100000 + random.nextInt(900000);
    return code.toString();
  }

  /// Creates a new 6-digit lobby in Supabase and subscribes to Realtime channels.
  Future<void> createLobby({
    required String displayName,
    required SceneCategory category,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    localDisplayName = displayName.trim().isEmpty ? 'Host Actor' : displayName.trim();

    try {
      final roomCode = generateSixDigitCode();
      final livekitRoomName = 'act_like_it_$roomCode';

      final insertedLobby = await supabase
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

      await supabase.from('lobby_players').insert({
        'lobby_id': _session!.id,
        'user_id': localUserId,
        'display_name': localDisplayName,
        'is_host': true,
        'is_ready': true,
      });

      await _refreshPlayers(_session!.id);
      _subscribeToLobbyRealtime(_session!);
    } catch (e) {
      _errorMessage = 'Failed to create lobby: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Joins an existing lobby using a 6-digit code if capacity (< 8 players) permits.
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
    localDisplayName = displayName.trim().isEmpty ? 'Remote Actor' : displayName.trim();

    try {
      final lobbyRecord = await supabase
          .from('lobbies')
          .select()
          .eq('room_code', sanitizedCode)
          .maybeSingle();

      if (lobbyRecord == null) {
        throw Exception('No active lobby found for code $sanitizedCode.');
      }

      final lobby = LobbySession.fromJson(lobbyRecord);
      final existingPlayers = await supabase
          .from('lobby_players')
          .select()
          .eq('lobby_id', lobby.id);

      if (existingPlayers.length >= lobby.maxPlayers) {
        throw Exception('Lobby $sanitizedCode is full (max ${lobby.maxPlayers} players).');
      }

      await supabase.from('lobby_players').upsert(
        {
          'lobby_id': lobby.id,
          'user_id': localUserId,
          'display_name': localDisplayName,
          'is_host': lobby.hostId == localUserId,
          'is_ready': false,
        },
        onConflict: 'lobby_id,user_id',
      );

      _session = lobby;
      await _refreshPlayers(lobby.id);
      _subscribeToLobbyRealtime(lobby);
    } catch (e) {
      _errorMessage = 'Unable to join lobby: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Toggles the local player's ready state and broadcasts over Supabase Realtime.
  Future<void> toggleReadyState() async {
    if (_session == null) return;
    final me = _players.where((p) => p.userId == localUserId).firstOrNull;
    if (me == null) return;

    final nextReady = !me.isReady;
    try {
      await supabase
          .from('lobby_players')
          .update({'is_ready': nextReady})
          .eq('lobby_id', _session!.id)
          .eq('user_id', localUserId);

      await _realtimeChannel?.sendBroadcastMessage(
        event: 'player_ready_changed',
        payload: {
          'user_id': localUserId,
          'is_ready': nextReady,
        },
      );
      await _refreshPlayers(_session!.id);
    } catch (e) {
      _errorMessage = 'Could not update ready state: $e';
      notifyListeners();
    }
  }

  /// Updates the active scene category (Host only) and syncs across all connected clients.
  Future<void> updateCategory(SceneCategory category) async {
    if (_session == null || !isHost) return;
    try {
      final updated = await supabase
          .from('lobbies')
          .update({
            'selected_category': category.key,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', _session!.id)
          .select()
          .single();

      _session = LobbySession.fromJson(updated);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to change category: $e';
      notifyListeners();
    }
  }

  /// Draws a random scene prompt from the selected Supabase category table
  /// and transitions the lobby into the 'performing' state for all 2–8 players.
  Future<void> startPerformanceRound() async {
    if (_session == null || !isHost) return;
    if (_players.length < 2) {
      _errorMessage = 'At least 2 remote players are required to start a round.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final category = _session!.selectedCategory;
      List<dynamic> rows;

      if (category.awardFilter != null) {
        rows = await supabase
            .from(category.table)
            .select()
            .eq('award_subcategory', category.awardFilter!);
      } else {
        rows = await supabase.from(category.table).select();
      }

      if (rows.isEmpty) {
        throw Exception('No scenes found in table ${category.table}.');
      }

      final random = Random.secure();
      final chosenMap =
          Map<String, dynamic>.from(rows[random.nextInt(rows.length)] as Map);
      final chosenScene = ScenePrompt.fromJson(chosenMap);

      final nextActor = _players[random.nextInt(_players.length)];

      final updatedLobby = await supabase
          .from('lobbies')
          .update({
            'status': 'performing',
            'active_actor_id': nextActor.userId,
            'active_scene_id': chosenScene.id,
            'active_scene_payload': chosenScene.toJson(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', _session!.id)
          .select()
          .single();

      _session = LobbySession.fromJson(updatedLobby);

      await _realtimeChannel?.sendBroadcastMessage(
        event: 'round_started',
        payload: {
          'room_code': _session!.roomCode,
          'active_actor_id': nextActor.userId,
          'scene': chosenScene.toJson(),
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to start performance round: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _refreshPlayers(String lobbyId) async {
    final data = await supabase
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
    _realtimeChannel?.unsubscribe();

    final channel = supabase.channel(
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
        .onBroadcast(
          event: 'round_started',
          callback: (payload) {
            final sceneMap = payload['scene'];
            if (_session != null && sceneMap is Map<String, dynamic>) {
              _session = LobbySession(
                id: _session!.id,
                roomCode: _session!.roomCode,
                hostId: _session!.hostId,
                selectedCategory: _session!.selectedCategory,
                status: 'performing',
                minPlayers: _session!.minPlayers,
                maxPlayers: _session!.maxPlayers,
                activeActorId: payload['active_actor_id']?.toString(),
                activeScene: ScenePrompt.fromJson(sceneMap),
                roundNumber: _session!.roundNumber,
                livekitRoomName: _session!.livekitRoomName,
              );
              notifyListeners();
            }
          },
        )
        .subscribe();

    _realtimeChannel = channel;
  }

  Future<void> leaveLobby() async {
    final current = _session;
    if (current != null) {
      try {
        await supabase
            .from('lobby_players')
            .delete()
            .eq('lobby_id', current.id)
            .eq('user_id', localUserId);
      } catch (_) {}
    }
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

/// Interactive Matchmaking & 6-Digit Room UI for 2–8 Remote Players.
class LobbyMatchmakingScreen extends StatefulWidget {
  final SceneCategory initialCategory;
  final bool startInJoinMode;

  const LobbyMatchmakingScreen({
    super.key,
    this.initialCategory = SceneCategory.era1970To1999,
    this.startInJoinMode = false,
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
              labelText: 'Select Supabase Scene Category',
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
                    );
                  }
                },
          child: Text(
            _lobbyManager.isLoading
                ? 'Synchronizing with Supabase Realtime...'
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
                'Capacity: ${players.length}/${session.maxPlayers} Remote Players · '
                'LiveKit Room: ${session.livekitRoomName}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (activeScene != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE11D48)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        const Text(
          'Connected Remote Players (2–8 SFU Slots)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        ...players.map(
          (player) => Card(
            margin: const EdgeInsets.only(bottom: 8),
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
                child: const Text('Toggle Ready Status'),
              ),
            ),
            const SizedBox(width: 12),
            if (_lobbyManager.isHost)
              Expanded(
                child: ElevatedButton(
                  onPressed: _lobbyManager.canStartMatch
                      ? () => _lobbyManager.startPerformanceRound()
                      : null,
                  child: const Text('Draw Scene & Launch Stage'),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
