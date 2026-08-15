import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/auth_provider.dart';
import 'package:flutter/gestures.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../widgets/app_input_field.dart';

import 'teacher_signup_screen.dart';
import 'forgot_password_screen.dart';

class TeacherSignInScreen extends ConsumerStatefulWidget {
  const TeacherSignInScreen({super.key});

  @override
  ConsumerState<TeacherSignInScreen> createState() => _TeacherSignInScreenState();
}

class _TeacherSignInScreenState extends ConsumerState<TeacherSignInScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe      = false;
  bool get _isLoading => ref.watch(authProvider).isLoading;

  late AnimationController _animController;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  // ─── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
        parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Actions ────────────────────────────────────────────────────────────────

  void _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    
    final success = await ref.read(authProvider.notifier).signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Signed in securely via JWT! 🚀'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Invalid email or password.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _handleForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ForgotPasswordScreen(),
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackgroundBlobs(r),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: r.showTwoPanel
                    ? _buildDesktopLayout(r)
                    : _buildMobileTabletLayout(r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Desktop: two-panel ───────────────────────────────────────────────────

  Widget _buildDesktopLayout(Responsive r) {
    return Row(
      children: [
        // Left: branding panel
        Expanded(flex: 5, child: _buildBrandingPanel()),
        // Right: form
        Expanded(
          flex: 6,
          child: Container(
            color: AppColors.background,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 48, vertical: 40),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: r.formMaxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(r),
                      SizedBox(height: r.fieldSpacing * 1.8),
                      _buildFormCard(r),
                      SizedBox(height: r.fieldSpacing),
                      _buildSignUpRow(r),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Mobile / Tablet ──────────────────────────────────────────────────────

  Widget _buildMobileTabletLayout(Responsive r) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: r.horizontalPadding, vertical: 0),
      child: Column(
        crossAxisAlignment: r.isTablet
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          if (r.isTablet)
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: r.formMaxWidth),
                child: _buildHeader(r),
              ),
            )
          else
            _buildHeader(r),
          SizedBox(height: r.fieldSpacing * 2),
          if (r.isTablet)
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: r.formMaxWidth),
                child: _buildFormCard(r),
              ),
            )
          else
            _buildFormCard(r),
          SizedBox(height: r.fieldSpacing),
          _buildSignUpRow(r),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // ─── Background blobs ─────────────────────────────────────────────────────

  Widget _buildBackgroundBlobs(Responsive r) {
    if (r.isDesktop) return const SizedBox.shrink();
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.secondary.withValues(alpha: 0.22),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          left: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.primary.withValues(alpha: 0.18),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Branding Panel (desktop only) ────────────────────────────────────────

  Widget _buildBrandingPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF3730A3),
            AppColors.primary,
            AppColors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60, left: -60,
            child: _blurCircle(300, Colors.white.withValues(alpha: 0.06)),
          ),
          Positioned(
            bottom: -80, right: -80,
            child: _blurCircle(360, Colors.white.withValues(alpha: 0.05)),
          ),
          Positioned(
            top: 200, right: -40,
            child: _blurCircle(180, Colors.white.withValues(alpha: 0.08)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5),
                  ),
                  child: const Icon(Icons.school_rounded,
                      color: Colors.white, size: 34),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Welcome\nBack,\nTeacher!',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sign in to access your dashboard,\nstudent records, and more.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.78),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 48),
                ...[
                  ('📋', 'Manage student records easily'),
                  ('📊', 'Track grades & performance'),
                  ('🏫', 'Multi-department access'),
                  ('🔒', 'Secure & encrypted sessions'),
                ].map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          Text(item.$1,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 12),
                          Text(
                            item.$2,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blurCircle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(Responsive r) {
    final double iconSize    = r.choose(mobile: 52.0, tablet: 56.0, desktop: 60.0);
    final double headingSize = r.choose(mobile: 28.0, tablet: 32.0, desktop: 34.0);
    final double subSize     = r.choose(mobile: 13.0, tablet: 13.5, desktop: 14.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo badge
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(Icons.login_rounded,
              color: Colors.white, size: iconSize * 0.48),
        ),
        const SizedBox(height: 18),
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: headingSize,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to your teacher account',
          style: TextStyle(
            fontSize: subSize,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─── Form Card ────────────────────────────────────────────────────────────

  Widget _buildFormCard(Responsive r) {
    final double spacing = r.fieldSpacing;

    return Container(
      padding: EdgeInsets.all(r.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
            r.choose(mobile: 20.0, tablet: 24.0, desktop: 24.0)),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Email ──────────────────────────────────────────────────────
            AppInputField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'teacher@school.edu',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(v)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            SizedBox(height: spacing),

            // ── Password ───────────────────────────────────────────────────
            AppInputField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              suffixIcon: _visibilityButton(
                visible: _obscurePassword,
                onTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 8) return 'Min. 8 characters';
                return null;
              },
            ),
            SizedBox(height: spacing - 2),

            // ── Remember me + Forgot password ──────────────────────────────
            _buildRememberRow(r),
            SizedBox(height: spacing + 8),

            // ── Sign In Button ─────────────────────────────────────────────
            _buildSignInButton(r),

            SizedBox(height: spacing),

            // ── Divider ────────────────────────────────────────────────────
            _buildDivider(),

            SizedBox(height: spacing),

            // ── Google SSO (placeholder) ───────────────────────────────────
            _buildGoogleButton(r),
          ],
        ),
      ),
    );
  }

  // ─── Remember me + Forgot password row ────────────────────────────────────

  Widget _buildRememberRow(Responsive r) {
    final double fontSize = r.choose(mobile: 12.5, tablet: 13.0, desktop: 13.0);

    return Row(
      children: [
        // Animated checkbox
        GestureDetector(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: _rememberMe
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: _rememberMe ? null : Colors.transparent,
              border: Border.all(
                color: _rememberMe
                    ? Colors.transparent
                    : AppColors.textSecondary.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: _rememberMe
                ? const Icon(Icons.check, color: Colors.white, size: 12)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Remember me',
          style: TextStyle(
              fontSize: fontSize, color: AppColors.textSecondary),
        ),
        const Spacer(),
        // Forgot password
        GestureDetector(
          onTap: _handleForgotPassword,
          child: Text(
            'Forgot password?',
            style: TextStyle(
              fontSize: fontSize,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Sign In button ────────────────────────────────────────────────────────

  Widget _buildSignInButton(Responsive r) {
    final double height   = r.choose(mobile: 50.0, tablet: 52.0, desktop: 54.0);
    final double fontSize = r.choose(mobile: 14.0, tablet: 15.0, desktop: 15.5);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.secondary, AppColors.primary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.4),
                )
              : Text(
                  'SIGN IN',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
        ),
      ),
    );
  }

  // ─── Divider ──────────────────────────────────────────────────────────────

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
              color: AppColors.border, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
              color: AppColors.border, thickness: 1),
        ),
      ],
    );
  }

  // ─── Google SSO button ────────────────────────────────────────────────────

  Widget _buildGoogleButton(Responsive r) {
    final double height   = r.choose(mobile: 48.0, tablet: 50.0, desktop: 52.0);
    final double fontSize = r.choose(mobile: 13.5, tablet: 14.0, desktop: 14.5);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Text('G',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4285F4),
            )),
        label: Text(
          'Sign in with Google',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border, width: 1.4),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // ─── Visibility toggle ────────────────────────────────────────────────────

  Widget _visibilityButton(
      {required bool visible, required VoidCallback onTap}) {
    return IconButton(
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.textSecondary,
        size: 20,
      ),
      onPressed: onTap,
    );
  }

  // ─── Sign Up Row ──────────────────────────────────────────────────────────

  Widget _buildSignUpRow(Responsive r) {
    final double fontSize = r.choose(mobile: 13.5, tablet: 14.0, desktop: 14.0);

    return Center(
      child: RichText(
        text: TextSpan(
          style:
              TextStyle(fontSize: fontSize, color: AppColors.textSecondary),
          children: [
            const TextSpan(text: "Don't have an account?  "),
            TextSpan(
              text: 'Sign Up',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TeacherSignUpScreen(),
                    ),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}

