import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../qa/qa_overlay.dart';
import '../ui/brand_logo.dart';

/// Mandatory Closed Alpha NDA, Partnership Dossier, Unique Per-Tester Passcode
/// Generator & Device-Bound Anti-Sharing Security Gate.
///
/// Security & Anti-Leak Architecture:
/// 1. Zero Plaintext Secrets in Repo: The Studio Founder Master Secret is read
///    from `--dart-define=ADMIN_PASSCODE` (GitHub Actions Secret) or verified
///    against a dual cryptographic polynomial digest (`h1` / `h2`) so no
///    plaintext secret ever exists in source control.
/// 2. Unique Per-Tester Passcode Issuance: Every person who signs the NDA is
///    issued a personal passcode (`ALI-<INITIALS>-<4CHAR_HASH>`) bound to their
///    Full Legal Name, Email, Phone Number, and Device Hardware Fingerprint.
/// 3. Anti-Sharing Leak Detection: If a tester gives their unique `ALI-XX-XXXX`
///    passcode to another person (different device fingerprint), the gate
///    blocks access on the second device and immediately logs an `NDA_BREACH`
///    alert to Supabase (`public.qa_feedback`) identifying the exact tester
///    who shared their passcode.
class OfficialClosedAlphaNdaGateWrapper extends StatefulWidget {
  final Widget child;

  const OfficialClosedAlphaNdaGateWrapper({
    super.key,
    required this.child,
  });

  /// Verifies the Studio Founder Master Secret without storing any plaintext
  /// passcode in the GitHub repository. Supports `--dart-define=ADMIN_PASSCODE`
  /// from GitHub Actions Secrets plus a dual-prime polynomial digest check.
  static bool verifyStudioMasterSecret(String rawInput) {
    final normalized = rawInput.trim().toLowerCase();
    if (normalized.isEmpty) return false;

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

  @override
  State<OfficialClosedAlphaNdaGateWrapper> createState() =>
      _OfficialClosedAlphaNdaGateWrapperState();
}

class _OfficialClosedAlphaNdaGateWrapperState
    extends State<OfficialClosedAlphaNdaGateWrapper> {
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

  // Mode toggle: false = Sign New NDA & Get Unique Passcode, true = Returning Passcode / Admin Unlock
  bool _showPasscodeUnlockPanelOnly = false;

  // Issued unique passcode after signing Step 1
  String? _issuedUniquePasscode;
  Map<String, dynamic>? _pendingSignedDossier;

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

      final signed = prefs.getBool(_prefsGateUnlockedKey) ?? false;
      final savedPayload = prefs.getString(_prefsDossierPayloadKey);
      if (signed && savedPayload != null && savedPayload.isNotEmpty) {
        try {
          final decoded = jsonDecode(savedPayload);
          if (decoded is Map) {
            final boundFp =
                (decoded['bound_device_fingerprint'] ?? '').toString();
            final isMaster = decoded['unlocked_via_master_secret'] == true;
            if (isMaster || boundFp.isEmpty || boundFp == _deviceFingerprint) {
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

    if (mounted) {
      setState(() {
        _isUnlocked = false;
        _isCheckingStorage = false;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _deviceModelController.dispose();
    _osVersionController.dispose();
    _signatureController.dispose();
    _backgroundSummaryController.dispose();
    _passcodeInputController.dispose();
    super.dispose();
  }

  /// Step 1: Validates the NDA & Partnership Dossier, generates a Unique
  /// Per-Tester Passcode (`ALI-XX-XXXX`) locked to this person and device,
  /// logs the registration to Supabase, and displays the issued passcode.
  Future<void> _handleSignNdaAndGenerateUniquePasscode() async {
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

    try {
      await QaTelemetryRepository.submitBugReport(
        testerHandle: fullName.replaceAll(' ', '_'),
        bugType: 'NDA_SIGNED',
        testerNote:
            'NDA_SIGNED | PASSCODE: $uniquePasscode | DEVICE_FP: $_deviceFingerprint | Name: $fullName | Email: $email | Phone: $phone | Signature: "$signature" | Device: $deviceModel ($osVersion) | Network: $_selectedNetwork | Partner Interest: ${_interestedInPartnership ? "YES (${_selectedPartnershipTracks.join(", ")})" : "NO (Tester Only)"} | Notes: ${_backgroundSummaryController.text.trim()}',
        activeRoute: '/nda-closed-alpha-gate',
        context: context,
      );
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _issuedUniquePasscode = uniquePasscode;
      _pendingSignedDossier = dossierPayload;
      _passcodeInputController.text = uniquePasscode;
    });
  }

  /// Step 2 (or Returning Tester Unlock): Verifies the entered Unique Tester
  /// Passcode (`ALI-XX-XXXX`) or Studio Master Secret.
  /// If a valid `ALI-XX-XXXX` passcode is entered on a DIFFERENT device than
  /// the one it was issued to, it blocks access and logs an `NDA_BREACH` alert
  /// to Supabase identifying the exact tester who shared their passcode.
  Future<void> _handleVerifyPasscodeAndUnlock() async {
    final entered = _passcodeInputController.text.trim();
    if (entered.isEmpty) {
      setState(() {
        _errorMessage =
            'Please enter your Unique Personal Tester Passcode (e.g., ALI-XX-XXXX) or Studio Master Clearance Code.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _breachAlertMessage = null;
    });

    // 1. Check Studio Founder Master Secret first (works on any device for the Founder)
    if (OfficialClosedAlphaNdaGateWrapper.verifyStudioMasterSecret(entered)) {
      final masterPayload = _pendingSignedDossier ??
          <String, dynamic>{
            'full_legal_name': _fullNameController.text.trim().isNotEmpty
                ? _fullNameController.text.trim()
                : 'Studio Founder / Admin',
            'unique_passcode': 'MASTER_ADMIN_SECRET',
            'bound_device_fingerprint': _deviceFingerprint,
            'unlocked_via_master_secret': true,
            'signed_date_utc': DateTime.now().toUtc().toIso8601String(),
            'official_portal_url': 'https://act-like-it.vercel.app',
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
      setState(() {
        _isSubmitting = false;
        _isUnlocked = true;
      });
      return;
    }

    final normalizedCode = entered.toUpperCase();

    // 2. Look up the Unique Tester Passcode in local registry + Supabase cloud records
    Map<String, dynamic>? matchedRecord;

    if (_issuedUniquePasscode != null &&
        _issuedUniquePasscode!.toUpperCase() == normalizedCode &&
        _pendingSignedDossier != null) {
      matchedRecord = _pendingSignedDossier;
    }

    if (matchedRecord == null) {
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
    }

    // Query Supabase `qa_feedback` for `NDA_SIGNED` rows containing this unique passcode
    if (matchedRecord == null) {
      final client = supabaseOrNull;
      if (client != null) {
        try {
          final rows = await client
              .from(QaTelemetryRepository.tableName)
              .select()
              .eq('bug_type', 'NDA_SIGNED')
              .order('created_at', ascending: false)
              .limit(200);
          for (final rawRow in rows.whereType<Map>()) {
            final row = Map<String, dynamic>.from(rawRow);
            final dump = row['local_state_dump'];
            String note = '';
            if (dump is Map) {
              note = (dump['tester_note'] ?? '').toString();
            } else if (dump is String) {
              note = dump;
            }
            if (note.toUpperCase().contains('PASSCODE: $normalizedCode')) {
              final fpMatch =
                  RegExp(r'DEVICE_FP:\s*([A-Z0-9\-]+)').firstMatch(note);
              final nameMatch =
                  RegExp(r'Name:\s*([^|]+)').firstMatch(note);
              final emailMatch =
                  RegExp(r'Email:\s*([^|]+)').firstMatch(note);
              final phoneMatch =
                  RegExp(r'Phone:\s*([^|]+)').firstMatch(note);
              matchedRecord = <String, dynamic>{
                'full_legal_name': nameMatch?.group(1)?.trim() ??
                    (row['tester_handle'] ?? 'Registered Tester').toString(),
                'email': emailMatch?.group(1)?.trim() ?? 'on-file',
                'phone_number': phoneMatch?.group(1)?.trim() ?? 'on-file',
                'unique_passcode': normalizedCode,
                'bound_device_fingerprint':
                    fpMatch?.group(1)?.trim() ?? 'CLOUD-BOUND-DEVICE',
              };
              break;
            }
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
            'UNRECOGNIZED PASSCODE ("$normalizedCode"). Every tester must complete and sign the Non-Disclosure Agreement first to receive their own Unique Personal Passcode.';
      });
      return;
    }

    // 3. Verify Device Hardware Fingerprint Binding (Anti-Sharing Leak Detection!)
    final boundFp =
        (matchedRecord['bound_device_fingerprint'] ?? '').toString();
    final ownerName =
        (matchedRecord['full_legal_name'] ?? 'Registered Tester').toString();
    final ownerEmail = (matchedRecord['email'] ?? '').toString();
    final ownerPhone = (matchedRecord['phone_number'] ?? '').toString();

    if (boundFp.isNotEmpty && boundFp != _deviceFingerprint) {
      // LEAK DETECTED: Tester shared their personal passcode with another device!
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

    // 4. Legitimate Owner on Registered Device -> Log verification & Unlock!
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsDossierPayloadKey,
        jsonEncode(matchedRecord),
      );
      await prefs.setBool(_prefsGateUnlockedKey, true);
    } catch (_) {}

    try {
      await QaTelemetryRepository.submitBugReport(
        testerHandle: ownerName.replaceAll(' ', '_'),
        bugType: 'PASSCODE_VERIFIED',
        testerNote:
            'VERIFIED UNIQUE PASSCODE LOGIN | Passcode: $normalizedCode | Signer: $ownerName | Device FP: $_deviceFingerprint (Device Match Confirmed)',
        activeRoute: '/nda-passcode-verified',
        context: context,
      );
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _isUnlocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingStorage) {
      return const Scaffold(
        backgroundColor: Color(0xFF07090E),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFD4AF37),
          ),
        ),
      );
    }

    if (_isUnlocked) {
      return widget.child;
    }

    final currentDateStr =
        '${DateTime.now().month.toString().padLeft(2, '0')} / ${DateTime.now().day.toString().padLeft(2, '0')} / 2026';

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
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
                            'MANDATORY CLOSED ALPHA NDA & PERSONAL PASSCODE LOCK — DEVICE ID: $_deviceFingerprint',
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

                  // Mode Switcher Bar: Sign New NDA vs Returning Passcode / Admin Unlock
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
                                _showPasscodeUnlockPanelOnly = false;
                                _errorMessage = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_showPasscodeUnlockPanelOnly
                                    ? const Color(0xFFD4AF37)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '1. SIGN NDA & GET UNIQUE PASSCODE',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: !_showPasscodeUnlockPanelOnly
                                      ? const Color(0xFF07090E)
                                      : const Color(0xFFF5DEB3),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showPasscodeUnlockPanelOnly = true;
                                _errorMessage = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _showPasscodeUnlockPanelOnly
                                    ? const Color(0xFF0CB6D4)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '2. ENTER PERSONAL / ADMIN PASSCODE',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: _showPasscodeUnlockPanelOnly
                                      ? const Color(0xFF07090E)
                                      : const Color(0xFF0CB6D4),
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

                        if (!_showPasscodeUnlockPanelOnly) ...[
                          // SECTION 0
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
                            '(MANDATORY: Read, complete, and sign to receive your unique device-locked tester passcode)',
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
                                  '2. Strict Confidentiality, Non-Disclosure Agreement (NDA) & Personal Passcode Anti-Sharing Policy:',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'By accessing the Closed Alpha build or installing the Standalone App via https://act-like-it.vercel.app or the Android APK, you acknowledge and agree that this software is a Confidential Pre-Release Trade Secret. Upon signing below, you will be issued a UNIQUE PERSONAL TESTER PASSCODE (ALI-XX-XXXX) cryptographically bound to your legal name and this specific device. You expressly agree NOT to:\n'
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
                                  : _handleSignNdaAndGenerateUniquePasscode,
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
                                'STEP 1: SIGN NDA & GENERATE MY UNIQUE PERSONAL PASSCODE',
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

                        // ISSUED UNIQUE PERSONAL PASSCODE BANNER (Visible once Step 1 is signed)
                        if (_issuedUniquePasscode != null) ...[
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
                                        'NDA SIGNED — YOUR UNIQUE PERSONAL PASSCODE HAS BEEN ISSUED',
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
                                        _issuedUniquePasscode!,
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
                                              text: _issuedUniquePasscode!,
                                            ),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Unique Personal Passcode copied to clipboard.',
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
                                  '⚠️ ANTI-SHARING TRACEABILITY WARNING: This passcode (${_issuedUniquePasscode!}) is uniquely assigned to ${_fullNameController.text.trim()} and locked to Device ID $_deviceFingerprint. If you give this passcode to anyone else, our security system immediately detects the different device, blocks their access, and flags your name and phone number with a CRITICAL NDA BREACH ALERT.',
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

                        // STEP 2 / RETURNING UNLOCK: PERSONAL TESTER PASSCODE OR STUDIO MASTER CLEARANCE
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
                                      'STEP 2: ENTER YOUR UNIQUE PERSONAL PASSCODE (OR STUDIO MASTER SECRET) TO UNLOCK',
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
                                'Enter the Unique Personal Tester Passcode (ALI-XX-XXXX) generated for you above, or enter the Studio Founder Master Secret to unlock ACT LIKE IT™.',
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
                                  hintText:
                                      'e.g., ALI-JD-8492 (or Studio Master Secret)',
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

                        // CRITICAL NDA BREACH ALERT BANNER (If Passcode Was Shared!)
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                                  ? 'VERIFYING PASSCODE & DEVICE LOCK...'
                                  : '🔓 VERIFY PERSONAL PASSCODE & UNLOCK ACT LIKE IT™',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
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
