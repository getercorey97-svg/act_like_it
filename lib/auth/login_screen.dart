import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../dashboard_marquee.dart';
import '../ui/intro_cinematic.dart';
import 'auth_service.dart';
import 'onboarding_questionnaire.dart';

/// "The Living Marquee" Login & Persistent Onboarding Entry Screen.
/// Features a dark obsidian canvas (`#07090E`) with slow-moving Cyan, Purple,
/// and Amber neon spotlights, the central `assets/app_logo.png` interactive
/// centerpiece, and Dual-Track Auth:
/// - Track A ("Claim Your Star"): Full Cloud Auth + 2.5D Casting Questionnaire
/// - Track B ("Sneak Backstage"): Instant Express Pass with 2.5D Avatar Selector
class LivingMarqueeLoginScreen extends StatefulWidget {
  const LivingMarqueeLoginScreen({super.key});

  @override
  State<LivingMarqueeLoginScreen> createState() =>
      _LivingMarqueeLoginScreenState();
}

class _LivingMarqueeLoginScreenState extends State<LivingMarqueeLoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spotlightController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _isSignUpMode = false;
  bool _isTrackBSneakBackstage = false;
  String _selectedArchetypeId = 'the_method_actor';
  int _birthYear = 1998;
  bool _isSubmitting = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _spotlightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
    _restoreExistingSessionIfAvailable();
  }

  Future<void> _restoreExistingSessionIfAvailable() async {
    await AuthService.instance.initialize();
    if (!mounted) return;
    final profile = AuthService.instance.currentProfile;
    if (profile != null) {
      _emailController.text = profile.email;
      _usernameController.text = profile.username;
      _birthYear = profile.birthYear;
      _selectedArchetypeId = profile.avatarArchetypeId;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _spotlightController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _statusMessage = 'Please enter a valid stage email address.';
      });
      return;
    }
    if (password.length < 6) {
      setState(() {
        _statusMessage = 'Password must be at least 6 characters.';
      });
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isSubmitting = true;
      _statusMessage = null;
    });

    try {
      if (_isSignUpMode) {
        final createdProfile =
            await AuthService.instance.signUpWithEmailAndPassword(
          email: email,
          password: password,
          username: _usernameController.text.trim(),
          birthYear: _birthYear,
        );

        if (!mounted) return;
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OnboardingQuestionnaireScreen(
              initialUsername: createdProfile.username,
              initialBirthYear: createdProfile.birthYear,
            ),
          ),
        );
      } else {
        final hydratedProfile =
            await AuthService.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0B0E17),
            content: Text(
              'Welcome back, ${hydratedProfile.username}! Restored ${hydratedProfile.aiTokenBalance} AI Tokens · Eras: ${hydratedProfile.favoriteEras.join(", ")}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );

        if (!hydratedProfile.onboardingCompleted) {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => OnboardingQuestionnaireScreen(
                initialUsername: hydratedProfile.username,
                initialBirthYear: hydratedProfile.birthYear,
              ),
            ),
          );
        } else {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const LivingMarqueeDashboardScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingProfile = AuthService.instance.currentProfile;

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: Stack(
        children: [
          // Slow-moving animated neon spotlights (Cyan, Purple, Amber)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _spotlightController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _LivingMarqueeLoginSpotlightPainter(
                    progress: _spotlightController.value,
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildMarqueeCrest(),
                      const SizedBox(height: 20),
                      if (existingProfile != null) ...[
                        _buildInstantResumeBanner(existingProfile),
                        const SizedBox(height: 16),
                      ],
                      _buildAuthCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleTrackBSneakBackstage() async {
    if (_isSubmitting) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _isSubmitting = true;
      _statusMessage = null;
    });

    try {
      final archetype = resolveAvatarArchetype(_selectedArchetypeId);
      final customHandle = _usernameController.text.trim();
      final stageHandle = customHandle.isNotEmpty
          ? customHandle
          : archetype.name.replaceAll(' ', '_');

      await AuthService.instance.saveOnboardingQuestionnaire(
        username: stageHandle,
        birthYear: _birthYear,
        favoriteEras: const <String>['1970s', '2000s'],
        actingStrengths: const <String>['Drama', 'Comedy'],
        avatarArchetypeId: _selectedArchetypeId,
        castingTrack: 'track_b_backstage',
      );

      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LivingMarqueeDashboardScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildMarqueeCrest() {
    return Column(
      children: [
        const ActLikeItBrandCenterpiece(
          height: 122,
          compact: true,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0E17),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
          ),
          child: const Text(
            '2.5D PREMIERE CASTING · DUAL-TRACK AUTH',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: Color(0xFFF59E0B),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose Track A to Claim Your Star with full cloud sync, or Track B to Sneak Backstage with an instant 2.5D Archetype Pass.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            color: Color(0xFF94A3B8),
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildInstantResumeBanner(ActorProfileState profile) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E17),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF10B981), width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_rounded,
            color: Color(0xFF10B981),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SAVED PASS: ${profile.username.toUpperCase()}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${profile.aiTokenBalance} AI Tokens · Eras: ${profile.favoriteEras.join("/")} · Strengths: ${profile.actingStrengths.join("/")}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10.5,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: const Color(0xFF07090E),
            ),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const LivingMarqueeDashboardScreen(),
                ),
              );
            },
            child: const Text(
              'STAGE',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard() {
    final currentYear = DateTime.now().year;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E17).withOpacity(0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isSignUpMode
              ? const Color(0xFFA855F7)
              : const Color(0xFF06B6D4),
          width: 1.5,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (_isSignUpMode
                    ? const Color(0xFFA855F7)
                    : const Color(0xFF06B6D4))
                .withOpacity(0.18),
            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dual-Track Selector: Track A (Claim Your Star) vs Track B (Sneak Backstage)
          Row(
            children: [
              Expanded(
                child: _buildModeTab(
                  label: 'TRACK A · CLAIM YOUR STAR',
                  selected: !_isTrackBSneakBackstage,
                  accent: const Color(0xFFF59E0B),
                  onTap: () => setState(() => _isTrackBSneakBackstage = false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildModeTab(
                  label: 'TRACK B · SNEAK BACKSTAGE',
                  selected: _isTrackBSneakBackstage,
                  accent: const Color(0xFF10B981),
                  onTap: () => setState(() => _isTrackBSneakBackstage = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 2.5D Cell-Shaded 14-Archetype Selector Strip
          _buildCellShadedArchetypePicker(),
          const SizedBox(height: 14),
          if (_isTrackBSneakBackstage) ...[
            TextField(
              controller: _usernameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                label: 'EXPRESS STAGE HANDLE (OPTIONAL)',
                hint: 'Leave blank to use Archetype Title',
                icon: Icons.badge_outlined,
                accent: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: const Color(0xFF07090E),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF05070B), width: 2.5),
                ),
              ),
              onPressed: _isSubmitting ? null : _handleTrackBSneakBackstage,
              icon: const Icon(Icons.bolt_rounded),
              label: const Text(
                'SNEAK BACKSTAGE NOW · ENTER RED CARPET',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ] else ...[
          Row(
            children: [
              Expanded(
                child: _buildModeTab(
                  label: 'SIGN IN',
                  selected: !_isSignUpMode,
                  accent: const Color(0xFF06B6D4),
                  onTap: () => setState(() => _isSignUpMode = false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildModeTab(
                  label: 'NEW ACTOR PASS',
                  selected: _isSignUpMode,
                  accent: const Color(0xFFA855F7),
                  onTap: () => setState(() => _isSignUpMode = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              label: 'STAGE EMAIL',
              hint: 'actor@studio.com',
              icon: Icons.alternate_email_rounded,
              accent: const Color(0xFF06B6D4),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              label: 'BACKSTAGE PASSWORD',
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              accent: const Color(0xFF06B6D4),
            ),
          ),
          if (_isSignUpMode) ...[
            const SizedBox(height: 14),
            TextField(
              controller: _usernameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                label: 'STAGE HANDLE (USERNAME)',
                hint: 'e.g., NeonMethodActor',
                icon: Icons.person_outline_rounded,
                accent: const Color(0xFFA855F7),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'BIRTH YEAR (18+ GATE)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                Text(
                  '$_birthYear (${(currentYear - _birthYear) >= 18 ? "18+ Verified" : "Standard"})',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Slider(
              value: _birthYear.toDouble(),
              min: 1945,
              max: (currentYear - 13).toDouble(),
              divisions: (currentYear - 13) - 1945,
              activeColor: const Color(0xFFF59E0B),
              inactiveColor: const Color(0xFF1E293B),
              onChanged: (v) => setState(() => _birthYear = v.round()),
            ),
          ],
          if (_statusMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF7F1D1D).withOpacity(0.35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEF4444)),
              ),
              child: Text(
                _statusMessage!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFFECACA),
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSignUpMode
                  ? const Color(0xFFA855F7)
                  : const Color(0xFF06B6D4),
              foregroundColor: const Color(0xFF07090E),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isSubmitting ? null : _handleAuthSubmit,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Color(0xFF07090E),
                    ),
                  )
                : Icon(
                    _isSignUpMode
                        ? Icons.confirmation_number_rounded
                        : Icons.login_rounded,
                  ),
            label: Text(
              _isSignUpMode
                  ? 'CREATE PASS & LAUNCH RED CARPET'
                  : 'SIGN IN & SYNC SUPABASE PROFILE',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OnboardingQuestionnaireScreen(
                    initialUsername: _usernameController.text.trim(),
                    initialBirthYear: _birthYear,
                    initialArchetypeId: _selectedArchetypeId,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.style_rounded,
              size: 16,
              color: Color(0xFFF59E0B),
            ),
            label: const Text(
              'OPEN "THE RED CARPET" 2.5D CASTING QUESTIONNAIRE',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFFF59E0B),
              ),
            ),
          ),
          ],
        ],
      ),
    );
  }

  Widget _buildCellShadedArchetypePicker() {
    final chosen = resolveAvatarArchetype(_selectedArchetypeId);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF07090E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: chosen.primaryInkColor, width: 2.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                chosen.signatureIcon,
                color: chosen.primaryInkColor,
                size: 15,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '2.5D AVATAR ARCHETYPE: ${chosen.name} (${chosen.roleBadge})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: chosen.primaryInkColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kFourteenAvatarArchetypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final arch = kFourteenAvatarArchetypes[index];
                final selected = arch.id == _selectedArchetypeId;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedArchetypeId = arch.id;
                    });
                    AuthService.instance.updateAvatarArchetype(arch.id);
                  },
                  child: BoondocksAvatarPortrait(
                    archetype: arch,
                    size: selected ? 60 : 52,
                    isSelected: selected,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required String label,
    required bool selected,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.18) : const Color(0xFF07090E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? accent : const Color(0xFF1E293B),
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: selected ? accent : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    required Color accent,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontFamily: 'monospace',
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: accent,
      ),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF475569)),
      prefixIcon: Icon(icon, color: accent, size: 19),
      filled: true,
      fillColor: const Color(0xFF07090E),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E293B)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accent, width: 1.5),
      ),
    );
  }
}

/// Slow-moving Cyan, Purple, and Amber neon spotlights for the Login screen.
class _LivingMarqueeLoginSpotlightPainter extends CustomPainter {
  final double progress;

  const _LivingMarqueeLoginSpotlightPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final angle = progress * math.pi * 2;

    final cyanPos = Offset(
      size.width * (0.20 + 0.18 * math.cos(angle)),
      size.height * (0.22 + 0.12 * math.sin(angle)),
    );
    final purplePos = Offset(
      size.width * (0.80 - 0.16 * math.sin(angle * 0.85)),
      size.height * (0.48 + 0.14 * math.cos(angle * 0.85)),
    );
    final amberPos = Offset(
      size.width * (0.50 + 0.22 * math.sin(angle * 0.65)),
      size.height * (0.82 - 0.10 * math.cos(angle * 0.65)),
    );

    _paintBeam(
      canvas,
      center: cyanPos,
      radius: size.width * 0.72,
      color: const Color(0xFF06B6D4).withOpacity(0.16),
    );
    _paintBeam(
      canvas,
      center: purplePos,
      radius: size.width * 0.74,
      color: const Color(0xFFA855F7).withOpacity(0.15),
    );
    _paintBeam(
      canvas,
      center: amberPos,
      radius: size.width * 0.68,
      color: const Color(0xFFF59E0B).withOpacity(0.14),
    );
  }

  void _paintBeam(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[color, Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(
          covariant _LivingMarqueeLoginSpotlightPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
