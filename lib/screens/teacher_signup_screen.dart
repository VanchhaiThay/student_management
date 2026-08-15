import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../theme/app_colors.dart';
import '../widgets/widgets.dart';
import 'teacher_signin_screen.dart';

class TeacherSignUpScreen extends StatefulWidget {
  const TeacherSignUpScreen({super.key});

  @override
  State<TeacherSignUpScreen> createState() => _TeacherSignUpScreenState();
}

class _TeacherSignUpScreenState extends State<TeacherSignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ─────────────────────────────────────────────────────────────
  final _fullNameController        = TextEditingController();
  final _emailController           = TextEditingController();
  final _phoneController           = TextEditingController();
  final _teacherIdController       = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _agreeToTerms           = false;
  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading              = false;
  String? _selectedDepartment;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const List<String> _departments = [
    'Mathematics', 'Science', 'English', 'History',
    'Computer Science', 'Arts', 'Physical Education',
    'Social Studies', 'Other',
  ];

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _teacherIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please agree to Terms & Conditions.'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Account created successfully! 🎉'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          // ── ResponsiveLayout: mobile/tablet → scroll, desktop → two-panel ──
          child: ResponsiveLayout.builder(
            mobile:  (r) => _mobileTabletScroll(r),
            tablet:  (r) => _mobileTabletScroll(r),
            desktop: (r) => _desktopTwoPanel(r),
          ),
        ),
      ),
    );
  }

  // ── Desktop two-panel layout ─────────────────────────────────────────────────

  Widget _desktopTwoPanel(Responsive r) {
    return Row(
      children: [
        // Left: branding panel
        Expanded(flex: 5, child: _BrandingPanel()),
        // Right: form panel — uses ResponsiveConstrainedBox to cap width
        Expanded(
          flex: 6,
          child: Container(
            color: AppColors.background,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
              child: ResponsiveConstrainedBox(
                child: _formContent(r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Mobile / Tablet scrollable layout ────────────────────────────────────────

  Widget _mobileTabletScroll(Responsive r) {
    return Stack(
      children: [
        // Background blobs hidden on desktop (branding panel takes over)
        _BackgroundBlobs(),
        SafeArea(
          // ResponsivePagePadding applies r.horizontalPadding automatically
          child: ResponsivePagePadding(
            extraVertical: 0,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 28),
                  // ResponsiveConstrainedBox centres + caps width on tablet
                  ResponsiveConstrainedBox(
                    alignment: Alignment.topLeft,
                    child: _Header(),
                  ),
                  SizedBox(height: r.fieldSpacing * 2),
                  // Form card centred + capped on tablet, full-width on mobile
                  ResponsiveConstrainedBox(
                    child: _formContent(r),
                  ),
                  SizedBox(height: r.fieldSpacing),
                  _SignInRow(),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Form content (shared between mobile/tablet and desktop) ──────────────────

  Widget _formContent(Responsive r) {
    final double spacing = r.fieldSpacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormCard(
          formKey: _formKey,
          r: r,
          spacing: spacing,
          fullNameController: _fullNameController,
          emailController: _emailController,
          phoneController: _phoneController,
          teacherIdController: _teacherIdController,
          passwordController: _passwordController,
          confirmPasswordController: _confirmPasswordController,
          selectedDepartment: _selectedDepartment,
          departments: _departments,
          agreeToTerms: _agreeToTerms,
          obscurePassword: _obscurePassword,
          obscureConfirmPassword: _obscureConfirmPassword,
          isLoading: _isLoading,
          onDepartmentChanged: (v) => setState(() => _selectedDepartment = v),
          onToggleAgree: () => setState(() => _agreeToTerms = !_agreeToTerms),
          onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
          onToggleConfirm: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          onSubmit: _handleSignUp,
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// Stateless sub-widgets — each uses ResponsiveValue for its own tokens
// ════════════════════════════════════════════════════════════════════════════════

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final iconSize = ResponsiveValue<double>(
      context: context, mobile: 52, tablet: 56, desktop: 60,
    ).value;
    final headingSize = ResponsiveValue<double>(
      context: context, mobile: 28, tablet: 32, desktop: 34,
    ).value;
    final subtitleSize = ResponsiveValue<double>(
      context: context, mobile: 13, tablet: 13.5, desktop: 14,
    ).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo badge
        Container(
          width: iconSize, height: iconSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 16, offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(Icons.school_rounded,
              color: Colors.white, size: iconSize * 0.52),
        ),
        const SizedBox(height: 18),
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: headingSize,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Teacher Sign Up — Student Management System',
          style: TextStyle(
            fontSize: subtitleSize,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Form Card ─────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.formKey,
    required this.r,
    required this.spacing,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.teacherIdController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.selectedDepartment,
    required this.departments,
    required this.agreeToTerms,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.isLoading,
    required this.onDepartmentChanged,
    required this.onToggleAgree,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final Responsive r;
  final double spacing;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController teacherIdController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String? selectedDepartment;
  final List<String> departments;
  final bool agreeToTerms;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isLoading;
  final void Function(String?) onDepartmentChanged;
  final VoidCallback onToggleAgree;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final cardRadius = ResponsiveValue<double>(
      context: context, mobile: 20, tablet: 24, desktop: 24,
    ).value;
    final cardPad = ResponsiveValue<double>(
      context: context, mobile: 20, tablet: 28, desktop: 32,
    ).value;

    return Container(
      padding: EdgeInsets.all(cardPad),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            // ── Full Name ─────────────────────────────────────────────────────
            AppInputField(
              controller: fullNameController,
              label: 'Full Name',
              hint: 'e.g. Dr. Sarah Johnson',
              icon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
            ),
            SizedBox(height: spacing),

            // ── Email + Phone (ResponsiveRow: row on tablet+, column on mobile)
            ResponsiveRow(
              spacing: 16,
              columnSpacing: spacing,
              children: [
                AppInputField(
                  controller: emailController,
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
                AppInputField(
                  controller: phoneController,
                  label: 'Phone Number',
                  hint: '+855 12 345 678',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Phone number is required' : null,
                ),
              ],
            ),
            SizedBox(height: spacing),

            // ── Teacher ID + Department (ResponsiveRow) ───────────────────────
            ResponsiveRow(
              spacing: 16,
              columnSpacing: spacing,
              children: [
                AppInputField(
                  controller: teacherIdController,
                  label: 'Teacher ID',
                  hint: 'TCH-2024-001',
                  icon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Teacher ID is required' : null,
                ),
                _DepartmentDropdown(
                  selectedValue: selectedDepartment,
                  departments: departments,
                  onChanged: onDepartmentChanged,
                ),
              ],
            ),
            SizedBox(height: spacing),

            // ── Password + Confirm (ResponsiveRow) ────────────────────────────
            ResponsiveRow(
              spacing: 16,
              columnSpacing: spacing,
              children: [
                AppInputField(
                  controller: passwordController,
                  label: 'Password',
                  hint: 'Min. 8 characters',
                  icon: Icons.lock_outline_rounded,
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.next,
                  suffixIcon: _VisibilityBtn(
                      visible: obscurePassword, onTap: onTogglePassword),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) return 'Min. 8 characters';
                    return null;
                  },
                ),
                AppInputField(
                  controller: confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  suffixIcon: _VisibilityBtn(
                      visible: obscureConfirmPassword, onTap: onToggleConfirm),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm your password';
                    if (v != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
            SizedBox(height: spacing + 4),

            // ── Terms ─────────────────────────────────────────────────────────
            _TermsCheckbox(
              agreed: agreeToTerms,
              onToggle: onToggleAgree,
            ),
            SizedBox(height: spacing + 8),

            // ── Submit ────────────────────────────────────────────────────────
            _SubmitButton(isLoading: isLoading, onPressed: onSubmit),
          ],
        ),
      ),
    );
  }
}

// ── Department Dropdown ───────────────────────────────────────────────────────

class _DepartmentDropdown extends StatelessWidget {
  const _DepartmentDropdown({
    required this.selectedValue,
    required this.departments,
    required this.onChanged,
  });

  final String? selectedValue;
  final List<String> departments;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    final labelSize = ResponsiveValue<double>(
      context: context, mobile: 12.5, tablet: 13, desktop: 13.5,
    ).value;
    final textSize = ResponsiveValue<double>(
      context: context, mobile: 13.5, tablet: 14, desktop: 14.5,
    ).value;
    final vPad = ResponsiveValue<double>(
      context: context, mobile: 14, tablet: 15, desktop: 16,
    ).value;
    final radius = ResponsiveValue<double>(
      context: context, mobile: 12, tablet: 14, desktop: 14,
    ).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Department',
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedValue,
          hint: Text(
            'Select your department',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              fontSize: textSize,
            ),
          ),
          style: TextStyle(color: AppColors.textPrimary, fontSize: textSize),
          dropdownColor: AppColors.surface,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary),
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 14, right: 10),
              child: Icon(Icons.business_outlined,
                  color: AppColors.primary, size: 20),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: AppColors.inputFill,
            contentPadding:
                EdgeInsets.symmetric(vertical: vPad, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: AppColors.error, width: 1.4),
            ),
          ),
          items: departments
              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
              .toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? 'Please select a department' : null,
        ),
      ],
    );
  }
}

// ── Visibility toggle button ──────────────────────────────────────────────────

class _VisibilityBtn extends StatelessWidget {
  const _VisibilityBtn({required this.visible, required this.onTap});
  final bool visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.textSecondary,
        size: 20,
      ),
      onPressed: onTap,
    );
  }
}

// ── Terms Checkbox ────────────────────────────────────────────────────────────

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.agreed, required this.onToggle});
  final bool agreed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveValue<double>(
      context: context, mobile: 12.5, tablet: 13, desktop: 13.5,
    ).value;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22, height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: agreed
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    )
                  : null,
              color: agreed ? null : Colors.transparent,
              border: Border.all(
                color: agreed
                    ? Colors.transparent
                    : AppColors.textSecondary.withValues(alpha: 0.5),
                width: 1.6,
              ),
            ),
            child: agreed
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: fontSize, color: AppColors.textSecondary),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms & Conditions',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Submit Button ─────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isLoading, required this.onPressed});
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final height = ResponsiveValue<double>(
      context: context, mobile: 50, tablet: 52, desktop: 54,
    ).value;
    final fontSize = ResponsiveValue<double>(
      context: context, mobile: 14, tablet: 15, desktop: 15.5,
    ).value;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.centerLeft, end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16, offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.4),
                )
              : Text(
                  'CREATE ACCOUNT',
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
}

// ── Sign In Row ───────────────────────────────────────────────────────────────

class _SignInRow extends StatelessWidget {
  const _SignInRow();

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveValue<double>(
      context: context, mobile: 13.5, tablet: 14, desktop: 14,
    ).value;

    return Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: fontSize, color: AppColors.textSecondary),
          children: [
            const TextSpan(text: 'Already have an account?  '),
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
                      builder: (_) => const TeacherSignInScreen(),
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

// ── Background Blobs ──────────────────────────────────────────────────────────

class _BackgroundBlobs extends StatelessWidget {
  const _BackgroundBlobs();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80, right: -80,
          child: Container(
            width: 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.primary.withValues(alpha: 0.22),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: -60, left: -60,
          child: Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.secondary.withValues(alpha: 0.18),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Desktop Branding Panel ────────────────────────────────────────────────────

class _BrandingPanel extends StatelessWidget {
  const _BrandingPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3730A3), AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -60, left: -60,
              child: _circle(300, Colors.white.withValues(alpha: 0.06))),
          Positioned(bottom: -80, right: -80,
              child: _circle(360, Colors.white.withValues(alpha: 0.05))),
          Positioned(top: 200, right: -40,
              child: _circle(180, Colors.white.withValues(alpha: 0.08))),
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
                        color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: const Icon(Icons.school_rounded,
                      color: Colors.white, size: 34),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Student\nManagement\nSystem',
                  style: TextStyle(
                    fontSize: 38, fontWeight: FontWeight.w800,
                    color: Colors.white, height: 1.2, letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'A powerful platform to manage students,\nteachers, grades, and reports all in one place.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.78),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 48),
                ...[
                  ('📋', 'Complete student record management'),
                  ('📊', 'Real-time grade tracking & analytics'),
                  ('🏫', 'Multi-department teacher portal'),
                  ('🔔', 'Smart notifications & reminders'),
                ].map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(children: [
                        Text(item.$1, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 12),
                        Text(item.$2,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                            )),
                      ]),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
