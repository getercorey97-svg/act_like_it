import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

/// Immutable snapshot of an actor's persistent profile, Red Carpet
/// questionnaire answers, 18+ age-gate birth year, and AI Token balance.
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
    required this.updatedAt,
  });

  /// Computes whether the actor meets the 18+ threshold for the Late-Night vault.
  bool get is18PlusVerified => (DateTime.now().year - birthYear) >= 18;

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
        : int.tryParse('${json['ai_token_balance'] ?? ''}') ?? 10;

    return ActorProfileState(
      userId: (json['id'] ?? json['user_id'] ?? 'local-s26-actor').toString(),
      email: (json['email'] ?? '').toString(),
      username: (json['username'] ?? 'StageStar').toString(),
      birthYear: parsedBirthYear.clamp(1900, DateTime.now().year),
      favoriteEras: parseStringList(
        json['favorite_eras'],
        const <String>['1970s', '2000s'],
      ),
      actingStrengths: parseStringList(
        json['acting_strengths'],
        const <String>['Drama'],
      ),
      aiTokenBalance: parsedTokens < 0 ? 0 : parsedTokens,
      unlockedScenePacks: parseStringList(
        json['unlocked_scene_packs'],
        const <String>[],
      ),
      onboardingCompleted: json['onboarding_completed'] == true,
      updatedAt: DateTime.tryParse('${json['updated_at'] ?? ''}') ??
          DateTime.now().toUtc(),
    );
  }
}

/// Global authentication and persistent profile state manager.
/// Synchronizes user profiles, Red Carpet questionnaire preferences, 18+ birth
/// year verification, Host-Pays scene pack unlocks, and AI Token balances
/// between Supabase (`public.profiles` + Auth metadata) and local storage.
class AuthService extends ChangeNotifier {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  static const String _kLocalProfilePrefix = 'act_like_it_profile_v1_';
  static const String _kLastActiveUserIdKey = 'act_like_it_last_user_id_v1';
  static const int kDefaultStarterAiTokens = 10;

  ActorProfileState? _currentProfile;
  bool _isLoading = false;
  String? _lastError;
  StreamSubscription<AuthState>? _authSubscription;

  ActorProfileState? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  bool get isAuthenticated => _currentProfile != null;
  int get aiTokenBalance => _currentProfile?.aiTokenBalance ?? kDefaultStarterAiTokens;
  bool get is18PlusVerified => _currentProfile?.is18PlusVerified ?? false;

  /// Initializes the service on app boot and automatically restores any active
  /// Supabase session or cached profile from the `profiles` table.
  Future<void> initialize() async {
    _setLoading(true);
    _lastError = null;

    try {
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

      // Restore most recent cached profile when offline or before cloud sign-in
      final prefs = await SharedPreferences.getInstance();
      final lastUserId = prefs.getString(_kLastActiveUserIdKey);
      if (lastUserId != null && lastUserId.isNotEmpty) {
        final cached = await _readLocalProfile(lastUserId);
        if (cached != null) {
          _currentProfile = cached;
          notifyListeners();
        }
      }
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Signs in an existing actor via Supabase Auth (with offline/local fallback)
  /// and immediately queries `public.profiles` to load historical questionnaire
  /// answers, birth year, and AI Token balance into global state.
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

      // Offline / Standalone Galaxy S26 Ultra fallback keyed by deterministic ID
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

  /// Registers a new actor account, seeds their initial row in `public.profiles`,
  /// and prepares them for "The Red Carpet" Onboarding Questionnaire.
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
            'favorite_eras': const <String>['1970s', '2000s'],
            'acting_strengths': const <String>['Drama'],
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
        favoriteEras: const <String>['1970s', '2000s'],
        actingStrengths: const <String>['Drama'],
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

  /// Queries `public.profiles` (and merges Supabase Auth metadata + local cache)
  /// to hydrate the actor's complete historical profile on every sign-in.
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
          // If the user already has a persisted row in `public.profiles` with
          // favorite_eras or username, mark onboarding completed unless explicitly false.
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

  /// Saves the "Red Carpet" Questionnaire selections (`favoriteEras`,
  /// `actingStrengths`, `birthYear`, `username`, and `aiTokenBalance`) to
  /// `public.profiles` and updates the global state immediately.
  Future<ActorProfileState> saveOnboardingQuestionnaire({
    required String username,
    required int birthYear,
    required List<String> favoriteEras,
    required List<String> actingStrengths,
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
        favoriteEras:
            favoriteEras.isEmpty ? const <String>['1970s', '2000s'] : favoriteEras,
        actingStrengths: actingStrengths.isEmpty
            ? const <String>['Drama']
            : actingStrengths,
        aiTokenBalance:
            initialAiTokens ?? current?.aiTokenBalance ?? kDefaultStarterAiTokens,
        unlockedScenePacks: current?.unlockedScenePacks ?? const <String>[],
        onboardingCompleted: true,
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

  /// Writes the full `ActorProfileState` to `public.profiles` in Supabase
  /// (falling back gracefully if optional extended columns are not yet present),
  /// syncs `auth.users` metadata, and persists to local SharedPreferences.
  Future<void> persistProfileToSupabaseAndCache(
    ActorProfileState profile,
  ) async {
    _currentProfile = profile;
    await _writeLocalProfile(profile);
    notifyListeners();

    if (!AppConfig.hasCloudSupabase) return;

    final client = Supabase.instance.client;

    // 1. Upsert into `public.profiles`. Try full extended payload first; if the
    // remote table only has the initial migration columns (id, username, birth_year),
    // automatically retry with the strict base schema so it never fails.
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
    } catch (_) {
      try {
        await client.from('profiles').upsert(<String, dynamic>{
          'id': profile.userId,
          'username': profile.username,
          'birth_year': profile.birthYear,
        }).timeout(const Duration(seconds: 5));
      } catch (innerError) {
        debugPrint('Supabase profiles base upsert notice: $innerError');
      }
    }

    // 2. Also persist questionnaire answers & token balance in Supabase Auth
    // userMetadata so multi-device sign-ins always recover 100% of fields.
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
                },
              ),
            )
            .timeout(const Duration(seconds: 5));
      } catch (metaError) {
        debugPrint('Supabase auth metadata sync notice: $metaError');
      }
    }
  }

  /// Deducts 1 AI Token prior to a Gemini AI Telemetrics call and persists the
  /// updated balance to Supabase `profiles`. Returns false if balance is 0.
  Future<bool> consumeAiToken() async {
    final profile = _currentProfile;
    if (profile == null) {
      return false;
    }
    if (profile.aiTokenBalance <= 0) {
      return false;
    }
    final updated = profile.copyWith(
      aiTokenBalance: profile.aiTokenBalance - 1,
      updatedAt: DateTime.now().toUtc(),
    );
    await persistProfileToSupabaseAndCache(updated);
    return true;
  }

  /// Adds AI Telemetrics tokens to the user's balance and persists to Supabase.
  Future<ActorProfileState?> topUpAiTokens(int amount) async {
    if (amount <= 0) return _currentProfile;
    final base = _currentProfile ??
        ActorProfileState(
          userId: 'local-s26-actor',
          email: 'actor@actlikeit.stage',
          username: 'Galaxy S26 Actor',
          birthYear: 1998,
          favoriteEras: const <String>['1970s', '2000s'],
          actingStrengths: const <String>['Drama'],
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

  /// Unlocks a premium Host-Pays Scene Pack (`emmy_vault`, `cult_classics`,
  /// `late_night`) and persists the unlock flag to Supabase.
  Future<ActorProfileState?> unlockScenePack(String packKey) async {
    final base = _currentProfile ??
        ActorProfileState(
          userId: 'local-s26-actor',
          email: 'actor@actlikeit.stage',
          username: 'Galaxy S26 Actor',
          birthYear: 1998,
          favoriteEras: const <String>['1970s', '2000s'],
          actingStrengths: const <String>['Drama'],
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
    return _currentProfile?.unlockedScenePacks.contains(packKey) ?? false;
  }

  /// Signs out from Supabase Auth while preserving the local profile record in
  /// SharedPreferences so historical data is never lost when offline.
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
