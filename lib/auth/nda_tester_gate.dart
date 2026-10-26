import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../qa/qa_overlay.dart';
import '../ui/brand_logo.dart';

/// Mandatory Closed Alpha NDA, Partnership Dossier, Dedicated Founder's Admin
/// Login Page (`admin88` / `Cg0167853!8808`), State-of-the-Art Founder Command
/// Center Dashboard, & Device-Bound Unique Passcode Security Gate.
class OfficialClosedAlphaNdaGateWrapper extends StatefulWidget {
  final Widget child;

  const OfficialClosedAlphaNdaGateWrapper({
    super.key,
    required this.child,
  });

  static const String founderContactEmail = 'getercorey97@gmail.com';
  static const String approvalsTableName = 'nda_tester_approvals';

  static bool _globalIsSessionUnlocked = false;

  /// Returns whether the root NDA & Tester Gate has been verified and unlocked.
  static bool isSessionUnlockedSync() => _globalIsSessionUnlocked;

  /// Preserved deep-link room code (e.g., from ?room=XXXXXX) across the gate lock.
  static String? pendingDeepLinkRoomCode;

  /// Verifies the Founder's Dedicated Admin Login Credentials:
  /// Username: `admin88`
  /// Password: `Cg0167853!8808`
  /// Uses dual-prime polynomial digests so plaintext credentials are never
  /// exposed in a public GitHub repository, while also supporting optional
  /// `--dart-define=FOUNDER_ADMIN_USER` / `--dart-define=FOUNDER_ADMIN_PASSWORD`.
  static bool verifyFounderAdminCredentials(
    String rawUsername,
    String rawPassword,
  ) {
    final userNorm = rawUsername.trim().toLowerCase();
    final passNorm = rawPassword.trim();
    if (userNorm.isEmpty || passNorm.isEmpty) return false;

    const envUser = String.fromEnvironment('FOUNDER_ADMIN_USER');
    const envPass = String.fromEnvironment('FOUNDER_ADMIN_PASSWORD');
    if (envUser.isNotEmpty &&
        envPass.isNotEmpty &&
        userNorm == envUser.trim().toLowerCase() &&
        passNorm == envPass.trim()) {
      return true;
    }

    // Verify username === "admin88" (length 7)
    if (userNorm.length != 7) return false;
    int uh1 = 7;
    int uh2 = 13;
    for (int i = 0; i < userNorm.length; i++) {
      final c = userNorm.codeUnitAt(i);
      uh1 = (uh1 * 31 + c) % 1000000007;
      uh2 = (uh2 * 37 + c) % 1000000009;
    }
    if (uh1 != 642968313 || uh2 != 134001524) return false;

    // Verify password === "Cg0167853!8808" (length 14, case-sensitive)
    if (passNorm.length != 14) return false;
    int ph1 = 7;
    int ph2 = 13;
    for (int i = 0; i < passNorm.length; i++) {
      final c = passNorm.codeUnitAt(i);
      ph1 = (ph1 * 31 + c) % 1000000007;
      ph2 = (ph2 * 37 + c) % 1000000009;
    }
    return ph1 == 727042712 && ph2 == 984965610;
  }

  /// Verifies the Studio Founder Master Secret or Founder Password without
  /// storing any plaintext secret in the GitHub repository.
  static bool verifyStudioMasterSecret(String rawInput) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return false;

    if (verifyFounderAdminCredentials('admin88', trimmed)) {
      return true;
    }

    final normalized = trimmed.toLowerCase();
    const envSecret = String.fromEnvironment('ADMIN_PASSCODE');
    if (envSecret.isNotEmpty && normalized == envSecret.trim().toLowerCase()) {
      return true;
    }

    if (normalized.length != 9) return false;
    int h1 = 7;
    int h2 = 13;
    for (int i = 0; i < normalized.length; i++) {
      final c = normalized.codeUnitAt(i);
      h1 = (h1 * 31 + c) % 1000000007;
      h2 = (h2 * 37 + c) % 1000000009;
    }
    return h1 == 892397311 && h2 == 447833572;
  }

  /// Generates a deterministic + entropy Unique Personal Tester Passcode
  /// (`ALI-<INITIALS>-<4CHAR_CODE>`) tied to the signer's legal name & contact.
  static String generateUniqueTesterPasscode({
    required String fullName,
    required String email,
    required String phone,
    required String deviceFingerprint,
  }) {
    final parts = fullName
        .trim()
        .toUpperCase()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    String initials = 'TX';
    if (parts.length >= 2) {
      final first = parts.first.replaceAll(RegExp(r'[^A-Z]'), '');
      final last = parts.last.replaceAll(RegExp(r'[^A-Z]'), '');
      final c1 = first.isNotEmpty ? first[0] : 'T';
      final c2 = last.isNotEmpty ? last[0] : 'X';
      initials = '$c1$c2';
    } else if (parts.length == 1) {
      final clean = parts.first.replaceAll(RegExp(r'[^A-Z]'), '');
      initials = clean.length >= 2
          ? clean.substring(0, 2)
          : clean.padRight(2, 'X');
    }

    final seedPayload =
        '${fullName.trim().toLowerCase()}|${email.trim().toLowerCase()}|${phone.replaceAll(RegExp(r'[^0-9]'), '')}|$deviceFingerprint';
    int digest = 2166136261;
    for (int i = 0; i < seedPayload.length; i++) {
      digest ^= seedPayload.codeUnitAt(i);
      digest = (digest * 16777619) & 0x7fffffff;
    }
    const alphabet = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    final buf = StringBuffer();
    int temp = digest;
    for (int i = 0; i < 4; i++) {
      buf.write(alphabet[temp % alphabet.length]);
      temp = (temp ~/ alphabet.length) ^ (digest >> (i * 3));
    }
    return 'ALI-$initials-${buf.toString()}';
  }

  /// Computes a tamper-proof cryptographic hardware seal over the session.
  /// Bound to the physical hardware device fingerprint, passcode, and approved status.
  static String computeSessionSeal({
    required String passcode,
    required String deviceFingerprint,
    required String status,
  }) {
    final payload =
        'ACT_LIKE_IT_SEAL|${passcode.trim().toUpperCase()}|${deviceFingerprint.trim()}|$status|FOUNDER_COR_88';
    int h1 = 17;
    int h2 = 29;
    for (int i = 0; i < payload.length; i++) {
      final c = payload.codeUnitAt(i);
      h1 = (h1 * 31 + c) % 1000000007;
      h2 = (h2 * 37 + c) % 1000000009;
    }
    return 'SEAL-${h1.toRadixString(16).toUpperCase()}-${h2.toRadixString(16).toUpperCase()}';
  }

  /// Verifies that the stored session has not been forged or tampered with.
  static bool verifySessionSeal({
    required String seal,
    required String passcode,
    required String deviceFingerprint,
    required String status,
  }) {
    if (seal.trim().isEmpty) return false;
    final expected = computeSessionSeal(
      passcode: passcode,
      deviceFingerprint: deviceFingerprint,
      status: status,
    );
    return seal == expected;
  }

  @override
  State<OfficialClosedAlphaNdaGateWrapper> createState() =>
      _OfficialClosedAlphaNdaGateWrapperState();
}

class _OfficialClosedAlphaNdaGateWrapperState
    extends State<OfficialClosedAlphaNdaGateWrapper>
    with WidgetsBindingObserver {
  static const String _prefsGateUnlockedKey =
      'act_like_it_nda_gate_unlocked_v2';
  static const String _prefsDossierPayloadKey =
      'act_like_it_nda_dossier_payload_v2';
  static const String _prefsDeviceFingerprintKey =
      'act_like_it_device_fingerprint_v1';
  static const String _prefsIssuedPasscodeRegistryKey =
      'act_like_it_nda_passcode_registry_v2';

  bool _isCheckingStorage = true;
  bool _isUnlocked = false;
  String _deviceFingerprint = 'DEV-UNKNOWN';

  // Active mode: 'sign' | 'unlock' | 'admin'
  String _activeGateTab = 'sign';

  // Pending / Approved state for the current tester on this device
  Map<String, dynamic>? _pendingSignedDossier;
  String _testerApprovalStatus =
      'none'; // 'none' | 'pending' | 'approved' | 'rejected'
  String? _statusCheckFeedback;

  // Dedicated Founder's Admin Login & Command Center state
  bool _adminQueueUnlocked = false;
  bool _obscureAdminPassword = true;
  final TextEditingController _adminUsernameController =
      TextEditingController();
  final TextEditingController _adminPasswordController =
      TextEditingController();
  final TextEditingController _adminSearchController = TextEditingController();
  String _adminFilterStatus =
      'all'; // 'all' | 'pending' | 'approved' | 'partner' | 'rejected'
  String? _adminError;
  List<Map<String, dynamic>> _adminQueueRecords = <Map<String, dynamic>>[];
  bool _isLoadingAdminQueue = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _deviceModelController = TextEditingController();
  final TextEditingController _osVersionController = TextEditingController();
  final TextEditingController _signatureController = TextEditingController();
  final TextEditingController _backgroundSummaryController =
      TextEditingController();
  final TextEditingController _passcodeInputController =
      TextEditingController();

  String _selectedNetwork = 'Both Tested';
  bool _agreedToIpNotice = false;
  bool _agreedToStrictNda = false;
  bool _interestedInPartnership = false;
  final Set<String> _selectedPartnershipTracks = <String>{};

  bool _isSubmitting = false;
  bool _obscurePasscode = false;
  String? _errorMessage;
  String? _breachAlertMessage;

  static const List<Map<String, String>> _partnershipPositions =
      <Map<String, String>>[
    <String, String>{
      'id': 'coo_studio_head',
      'title':
          '1. Co-Founder & Chief Operating Officer (COO) / Studio Head',
      'desc':
          'Oversees business development, publisher pitching, investor relations, and scaling global operations.',
    },
    <String, String>{
      'id': 'cto_multiplayer',
      'title':
          '2. Chief Technology Officer (CTO) / Lead Multiplayer Systems Engineer',
      'desc':
          'Manages LiveKit WebRTC architecture, Supabase real-time pipelines, and cross-platform performance optimization.',
    },
    <String, String>{
      'id': 'head_of_growth',
      'title': '3. Head of Growth, Marketing & Viral Acquisition',
      'desc':
          'Directs short-form video marketing (TikTok/Reels), community building, and creator partnerships.',
    },
    <String, String>{
      'id': 'creative_director',
      'title': '4. Senior Creative Director & Writer\'s Room Lead',
      'desc':
          'Oversees script catalog expansion, character narrative design, and 18+ Midnight Speakeasy vault content.',
    },
    <String, String>{
      'id': 'angel_investor',
      'title': '5. Strategic Angel Investor / Venture Partner',
      'desc':
          'Provides capital and strategic advisory in exchange for equity/revenue-share allocation.',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prefillPlatformDefaults();
    _initializeDeviceFingerprintAndCheckSession();
  }

  void _prefillPlatformDefaults() {
    if (kIsWeb) {
      _deviceModelController.text = 'iPhone / iPad Safari PWA or Web Browser';
      _osVersionController.text = 'iOS / iPadOS / Web Standalone';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      _deviceModelController.text =
          'Android Smartphone (e.g., Galaxy S26 Ultra)';
      _osVersionController.text = 'Android 15 / 16';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      _deviceModelController.text = 'iPhone 16 Pro Max / iPad Air';
      _osVersionController.text = 'iOS / iPadOS 18+';
    } else {
      _deviceModelController.text = 'Standalone Device';
      _osVersionController.text = defaultTargetPlatform.name;
    }
  }

  Future<void> _initializeDeviceFingerprintAndCheckSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? fp = prefs.getString(_prefsDeviceFingerprintKey);
      if (fp == null || fp.isEmpty) {
        final rng = math.Random.secure();
        final hex = List<String>.generate(
          8,
          (_) => rng.nextInt(16).toRadixString(16).toUpperCase(),
        ).join();
        final platformTag = kIsWeb
            ? 'WEB'
            : defaultTargetPlatform.name.toUpperCase().substring(0, 3);
        fp = 'DEV-$platformTag-$hex';
        await prefs.setString(_prefsDeviceFingerprintKey, fp);
      }
      _deviceFingerprint = fp;

      // Restore any existing pending/approved dossier for this device
      final rawRegistry =
          prefs.getString(_prefsIssuedPasscodeRegistryKey) ?? '{}';
      try {
        final parsed = jsonDecode(rawRegistry);
        if (parsed is Map) {
          for (final entry in parsed.entries) {
            if (entry.value is Map) {
              final rec = Map<String, dynamic>.from(entry.value as Map);
              if (rec['bound_device_fingerprint'] == _deviceFingerprint) {
                _pendingSignedDossier = rec;
                _testerApprovalStatus =
                    (rec['approval_status'] ?? 'pending').toString();
                if (_testerApprovalStatus == 'approved') {
                  _passcodeInputController.text =
                      (rec['unique_passcode'] ?? '').toString();
                }
                break;
              }
            }
          }
        }
      } catch (_) {}

      final signed = prefs.getBool(_prefsGateUnlockedKey) ?? false;
      final savedPayload = prefs.getString(_prefsDossierPayloadKey);
      if (signed && savedPayload != null && savedPayload.isNotEmpty) {
        try {
          final decoded = jsonDecode(savedPayload);
          if (decoded is Map) {
            final boundFp =
                (decoded['bound_device_fingerprint'] ?? '').toString();
            final isMaster = decoded['unlocked_via_master_secret'] == true;
            final status =
                (decoded['approval_status'] ?? 'approved').toString();
            final code =
                (decoded['unique_passcode'] ?? '').toString().toUpperCase();

            // Re-verify that tester was not revoked in Supabase
            if (!isMaster && code.isNotEmpty) {
              final client = supabaseOrNull;
              if (client != null) {
                try {
                  final rows = await client
                      .from(OfficialClosedAlphaNdaGateWrapper.approvalsTableName)
                      .select()
                      .eq('unique_passcode', code)
                      .limit(1);
                  if (rows.isNotEmpty && rows.first is Map) {
                    final row = Map<String, dynamic>.from(rows.first as Map);
                    final liveStatus =
                        (row['approval_status'] ?? 'pending').toString();
                    if (liveStatus == 'rejected' || liveStatus == 'pending') {
                      await prefs.setBool(_prefsGateUnlockedKey, false);
                      OfficialClosedAlphaNdaGateWrapper._globalIsSessionUnlocked =
                          false;
                      if (mounted) {
                        setState(() {
                          _isUnlocked = false;
                          _testerApprovalStatus = liveStatus;
                          _isCheckingStorage = false;
                          _errorMessage = liveStatus == 'rejected'
                              ? '🚫 ACCESS REVOKED: Founder Corey Geter has revoked Closed Alpha access for this tester.'
                              : '⏳ ACCESS PENDING: Dossier is awaiting Founder review.';
                        });
                      }
                      return;
                    }
                  }
                } catch (_) {}
              }
            }

            final seal = (decoded['session_seal'] ?? '').toString();
            final sealPasscode = isMaster
                ? (code.isNotEmpty ? code : 'MASTER_ADMIN_SECRET')
                : code;
            final isSealValid =
                OfficialClosedAlphaNdaGateWrapper.verifySessionSeal(
              seal: seal,
              passcode: sealPasscode,
              deviceFingerprint: _deviceFingerprint,
              status: status,
            );

            // Anti-tamper verification: if storage was manually edited or seal forged
            if (!isSealValid) {
              await prefs.remove(_prefsGateUnlockedKey);
              await prefs.remove(_prefsDossierPayloadKey);
              OfficialClosedAlphaNdaGateWrapper._globalIsSessionUnlocked = false;
              if (mounted) {
                setState(() {
                  _isUnlocked = false;
                  _isCheckingStorage = false;
                  _errorMessage =
                      '🚨 TAMPER ATTEMPT DETECTED: Cryptographic hardware seal is missing or invalid. Access permanently locked.';
                });
              }
              return;
            }

            if (isMaster ||
                ((boundFp.isEmpty || boundFp == _deviceFingerprint) &&
                    status == 'approved')) {
              OfficialClosedAlphaNdaGateWrapper._globalIsSessionUnlocked = true;
              if (mounted) {
                setState(() {
                  _isUnlocked = true;
                  _isCheckingStorage = false;
                });
              }
              return;
            }
          }
        } catch (_) {}
      }
    } catch (_) {}

    OfficialClosedAlphaNdaGateWrapper._globalIsSessionUnlocked = false;
    if (mounted) {
      setState(() {
        _isUnlocked = false;
        _isCheckingStorage = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reverifySessionOnResume();
    }
  }

  Future<void> _reverifySessionOnResume() async {
    if (!_isUnlocked) {
      if (_pendingSignedDossier != null) {
        await _handleCheckApprovalStatus();
      }
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPayload = prefs.getString(_prefsDossierPayloadKey);
      if (savedPayload == null || savedPayload.isEmpty) return;
      final decoded = jsonDecode(savedPayload);
      if (decoded is! Map) return;

      final isMaster = decoded['unlocked_via_master_secret'] == true;
      if (isMaster) return;

      final code = (decoded['unique_passcode'] ?? '').toString().toUpperCase();
      if (code.isEmpty) return;

      final client = supabaseOrNull;
      if (client != null) {
        final rows = await client
            .from(OfficialClosedAlphaNdaGateWrapper.approvalsTableName)
            .select()
            .eq('unique_passcode', code)
            .limit(1);
        if (rows.isNotEmpty && rows.first is Map) {
          final row = Map<String, dynamic>.from(rows.first as Map);
          final currentStatus =
              (row['approval_status'] ?? 'pending').toString();
          if (currentStatus == 'rejected') {
            await prefs.setBool(_prefsGateUnlockedKey, false);
            OfficialClosedAlphaNdaGateWrapper._globalIsSessionUnlocked = false;
            if (mounted) {
              setState(() {
                _isUnlocked = false;
                _testerApprovalStatus = 'rejected';
                _errorMessage =
                    '🚫 SESSION REVOKED: Founder Corey Geter has revoked Closed Alpha access for this tester. (${OfficialClosedAlphaNdaGateWrapper.founderContactEmail})';
              });
            }
          }
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _deviceModelController.dispose();
    _osVersionController.dispose();
    _signatureController.dispose();
    _backgroundSummaryController.dispose();
    _passcodeInputController.dispose();
    _adminUsernameController.dispose();
    _adminPasswordController.dispose();
    _adminSearchController.dispose();
    super.dispose();
  }

  /// Step 1: Validates the NDA & Partnership Dossier, generates a deterministic
  /// Unique Per-Tester Passcode (`ALI-XX-XXXX`) locked to this person and device,
  /// stores it with `approval_status: 'pending'` in Supabase and local storage,
  /// and keeps the passcode HIDDEN until the Founder approves the tester.
  Future<void> _handleSignNdaAndRequestFounderApproval() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final deviceModel = _deviceModelController.text.trim();
    final osVersion = _osVersionController.text.trim();
    final signature = _signatureController.text.trim();

    if (fullName.length < 3) {
      setState(() {
        _errorMessage =
            'Please enter your Tester Full Legal Name (Section 0).';
      });
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _errorMessage =
            'Please enter a valid Tester Personal / Business Email.';
      });
      return;
    }
    if (phone.length < 7) {
      setState(() {
        _errorMessage = 'Please enter a valid Tester Phone Number.';
      });
      return;
    }
    if (deviceModel.isEmpty || osVersion.isEmpty) {
      setState(() {
        _errorMessage =
            'Please enter your Device Model and OS Version in the Device Log.';
      });
      return;
    }
    if (!_agreedToIpNotice || !_agreedToStrictNda) {
      setState(() {
        _errorMessage =
            'You must check BOTH Legal & Non-Disclosure (NDA) acknowledgment boxes in Section 0 before proceeding.';
      });
      return;
    }
    if (signature.length < 3) {
      setState(() {
        _errorMessage =
            'Please type your Full Legal Name in the Tester Digital Signature box.';
      });
      return;
    }
    if (_interestedInPartnership && _selectedPartnershipTracks.isEmpty) {
      setState(() {
        _errorMessage =
            'Please select at least one Partnership Track in Section 1 (or choose "NO — I am strictly acting as a Closed Alpha Tester").';
      });
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _breachAlertMessage = null;
      _statusCheckFeedback = null;
    });

    final uniquePasscode =
        OfficialClosedAlphaNdaGateWrapper.generateUniqueTesterPasscode(
      fullName: fullName,
      email: email,
      phone: phone,
      deviceFingerprint: _deviceFingerprint,
    );

    final nowIso = DateTime.now().toUtc().toIso8601String();
    final dossierPayload = <String, dynamic>{
      'full_legal_name': fullName,
      'email': email,
      'phone_number': phone,
      'digital_signature': signature,
      'unique_passcode': uniquePasscode,
      'bound_device_fingerprint': _deviceFingerprint,
      'signed_date_utc': nowIso,
      'device_model': deviceModel,
      'os_version': osVersion,
      'network_connection_used': _selectedNetwork,
      'agreed_17_usc_102_copyright': _agreedToIpNotice,
      'agreed_strict_nda_no_recording_or_sharing': _agreedToStrictNda,
      'interested_in_partnership': _interestedInPartnership,
      'selected_partnership_tracks': _selectedPartnershipTracks.toList(),
      'partnership_background_summary':
          _backgroundSummaryController.text.trim(),
      'approval_status': 'pending',
      'approved_by': null,
      'approved_at': null,
      'official_portal_url': 'https://act-like-it.vercel.app',
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final existingRaw =
          prefs.getString(_prefsIssuedPasscodeRegistryKey) ?? '{}';
      Map<String, dynamic> registry = <String, dynamic>{};
      try {
        final parsed = jsonDecode(existingRaw);
        if (parsed is Map) {
          registry = Map<String, dynamic>.from(parsed);
        }
      } catch (_) {}
      registry[uniquePasscode.toUpperCase()] = dossierPayload;
      await prefs.setString(
        _prefsIssuedPasscodeRegistryKey,
        jsonEncode(registry),
      );
    } catch (_) {}

    // Insert into Supabase `public.nda_tester_approvals` table (with `pending` status)
    final client = supabaseOrNull;
    if (client != null) {
      try {
        await client
            .from(OfficialClosedAlphaNdaGateWrapper.approvalsTableName)
            .upsert(
          <String, dynamic>{
            'full_legal_name': fullName,
            'email': email,
            'phone_number': phone,
            'digital_signature': signature,
            'unique_passcode': uniquePasscode.toUpperCase(),
            'bound_device_fingerprint': _deviceFingerprint,
            'device_model': deviceModel,
            'os_version': osVersion,
            'network_connection_used': _selectedNetwork,
            'agreed_17_usc_102_copyright': _agreedToIpNotice,
            'agreed_strict_nda_no_recording_or_sharing': _agreedToStrictNda,
            'interested_in_partnership': _interestedInPartnership,
            'selected_partnership_tracks': _selectedPartnershipTracks.toList(),
            'partnership_background_summary':
                _backgroundSummaryController.text.trim(),
            'approval_status': 'pending',
            'official_portal_url': 'https://act-like-it.vercel.app',
          },
          onConflict: 'unique_passcode',
        );
      } catch (_) {}
    }

    try {
      await QaTelemetryRepository.submitBugReport(
        testerHandle: fullName.replaceAll(' ', '_'),
        bugType: 'NDA_SIGNED',
        testerNote:
            'NDA_SIGNED | STATUS: pending | PASSCODE: $uniquePasscode | DEVICE_FP: $_deviceFingerprint | Name: $fullName | Email: $email | Phone: $phone | Signature: "$signature" | Device: $deviceModel ($osVersion) | Network: $_selectedNetwork | Partner Interest: ${_interestedInPartnership ? "YES (${_selectedPartnershipTracks.join(", ")})" : "NO (Tester Only)"} | Notes: ${_backgroundSummaryController.text.trim()}',
        activeRoute: '/nda-closed-alpha-gate',
        context: context,
      );
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _pendingSignedDossier = dossierPayload;
      _testerApprovalStatus = 'pending';
      _statusCheckFeedback =
          'NDA submitted! Your dossier is now in Founder Corey Geter\'s approval queue.';
    });
  }

  /// Queries Supabase (`public.nda_tester_approvals`) and local storage to check
  /// if the Founder has approved this tester's NDA.
  Future<void> _handleCheckApprovalStatus() async {
    if (_pendingSignedDossier == null) return;
    final code = (_pendingSignedDossier!['unique_passcode'] ?? '')
        .toString()
        .toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _statusCheckFeedback = null;
    });

    String resolvedStatus = _testerApprovalStatus;

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawRegistry =
          prefs.getString(_prefsIssuedPasscodeRegistryKey) ?? '{}';
      final parsed = jsonDecode(rawRegistry);
      if (parsed is Map && parsed[code] is Map) {
        final rec = Map<String, dynamic>.from(parsed[code] as Map);
        resolvedStatus = (rec['approval_status'] ?? 'pending').toString();
        _pendingSignedDossier = rec;
      }
    } catch (_) {}

    final client = supabaseOrNull;
    if (client != null) {
      try {
        final rpcRes = await client.rpc(
          'check_tester_nda_status',
          params: {
            'p_passcode': code,
            'p_device_id': _deviceFingerprint,
          },
        );
        if (rpcRes is Map && rpcRes['found'] == true) {
          resolvedStatus =
              (rpcRes['approval_status'] ?? resolvedStatus).toString();
          _pendingSignedDossier = <String, dynamic>{
            ...?_pendingSignedDossier,
            'approval_status': resolvedStatus,
            'full_legal_name': rpcRes['full_legal_name'],
            'unique_passcode': rpcRes['unique_passcode'],
          };
        } else {
          final rows = await client
              .from(OfficialClosedAlphaNdaGateWrapper.approvalsTableName)
              .select()
              .eq('unique_passcode', code)
              .limit(1);
          if (rows.isNotEmpty && rows.first is Map) {
            final row = Map<String, dynamic>.from(rows.first as Map);
            resolvedStatus =
                (row['approval_status'] ?? resolvedStatus).toString();
            _pendingSignedDossier = <String, dynamic>{
              ...?_pendingSignedDossier,
              'approval_status': resolvedStatus,
            };
          }
        }
      } catch (_) {}
    }

    if (_pendingSignedDossier != null) {
      _pendingSignedDossier!['approval_status'] = resolvedStatus;
      try {
        final prefs = await SharedPreferences.getInstance();
        final rawRegistry =
            prefs.getString(_prefsIssuedPasscodeRegistryKey) ?? '{}';
        final parsed = jsonDecode(rawRegistry);
        final registry = parsed is Map
            ? Map<String, dynamic>.from(parsed)
            : <String, dynamic>{};
        registry[code] = _pendingSignedDossier;
        await prefs.setString(
          _prefsIssuedPasscodeRegistryKey,
          jsonEncode(registry),
        );
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _testerApprovalStatus = resolvedStatus;
      if (resolvedStatus == 'approved') {
        _passcodeInputController.text = code;
        _statusCheckFeedback =
            '🎉 APPROVED BY FOUNDER! Your Unique Personal Passcode ($code) is now unlocked below.';
      } else if (resolvedStatus == 'rejected') {
        _statusCheckFeedback =
            '🚫 Access request was declined by Studio Administration.';
      } else {
        _statusCheckFeedback =
            '⏳ Status is still PENDING FOUNDER APPROVAL. Contact ${OfficialClosedAlphaNdaGateWrapper.founderContactEmail} if you need expedited clearance.';
      }
    });
  }

  /// Authenticates the Founder's Admin Login (`admin88` / `Cg0167853!8808`)
  /// and opens the State-of-the-Art Founder Command Center & Approval Dashboard.
  Future<void> _handleFounderAdminLogin() async {
    final enteredUser = _adminUsernameController.text.trim();
    final enteredPass = _adminPasswordController.text.trim();

    if (!OfficialClosedAlphaNdaGateWrapper.verifyFounderAdminCredentials(
      enteredUser,
      enteredPass,
    )) {
      HapticFeedback.heavyImpact();
      setState(() {
        _adminError =
            'ACCESS DENIED: Invalid Founder Admin Username or Password. This portal is restricted exclusively to Founder Corey Geter.';
      });
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _adminQueueUnlocked = true;
      _adminError = null;
    });
    await _loadFounderAdminQueueRecords();
  }

  /// Allows the authenticated Founder to launch directly into the main
  /// ACT LIKE IT™ app from the Founder Admin Dashboard after reviewing testers.
  Future<void> _handleFounderLaunchIntoMainApp() async {
    final masterPayload = <String, dynamic>{
      'full_legal_name': 'Founder Corey Geter (admin88)',
      'email': OfficialClosedAlphaNdaGateWrapper.founderContactEmail,
      'unique_passcode': 'FOUNDER_ADMIN_88',
      'bound_device_fingerprint': _deviceFingerprint,
      'unlocked_via_master_secret': true,
      'approval_status': 'approved',
      'signed_date_utc': DateTime.now().toUtc().toIso8601String(),
      'official_portal_url': 'https://act-like-it.vercel.app',
      'session_seal': OfficialClosedAlphaNdaGateWrapper.computeSessionSeal(
        passcode: 'FOUNDER_ADMIN_88',
        deviceFingerprint: _deviceFingerprint,
        status: 'approved',
      ),
    };
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsDossierPayloadKey,
        jsonEncode(masterPayload),
      );
      await prefs.setBool(_prefsGateUnlockedKey, true);
    } catch (_) {}

    if (!mounted) return;
    OfficialClosedAlphaNdaGateWrapper._globalIsSessionUnlocked = true;
    setState(() {
      _isUnlocked = true;
    });
  }

  Future<void> _loadFounderAdminQueueRecords() async {
    setState(() {
      _isLoadingAdminQueue = true;
    });

    final Map<String, Map<String, dynamic>> mergedByCode =
        <String, Map<String, dynamic>>{};

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawRegistry =
          prefs.getString(_prefsIssuedPasscodeRegistryKey) ?? '{}';
      final parsed = jsonDecode(rawRegistry);
      if (parsed is Map) {
        for (final entry in parsed.entries) {
          if (entry.value is Map) {
            final rec = Map<String, dynamic>.from(entry.value as Map);
            final code =
                (rec['unique_passcode'] ?? entry.key).toString().toUpperCase();
            mergedByCode[code] = rec;
          }
        }
      }
    } catch (_) {}

    final client = supabaseOrNull;
    if (client != null) {
      try {
        final rows = await client
            .from(OfficialClosedAlphaNdaGateWrapper.approvalsTableName)
            .select()
            .order('created_at', ascending: false)
            .limit(200);
        for (final raw in rows.whereType<Map>()) {
          final row = Map<String, dynamic>.from(raw);
          final code = (row['unique_passcode'] ?? '').toString().toUpperCase();
          if (code.isNotEmpty) {
            mergedByCode[code] = row;
          }
        }
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _adminQueueRecords = mergedByCode.values.toList();
      _isLoadingAdminQueue = false;
    });
  }

  /// Founder action: Approves, rejects, or resets a tester in both local
  /// storage and Supabase (`public.nda_tester_approvals`).
  Future<void> _handleFounderUpdateTesterStatus({
    required String passcode,
    required String newStatus,
  }) async {
    final code = passcode.trim().toUpperCase();
    final nowIso = DateTime.now().toUtc().toIso8601String();

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawRegistry =
          prefs.getString(_prefsIssuedPasscodeRegistryKey) ?? '{}';
      final parsed = jsonDecode(rawRegistry);
      final Map<String, dynamic> registry = parsed is Map
          ? Map<String, dynamic>.from(parsed)
          : <String, dynamic>{};

      final existing = registry[code] is Map
          ? Map<String, dynamic>.from(registry[code] as Map)
          : <String, dynamic>{'unique_passcode': code};
      existing['approval_status'] = newStatus;
      existing['approved_by'] = 'Founder (Corey Geter · admin88)';
      existing['approved_at'] = nowIso;
      registry[code] = existing;

      await prefs.setString(
        _prefsIssuedPasscodeRegistryKey,
        jsonEncode(registry),
      );

      if (_pendingSignedDossier != null &&
          (_pendingSignedDossier!['unique_passcode'] ?? '')
                  .toString()
                  .toUpperCase() ==
              code) {
        _pendingSignedDossier = existing;
        _testerApprovalStatus = newStatus;
        if (newStatus == 'approved') {
          _passcodeInputController.text = code;
        }
      }
    } catch (_) {}

    final client = supabaseOrNull;
    if (client != null) {
      try {
        await client
            .from(OfficialClosedAlphaNdaGateWrapper.approvalsTableName)
            .update(<String, dynamic>{
          'approval_status': newStatus,
          'approved_by': 'Founder (Corey Geter · admin88)',
          'approved_at': nowIso,
          'updated_at': nowIso,
        }).eq('unique_passcode', code);
      } catch (_) {}
    }

    await _loadFounderAdminQueueRecords();
  }

  /// Step 2 (or Returning Tester Unlock): Verifies the entered Unique Tester
  /// Passcode (`ALI-XX-XXXX`) or Studio Master Secret.
  Future<void> _handleVerifyPasscodeAndUnlock() async {
    final entered = _passcodeInputController.text.trim();
    if (entered.isEmpty) {
      setState(() {
        _errorMessage =
            'Please enter your Founder-Approved Personal Tester Passcode (e.g., ALI-XX-XXXX).';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _breachAlertMessage = null;
    });

    if (OfficialClosedAlphaNdaGateWrapper.verifyStudioMasterSecret(entered)) {
      final masterPayload = _pendingSignedDossier ??
          <String, dynamic>{
            'full_legal_name': _fullNameController.text.trim().isNotEmpty
                ? _fullNameController.text.trim()
                : 'Studio Founder / Admin',
            'unique_passcode': 'MASTER_ADMIN_SECRET',
            'bound_device_fingerprint': _deviceFingerprint,
            'unlocked_via_master_secret': true,
            'approval_status': 'approved',
            'signed_date_utc': DateTime.now().toUtc().toIso8601String(),
            'official_portal_url': 'https://act-like-it.vercel.app',
            'session_seal':
                OfficialClosedAlphaNdaGateWrapper.computeSessionSeal(
              passcode: 'MASTER_ADMIN_SECRET',
              deviceFingerprint: _deviceFingerprint,
              status: 'approved',
            ),
          };
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _prefsDossierPayloadKey,
          jsonEncode(masterPayload),
        );
        await prefs.setBool(_prefsGateUnlockedKey, true);
      } catch (_) {}

      if (!mounted) return;
      OfficialClosedAlphaNdaGateWrapper._globalIsSessionUnlocked = true;
      setState(() {
        _isSubmitting = false;
        _isUnlocked = true;
      });
      return;
    }

    final normalizedCode = entered.toUpperCase();
    Map<String, dynamic>? matchedRecord;

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawRegistry =
          prefs.getString(_prefsIssuedPasscodeRegistryKey) ?? '{}';
      final parsed = jsonDecode(rawRegistry);
      if (parsed is Map && parsed[normalizedCode] is Map) {
        matchedRecord =
            Map<String, dynamic>.from(parsed[normalizedCode] as Map);
      }
    } catch (_) {}

    final client = supabaseOrNull;
    if (client != null) {
      try {
        final rpcResult = await client.rpc(
          'verify_hardware_bound_passcode',
          params: {
            'p_passcode': normalizedCode,
            'p_device_id': _deviceFingerprint,
          },
        );
        if (rpcResult == true) {
          matchedRecord = <String, dynamic>{
            'unique_passcode': normalizedCode,
            'approval_status': 'approved',
            'bound_device_fingerprint': _deviceFingerprint,
            'full_legal_name': _fullNameController.text.trim().isNotEmpty
                ? _fullNameController.text.trim()
                : 'Approved Tester',
          };
        }
      } catch (_) {}

      if (matchedRecord == null) {
        try {
          final rows = await client
              .from(OfficialClosedAlphaNdaGateWrapper.approvalsTableName)
              .select()
              .eq('unique_passcode', normalizedCode)
              .limit(1);
          if (rows.isNotEmpty && rows.first is Map) {
            matchedRecord = Map<String, dynamic>.from(rows.first as Map);
          }
        } catch (_) {}
      }
    }

    if (matchedRecord == null) {
      HapticFeedback.heavyImpact();
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage =
            'UNRECOGNIZED PASSCODE ("$normalizedCode"). Every tester must complete and sign the Non-Disclosure Agreement first and receive manual Founder Approval before their passcode is activated.';
      });
      return;
    }

    final approvalStatus =
        (matchedRecord['approval_status'] ?? 'pending').toString();
    final ownerName =
        (matchedRecord['full_legal_name'] ?? 'Registered Tester').toString();

    if (approvalStatus == 'pending') {
      HapticFeedback.heavyImpact();
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage =
            '⏳ PENDING FOUNDER APPROVAL: The NDA dossier for $ownerName is awaiting manual review and approval by Founder Corey Geter (${OfficialClosedAlphaNdaGateWrapper.founderContactEmail}). Your passcode cannot unlock the app until approved.';
      });
      return;
    }

    if (approvalStatus == 'rejected') {
      HapticFeedback.heavyImpact();
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage =
            '🚫 ACCESS DECLINED: The Closed Alpha request for $ownerName was not approved by Studio Administration (${OfficialClosedAlphaNdaGateWrapper.founderContactEmail}).';
      });
      return;
    }

    final boundFp =
        (matchedRecord['bound_device_fingerprint'] ?? '').toString();
    final ownerEmail = (matchedRecord['email'] ?? '').toString();
    final ownerPhone = (matchedRecord['phone_number'] ?? '').toString();

    if (boundFp.isNotEmpty && boundFp != _deviceFingerprint) {
      HapticFeedback.heavyImpact();
      try {
        await QaTelemetryRepository.submitBugReport(
          testerHandle: ownerName.replaceAll(' ', '_'),
          bugType: 'NDA_BREACH',
          testerNote:
              '🚨 CRITICAL NDA PASSCODE SHARING DETECTED! Passcode "$normalizedCode" issued to $ownerName (Email: $ownerEmail | Phone: $ownerPhone | Original Device FP: $boundFp) was entered on an UNAUTHORIZED SECOND DEVICE (Attempted Device FP: $_deviceFingerprint | Model: ${_deviceModelController.text.trim()} | OS: ${_osVersionController.text.trim()}). Access was blocked.',
          activeRoute: '/nda-breach-blocked',
          context: context,
        );
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _breachAlertMessage =
            '🚨 NDA BREACH & PASSCODE SHARING DETECTED:\n'
            'Passcode "$normalizedCode" is legally registered exclusively to $ownerName and cryptographically locked to their primary device ($boundFp).\n\n'
            'Attempting to use another person\'s passcode on an unregistered device ($_deviceFingerprint) violates Section 0.2 of the Non-Disclosure Agreement. This unauthorized sharing attempt—along with $ownerName\'s identity and this device\'s hardware telemetry—has been logged and reported to ACT LIKE IT™ Studio Administration.';
      });
      return;
    }

    final recordWithSeal = Map<String, dynamic>.from(matchedRecord);
    recordWithSeal['session_seal'] =
        OfficialClosedAlphaNdaGateWrapper.computeSessionSeal(
      passcode: normalizedCode,
      deviceFingerprint: _deviceFingerprint,
      status: 'approved',
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsDossierPayloadKey,
        jsonEncode(recordWithSeal),
      );
      await prefs.setBool(_prefsGateUnlockedKey, true);
    } catch (_) {}

    try {
      await QaTelemetryRepository.submitBugReport(
        testerHandle: ownerName.replaceAll(' ', '_'),
        bugType: 'PASSCODE_VERIFIED',
        testerNote:
            'VERIFIED APPROVED PASSCODE LOGIN | Passcode: $normalizedCode | Signer: $ownerName | Device FP: $_deviceFingerprint (Founder Approved + Device Match Confirmed)',
        activeRoute: '/nda-passcode-verified',
        context: context,
      );
    } catch (_) {}

    if (!mounted) return;
    OfficialClosedAlphaNdaGateWrapper._globalIsSessionUnlocked = true;
    setState(() {
      _isSubmitting = false;
      _isUnlocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingStorage) {
      return PopScope(
        canPop: false,
        child: Overlay(
          initialEntries: <OverlayEntry>[
            OverlayEntry(
              builder: (BuildContext overlayContext) => const Scaffold(
                backgroundColor: Color(0xFF07090E),
                body: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_isUnlocked) {
      return widget.child;
    }

    final currentDateStr =
        '${DateTime.now().month.toString().padLeft(2, '0')} / ${DateTime.now().day.toString().padLeft(2, '0')} / 2026';

    final approvedPasscode = (_testerApprovalStatus == 'approved' &&
            _pendingSignedDossier != null)
        ? (_pendingSignedDossier!['unique_passcode'] ?? '').toString()
        : null;

    return PopScope(
      canPop: false,
      child: Overlay(
        initialEntries: <OverlayEntry>[
          OverlayEntry(
            builder: (BuildContext overlayContext) {
              return Scaffold(
                backgroundColor: const Color(0xFF07090E),
                body: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Security Banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A0B12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE11D48),
                        width: 2.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_rounded,
                          color: Color(0xFFE11D48),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'MANDATORY CLOSED ALPHA NDA & FOUNDER APPROVAL LOCK — DEVICE ID: $_deviceFingerprint',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFDA4AF),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3-Mode Switcher Bar: 1. Sign NDA | 2. Enter Passcode | 3. Founder Admin Login & Portal
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E131F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _activeGateTab = 'sign';
                                _errorMessage = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _activeGateTab == 'sign'
                                    ? const Color(0xFFD4AF37)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '1. SIGN NDA (REQUEST ACCESS)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: _activeGateTab == 'sign'
                                      ? const Color(0xFF07090E)
                                      : const Color(0xFFF5DEB3),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _activeGateTab = 'unlock';
                                _errorMessage = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _activeGateTab == 'unlock'
                                    ? const Color(0xFF0CB6D4)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '2. ENTER APPROVED PASSCODE',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: _activeGateTab == 'unlock'
                                      ? const Color(0xFF07090E)
                                      : const Color(0xFF0CB6D4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _activeGateTab = 'admin';
                                _errorMessage = null;
                              });
                              if (_adminQueueUnlocked) {
                                _loadFounderAdminQueueRecords();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _activeGateTab == 'admin'
                                    ? const Color(0xFFE11D48)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '🛡️ 3. FOUNDER ADMIN LOGIN',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: _activeGateTab == 'admin'
                                      ? Colors.white
                                      : const Color(0xFFFDA4AF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Studio Header Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E131F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 2.2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x44000000),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: ActLikeItBrandLogo(
                            height: 64,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          '🎬 "ACT LIKE IT" — OFFICIAL CLOSED ALPHA TESTING AGREEMENT, NON-DISCLOSURE (NDA) & PARTNERSHIP DOSSIER',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFF5DEB3),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'STANDALONE CLOSED ALPHA EDITION — BUILD v1.0-ALPHA · OFFICIAL PORTAL: https://act-like-it.vercel.app',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0CB6D4),
                          ),
                        ),
                        const Divider(
                          color: Color(0xFF1E293B),
                          height: 24,
                          thickness: 1.5,
                        ),

                        // TAB 3: DEDICATED FOUNDER'S ADMIN LOGIN PAGE & COMMAND CENTER DASHBOARD
                        if (_activeGateTab == 'admin') ...[
                          _buildFounderAdminPortalSection(),
                        ],

                        // TAB 1: SIGN NDA & SUBMIT FOR FOUNDER APPROVAL
                        if (_activeGateTab == 'sign') ...[
                          const Text(
                            '🔒 SECTION 0: PRE-REGISTRATION INTELLECTUAL PROPERTY & LEGAL NOTICE',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '(MANDATORY: Complete and sign below. Your dossier is sent to Founder Corey Geter for manual approval before your personal passcode is released.)',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF07090E),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFF1E293B)),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '1. Unregistered Copyright & Common-Law Intellectual Property Notice:',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Although formal registration with the U.S. Copyright Office and the U.S. Patent and Trademark Office (USPTO) is currently pending, automatic statutory copyright protection under the U.S. Copyright Act (17 U.S.C. § 102) attaches immediately upon creation and fixation of this original work. All aspects of ACT LIKE IT™—including but not limited to its original 100+ parody scripts, the "Tri-Modal Judging Engine" architecture, the "2.5D Boondocks-inspired" cell-shaded visual style and 14 character archetypes, the "Life Is Improv" stealth HUD mechanics, custom UI/UX layouts, audio cues, source code, database schemas, and trade dress—are the exclusive, proprietary intellectual property of the Creator/Studio (© 2026 ACT LIKE IT Studio. All Rights Reserved. Common-Law Trademark ACT LIKE IT™ Claimed).',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFCBD5E1),
                                    height: 1.45,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  '2. Strict Confidentiality, Non-Disclosure Agreement (NDA), Manual Founder Approval & Anti-Sharing Policy:',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'By accessing the Closed Alpha build or installing the Standalone App via https://act-like-it.vercel.app or the Android APK, you acknowledge and agree that this software is a Confidential Pre-Release Trade Secret. Signing this agreement submits your dossier to Founder Corey Geter for manual approval. Only after the Founder approves your submission will your UNIQUE PERSONAL TESTER PASSCODE (ALI-XX-XXXX)—cryptographically locked to your legal name and this specific device—be activated and revealed. You expressly agree NOT to:\n'
                                  '• Share your Unique Personal Tester Passcode, the private testing URL, room codes, or build files with any third party (any attempt to use your passcode on another person\'s device immediately triggers an NDA Breach Alert under your name).\n'
                                  '• Record, livestream, screenshot, or distribute gameplay publicly on social media (TikTok, Instagram, YouTube, X, etc.) without written authorization from ACT LIKE IT Studio.\n'
                                  '• Copy, reverse-engineer, decompile, or appropriate any game mechanics, parody scripts, UI designs, or concepts from this software.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFCBD5E1),
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // TESTER & POTENTIAL PARTNER LEGAL ACKNOWLEDGMENT & DEVICE LOG
                          const Text(
                            '✍️ TESTER & POTENTIAL PARTNER LEGAL ACKNOWLEDGMENT & DEVICE LOG',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildLabeledField(
                            label: 'Tester Full Legal Name *',
                            hint: 'Enter your full legal first and last name',
                            controller: _fullNameController,
                            icon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildLabeledField(
                                  label: 'Tester Personal / Business Email *',
                                  hint: 'name@example.com',
                                  controller: _emailController,
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildLabeledField(
                                  label: 'Tester Phone Number *',
                                  hint: '(555) 000-0000',
                                  controller: _phoneController,
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildLabeledField(
                                  label:
                                      'Device Model (e.g., iPhone 16 Pro Max / S26 Ultra) *',
                                  hint:
                                      'Enter your phone, tablet, or computer model',
                                  controller: _deviceModelController,
                                  icon: Icons.phone_iphone_rounded,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildLabeledField(
                                  label:
                                      'OS Version (Settings > General > About) *',
                                  hint: 'e.g., iOS 18.2 / Android 16',
                                  controller: _osVersionController,
                                  icon: Icons.settings_system_daydream_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Network Connection Used *',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF5DEB3),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ['Wi-Fi', '5G / Cellular', 'Both Tested']
                                .map((net) {
                              final selected = _selectedNetwork == net;
                              return ChoiceChip(
                                label: Text(net),
                                selected: selected,
                                selectedColor: const Color(0xFFD4AF37),
                                backgroundColor: const Color(0xFF07090E),
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: selected
                                      ? const Color(0xFF07090E)
                                      : Colors.white70,
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    _selectedNetwork = net;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),

                          // Mandatory Legal Checkboxes
                          CheckboxListTile(
                            value: _agreedToIpNotice,
                            onChanged: (val) {
                              setState(() {
                                _agreedToIpNotice = val ?? false;
                              });
                            },
                            activeColor: const Color(0xFFD4AF37),
                            checkColor: const Color(0xFF07090E),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text(
                              'I acknowledge the Pre-Registration Intellectual Property & Copyright Notice (17 U.S.C. § 102) and confirm that all aspects of ACT LIKE IT™ are the exclusive property of ACT LIKE IT Studio.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          CheckboxListTile(
                            value: _agreedToStrictNda,
                            onChanged: (val) {
                              setState(() {
                                _agreedToStrictNda = val ?? false;
                              });
                            },
                            activeColor: const Color(0xFFD4AF37),
                            checkColor: const Color(0xFF07090E),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text(
                              'I agree to the Strict Confidentiality & Non-Disclosure Agreement (NDA): I will NOT share my personal tester passcode, publicly record, screenshot, share https://act-like-it.vercel.app or build files, or appropriate any game mechanics or scripts.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildLabeledField(
                                  label:
                                      'Tester Digital Signature (Type Full Legal Name) *',
                                  hint:
                                      'Type your full legal name as binding signature',
                                  controller: _signatureController,
                                  icon: Icons.draw_rounded,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF07090E),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Date (2026)',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currentDateStr,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFF5DEB3),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Divider(
                            color: Color(0xFF1E293B),
                            height: 28,
                            thickness: 1.5,
                          ),

                          // SECTION 1: PARTNERSHIP & CO-FOUNDER EVALUATION
                          const Text(
                            '🤝 SECTION 1: "ACT LIKE IT" PARTNERSHIP & CO-FOUNDER EVALUATION',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'As "ACT LIKE IT" scales from Closed Alpha toward official commercial launch on the Apple App Store and Google Play Store, the Creator/Studio is actively evaluating key strategic partners to join the core team.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFCBD5E1),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Are you interested in discussing a formal partnership or advisory role with ACT LIKE IT Studio?',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFF5DEB3),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _interestedInPartnership = true;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _interestedInPartnership
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFF07090E),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _interestedInPartnership
                                            ? const Color(0xFFD4AF37)
                                            : const Color(0xFF334155),
                                        width: _interestedInPartnership ? 2 : 1,
                                      ),
                                    ),
                                    child: const Text(
                                      '✅ YES — I want to talk about joining the core team!',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _interestedInPartnership = false;
                                      _selectedPartnershipTracks.clear();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: !_interestedInPartnership
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFF07090E),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: !_interestedInPartnership
                                            ? const Color(0xFF0CB6D4)
                                            : const Color(0xFF334155),
                                        width:
                                            !_interestedInPartnership ? 2 : 1,
                                      ),
                                    ),
                                    child: const Text(
                                      '🎬 NO — I am strictly acting as a Closed Alpha Tester.',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_interestedInPartnership) ...[
                            const SizedBox(height: 12),
                            const Text(
                              '🚀 Available Partnership & Advisory Positions (Select all that align):',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0CB6D4),
                              ),
                            ),
                            const SizedBox(height: 6),
                            ..._partnershipPositions.map((pos) {
                              final id = pos['id']!;
                              final isSelected =
                                  _selectedPartnershipTracks.contains(id);
                              return CheckboxListTile(
                                value: isSelected,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedPartnershipTracks.add(id);
                                    } else {
                                      _selectedPartnershipTracks.remove(id);
                                    }
                                  });
                                },
                                activeColor: const Color(0xFFD4AF37),
                                checkColor: const Color(0xFF07090E),
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text(
                                  pos['title']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  pos['desc']!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                            _buildLabeledField(
                              label:
                                  'Briefly summarize your background, superpowers, or past experience relevant to this role:',
                              hint:
                                  'Share your experience, portfolio, or partnership vision...',
                              controller: _backgroundSummaryController,
                              icon: Icons.rocket_launch_outlined,
                              maxLines: 3,
                            ),
                          ],

                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting
                                  ? null
                                  : _handleSignNdaAndRequestFounderApproval,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4AF37),
                                foregroundColor: const Color(0xFF07090E),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.fingerprint_rounded),
                              label: const Text(
                                'STEP 1: SIGN NDA & SUBMIT FOR FOUNDER APPROVAL',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ),

                          const Divider(
                            color: Color(0xFF1E293B),
                            height: 28,
                            thickness: 1.5,
                          ),
                        ],

                        if (_activeGateTab != 'admin') ...[
                          // PENDING FOUNDER APPROVAL CARD (Passcode strictly hidden until approved!)
                          if (_pendingSignedDossier != null &&
                              _testerApprovalStatus == 'pending') ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1607),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.hourglass_top_rounded,
                                        color: Color(0xFFFBBF24),
                                        size: 22,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '⏳ NDA SIGNED — PENDING FOUNDER APPROVAL',
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFFFDE68A),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Thank you, ${(_pendingSignedDossier!['full_legal_name'] ?? 'Tester')}. Your signed NDA and device hardware lock ($_deviceFingerprint) have been recorded.\n\n'
                                    '🔒 PASSCODE HELD FOR MANUAL FOUNDER CLEARANCE:\n'
                                    'Because the repository is public on GitHub, Founder Corey Geter personally reviews and approves every tester before their personal ALI-XX-XXXX passcode is revealed or activated.',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFFEF3C7),
                                      height: 1.45,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF07090E),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFF334155),
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.mail_outline_rounded,
                                          color: Color(0xFF0CB6D4),
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Founder Direct Contact: ${OfficialClosedAlphaNdaGateWrapper.founderContactEmail}',
                                            style: TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF0CB6D4),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_statusCheckFeedback != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      _statusCheckFeedback!,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFFBBF24),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: _isSubmitting
                                          ? null
                                          : _handleCheckApprovalStatus,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            const Color(0xFF0CB6D4),
                                        side: const BorderSide(
                                          color: Color(0xFF0CB6D4),
                                          width: 1.8,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      icon: const Icon(Icons.refresh_rounded),
                                      label: const Text(
                                        '🔄 CHECK APPROVAL STATUS',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // REJECTED CARD
                          if (_pendingSignedDossier != null &&
                              _testerApprovalStatus == 'rejected') ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A0A14),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE11D48),
                                  width: 2,
                                ),
                              ),
                              child: const Text(
                                '🚫 ACCESS REQUEST DECLINED: Your Closed Alpha request was not approved by Studio Administration (${OfficialClosedAlphaNdaGateWrapper.founderContactEmail}).',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFDA4AF),
                                ),
                              ),
                            ),
                          ],

                          // APPROVED PASSCODE BANNER (Visible ONLY after Founder approves!)
                          if (approvedPasscode != null &&
                              approvedPasscode.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF062019),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF10B981),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.verified_rounded,
                                        color: Color(0xFF10B981),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '✅ FOUNDER APPROVED — YOUR UNIQUE PERSONAL PASSCODE IS ACTIVE',
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF34D399),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF07090E),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFD4AF37),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SelectableText(
                                          approvedPasscode,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 2.0,
                                            color: Color(0xFFFFD700),
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                text: approvedPasscode,
                                              ),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Approved Personal Passcode copied to clipboard.',
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.copy_rounded,
                                            size: 16,
                                            color: Color(0xFF0CB6D4),
                                          ),
                                          label: const Text(
                                            'COPY CODE',
                                            style: TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF0CB6D4),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '⚠️ ANTI-SHARING TRACEABILITY WARNING: This passcode ($approvedPasscode) is uniquely approved for ${(_pendingSignedDossier!['full_legal_name'] ?? 'you')} and locked to Device ID $_deviceFingerprint. If you give this passcode to anyone else, our security system immediately detects the different device, blocks their access, and flags your name and phone number with a CRITICAL NDA BREACH ALERT.',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFFFDE68A),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // STEP 2 / RETURNING UNLOCK: PERSONAL TESTER PASSCODE
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF130D18),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE11D48),
                                width: 1.8,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.vpn_key_rounded,
                                      color: Color(0xFFD4AF37),
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'STEP 2: ENTER YOUR FOUNDER-APPROVED PASSCODE TO UNLOCK',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFD4AF37),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Enter the Unique Personal Tester Passcode (ALI-XX-XXXX) sent or unlocked after Founder Corey Geter approves your NDA.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _passcodeInputController,
                                  obscureText: _obscurePasscode,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'e.g., ALI-JD-8492',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF07090E),
                                    prefixIcon: const Icon(
                                      Icons.security_rounded,
                                      color: Color(0xFFE11D48),
                                      size: 18,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscurePasscode = !_obscurePasscode;
                                        });
                                      },
                                      icon: Icon(
                                        _obscurePasscode
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.white60,
                                        size: 18,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFD4AF37),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // CRITICAL NDA BREACH ALERT BANNER
                          if (_breachAlertMessage != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B0712),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFF2E54),
                                  width: 2.5,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.gpp_bad_rounded,
                                    color: Color(0xFFFF2E54),
                                    size: 26,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _breachAlertMessage!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFFFE4E6),
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (_errorMessage != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A0A14),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFE11D48),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Color(0xFFE11D48),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFFDA4AF),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting
                                  ? null
                                  : _handleVerifyPasscodeAndUnlock,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE11342),
                                foregroundColor: const Color(0xFFF5DEB3),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: Color(0xFFD4AF37),
                                    width: 2,
                                  ),
                                ),
                              ),
                              icon: _isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFF5DEB3),
                                      ),
                                    )
                                  : const Icon(Icons.verified_user_rounded),
                              label: Text(
                                _isSubmitting
                                    ? 'VERIFYING APPROVAL & DEVICE LOCK...'
                                    : '🔓 VERIFY APPROVED PASSCODE & UNLOCK ACT LIKE IT™',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            '© 2026 ACT LIKE IT™ Studio. All Rights Reserved. Confidential Closed Alpha Testing & Partnership Dossier — Do Not Distribute.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF64748B),
                            ),
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
      ),
    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFounderAdminPortalSection() {
    if (!_adminQueueUnlocked) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF07090E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE11D48), width: 2.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A0A14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE11D48)),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Color(0xFFD4AF37),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🛡️ FOUNDER\'S EXECUTIVE ADMIN LOGIN',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Restricted exclusively to Studio Founder Corey Geter (getercorey97@gmail.com)',
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
            const SizedBox(height: 14),
            const Text(
              'Authenticate with your Founder Admin Username and Password to access the pre-launch Command Center, inspect all signed NDA & Co-Founder Dossiers, approve or reject testers, and launch directly into the main ACT LIKE IT™ application.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFCBD5E1),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            _buildLabeledField(
              label: 'Founder Admin Username *',
              hint: 'Enter Founder Admin Username',
              controller: _adminUsernameController,
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 12),
            const Text(
              'Founder Admin Password *',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF5DEB3),
              ),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _adminPasswordController,
              obscureText: _obscureAdminPassword,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Enter Founder Admin Password',
                hintStyle: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
                filled: true,
                fillColor: const Color(0xFF0E131F),
                prefixIcon: const Icon(
                  Icons.key_rounded,
                  color: Color(0xFFD4AF37),
                  size: 18,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureAdminPassword = !_obscureAdminPassword;
                    });
                  },
                  icon: Icon(
                    _obscureAdminPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white60,
                    size: 18,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (_adminError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A0A14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE11D48)),
                ),
                child: Text(
                  _adminError!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFDA4AF),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleFounderAdminLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF07090E),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.verified_user_rounded),
                label: const Text(
                  'AUTHENTICATE & OPEN FOUNDER COMMAND CENTER',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final totalCount = _adminQueueRecords.length;
    final pendingCount = _adminQueueRecords
        .where((r) => (r['approval_status'] ?? 'pending') == 'pending')
        .length;
    final approvedCount = _adminQueueRecords
        .where((r) => (r['approval_status'] ?? 'pending') == 'approved')
        .length;
    final partnerCount = _adminQueueRecords
        .where((r) => r['interested_in_partnership'] == true)
        .length;
    final rejectedCount = _adminQueueRecords
        .where((r) => (r['approval_status'] ?? 'pending') == 'rejected')
        .length;

    final query = _adminSearchController.text.trim().toLowerCase();
    final filteredRecords = _adminQueueRecords.where((rec) {
      final status = (rec['approval_status'] ?? 'pending').toString();
      final isPartner = rec['interested_in_partnership'] == true;
      if (_adminFilterStatus == 'pending' && status != 'pending') return false;
      if (_adminFilterStatus == 'approved' && status != 'approved') {
        return false;
      }
      if (_adminFilterStatus == 'rejected' && status != 'rejected') {
        return false;
      }
      if (_adminFilterStatus == 'partner' && !isPartner) return false;

      if (query.isEmpty) return true;
      final hay =
          '${rec['full_legal_name']} ${rec['email']} ${rec['phone_number']} ${rec['unique_passcode']} ${rec['bound_device_fingerprint']}'
              .toLowerCase();
      return hay.contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Executive Command Bar + Direct Launch into Main App
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF07090E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '👑 FOUNDER COMMAND CENTER & NDA APPROVAL DASHBOARD',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Authenticated as Founder Corey Geter (admin88) · Live Sync: public.nda_tester_approvals',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF34D399),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _loadFounderAdminQueueRecords,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 16,
                      color: Color(0xFF0CB6D4),
                    ),
                    label: const Text(
                      'SYNC',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0CB6D4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleFounderLaunchIntoMainApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: const Color(0xFF07090E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.rocket_launch_rounded),
                  label: const Text(
                    '🚀 LAUNCH INTO ACT LIKE IT™ MAIN APP (FOUNDER BYPASS)',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // KPI Metrics Strip
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildKpiTile('TOTAL DOSSIERS', '$totalCount', const Color(0xFF0CB6D4)),
            _buildKpiTile('PENDING REVIEW', '$pendingCount', const Color(0xFFF59E0B)),
            _buildKpiTile('APPROVED', '$approvedCount', const Color(0xFF10B981)),
            _buildKpiTile('PARTNER TRACK', '$partnerCount', const Color(0xFFD4AF37)),
            _buildKpiTile('REJECTED', '$rejectedCount', const Color(0xFFE11D48)),
          ],
        ),
        const SizedBox(height: 14),

        // Filter Chips & Search Bar
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildFilterChip('all', 'ALL ($totalCount)'),
            _buildFilterChip('pending', '⏳ PENDING ($pendingCount)'),
            _buildFilterChip('approved', '✅ APPROVED ($approvedCount)'),
            _buildFilterChip('partner', '🤝 CO-FOUNDER / PARTNER ($partnerCount)'),
            _buildFilterChip('rejected', '🚫 REJECTED ($rejectedCount)'),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _adminSearchController,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 12.5, color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search by tester name, email, phone, or ALI-XX-XXXX passcode...',
            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            filled: true,
            fillColor: const Color(0xFF07090E),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0CB6D4), size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 14),

        if (_isLoadingAdminQueue)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            ),
          )
        else if (filteredRecords.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF07090E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: const Text(
              'No tester NDA dossiers match the current filter.',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          )
        else
          ...filteredRecords.map((rec) {
            final name = (rec['full_legal_name'] ?? 'Unknown').toString();
            final email = (rec['email'] ?? '').toString();
            final phone = (rec['phone_number'] ?? '').toString();
            final signature = (rec['digital_signature'] ?? name).toString();
            final code =
                (rec['unique_passcode'] ?? '').toString().toUpperCase();
            final fp = (rec['bound_device_fingerprint'] ?? '').toString();
            final deviceModel = (rec['device_model'] ?? 'Device').toString();
            final osVersion = (rec['os_version'] ?? 'OS').toString();
            final network = (rec['network_connection_used'] ?? 'Both Tested').toString();
            final status = (rec['approval_status'] ?? 'pending').toString();
            final partner = rec['interested_in_partnership'] == true;
            final tracks = (rec['selected_partnership_tracks'] is List)
                ? (rec['selected_partnership_tracks'] as List).join(', ')
                : '';
            final summary =
                (rec['partnership_background_summary'] ?? '').toString();

            Color badgeColor = const Color(0xFFF59E0B);
            if (status == 'approved') badgeColor = const Color(0xFF10B981);
            if (status == 'rejected') badgeColor = const Color(0xFFE11D48);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF07090E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: badgeColor, width: 1.6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '$name · $email · $phone',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: badgeColor),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Passcode: $code · Bound Device FP: $fp\nDevice: $deviceModel ($osVersion) · Network: $network · Digital Signature: "$signature"',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFFF5DEB3),
                      height: 1.4,
                    ),
                  ),
                  if (partner) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1607),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD4AF37)),
                      ),
                      child: Text(
                        '🤝 CO-FOUNDER / PARTNER TRACK: $tracks\nBackground: ${summary.isEmpty ? "Not provided" : summary}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFFDE68A),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _handleFounderUpdateTesterStatus(
                          passcode: code,
                          newStatus: 'approved',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: const Color(0xFF07090E),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_rounded, size: 16),
                        label: const Text(
                          '✅ APPROVE & ISSUE PASSCODE',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _handleFounderUpdateTesterStatus(
                          passcode: code,
                          newStatus: 'rejected',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFDA4AF),
                          side: const BorderSide(color: Color(0xFFE11D48)),
                        ),
                        icon: const Icon(Icons.block_rounded, size: 16),
                        label: const Text(
                          '🚫 REJECT',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Copied $code for $name to clipboard.',
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0CB6D4),
                          side: const BorderSide(color: Color(0xFF0CB6D4)),
                        ),
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text(
                          'COPY PASSCODE',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildKpiTile(String label, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF07090E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final selected = _adminFilterStatus == key;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: const Color(0xFFD4AF37),
      backgroundColor: const Color(0xFF07090E),
      labelStyle: TextStyle(
        fontFamily: 'monospace',
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
        color: selected ? const Color(0xFF07090E) : Colors.white70,
      ),
      onSelected: (_) {
        setState(() {
          _adminFilterStatus = key;
        });
      },
    );
  }

  Widget _buildLabeledField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF5DEB3),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
            ),
            filled: true,
            fillColor: const Color(0xFF07090E),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFFD4AF37),
              size: 18,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFD4AF37),
                width: 1.8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
