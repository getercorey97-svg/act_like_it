import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_service.dart';
import '../auth/nda_tester_gate.dart';
import '../late_night_vault.dart';
import '../lobby.dart';
import '../main.dart';
import '../qa/qa_overlay.dart';
import '../qa/qa_web_portal.dart';
import '../services/system_health_service.dart';
import 'lobby_models_and_realtime.dart';
import 'scene_vault_screen.dart';
import 'system_health_table.dart';

/// Full Tech-Staff & Founder Command Dashboard (`founder88` / `admin88`):
/// 1. Live Signed-In Users & Currently Playing Monitor (`profiles`, `lobbies`, `lobby_players`)
/// 2. Create User / Tester Credentials Generator (`nda_tester_approvals` + 1-tap Copy)
/// 3. Tech-Staff Controls, Paywall Simulator, SystemHealth Check & AI/QA Telemetry
class FounderCommandDashboard extends StatefulWidget {
  final int initialTabIndex;

  const FounderCommandDashboard({
    super.key,
    this.initialTabIndex = 0,
  });

  static Future<void> show(
    BuildContext context, {
    int initialTabIndex = 0,
  }) async {
    HapticFeedback.mediumImpact();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF07090E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: Color(0xFFFFD700), width: 2.0),
      ),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.92,
        child: FounderCommandDashboard(initialTabIndex: initialTabIndex),
      ),
    );
  }

  @override
  State<FounderCommandDashboard> createState() =>
      _FounderCommandDashboardState();
}

class _FounderCommandDashboardState extends State<FounderCommandDashboard> {
  static const String _prefsIssuedPasscodeRegistryKey =
      'act_like_it_nda_passcode_registry_v2';

  late int _selectedTabIndex; // 0 = Live Roster, 1 = Create User, 2 = Tech Controls
  bool _isLoading = true;
  String? _statusMessage;
  String? _activeDeviceRoomCode;

  List<Map<String, dynamic>> _signedInProfiles = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _activeLobbies = <Map<String, dynamic>>[];
  Map<String, List<Map<String, dynamic>>> _playersByLobbyId =
      <String, List<Map<String, dynamic>>>{};
  List<Map<String, dynamic>> _telemetryLogs = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _recentMatches = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _issuedCredentials = <Map<String, dynamic>>[];

  RealtimeChannel? _founderRealtimeChannel;

  // Create User / Tester Credential form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _customCodeController = TextEditingController();
  final TextEditingController _tokensController =
      TextEditingController(text: '250');
  String _selectedTier = 'Beta Tester';
  bool _isIssuingCredentials = false;
  Map<String, dynamic>? _latestGeneratedCredential;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex.clamp(0, 2);
    _subscribeToLiveTables();
    unawaited(_refreshLiveRosterAndTelemetry());
  }

  void _subscribeToLiveTables() {
    final client = supabaseOrNull;
    if (client == null) return;
    try {
      final channel = client.channel('founder_tech_staff_live_hud');
      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'lobbies',
            callback: (_) {
              if (mounted) unawaited(_refreshLiveRosterAndTelemetry());
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'lobby_players',
            callback: (_) {
              if (mounted) unawaited(_refreshLiveRosterAndTelemetry());
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'profiles',
            callback: (_) {
              if (mounted) unawaited(_refreshLiveRosterAndTelemetry());
            },
          )
          .subscribe();
      _founderRealtimeChannel = channel;
    } catch (_) {}
  }

  @override
  void dispose() {
    if (_founderRealtimeChannel != null) {
      try {
        supabaseOrNull?.removeChannel(_founderRealtimeChannel!);
      } catch (_) {}
      _founderRealtimeChannel = null;
    }
    _nameController.dispose();
    _emailController.dispose();
    _customCodeController.dispose();
    _tokensController.dispose();
    super.dispose();
  }

  Future<void> _refreshLiveRosterAndTelemetry() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final List<Map<String, dynamic>> profiles = <Map<String, dynamic>>[];
    final List<Map<String, dynamic>> lobbies = <Map<String, dynamic>>[];
    final Map<String, List<Map<String, dynamic>>> lobbyPlayersMap =
        <String, List<Map<String, dynamic>>>{};
    final List<Map<String, dynamic>> telemetry = <Map<String, dynamic>>[];
    final List<Map<String, dynamic>> matches = <Map<String, dynamic>>[];
    final List<Map<String, dynamic>> issued = <Map<String, dynamic>>[];

    final activeRoom = await LobbyRealtimeManager.loadActiveRoomSession();

    // Local QA telemetry + local saved profiles + local issued passcodes
    try {
      final localQa = await QaTelemetryRepository.loadLocalCachedReports();
      for (final r in localQa) {
        telemetry.add(<String, dynamic>{
          'id': r.id,
          'tester_handle': r.testerHandle,
          'bug_type': r.bugType,
          'tester_note':
              r.localStateDump['tester_note'] ?? r.bugType,
          'active_route': r.localStateDump['active_page_route'] ?? '',
          'created_at': r.createdAt.toIso8601String(),
        });
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawReg = prefs.getString(_prefsIssuedPasscodeRegistryKey) ?? '{}';
      final decoded = jsonDecode(rawReg);
      if (decoded is Map) {
        for (final entry in decoded.entries) {
          if (entry.value is Map) {
            issued.add(Map<String, dynamic>.from(entry.value as Map));
          }
        }
      }
    } catch (_) {}

    final client = supabaseOrNull;
    if (client != null) {
      try {
        final rows = await client
            .from('profiles')
            .select()
            .order('updated_at', ascending: false)
            .limit(80)
            .timeout(const Duration(seconds: 5));
        for (final r in rows.whereType<Map>()) {
          profiles.add(Map<String, dynamic>.from(r));
        }
      } catch (_) {}

      try {
        final lobbyRows = await client
            .from('lobbies')
            .select()
            .order('created_at', ascending: false)
            .limit(40)
            .timeout(const Duration(seconds: 5));
        for (final r in lobbyRows.whereType<Map>()) {
          lobbies.add(Map<String, dynamic>.from(r));
        }
      } catch (_) {}

      try {
        final lpRows = await client
            .from('lobby_players')
            .select()
            .order('joined_at', ascending: false)
            .limit(120)
            .timeout(const Duration(seconds: 5));
        for (final r in lpRows.whereType<Map>()) {
          final map = Map<String, dynamic>.from(r);
          final lid = (map['lobby_id'] ?? '').toString();
          if (lid.isNotEmpty) {
            lobbyPlayersMap.putIfAbsent(lid, () => <Map<String, dynamic>>[]);
            lobbyPlayersMap[lid]!.add(map);
          }
        }
      } catch (_) {}

      try {
        final qaRows = await client
            .from('qa_feedback')
            .select()
            .order('created_at', ascending: false)
            .limit(80)
            .timeout(const Duration(seconds: 5));
        for (final r in qaRows.whereType<Map>()) {
          final row = Map<String, dynamic>.from(r);
          final id = (row['id'] ?? '').toString();
          if (id.isEmpty || !telemetry.any((t) => t['id'] == id)) {
            telemetry.add(row);
          }
        }
      } catch (_) {}

      try {
        final mhRows = await client
            .from('match_history')
            .select()
            .order('created_at', ascending: false)
            .limit(30)
            .timeout(const Duration(seconds: 5));
        for (final r in mhRows.whereType<Map>()) {
          matches.add(Map<String, dynamic>.from(r));
        }
      } catch (_) {}

      try {
        final ndaRows = await client
            .from(OfficialClosedAlphaNdaGateWrapper.approvalsTableName)
            .select()
            .order('created_at', ascending: false)
            .limit(60)
            .timeout(const Duration(seconds: 5));
        for (final r in ndaRows.whereType<Map>()) {
          final row = Map<String, dynamic>.from(r);
          final code = (row['unique_passcode'] ?? '').toString().toUpperCase();
          if (code.isNotEmpty &&
              !issued.any(
                (i) =>
                    (i['unique_passcode'] ?? '').toString().toUpperCase() ==
                    code,
              )) {
            issued.add(row);
          }
        }
      } catch (_) {}
    }

    // Merge active local profile + saved local roster
    final activeProfile = AuthService.instance.currentProfile;
    if (activeProfile != null &&
        !profiles.any((p) => p['id'] == activeProfile.userId)) {
      profiles.insert(0, <String, dynamic>{
        ...activeProfile.toJson(),
        'is_current_device': true,
        'platform': kIsWeb ? 'Web' : defaultTargetPlatform.name,
      });
    }
    for (final saved in AuthService.instance.savedProfiles) {
      if (!profiles.any((p) => p['id'] == saved.userId)) {
        profiles.add(<String, dynamic>{
          ...saved.toJson(),
          'platform': kIsWeb ? 'Web' : defaultTargetPlatform.name,
        });
      }
    }

    // If this device has an active local room code not yet returned from cloud
    if (activeRoom != null &&
        activeRoom.isNotEmpty &&
        !lobbies.any((l) => (l['room_code'] ?? '').toString() == activeRoom)) {
      lobbies.insert(0, <String, dynamic>{
        'id': 'local-room-$activeRoom',
        'room_code': activeRoom,
        'game_mode': 'local_or_hybrid',
        'status': 'active',
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    }

    if (!mounted) return;
    setState(() {
      _activeDeviceRoomCode = activeRoom;
      _signedInProfiles = profiles;
      _activeLobbies = lobbies;
      _playersByLobbyId = lobbyPlayersMap;
      _telemetryLogs = telemetry;
      _recentMatches = matches;
      _issuedCredentials = issued;
      _isLoading = false;
    });
  }

  String _generateTempPin() {
    final rng = math.Random.secure();
    final digits = List<int>.generate(6, (_) => rng.nextInt(10)).join();
    return digits;
  }

  Future<void> _handleGenerateTesterCredentials() async {
    final rawName = _nameController.text.trim();
    if (rawName.isEmpty) {
      setState(() {
        _statusMessage = 'Enter a Name or @handle first.';
      });
      return;
    }

    final cleanHandle = rawName.replaceAll('@', '').trim();
    final rawEmail = _emailController.text.trim();
    final resolvedEmail = rawEmail.isNotEmpty
        ? rawEmail.toLowerCase()
        : '${cleanHandle.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}@actlikeit.stage';
    final parsedTokens =
        (int.tryParse(_tokensController.text.trim()) ?? 250).clamp(0, 999999);
    final customCode = _customCodeController.text.trim().toUpperCase();
    final passcode = customCode.isNotEmpty
        ? customCode
        : OfficialClosedAlphaNdaGateWrapper.generateUniqueTesterPasscode(
            fullName: cleanHandle,
            email: resolvedEmail,
            phone: DateTime.now().millisecondsSinceEpoch.toString(),
            deviceFingerprint: 'FOUNDER_ISSUED',
          );
    final tempPin = _generateTempPin();
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final founderHandle = AuthService.instance.currentProfile?.username ?? 'founder88';

    setState(() {
      _isIssuingCredentials = true;
      _statusMessage = null;
    });

    final record = <String, dynamic>{
      'full_legal_name': cleanHandle,
      'email': resolvedEmail,
      'phone_number': 'ISSUED-$tempPin',
      'digital_signature': 'Founder-Issued ($founderHandle)',
      'unique_passcode': passcode,
      'bound_device_fingerprint': 'PENDING_FIRST_LOGIN',
      'device_model': 'Founder Tech-Staff Issued',
      'os_version': 'Web / Android',
      'network_connection_used': 'Both Tested',
      'agreed_17_usc_102_copyright': true,
      'agreed_strict_nda_no_recording_or_sharing': true,
      'interested_in_partnership': _selectedTier == 'VIP Cast',
      'selected_partnership_tracks': <String>[_selectedTier],
      'partnership_background_summary':
          'Tier: $_selectedTier | Starter AI Tokens: $parsedTokens',
      'approval_status': 'approved',
      'approved_by': 'Founder ($founderHandle)',
      'approved_at': nowIso,
      'founder_notes':
          'Tier=$_selectedTier; InitialTokens=$parsedTokens; TempPIN=$tempPin',
      'official_portal_url': 'https://act-like-it.vercel.app',
      'created_at': nowIso,
      'updated_at': nowIso,
    };

    // 1. Save into SharedPreferences issued passcode registry
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawReg = prefs.getString(_prefsIssuedPasscodeRegistryKey) ?? '{}';
      final decoded = jsonDecode(rawReg);
      final Map<String, dynamic> reg = decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{};
      reg[passcode] = record;
      await prefs.setString(_prefsIssuedPasscodeRegistryKey, jsonEncode(reg));
    } catch (_) {}

    // 2. Persist into Supabase public.nda_tester_approvals
    bool cloudSaved = false;
    final client = supabaseOrNull;
    if (client != null) {
      try {
        await client
            .from(OfficialClosedAlphaNdaGateWrapper.approvalsTableName)
            .upsert(record, onConflict: 'unique_passcode')
            .timeout(const Duration(seconds: 5));
        cloudSaved = true;
      } catch (_) {}

      // Best-effort profile seed so founder sees them in profiles roster cleanly
      try {
        final seededUserId =
            'actor_${cleanHandle.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch % 10000}';
        await client.from('profiles').upsert(<String, dynamic>{
          'id': seededUserId,
          'username': cleanHandle,
          'display_name': cleanHandle,
          'birth_year': 1998,
          'ai_token_balance': parsedTokens,
          'ai_tokens': parsedTokens,
          'tokens_balance': parsedTokens,
          'casting_track': _selectedTier.toLowerCase().replaceAll(' ', '_'),
          'updated_at': nowIso,
        }).timeout(const Duration(seconds: 4));
      } catch (_) {}
    }

    // 3. Log in local saved profile registry without overriding Founder session
    try {
      final createdLocal = await AuthService.instance.createLocalCastProfile(
        username: cleanHandle,
        birthYear: 1998,
        avatarArchetypeId: 'the_method_actor',
        switchToNewProfile: false,
      );
      if (parsedTokens != AuthService.kDefaultStarterAiTokens) {
        final prefs = await SharedPreferences.getInstance();
        final updatedJson = createdLocal
            .copyWith(
              aiTokenBalance: parsedTokens,
              castingTrack: _selectedTier.toLowerCase().replaceAll(' ', '_'),
            )
            .toJson();
        await prefs.setString(
          'act_like_it_profile_v1_${createdLocal.userId}',
          jsonEncode(updatedJson),
        );
      }
    } catch (_) {}

    if (!mounted) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _isIssuingCredentials = false;
      _latestGeneratedCredential = <String, dynamic>{
        'name': cleanHandle,
        'email': resolvedEmail,
        'tier': _selectedTier,
        'tokens': parsedTokens,
        'passcode': passcode,
        'tempPin': tempPin,
        'cloudSaved': cloudSaved,
      };
      _statusMessage = cloudSaved
          ? '✅ Credentials issued & synced to Supabase ($passcode).'
          : '✅ Credentials saved locally ($passcode). Cloud sync offline.';
    });
    unawaited(_refreshLiveRosterAndTelemetry());
  }

  Future<void> _copyCredentials(Map<String, dynamic> cred) async {
    final text = StringBuffer()
      ..writeln('ACT LIKE IT™ — OFFICIAL CAST / TESTER CREDENTIALS')
      ..writeln('Portal: https://act-like-it.vercel.app')
      ..writeln('Actor / Handle: @${cred['name']}')
      ..writeln('Email: ${cred['email']}')
      ..writeln('Access Tier: ${cred['tier']}')
      ..writeln('Starter AI Tokens: ${cred['tokens']}')
      ..writeln('Access Passcode: ${cred['passcode']}')
      ..writeln('Temporary PIN: ${cred['tempPin']}');
    await Clipboard.setData(ClipboardData(text: text.toString()));
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0E131F),
        content: Text(
          'Copied credentials for @${cred['name']} (${cred['passcode']})',
          style: const TextStyle(color: Color(0xFFF5DEB3)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final health = SystemHealthService.instance;
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[auth, health]),
      builder: (context, _) {
        final simulatePaywall = auth.adminSimulatePaywall;
        final godMode = auth.isGodModeActive;
        final activeHandle =
            auth.currentProfile?.username.isNotEmpty == true
                ? auth.currentProfile!.username
                : 'founder88';

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(context).viewInsets.bottom + 14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x33FFD700),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFFD700),
                          width: 1.5,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '👑 FOUNDER TECH COMMAND · @$activeHandle',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        unawaited(_refreshLiveRosterAndTelemetry());
                        unawaited(health.refreshHealthChecks());
                      },
                      tooltip: 'Refresh Live Roster',
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Color(0xFF0CB6D4),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Quick Founder summary strip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: godMode
                        ? const Color(0xFF082218)
                        : const Color(0xFF261219),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: godMode
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE11342),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        godMode
                            ? Icons.verified_user_rounded
                            : Icons.lock_person_rounded,
                        color: godMode
                            ? const Color(0xFFFFD700)
                            : const Color(0xFFFDA4AF),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            godMode
                                ? 'FULL ACCESS ACTIVE · ∞ TOKENS · SIGNED IN: ${_signedInProfiles.length} · LOBBIES: ${_activeLobbies.length}'
                                : 'PAYWALL SIM ON · TAP SWITCH IN CONTROLS TAB TO RESTORE ∞ ACCESS',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: godMode
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFFFDA4AF),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: health.indicatorColor.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: health.indicatorColor),
                        ),
                        child: Text(
                          health.statusLabel,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: health.indicatorColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // 3 Tabs
                Row(
                  children: [
                    _buildTabChip(
                      index: 0,
                      label: '👥 LIVE USERS (${_signedInProfiles.length})',
                    ),
                    const SizedBox(width: 6),
                    _buildTabChip(
                      index: 1,
                      label: '🪪 CREATE USER',
                    ),
                    const SizedBox(width: 6),
                    _buildTabChip(
                      index: 2,
                      label: '🛠️ TECH & QA (${_telemetryLogs.length})',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _buildTabBody(
                    simulatePaywall: simulatePaywall,
                    godMode: godMode,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabChip({required int index, required String label}) {
    final active = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedTabIndex = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFFD700) : const Color(0xFF0E131F),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? const Color(0xFFFFD700) : const Color(0xFF334155),
            ),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: active ? const Color(0xFF07090E) : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBody({
    required bool simulatePaywall,
    required bool godMode,
  }) {
    if (_selectedTabIndex == 1) {
      return _buildCreateCredentialsTab();
    }
    if (_selectedTabIndex == 2) {
      return _buildTechControlsTab(
        simulatePaywall: simulatePaywall,
        godMode: godMode,
      );
    }
    return _buildLiveRosterTab();
  }

  Widget _buildLiveRosterTab() {
    return ListView(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'LIVE SIGNED-IN ACCOUNTS & ACTIVE STAGE ROOMS',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFF5DEB3),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _refreshLiveRosterAndTelemetry,
              icon: const Icon(
                Icons.sync_rounded,
                size: 16,
                color: Color(0xFF0CB6D4),
              ),
              label: const Text(
                'REFRESH LIVE ROSTER',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0CB6D4),
                ),
              ),
            ),
          ],
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            ),
          ),
        // Section A: Currently Playing Lobbies + Players
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0C101A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF0CB6D4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎬 CURRENTLY PLAYING RIGHT NOW (${_activeLobbies.length} ROOMS)',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0CB6D4),
                ),
              ),
              const SizedBox(height: 8),
              if (_activeLobbies.isEmpty)
                const Text(
                  'No active multiplayer lobbies open right now.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                ),
              for (final lobby in _activeLobbies) ...[
                _buildLobbyCard(lobby),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Section B: Signed-In User Accounts
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0C101A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF5DEB3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '👤 SIGNED-IN ACCOUNTS & PROFILES (${_signedInProfiles.length})',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFF5DEB3),
                ),
              ),
              const SizedBox(height: 8),
              if (_signedInProfiles.isEmpty)
                const Text(
                  'No actor profiles found yet.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                ),
              for (final p in _signedInProfiles) _buildProfileRow(p),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLobbyCard(Map<String, dynamic> lobby) {
    final lid = (lobby['id'] ?? '').toString();
    final code = (lobby['room_code'] ?? '------').toString();
    final status = (lobby['status'] ?? 'waiting').toString().toUpperCase();
    final mode =
        (lobby['selected_category'] ?? lobby['game_mode'] ?? 'era_1970_1999')
            .toString();
    final activeScenePayload = lobby['active_scene_payload'];
    String sceneTitle = '';
    if (activeScenePayload is Map && activeScenePayload['title'] != null) {
      sceneTitle = activeScenePayload['title'].toString();
    }
    final players = _playersByLobbyId[lid] ?? const <Map<String, dynamic>>[];

    Color statusColor = const Color(0xFFF59E0B);
    if (status == 'PERFORMING' || status == 'ACTIVE') {
      statusColor = const Color(0xFF00FF88);
    } else if (status == 'JUDGING') {
      statusColor = const Color(0xFFE11342);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF111726),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ROOM #$code',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              if (_activeDeviceRoomCode == code) ...[
                const SizedBox(width: 6),
                const Text(
                  '(THIS DEVICE)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFD700),
                  ),
                ),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            sceneTitle.isNotEmpty
                ? 'Mode: $mode · Scene: "$sceneTitle"'
                : 'Mode: $mode · Players in room: ${players.length}',
            style: const TextStyle(fontSize: 11, color: Color(0xFFCBD5E1)),
          ),
          if (players.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: players.map((pl) {
                final name =
                    (pl['display_name'] ?? pl['user_id'] ?? 'Actor').toString();
                final isHost = pl['is_host'] == true;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF07090E),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isHost
                          ? const Color(0xFFFFD700)
                          : const Color(0xFF334155),
                    ),
                  ),
                  child: Text(
                    isHost ? '👑 $name' : '🎭 $name',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9.5,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileRow(Map<String, dynamic> p) {
    final handle = (p['username'] ?? 'StageStar').toString();
    final displayName = (p['display_name'] ?? handle).toString();
    final track = (p['casting_track'] ?? 'track_a_star').toString();
    final rawTokens = p['ai_token_balance'] ?? p['ai_tokens'] ?? p['tokens_balance'] ?? 50;
    final tokenStr = rawTokens.toString() == '999999' ? '∞' : rawTokens.toString();
    final updated = (p['updated_at'] ?? p['created_at'] ?? '').toString();
    final platform = (p['platform'] ?? 'Cloud').toString();
    final isCurrent = p['is_current_device'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF111726),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrent
              ? const Color(0xFF00FF88)
              : const Color(0xFF283548),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCurrent ? Icons.verified_rounded : Icons.person_pin_rounded,
            color: isCurrent
                ? const Color(0xFF00FF88)
                : const Color(0xFFFFD700),
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@$handle ($displayName)',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tier: $track · Device: $platform · Active: ${updated.length > 16 ? updated.substring(0, 16) : (updated.isEmpty ? 'Live' : updated)}',
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x26F5DEB3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF5DEB3)),
            ),
            child: Text(
              '$tokenStr TKN',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFFF5DEB3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateCredentialsTab() {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0C101A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '🪪 CREATE USER / TESTER CREDENTIALS',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Issues an immediate approved Access Passcode (ALI-XX-XXXX) + Temporary PIN synced to public.nda_tester_approvals and local cast storage.',
                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Full Name or @handle *',
                  hintText: 'e.g. @MarcusS26 or Marcus Vance',
                  filled: true,
                  fillColor: const Color(0xFF07090E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Email (Optional)',
                  hintText: 'actor@stage.com (auto-generated if blank)',
                  filled: true,
                  fillColor: const Color(0xFF07090E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Role / Access Tier',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFF5DEB3),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: <String>['Beta Tester', 'VIP Cast', 'Moderator/Staff']
                    .map((tier) {
                  final selected = _selectedTier == tier;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTier = tier),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF0CB6D4)
                                : const Color(0xFF07090E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF0CB6D4)
                                  : const Color(0xFF334155),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              tier,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: selected
                                    ? const Color(0xFF07090E)
                                    : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _tokensController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Initial AI Tokens',
                        filled: true,
                        fillColor: const Color(0xFF07090E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _customCodeController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Custom Code (Optional)',
                        hintText: 'Auto ALI-XX-XXXX',
                        filled: true,
                        fillColor: const Color(0xFF07090E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: <String>['50', '250', '1000', '9999'].map((preset) {
                  return GestureDetector(
                    onTap: () => setState(() => _tokensController.text = preset),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141B2B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Text(
                        '$preset TOKENS',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF5DEB3),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_statusMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _statusMessage!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF34D399),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF07090E),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                onPressed: _isIssuingCredentials
                    ? null
                    : _handleGenerateTesterCredentials,
                icon: const Icon(Icons.badge_rounded, size: 18),
                label: Text(
                  _isIssuingCredentials
                      ? 'ISSUING CREDENTIALS...'
                      : 'GENERATE & APPROVE USER CREDENTIALS',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_latestGeneratedCredential != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF082218),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF00FF88), width: 1.6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'READY FOR @${_latestGeneratedCredential!['name']}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF00FF88),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Passcode: ${_latestGeneratedCredential!['passcode']}   ·   Temp PIN: ${_latestGeneratedCredential!['tempPin']}\n'
                  'Tier: ${_latestGeneratedCredential!['tier']}   ·   AI Tokens: ${_latestGeneratedCredential!['tokens']}\n'
                  'Email: ${_latestGeneratedCredential!['email']}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Colors.white,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0CB6D4),
                    foregroundColor: const Color(0xFF07090E),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  onPressed: () => _copyCredentials(_latestGeneratedCredential!),
                  icon: const Icon(Icons.copy_all_rounded, size: 17),
                  label: const Text(
                    'COPY CREDENTIALS',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_issuedCredentials.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            'RECENTLY ISSUED / APPROVED PASSES (${_issuedCredentials.length})',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFFF5DEB3),
            ),
          ),
          const SizedBox(height: 6),
          for (final rec in _issuedCredentials.take(12))
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0E131F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF283548)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${rec['full_legal_name'] ?? 'Tester'} · ${rec['unique_passcode'] ?? ''}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Status: ${(rec['approval_status'] ?? 'approved').toString().toUpperCase()} · ${rec['founder_notes'] ?? rec['email'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy Passcode',
                    onPressed: () async {
                      final code = (rec['unique_passcode'] ?? '').toString();
                      await Clipboard.setData(ClipboardData(text: code));
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Copied $code')),
                      );
                    },
                    icon: const Icon(
                      Icons.copy_rounded,
                      size: 16,
                      color: Color(0xFF0CB6D4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildTechControlsTab({
    required bool simulatePaywall,
    required bool godMode,
  }) {
    final health = SystemHealthService.instance;
    return ListView(
      children: [
        const SystemHealthTable(),
        const SizedBox(height: 10),
        // Paywall simulator toggle
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: godMode ? const Color(0xFF082218) : const Color(0xFF261219),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: godMode ? const Color(0xFF10B981) : const Color(0xFFE11342),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      simulatePaywall
                          ? 'Simulate Standard Paywall: ON'
                          : 'Simulate Standard Paywall: OFF (∞ Full Access)',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Toggle to verify paywalls/age-gates as a standard user or restore Founder God-Mode.',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFFCBD5E1)),
                    ),
                  ],
                ),
              ),
              Switch(
                value: simulatePaywall,
                activeThumbColor: const Color(0xFFE11342),
                onChanged: (_) async {
                  HapticFeedback.selectionClick();
                  await AuthService.instance.toggleAdminSimulatePaywall();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Direct mode / lobby jumps & Health Refresh
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0CB6D4),
                foregroundColor: const Color(0xFF07090E),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                unawaited(health.refreshHealthChecks());
              },
              icon: const Icon(Icons.health_and_safety_rounded, size: 16),
              label: const Text(
                'RE-CHECK HEALTH',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11342),
                foregroundColor: const Color(0xFFF5DEB3),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LobbyMatchmakingScreen(
                      initialCategory: SceneCategory.era1970To1999,
                      startInJoinMode: false,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.meeting_room_rounded, size: 16),
              label: const Text(
                'OPEN LOBBY',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA55577),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LateNightAfterHoursScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.nightlife_rounded, size: 16),
              label: const Text(
                '18+ SPEAKEASY',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5DEB3),
                foregroundColor: const Color(0xFF07090E),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SceneVaultScreen()),
                );
              },
              icon: const Icon(Icons.movie_filter_rounded, size: 16),
              label: const Text(
                'SCENE VAULT',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: const Color(0xFF00FF88),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const QaWebPortalDashboardScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.bug_report_rounded, size: 16),
              label: const Text(
                'QA PORTAL',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_recentMatches.isNotEmpty) ...[
          Text(
            '🏆 RECENT VERIFIED MATCH TELEMETRY (${_recentMatches.length})',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFFD700),
            ),
          ),
          const SizedBox(height: 6),
          for (final m in _recentMatches.take(6))
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0E131F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Text(
                'Final: ${m['final_score']} · AI: ${m['ai_score']} · Peer: ${m['peer_score']} · Win: ${m['is_win']}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10.5,
                  color: Colors.white,
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
        Text(
          '📊 AI JUDGING, CALIBRATION & QA BUG TELEMETRY (${_telemetryLogs.length})',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0CB6D4),
          ),
        ),
        const SizedBox(height: 6),
        if (_telemetryLogs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text(
              'No telemetry events logged yet. Complete a take, rate AI calibration, or test a \$0.00 Sandbox Store unlock.',
              style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
            ),
          ),
        for (final item in _telemetryLogs.take(30))
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0E131F),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF283548)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[${item['bug_type'] ?? 'TELEMETRY'}] @${item['tester_handle'] ?? 'Actor'} · ${item['active_route'] ?? ''}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFF5DEB3),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item['tester_note'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
