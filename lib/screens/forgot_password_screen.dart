import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../widgets/app_input_field.dart';
import 'teacher_signin_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey        = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading  = false;
  bool _emailSent  = false;

  late AnimationController _animController;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  // Success animation
  late Animation<double> _successScaleAnim;

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
    ).animate(CurvedAnimation(
        parent: _animController, curve: Curves.easeOut));
    _successScaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ─── Actions ────────────────────────────────────────────────────────────────

  void _handleSendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
      _emailSent = true;
    });
    // Re-run animation for the success state
    _animController.reset();
    _animController.forward();
  }

  void _handleResend() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reset link resent successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
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
        Expanded(flex: 5, child: _buildBrandingPanel()),
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
                      _emailSent
                          ? _buildSuccessCard(r)
                          : _buildFormCard(r),
                      SizedBox(height: r.fieldSpacing),
                      _buildBackToSignIn(r),
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
          // Back button
          _buildBackButton(),
          const SizedBox(height: 16),
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
                child: _emailSent
                    ? _buildSuccessCard(r)
                    : _buildFormCard(r),
              ),
            )
          else
            (_emailSent ? _buildSuccessCard(r) : _buildFormCard(r)),
          SizedBox(height: r.fieldSpacing),
          _buildBackToSignIn(r),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // ─── Back button ─────────────────────────────────────────────────────────

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary, size: 16),
      ),
    );
  }

  // ─── Background blobs ─────────────────────────────────────────────────────

  Widget _buildBackgroundBlobs(Responsive r) {
    if (r.isDesktop) return const SizedBox.shrink();
    return Stack(
      children: [
        Positioned(
          top: -80, right: -60,
          child: Container(
            width: 260, height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.primary.withValues(alpha: 0.18),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: -60, left: -60,
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.secondary.withValues(alpha: 0.15),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Branding Panel (desktop) ─────────────────────────────────────────────

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
            top: 220, right: -40,
            child: _blurCircle(160, Colors.white.withValues(alpha: 0.08)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5),
                  ),
                  child: const Icon(Icons.lock_reset_rounded,
                      color: Colors.white, size: 34),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Forgot Your\nPassword?',
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
                  'No worries! Enter your email and we\'ll\nsend you a link to reset your password.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.78),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 48),
                ...[
                  ('📧', 'Check your inbox for the link'),
                  ('⏱️', 'Link expires in 15 minutes'),
                  ('🔒', 'Secure password reset process'),
                  ('🔁', 'Can resend if email not received'),
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
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(Responsive r) {
    final double iconSize    = r.choose(mobile: 52.0, tablet: 56.0, desktop: 60.0);
    final double headingSize = r.choose(mobile: 26.0, tablet: 30.0, desktop: 32.0);
    final double subSize     = r.choose(mobile: 13.0, tablet: 13.5, desktop: 14.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon badge
        Container(
          width: iconSize, height: iconSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(Icons.lock_reset_rounded,
              color: Colors.white, size: iconSize * 0.46),
        ),
        const SizedBox(height: 18),
        Text(
          'Forgot Password',
          style: TextStyle(
            fontSize: headingSize,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter your email to receive a reset link',
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
              textInputAction: TextInputAction.done,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(v)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            SizedBox(height: spacing + 4),

            // ── Info note ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: r.choose(mobile: 16.0, tablet: 17.0, desktop: 18.0)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'We\'ll send a password reset link to this email if it\'s registered.',
                      style: TextStyle(
                        fontSize:
                            r.choose(mobile: 12.0, tablet: 12.5, desktop: 13.0),
                        color: AppColors.primary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing + 8),

            // ── Send Reset Link Button ─────────────────────────────────────
            _buildSendButton(r),
          ],
        ),
      ),
    );
  }

  // ─── Success Card ─────────────────────────────────────────────────────────

  Widget _buildSuccessCard(Responsive r) {
    final double fontSize = r.choose(mobile: 13.5, tablet: 14.0, desktop: 14.5);
    final double titleSize = r.choose(mobile: 18.0, tablet: 20.0, desktop: 22.0);

    return ScaleTransition(
      scale: _successScaleAnim,
      child: Container(
        width: double.infinity,
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
        child: Column(
          children: [
            // Success icon
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.success, Color(0xFF16A34A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.mark_email_read_rounded,
                  color: Colors.white, size: 34),
            ),
            const SizedBox(height: 20),
            Text(
              'Check Your Email!',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'We\'ve sent a password reset link to',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: fontSize, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              _emailController.text.trim(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Steps guide
            _buildStepItem('1', 'Open your email inbox', fontSize),
            const SizedBox(height: 10),
            _buildStepItem('2', 'Click the reset link in the email', fontSize),
            const SizedBox(height: 10),
            _buildStepItem('3', 'Create your new password', fontSize),
            const SizedBox(height: 28),

            // Resend button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleResend,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary))
                    : const Icon(Icons.refresh_rounded,
                        size: 18, color: AppColors.primary),
                label: Text(
                  _isLoading ? 'Resending...' : 'Resend Email',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(String step, String text, double fontSize) {
    return Row(
      children: [
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Send Reset Link Button ────────────────────────────────────────────────

  Widget _buildSendButton(Responsive r) {
    final double height   = r.choose(mobile: 50.0, tablet: 52.0, desktop: 54.0);
    final double fontSize = r.choose(mobile: 14.0, tablet: 15.0, desktop: 15.5);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), AppColors.secondary],
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
          onPressed: _isLoading ? null : _handleSendReset,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.4))
              : Text(
                  'SEND RESET LINK',
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

  // ─── Back to Sign In ──────────────────────────────────────────────────────

  Widget _buildBackToSignIn(Responsive r) {
    final double fontSize = r.choose(mobile: 13.5, tablet: 14.0, desktop: 14.0);

    return Center(
      child: RichText(
        text: TextSpan(
          style:
              TextStyle(fontSize: fontSize, color: AppColors.textSecondary),
          children: [
            const TextSpan(text: 'Remember your password?  '),
            TextSpan(
              text: 'Sign In',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const TeacherSignInScreen()),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}
