import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

/// Immutable snapshot of an actor's persistent profile, Red Carpet
/// questionnaire answers, 18+ age-gate birth year, Acting DNA, and AI Token balance.
class ActorProfileState {
  final String userId;
  final String email;
  final String username;
  final int birthYear;
  final List<String> favoriteEras;
  final List<String> actingStrengths;
  final int aiTokenBalance;
  final List<String> unlockedScenePacks;
  final bool onboardingCompleted;
  final String avatarArchetypeId;
  final String castingTrack;
  final bool telemetryOptIn;
  final String regionalDialect;
  final double vocalProjectionDb;
  final String physicalStyle;
  final int careerXp;
  final DateTime updatedAt;

  const ActorProfileState({
    required this.userId,
    required this.email,
    required this.username,
    required this.birthYear,
    required this.favoriteEras,
    required this.actingStrengths,
    required this.aiTokenBalance,
    required this.unlockedScenePacks,
    required this.onboardingCompleted,
    this.avatarArchetypeId = 'the_method_actor',
    this.castingTrack = 'track_a_star',
    this.telemetryOptIn = true,
    this.regionalDialect = 'Hollywood Standard',
    this.vocalProjectionDb = -18.5,
    this.physicalStyle = 'High-Contrast Method',
    this.careerXp = 1250,
    required this.updatedAt,
  });

  /// Computes whether the actor meets the 18+ threshold for the Late-Night vault.
  bool get is18PlusVerified => (DateTime.now().year - birthYear) >= 18;

  String get careerRankBadge {
    if (careerXp >= 5000) return 'ACADEMY LEGEND';
    if (careerXp >= 2500) return 'HEADLINER STAR';
    if (careerXp >= 1000) return 'RISING LEAD';
    return 'STUDIO NEWCOMER';
  }

  ActorProfileState copyWith({
    String? userId,
    String? email,
    String? username,
    int? birthYear,
    List<String>? favoriteEras,
    List<String>? actingStrengths,
    int? aiTokenBalance,
    List<String>? unlockedScenePacks,
    bool? onboardingCompleted,
    String? avatarArchetypeId,
    String? castingTrack,
    bool? telemetryOptIn,
    String? regionalDialect,
    double? vocalProjectionDb,
    String? physicalStyle,
    int? careerXp,
    DateTime? updatedAt,
  }) {
    return ActorProfileState(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      username: username ?? this.username,
      birthYear: birthYear ?? this.birthYear,
      favoriteEras: favoriteEras ?? this.favoriteEras,
      actingStrengths: actingStrengths ?? this.actingStrengths,
      aiTokenBalance: aiTokenBalance ?? this.aiTokenBalance,
      unlockedScenePacks: unlockedScenePacks ?? this.unlockedScenePacks,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      avatarArchetypeId: avatarArchetypeId ?? this.avatarArchetypeId,
      castingTrack: castingTrack ?? this.castingTrack,
      telemetryOptIn: telemetryOptIn ?? this.telemetryOptIn,
      regionalDialect: regionalDialect ?? this.regionalDialect,
      vocalProjectionDb: vocalProjectionDb ?? this.vocalProjectionDb,
      physicalStyle: physicalStyle ?? this.physicalStyle,
      careerXp: careerXp ?? this.careerXp,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': userId,
      'email': email,
      'username': username,
      'birth_year': birthYear,
      'favorite_eras': favoriteEras,
      'acting_strengths': actingStrengths,
      'ai_token_balance': aiTokenBalance,
      'unlocked_scene_packs': unlockedScenePacks,
      'onboarding_completed': onboardingCompleted,
      'avatar_archetype': avatarArchetypeId,
      'casting_track': castingTrack,
      'telemetry_opt_in': telemetryOptIn,
      'regional_dialect': regionalDialect,
      'vocal_projection_db': vocalProjectionDb,
      'physical_style': physicalStyle,
      'career_xp': careerXp,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ActorProfileState.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic raw, List<String> fallback) {
      if (raw is List) {
        return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
      }
      if (raw is String && raw.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            return decoded
                .map((e) => e.toString())
                .where((s) => s.isNotEmpty)
                .toList();
          }
        } catch (_) {
          return raw
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }
      }
      return fallback;
    }

    final parsedBirthYear = json['birth_year'] is int
        ? json['birth_year'] as int
        : int.tryParse('${json['birth_year'] ?? ''}') ?? 1998;

    final parsedTokens = json['ai_token_balance'] is int
        ? json['ai_token_balance'] as int
        : int.tryParse('${json['ai_token_balance'] ?? ''}') ?? 25;

    final parsedVocalDb = (json['vocal_projection_db'] as num?)?.toDouble() ??
        double.tryParse('${json['vocal_projection_db'] ?? ''}') ??
        -18.5;

    final parsedCareerXp = json['career_xp'] is int
        ? json['career_xp'] as int
        : int.tryParse('${json['career_xp'] ?? ''}') ?? 1250;

    return ActorProfileState(
      userId: (json['id'] ?? json['user_id'] ?? 'local-s26-actor').toString(),
      email: (json['email'] ?? '').toString(),
      username: (json['username'] ?? 'StageStar').toString(),
      birthYear: parsedBirthYear.clamp(1900, DateTime.now().year),
      favoriteEras: parseStringList(
        json['favorite_eras'],
        const <String>['1970–1999', '2000–2026'],
      ),
      actingStrengths: parseStringList(
        json['acting_strengths'],
        const <String>['Method Drama', 'Improv Comedy'],
      ),
      aiTokenBalance: parsedTokens < 0 ? 0 : parsedTokens,
      unlockedScenePacks: parseStringList(
        json['unlocked_scene_packs'],
        const <String>[],
      ),
      onboardingCompleted: json['onboarding_completed'] == true,
      avatarArchetypeId: (json['avatar_archetype'] ??
              json['avatarArchetypeId'] ??
              'the_method_actor')
          .toString(),
      castingTrack:
          (json['casting_track'] ?? json['castingTrack'] ?? 'track_a_star')
              .toString(),
      telemetryOptIn: json['telemetry_opt_in'] != false,
      regionalDialect:
          (json['regional_dialect'] ?? 'Hollywood Standard').toString(),
      vocalProjectionDb: parsedVocalDb.clamp(-60.0, 0.0),
      physicalStyle:
          (json['physical_style'] ?? 'High-Contrast Method').toString(),
      careerXp: parsedCareerXp < 0 ? 0 : parsedCareerXp,
      updatedAt: DateTime.tryParse('${json['updated_at'] ?? ''}') ??
          DateTime.now().toUtc(),
    );
  }

  String get displayName => username.trim().isNotEmpty ? username : 'StageStar';
}

/// Global authentication, multi-profile switcher, and persistent profile state manager.
class AuthService extends ChangeNotifier {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  static const String _kLocalProfilePrefix = 'act_like_it_profile_v1_';
  static const String _kLastActiveUserIdKey = 'act_like_it_last_user_id_v1';
  static const String _kSavedProfilesRegistryKey = 'saved_actor_profiles_v1';
  static const String _kTelemetricsTokensPrefsKey =
      'act_like_it_telemetrics_tokens_v1';
  static const int kDefaultStarterAiTokens = 25;

  ActorProfileState? _currentProfile;
  final List<ActorProfileState> _savedProfiles = <ActorProfileState>[];
  bool _isLoading = false;
  String? _lastError;
  StreamSubscription<AuthState>? _authSubscription;

  ActorProfileState? get currentProfile => _currentProfile;
  List<ActorProfileState> get savedProfiles =>
      List<ActorProfileState>.unmodifiable(_savedProfiles);
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  bool get isAuthenticated => _currentProfile != null;
  int get aiTokenBalance =>
      _currentProfile?.aiTokenBalance ?? kDefaultStarterAiTokens;
  bool get is18PlusVerified => _currentProfile?.is18PlusVerified ?? false;

  bool get hasVipSpeakeasyPass =>
      hasUnlockedScenePack('vip_speakeasy_pass') ||
      hasUnlockedScenePack('late_night');

  bool get hasWatermarkFreePro => hasUnlockedScenePack('watermark_free_pro');

  bool get hasEmmyAndCultVault =>
      hasUnlockedScenePack('emmy_cult_bundle') ||
      hasUnlockedScenePack('all_era_bundle') ||
      hasUnlockedScenePack('emmy_vault') ||
      hasUnlockedScenePack('cult_classics');

  bool get hasAllEraBundle => hasUnlockedScenePack('all_era_bundle');

  /// Initializes the service on app boot and restores any active Supabase session
  /// plus the multi-profile registry (`saved_actor_profiles_v1`).
  Future<void> initialize() async {
    _setLoading(true);
    _lastError = null;

    try {
      await _loadSavedProfilesRegistry();

      if (AppConfig.hasCloudSupabase) {
        final client = Supabase.instance.client;
        await _authSubscription?.cancel();
        _authSubscription = client.auth.onAuthStateChange.listen((authState) {
          final user = authState.session?.user;
          if (user != null) {
            unawaited(
              fetchAndHydrateProfile(
                userId: user.id,
                email: user.email ?? '',
              ),
            );
          }
        });

        final activeUser = client.auth.currentUser;
        if (activeUser != null) {
          await fetchAndHydrateProfile(
            userId: activeUser.id,
            email: activeUser.email ?? '',
          );
          _setLoading(false);
          return;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final lastUserId = prefs.getString(_kLastActiveUserIdKey);
      if (lastUserId != null && lastUserId.isNotEmpty) {
        final cached = await _readLocalProfile(lastUserId);
        if (cached != null) {
          _currentProfile = cached;
          await _syncRegistryWithProfile(cached);
          notifyListeners();
          return;
        }
      }

      if (_savedProfiles.isNotEmpty) {
        _currentProfile = _savedProfiles.first;
        notifyListeners();
      } else {
        final defaultProfile = ActorProfileState(
          userId: 'local-s26-actor',
          email: 'actor@actlikeit.stage',
          username: 'kkl',
          birthYear: 1998,
          favoriteEras: const <String>['1970–1999', '2000–2026'],
          actingStrengths: const <String>['Method Drama', 'Improv Comedy'],
          aiTokenBalance: kDefaultStarterAiTokens,
          unlockedScenePacks: const <String>[],
          onboardingCompleted: true,
          avatarArchetypeId: 'the_method_actor',
          updatedAt: DateTime.now().toUtc(),
        );
        _currentProfile = defaultProfile;
        await _writeLocalProfile(defaultProfile);
        notifyListeners();
      }
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Switches the active profile across the entire app immediately.
  Future<ActorProfileState?> switchToProfile(String userId) async {
    final matchIdx = _savedProfiles.indexWhere((p) => p.userId == userId);
    ActorProfileState? target =
        matchIdx >= 0 ? _savedProfiles[matchIdx] : await _readLocalProfile(userId);
    if (target == null) return _currentProfile;

    _currentProfile = target;
    await _writeLocalProfile(target);
    notifyListeners();
    return target;
  }

  /// Creates a new local/cloud Actor Profile and switches to it immediately.
  Future<ActorProfileState> createAndSwitchToNewProfile({
    required String username,
    required int birthYear,
    required String avatarArchetypeId,
    List<String>? favoriteEras,
    List<String>? actingStrengths,
    String regionalDialect = 'Hollywood Standard',
    String physicalStyle = 'High-Contrast Method',
  }) async {
    final cleanHandle =
        username.trim().replaceAll('@', '').isEmpty ? 'StageStar' : username.trim().replaceAll('@', '');
    final newUserId =
        'actor_${cleanHandle.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch % 100000}';
    final created = ActorProfileState(
      userId: newUserId,
      email: '${cleanHandle.toLowerCase()}@actlikeit.stage',
      username: cleanHandle,
      birthYear: birthYear.clamp(1920, DateTime.now().year),
      favoriteEras: favoriteEras == null || favoriteEras.isEmpty
          ? const <String>['1970–1999', '2000–2026']
          : favoriteEras,
      actingStrengths: actingStrengths == null || actingStrengths.isEmpty
          ? const <String>['Method Drama', 'Improv Comedy']
          : actingStrengths,
      aiTokenBalance: kDefaultStarterAiTokens,
      unlockedScenePacks: const <String>[],
      onboardingCompleted: true,
      avatarArchetypeId: avatarArchetypeId,
      regionalDialect: regionalDialect,
      physicalStyle: physicalStyle,
      careerXp: 500,
      updatedAt: DateTime.now().toUtc(),
    );
    await persistProfileToSupabaseAndCache(created);
    return created;
  }

  /// Awards Career XP after a round/match finalization and persists to cache & Supabase.
  Future<ActorProfileState?> addCareerXp(int earnedXp) async {
    if (earnedXp <= 0) return _currentProfile;
    final current = _currentProfile;
    if (current == null) return null;
    final updated = current.copyWith(
      careerXp: current.careerXp + earnedXp,
      updatedAt: DateTime.now().toUtc(),
    );
    await persistProfileToSupabaseAndCache(updated);
    return updated;
  }

  /// Play Store Account & Data Deletion Compliance:
  /// Wipes the active profile (or all local data) from SharedPreferences and
  /// Supabase `profiles`, signs out, and resets the session cleanly.
  Future<void> deleteCurrentActorProfileAndData() async {
    _setLoading(true);
    try {
      final targetId = _currentProfile?.userId;
      final prefs = await SharedPreferences.getInstance();

      if (targetId != null) {
        await prefs.remove('$_kLocalProfilePrefix$targetId');
        _savedProfiles.removeWhere((p) => p.userId == targetId);
        await prefs.setString(
          _kSavedProfilesRegistryKey,
          jsonEncode(_savedProfiles.map((e) => e.toJson()).toList()),
        );
      }

      if (AppConfig.hasCloudSupabase && targetId != null) {
        final client = Supabase.instance.client;
        try {
          await client.from('profiles').delete().eq('id', targetId);
        } catch (_) {}
        try {
          await client.auth.signOut();
        } catch (_) {}
      }

      if (_savedProfiles.isNotEmpty) {
        _currentProfile = _savedProfiles.first;
        await prefs.setString(_kLastActiveUserIdKey, _currentProfile!.userId);
      } else {
        await prefs.remove(_kLastActiveUserIdKey);
        await prefs.remove(_kSavedProfilesRegistryKey);
        _currentProfile = null;
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<ActorProfileState> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    _setLoading(true);
    _lastError = null;

    try {
      if (AppConfig.hasCloudSupabase) {
        final client = Supabase.instance.client;
        final response = await client.auth.signInWithPassword(
          email: normalizedEmail,
          password: password,
        );
        final user = response.user;
        if (user == null) {
          throw StateError('Authentication succeeded without a user session.');
        }

        final profile = await fetchAndHydrateProfile(
          userId: user.id,
          email: user.email ?? normalizedEmail,
        );
        return profile;
      }

      final fallbackUserId = _deterministicUserIdForEmail(normalizedEmail);
      final hydrated = await fetchAndHydrateProfile(
        userId: fallbackUserId,
        email: normalizedEmail,
      );
      return hydrated;
    } catch (e) {
      _lastError = _humanizeAuthError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<ActorProfileState> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required int birthYear,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final sanitizedUsername = username.trim().isEmpty
        ? normalizedEmail.split('@').first
        : username.trim();
    final clampedBirthYear = birthYear.clamp(1920, DateTime.now().year);

    _setLoading(true);
    _lastError = null;

    try {
      String userId = _deterministicUserIdForEmail(normalizedEmail);

      if (AppConfig.hasCloudSupabase) {
        final client = Supabase.instance.client;
        final response = await client.auth.signUp(
          email: normalizedEmail,
          password: password,
          data: <String, dynamic>{
            'username': sanitizedUsername,
            'birth_year': clampedBirthYear,
            'favorite_eras': const <String>['1970–1999', '2000–2026'],
            'acting_strengths': const <String>['Method Drama'],
            'ai_token_balance': kDefaultStarterAiTokens,
            'unlocked_scene_packs': const <String>[],
            'onboarding_completed': false,
          },
        );
        if (response.user != null) {
          userId = response.user!.id;
        }
      }

      final initialProfile = ActorProfileState(
        userId: userId,
        email: normalizedEmail,
        username: sanitizedUsername,
        birthYear: clampedBirthYear,
        favoriteEras: const <String>['1970–1999', '2000–2026'],
        actingStrengths: const <String>['Method Drama'],
        aiTokenBalance: kDefaultStarterAiTokens,
        unlockedScenePacks: const <String>[],
        onboardingCompleted: false,
        updatedAt: DateTime.now().toUtc(),
      );

      await persistProfileToSupabaseAndCache(initialProfile);
      return initialProfile;
    } catch (e) {
      _lastError = _humanizeAuthError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<ActorProfileState> fetchAndHydrateProfile({
    required String userId,
    String email = '',
  }) async {
    final localCached = await _readLocalProfile(userId);
    Map<String, dynamic> mergedData = <String, dynamic>{
      if (localCached != null) ...localCached.toJson(),
      'id': userId,
      if (email.isNotEmpty) 'email': email,
    };

    if (AppConfig.hasCloudSupabase) {
      final client = Supabase.instance.client;
      final activeUser = client.auth.currentUser;
      if (activeUser != null && activeUser.id == userId) {
        final meta = activeUser.userMetadata;
        if (meta != null) {
          mergedData.addAll(meta);
        }
        if ((activeUser.email ?? '').isNotEmpty) {
          mergedData['email'] = activeUser.email;
        }
      }

      try {
        final row = await client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle()
            .timeout(const Duration(seconds: 5));

        if (row != null) {
          mergedData.addAll(Map<String, dynamic>.from(row));
          if (!mergedData.containsKey('onboarding_completed')) {
            mergedData['onboarding_completed'] = true;
          }
        }
      } catch (e) {
        debugPrint('Supabase profiles query notice: $e');
      }
    }

    final hydrated = ActorProfileState.fromJson(mergedData);
    _currentProfile = hydrated;
    await _writeLocalProfile(hydrated);
    notifyListeners();
    return hydrated;
  }

  Future<ActorProfileState> saveOnboardingQuestionnaire({
    required String username,
    required int birthYear,
    required List<String> favoriteEras,
    required List<String> actingStrengths,
    String? avatarArchetypeId,
    String? castingTrack,
    bool? telemetryOptIn,
    int? initialAiTokens,
  }) async {
    _setLoading(true);
    _lastError = null;

    try {
      final current = _currentProfile;
      final effectiveUserId = current?.userId ??
          (AppConfig.hasCloudSupabase
              ? (Supabase.instance.client.auth.currentUser?.id ??
                  'local-s26-actor')
              : 'local-s26-actor');
      final effectiveEmail = current?.email ??
          (AppConfig.hasCloudSupabase
              ? (Supabase.instance.client.auth.currentUser?.email ?? '')
              : 'actor@actlikeit.stage');

      final updated = ActorProfileState(
        userId: effectiveUserId,
        email: effectiveEmail,
        username: username.trim().isEmpty ? 'StageStar' : username.trim(),
        birthYear: birthYear.clamp(1920, DateTime.now().year),
        favoriteEras: favoriteEras.isEmpty
            ? const <String>['1970–1999', '2000–2026']
            : favoriteEras,
        actingStrengths: actingStrengths.isEmpty
            ? const <String>['Method Drama']
            : actingStrengths,
        aiTokenBalance: initialAiTokens ??
            current?.aiTokenBalance ??
            kDefaultStarterAiTokens,
        unlockedScenePacks: current?.unlockedScenePacks ?? const <String>[],
        onboardingCompleted: true,
        avatarArchetypeId:
            avatarArchetypeId ?? current?.avatarArchetypeId ?? 'the_method_actor',
        castingTrack: castingTrack ?? current?.castingTrack ?? 'track_a_star',
        telemetryOptIn: telemetryOptIn ?? current?.telemetryOptIn ?? true,
        regionalDialect: current?.regionalDialect ?? 'Hollywood Standard',
        vocalProjectionDb: current?.vocalProjectionDb ?? -18.5,
        physicalStyle: current?.physicalStyle ?? 'High-Contrast Method',
        careerXp: current?.careerXp ?? 1250,
        updatedAt: DateTime.now().toUtc(),
      );

      await persistProfileToSupabaseAndCache(updated);
      return updated;
    } catch (e) {
      _lastError = _humanizeAuthError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<ActorProfileState?> updateAvatarArchetype(String archetypeId) async {
    final current = _currentProfile;
    final base = current ??
        ActorProfileState(
          userId: 'local-s26-actor',
          email: 'actor@actlikeit.stage',
          username: 'StageStar',
          birthYear: 1998,
          favoriteEras: const <String>['1970–1999', '2000–2026'],
          actingStrengths: const <String>['Method Drama'],
          aiTokenBalance: kDefaultStarterAiTokens,
          unlockedScenePacks: const <String>[],
          onboardingCompleted: true,
          avatarArchetypeId: archetypeId,
          updatedAt: DateTime.now().toUtc(),
        );
    final updated = base.copyWith(
      avatarArchetypeId: archetypeId,
      updatedAt: DateTime.now().toUtc(),
    );
    await persistProfileToSupabaseAndCache(updated);
    return updated;
  }

  Future<ActorProfileState?> upsertAdditiveProfileFields({
    String? avatarArchetypeId,
    String? castingTrack,
    bool? telemetryOptIn,
    String? username,
    int? birthYear,
    List<String>? favoriteEras,
    List<String>? actingStrengths,
    String? regionalDialect,
    double? vocalProjectionDb,
    String? physicalStyle,
    int? careerXp,
  }) async {
    final current = _currentProfile;
    final base = current ??
        ActorProfileState(
          userId: 'local-s26-actor',
          email: 'actor@actlikeit.stage',
          username: username ?? 'StageStar',
          birthYear: birthYear ?? 1998,
          favoriteEras:
              favoriteEras ?? const <String>['1970–1999', '2000–2026'],
          actingStrengths: actingStrengths ?? const <String>['Method Drama'],
          aiTokenBalance: kDefaultStarterAiTokens,
          unlockedScenePacks: const <String>[],
          onboardingCompleted: true,
          avatarArchetypeId: avatarArchetypeId ?? 'the_method_actor',
          castingTrack: castingTrack ?? 'track_a_star',
          telemetryOptIn: telemetryOptIn ?? true,
          updatedAt: DateTime.now().toUtc(),
        );
    final updated = base.copyWith(
      username: username ?? base.username,
      birthYear: birthYear ?? base.birthYear,
      favoriteEras: favoriteEras ?? base.favoriteEras,
      actingStrengths: actingStrengths ?? base.actingStrengths,
      avatarArchetypeId: avatarArchetypeId ?? base.avatarArchetypeId,
      castingTrack: castingTrack ?? base.castingTrack,
      telemetryOptIn: telemetryOptIn ?? base.telemetryOptIn,
      regionalDialect: regionalDialect ?? base.regionalDialect,
      vocalProjectionDb: vocalProjectionDb ?? base.vocalProjectionDb,
      physicalStyle: physicalStyle ?? base.physicalStyle,
      careerXp: careerXp ?? base.careerXp,
      updatedAt: DateTime.now().toUtc(),
    );
    await persistProfileToSupabaseAndCache(updated);
    return updated;
  }

  Future<void> persistProfileToSupabaseAndCache(
    ActorProfileState profile,
  ) async {
    _currentProfile = profile;
    await _writeLocalProfile(profile);
    notifyListeners();

    if (!AppConfig.hasCloudSupabase) return;

    final client = Supabase.instance.client;

    try {
      await client.from('profiles').upsert(<String, dynamic>{
        'id': profile.userId,
        'username': profile.username,
        'birth_year': profile.birthYear,
        'favorite_eras': profile.favoriteEras,
        'acting_strengths': profile.actingStrengths,
        'ai_token_balance': profile.aiTokenBalance,
        'unlocked_scene_packs': profile.unlockedScenePacks,
        'onboarding_completed': profile.onboardingCompleted,
        'avatar_archetype': profile.avatarArchetypeId,
        'casting_track': profile.castingTrack,
        'telemetry_opt_in': profile.telemetryOptIn,
      }).timeout(const Duration(seconds: 5));
    } catch (_) {
      try {
        await client.from('profiles').upsert(<String, dynamic>{
          'id': profile.userId,
          'username': profile.username,
          'birth_year': profile.birthYear,
          'favorite_eras': profile.favoriteEras,
          'acting_strengths': profile.actingStrengths,
          'ai_token_balance': profile.aiTokenBalance,
          'unlocked_scene_packs': profile.unlockedScenePacks,
          'onboarding_completed': profile.onboardingCompleted,
        }).timeout(const Duration(seconds: 5));
      } catch (_) {}
    }

    if (client.auth.currentUser != null) {
      try {
        await client.auth
            .updateUser(
              UserAttributes(
                data: <String, dynamic>{
                  'username': profile.username,
                  'birth_year': profile.birthYear,
                  'favorite_eras': profile.favoriteEras,
                  'acting_strengths': profile.actingStrengths,
                  'ai_token_balance': profile.aiTokenBalance,
                  'unlocked_scene_packs': profile.unlockedScenePacks,
                  'onboarding_completed': profile.onboardingCompleted,
                  'avatar_archetype': profile.avatarArchetypeId,
                  'casting_track': profile.castingTrack,
                  'telemetry_opt_in': profile.telemetryOptIn,
                },
              ),
            )
            .timeout(const Duration(seconds: 5));
      } catch (_) {}
    }
  }

  Future<bool> consumeAiToken() async {
    final profile = _currentProfile;
    if (profile == null) return false;
    if (profile.aiTokenBalance <= 0) return false;
    final updated = profile.copyWith(
      aiTokenBalance: profile.aiTokenBalance - 1,
      updatedAt: DateTime.now().toUtc(),
    );
    await persistProfileToSupabaseAndCache(updated);
    return true;
  }

  Future<ActorProfileState?> topUpAiTokens(int amount) async {
    if (amount <= 0) return _currentProfile;
    final base = _currentProfile ??
        ActorProfileState(
          userId: 'local-s26-actor',
          email: 'actor@actlikeit.stage',
          username: 'kkl',
          birthYear: 1998,
          favoriteEras: const <String>['1970–1999', '2000–2026'],
          actingStrengths: const <String>['Method Drama'],
          aiTokenBalance: kDefaultStarterAiTokens,
          unlockedScenePacks: const <String>[],
          onboardingCompleted: true,
          updatedAt: DateTime.now().toUtc(),
        );
    final updated = base.copyWith(
      aiTokenBalance: base.aiTokenBalance + amount,
      updatedAt: DateTime.now().toUtc(),
    );
    await persistProfileToSupabaseAndCache(updated);
    return updated;
  }

  Future<ActorProfileState?> addAiTokens(int amount) => topUpAiTokens(amount);

  Future<ActorProfileState?> unlockScenePack(String packKey) async {
    final base = _currentProfile ??
        ActorProfileState(
          userId: 'local-s26-actor',
          email: 'actor@actlikeit.stage',
          username: 'kkl',
          birthYear: 1998,
          favoriteEras: const <String>['1970–1999', '2000–2026'],
          actingStrengths: const <String>['Method Drama'],
          aiTokenBalance: kDefaultStarterAiTokens,
          unlockedScenePacks: const <String>[],
          onboardingCompleted: true,
          updatedAt: DateTime.now().toUtc(),
        );
    if (base.unlockedScenePacks.contains(packKey)) {
      return base;
    }
    final updatedPacks = List<String>.from(base.unlockedScenePacks)..add(packKey);
    final updated = base.copyWith(
      unlockedScenePacks: updatedPacks,
      updatedAt: DateTime.now().toUtc(),
    );
    await persistProfileToSupabaseAndCache(updated);
    return updated;
  }

  bool hasUnlockedScenePack(String packKey) {
    final packs = _currentProfile?.unlockedScenePacks ?? const <String>[];
    if (packs.contains('all_era_bundle')) return true;
    return packs.contains(packKey);
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      if (AppConfig.hasCloudSupabase) {
        await Supabase.instance.client.auth.signOut();
      }
      _currentProfile = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadSavedProfilesRegistry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kSavedProfilesRegistryKey);
      _savedProfiles.clear();
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) {
              _savedProfiles.add(
                ActorProfileState.fromJson(Map<String, dynamic>.from(item)),
              );
            }
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _syncRegistryWithProfile(ActorProfileState profile) async {
    final idx = _savedProfiles.indexWhere((p) => p.userId == profile.userId);
    if (idx >= 0) {
      _savedProfiles[idx] = profile;
    } else {
      _savedProfiles.insert(0, profile);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kSavedProfilesRegistryKey,
        jsonEncode(_savedProfiles.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  Future<void> _writeLocalProfile(ActorProfileState profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_kLocalProfilePrefix${profile.userId}',
        jsonEncode(profile.toJson()),
      );
      if (profile.email.isNotEmpty) {
        await prefs.setString(
          '$_kLocalProfilePrefix${_deterministicUserIdForEmail(profile.email)}',
          jsonEncode(profile.toJson()),
        );
      }
      await prefs.setString(_kLastActiveUserIdKey, profile.userId);
      await prefs.setInt(_kTelemetricsTokensPrefsKey, profile.aiTokenBalance);
      await _syncRegistryWithProfile(profile);
    } catch (e) {
      debugPrint('Local profile cache write notice: $e');
    }
  }

  Future<ActorProfileState?> _readLocalProfile(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_kLocalProfilePrefix$userId');
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return ActorProfileState.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  String _deterministicUserIdForEmail(String email) {
    final cleaned = email.trim().toLowerCase();
    if (cleaned.isEmpty) return 'local-s26-actor';
    int hash = 5381;
    for (final codeUnit in cleaned.codeUnits) {
      hash = ((hash << 5) + hash) ^ codeUnit;
    }
    final hex = (hash & 0x7FFFFFFF).toRadixString(16).padLeft(8, '0');
    return '00000000-0000-4000-8000-${hex.padRight(12, '0')}';
  }

  String _humanizeAuthError(Object error) {
    if (error is AuthException) {
      return error.message;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }
}
