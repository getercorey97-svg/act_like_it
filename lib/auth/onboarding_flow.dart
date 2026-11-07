import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ui/boondocks_character_rig.dart';
import '../ui/soundstage_audio_controller.dart';
import 'auth_service.dart';

// ============================================================================
// UNIVERSAL MULTI-PROFILE SIGN-IN (COUCH & CROSS-INTERNET)
// ============================================================================
// 1. Cross-Internet Guest Flow (VipGuestOnboardingFlow):
//    Fast-tracks players joining via a 6-digit room code through a streamlined
//    "VIP Guest" setup: Stage Name, 18+ Verification toggle, and 2.5D Avatar
//    selection before entering the Green Room.
// 2. Couch Pass & Play Profile Switcher (LocalCastRosterBottomSheet):
//    Reads local `shared_preferences` (`saved_actor_profiles_v1`) to list all
//    previously created local Actor Profiles on the device and provides a
//    "+ Create New Local Actor" flow so Player 2 (and any additional couch
//    cast members) log stats to their own distinct ActorProfileState rather
//    than a generic "Player 2" placeholder.
// ============================================================================

class VipGuestOnboardingResult {
  final ActorProfileState profile;
  final String stageName;
  final bool is18PlusVerified;
  final String avatarArchetypeId;

  const VipGuestOnboardingResult({
    required this.profile,
    required this.stageName,
    required this.is18PlusVerified,
    required this.avatarArchetypeId,
  });
}

class VipGuestOnboardingFlow extends StatefulWidget {
  final String initialStageName;
  final String? roomCode;

  const VipGuestOnboardingFlow({
    super.key,
    this.initialStageName = '',
    this.roomCode,
  });

  /// Opens the "VIP Guest" fast-track modal before a cross-internet player
  /// joins a 6-digit room code so they confirm their Stage Name, 18+ status,
  /// and 2.5D Avatar before appearing in the Green Room.
  static Future<VipGuestOnboardingResult?> ensureVipGuestBeforeJoin(
    BuildContext context, {
    String initialName = '',
    String? roomCode,
  }) async {
    return showModalBottomSheet<VipGuestOnboardingResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => VipGuestOnboardingFlow(
        initialStageName: initialName,
        roomCode: roomCode,
      ),
    );
  }

  @override
  State<VipGuestOnboardingFlow> createState() => _VipGuestOnboardingFlowState();
}

class _VipGuestOnboardingFlowState extends State<VipGuestOnboardingFlow> {
  late final TextEditingController _stageNameController;
  bool _is18PlusVerified = true;
  late String _selectedAvatarId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final current = AuthService.instance.currentProfile;
    final seededName = widget.initialStageName.trim().isNotEmpty
        ? widget.initialStageName.trim()
        : (current != null && current.username.trim().isNotEmpty
            ? current.username.trim()
            : '');
    _stageNameController = TextEditingController(text: seededName);
    _is18PlusVerified = current?.is18PlusVerified ?? true;
    _selectedAvatarId =
        current != null && current.avatarArchetypeId.isNotEmpty
            ? current.avatarArchetypeId
            : kFourteenAvatarArchetypes.first.id;
  }

  @override
  void dispose() {
    _stageNameController.dispose();
    super.dispose();
  }

  Future<void> _confirmVipGuestSetup() async {
    if (_isSaving) return;
    final cleanName = _stageNameController.text.trim().isEmpty
        ? 'VIP_Guest_${DateTime.now().millisecondsSinceEpoch % 1000}'
        : _stageNameController.text.trim();
    final birthYear = _is18PlusVerified ? 1996 : 2010;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();
    SoundstageAudioController.instance.playClapperSnap();

    final updated = await AuthService.instance.upsertAdditiveProfileFields(
      username: cleanName,
      birthYear: birthYear,
      avatarArchetypeId: _selectedAvatarId,
    );

    if (!mounted) return;
    final resolvedProfile = updated ??
        AuthService.instance.currentProfile ??
        ActorProfileState(
          userId: 'vip_guest_${DateTime.now().millisecondsSinceEpoch % 10000}',
          email: 'vipguest@actlikeit.stage',
          username: cleanName,
          birthYear: birthYear,
          favoriteEras: const <String>['1970–1999', '2000–2026'],
          actingStrengths: const <String>['Method Drama', 'Improv Comedy'],
          aiTokenBalance: 25,
          unlockedScenePacks: const <String>[],
          onboardingCompleted: true,
          avatarArchetypeId: _selectedAvatarId,
          updatedAt: DateTime.now().toUtc(),
        );
    Navigator.of(context).pop(
      VipGuestOnboardingResult(
        profile: resolvedProfile,
        stageName: cleanName,
        is18PlusVerified: _is18PlusVerified,
        avatarArchetypeId: _selectedAvatarId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final roomBadge =
        (widget.roomCode != null && widget.roomCode!.trim().isNotEmpty)
            ? 'ROOM ${widget.roomCode!.trim().toUpperCase()}'
            : 'CROSS-INTERNET 6-DIGIT JOIN';

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight:
              (MediaQuery.sizeOf(context).height * 0.88).clamp(420.0, 760.0),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0E0B16),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.55),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.85),
              blurRadius: 32,
              spreadRadius: 4,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Text(
                        'VIP GUEST FAST-TRACK',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          roomBadge,
                          style: const TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white54,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Claim Your Stage Identity Before Entering Green Room',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Set your Stage Name, 18+ Vault clearance, and 2.5D Avatar so remote co-stars see your live persona on the Call Sheet.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _stageNameController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    labelText: 'STAGE NAME / CALL SHEET HANDLE',
                    labelStyle: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                    hintText: 'e.g. MethodMaverick',
                    hintStyle: const TextStyle(color: Colors.white30),
                    prefixIcon: const Icon(
                      Icons.theater_comedy_rounded,
                      color: Color(0xFFFFD700),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFFFD700),
                        width: 1.6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: _is18PlusVerified
                        ? const Color(0xFFFF1744).withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _is18PlusVerified
                          ? const Color(0xFFFF1744).withValues(alpha: 0.5)
                          : Colors.white24,
                    ),
                  ),
                  child: SwitchListTile(
                    value: _is18PlusVerified,
                    activeColor: const Color(0xFFFFD700),
                    activeTrackColor: const Color(0xFFFF1744),
                    title: const FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '18+ Rated-R / TV-MA Speakeasy Clearance',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      _is18PlusVerified
                          ? 'Verified 18+ Adult Cast Member · Full Uncensored Script Access'
                          : 'PG-13 Family-Friendly Filter Active',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      setState(() => _is18PlusVerified = val);
                    },
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'SELECT YOUR 2.5D STAGE AVATAR RIG',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 132,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: kFourteenAvatarArchetypes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, idx) {
                      final arch = kFourteenAvatarArchetypes[idx];
                      final isSelected = arch.id == _selectedAvatarId;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          SoundstageAudioController.instance.playSelectSweep();
                          setState(() => _selectedAvatarId = arch.id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 102,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? arch.rimAccentColor.withValues(alpha: 0.22)
                                : Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFFD700)
                                  : Colors.white12,
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BoondocksCharacterRig(
                                archetype: arch,
                                size: 54,
                                isSelected: isSelected,
                              ),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  arch.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFFFFD700)
                                        : Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  arch.roleBadge,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 8.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _confirmVipGuestSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.meeting_room_rounded, size: 20),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _isSaving
                            ? 'LOCKING VIP CREDENTIALS...'
                            : 'ENTER GREEN ROOM AS VIP GUEST',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.0,
                        ),
                      ),
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
// COUCH PASS & PLAY PROFILE SWITCHER (LOCAL CAST ROSTER BOTTOM SHEET)
// ============================================================================

class LocalCastRosterBottomSheet extends StatefulWidget {
  final String slotLabel;
  final bool switchActiveProfile;
  final Set<String> excludedUserIds;

  const LocalCastRosterBottomSheet({
    super.key,
    this.slotLabel = 'Player 2',
    this.switchActiveProfile = false,
    this.excludedUserIds = const <String>{},
  });

  /// Opens the `LocalCastRosterBottomSheet` which reads the local
  /// `shared_preferences` database (`saved_actor_profiles_v1`), lists all
  /// previously created profiles on the device, and includes a
  /// "+ Create New Local Actor" button so every local turn logs stats to a
  /// distinct user profile rather than a generic "Player 2".
  static Future<ActorProfileState?> show(
    BuildContext context, {
    String slotLabel = 'Player 2',
    bool switchActiveProfile = false,
    Set<String> excludedUserIds = const <String>{},
  }) async {
    return showModalBottomSheet<ActorProfileState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => LocalCastRosterBottomSheet(
        slotLabel: slotLabel,
        switchActiveProfile: switchActiveProfile,
        excludedUserIds: excludedUserIds,
      ),
    );
  }

  @override
  State<LocalCastRosterBottomSheet> createState() =>
      _LocalCastRosterBottomSheetState();
}

class _LocalCastRosterBottomSheetState
    extends State<LocalCastRosterBottomSheet> {
  List<ActorProfileState> _savedProfiles = const [];
  bool _isLoading = true;
  bool _showCreateNewActorForm = false;

  final TextEditingController _newStageNameController = TextEditingController();
  bool _newActor18Plus = true;
  String _newActorAvatarId = kFourteenAvatarArchetypes.length > 1
      ? kFourteenAvatarArchetypes[1].id
      : kFourteenAvatarArchetypes.first.id;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadSavedProfilesFromSharedPreferences();
  }

  @override
  void dispose() {
    _newStageNameController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedProfilesFromSharedPreferences() async {
    setState(() => _isLoading = true);
    final profiles = await AuthService.instance.loadSavedProfilesFromPrefs();
    if (!mounted) return;
    setState(() {
      _savedProfiles = profiles;
      _isLoading = false;
    });
  }

  Future<void> _handleSelectExistingProfile(ActorProfileState profile) async {
    HapticFeedback.mediumImpact();
    SoundstageAudioController.instance.playSelectSweep();
    if (widget.switchActiveProfile) {
      await AuthService.instance.switchToProfile(profile.userId);
    }
    if (!mounted) return;
    Navigator.of(context).pop(profile);
  }

  Future<void> _handleCreateNewLocalActor() async {
    if (_isCreating) return;
    final stageName = _newStageNameController.text.trim();
    if (stageName.isEmpty) return;

    setState(() => _isCreating = true);
    HapticFeedback.heavyImpact();
    SoundstageAudioController.instance.playClapperSnap();

    final createdProfile = await AuthService.instance.createLocalCastProfile(
      username: stageName,
      birthYear: _newActor18Plus ? 1996 : 2010,
      avatarArchetypeId: _newActorAvatarId,
      switchToNewProfile: widget.switchActiveProfile,
    );

    if (!mounted) return;
    Navigator.of(context).pop(createdProfile);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final activeHostId = AuthService.instance.currentProfile?.userId;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight:
              (MediaQuery.sizeOf(context).height * 0.88).clamp(420.0, 780.0),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0E0B16),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.55),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.88),
              blurRadius: 32,
              spreadRadius: 4,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
                        ),
                      ),
                      child: Text(
                        'COUCH PASS & PLAY · ${widget.slotLabel.toUpperCase()}',
                        style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white54,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Local Cast Roster · Select or Create Actor Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Every couch turn logs Career XP, Takes, and AI Telemetrics to a distinct saved profile on this device instead of a generic "Player 2".',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFD700),
                      ),
                    ),
                  )
                else ...[
                  const Text(
                    'SAVED PROFILES ON THIS DEVICE',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_savedProfiles.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Text(
                        'No local actor profiles saved yet. Tap "+ Create New Local Actor" below to register Player 2!',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _savedProfiles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final profile = _savedProfiles[index];
                          final arch = resolveAvatarArchetype(
                            profile.avatarArchetypeId,
                          );
                          final isCurrentHost =
                              activeHostId != null && profile.userId == activeHostId;
                          final isAlreadyInCast =
                              widget.excludedUserIds.contains(profile.userId);

                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => _handleSelectExistingProfile(profile),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrentHost
                                    ? const Color(0xFFFFD700)
                                        .withValues(alpha: 0.12)
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isCurrentHost
                                      ? const Color(0xFFFFD700)
                                          .withValues(alpha: 0.55)
                                      : Colors.white24,
                                ),
                              ),
                              child: Row(
                                children: [
                                  BoondocksCharacterRig(
                                    archetype: arch,
                                    size: 44,
                                    isSelected: isCurrentHost,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  profile.username,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (isCurrentHost) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFFD700)
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'PLAYER 1 HOST',
                                                  style: TextStyle(
                                                    color: Color(0xFFFFD700),
                                                    fontSize: 8.5,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            if (isAlreadyInCast &&
                                                !isCurrentHost) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF00E5FF)
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'ON CALL SHEET',
                                                  style: TextStyle(
                                                    color: Color(0xFF00E5FF),
                                                    fontSize: 8.5,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${arch.name} · ${profile.careerXp} XP · ${profile.careerRankBadge} · ${profile.is18PlusVerified ? "18+" : "PG-13"}',
                                          style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Color(0xFF00E5FF),
                                    size: 15,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _showCreateNewActorForm = !_showCreateNewActorForm;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFFD700),
                      side: const BorderSide(
                        color: Color(0xFFFFD700),
                        width: 1.4,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: Icon(
                      _showCreateNewActorForm
                          ? Icons.expand_less_rounded
                          : Icons.person_add_alt_1_rounded,
                      size: 18,
                    ),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '+ Create New Local Actor',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_showCreateNewActorForm) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NEW LOCAL ACTOR FOR ${widget.slotLabel.toUpperCase()}',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _newStageNameController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Stage Name (e.g. CinemaQueen)',
                            labelStyle: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            filled: true,
                            fillColor: Colors.black38,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _newActor18Plus,
                          activeColor: const Color(0xFFFFD700),
                          title: const Text(
                            '18+ Vault Clearance',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          onChanged: (val) =>
                              setState(() => _newActor18Plus = val),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Select 2.5D Avatar:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 108,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: kFourteenAvatarArchetypes.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, idx) {
                              final arch = kFourteenAvatarArchetypes[idx];
                              final selected = arch.id == _newActorAvatarId;
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _newActorAvatarId = arch.id);
                                },
                                child: Container(
                                  width: 86,
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? arch.rimAccentColor
                                            .withValues(alpha: 0.22)
                                        : Colors.black26,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: selected
                                          ? const Color(0xFFFFD700)
                                          : Colors.white12,
                                      width: selected ? 2.0 : 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      BoondocksCharacterRig(
                                        archetype: arch,
                                        size: 44,
                                        isSelected: selected,
                                      ),
                                      const SizedBox(height: 4),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          arch.name,
                                          style: TextStyle(
                                            color: selected
                                                ? const Color(0xFFFFD700)
                                                : Colors.white,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: _isCreating
                                ? null
                                : _handleCreateNewLocalActor,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E5FF),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                            ),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _isCreating
                                    ? 'SAVING PROFILE...'
                                    : 'SAVE & ASSIGN TO ${widget.slotLabel.toUpperCase()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
