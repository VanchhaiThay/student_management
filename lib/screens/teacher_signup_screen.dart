import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../widgets/app_input_field.dart';

class TeacherSignUpScreen extends StatefulWidget {
  const TeacherSignUpScreen({super.key});

  @override
  State<TeacherSignUpScreen> createState() => _TeacherSignUpScreenState();
}

class _TeacherSignUpScreenState extends State<TeacherSignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _fullNameController        = TextEditingController();
  final _emailController           = TextEditingController();
  final _phoneController           = TextEditingController();
  final _teacherIdController       = TextEditingController();
  final _departmentController      = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _agreeToTerms           = false;
  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading              = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<String> _departments = [
    'Mathematics',
    'Science',
    'English',
    'History',
    'Computer Science',
    'Arts',
    'Physical Education',
    'Social Studies',
    'Other',
  ];
  String? _selectedDepartment;

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _teacherIdController.dispose();
    _departmentController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to Terms & Conditions.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Account created successfully! 🎉'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

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
                // ── Layout switch ────────────────────────────────────────────
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
        // Left branding panel
        Expanded(
          flex: 5,
          child: _buildBrandingPanel(),
        ),
        // Right form panel
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
                      _buildSignInRow(r),
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

  /// Left side gradient branding panel shown only on desktop.
  Widget _buildBrandingPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3730A3), AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -60,
            left: -60,
            child: _blurCircle(300, Colors.white.withValues(alpha: 0.06)),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: _blurCircle(360, Colors.white.withValues(alpha: 0.05)),
          ),
          Positioned(
            top: 200,
            right: -40,
            child: _blurCircle(180, Colors.white.withValues(alpha: 0.08)),
          ),
          // Content
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
                        color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: const Icon(Icons.school_rounded,
                      color: Colors.white, size: 34),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Student\nManagement\nSystem',
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
                  'A powerful platform to manage students,\nteachers, grades, and reports all in one place.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.78),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 48),
                // Feature bullets
                ...[
                  ('📋', 'Complete student record management'),
                  ('📊', 'Real-time grade tracking & analytics'),
                  ('🏫', 'Multi-department teacher portal'),
                  ('🔔', 'Smart notifications & reminders'),
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

  Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  // ─── Mobile / Tablet: single-column scrollable ────────────────────────────

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
          // On tablet: center the header + constrain width
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
          // Center form card on tablet
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
          _buildSignInRow(r),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // ─── Background blobs ─────────────────────────────────────────────────────

  Widget _buildBackgroundBlobs(Responsive r) {
    // Hide on desktop — branding panel provides its own background
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
                AppColors.primary.withValues(alpha: 0.22),
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
                AppColors.secondary.withValues(alpha: 0.18),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(Responsive r) {
    final double iconSize = r.choose(mobile: 52.0, tablet: 56.0, desktop: 60.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo badge
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
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
            fontSize: r.headingSize,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Teacher Sign Up — Student Management System',
          style: TextStyle(
            fontSize: r.subtitleSize,
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
        borderRadius: BorderRadius.circular(r.choose(
            mobile: 20.0, tablet: 24.0, desktop: 24.0)),
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
          children: [
            AppInputField(
              controller: _fullNameController,
              label: 'Full Name',
              hint: 'e.g. Dr. Sarah Johnson',
              icon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
            ),
            SizedBox(height: spacing),

            // On tablet+ show Email & Phone side by side
            if (r.isTablet || r.isDesktop)
              _buildRow(
                left: AppInputField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'teacher@school.edu',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(v)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                right: AppInputField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '+855 12 345 678',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Phone is required' : null,
                ),
              )
            else ...[
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
              AppInputField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '+855 12 345 678',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Phone number is required' : null,
              ),
            ],
            SizedBox(height: spacing),

            // Teacher ID + Department side by side on tablet+
            if (r.isTablet || r.isDesktop)
              _buildRow(
                left: AppInputField(
                  controller: _teacherIdController,
                  label: 'Teacher ID',
                  hint: 'TCH-2024-001',
                  icon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Teacher ID is required' : null,
                ),
                right: _buildDepartmentDropdown(r),
              )
            else ...[
              AppInputField(
                controller: _teacherIdController,
                label: 'Teacher ID',
                hint: 'TCH-2024-001',
                icon: Icons.badge_outlined,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Teacher ID is required' : null,
              ),
              SizedBox(height: spacing),
              _buildDepartmentDropdown(r),
            ],
            SizedBox(height: spacing),

            // Password + Confirm side by side on desktop
            if (r.isDesktop)
              _buildRow(
                left: AppInputField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Min. 8 characters',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
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
                right: AppInputField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  suffixIcon: _visibilityButton(
                    visible: _obscureConfirmPassword,
                    onTap: () => setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm password';
                    if (v != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              )
            else ...[
              AppInputField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Min. 8 characters',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                suffixIcon: _visibilityButton(
                  visible: _obscurePassword,
                  onTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing),
              AppInputField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: 'Re-enter your password',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                suffixIcon: _visibilityButton(
                  visible: _obscureConfirmPassword,
                  onTap: () => setState(() =>
                      _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please confirm your password';
                  if (v != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
            SizedBox(height: spacing + 4),

            _buildTermsCheckbox(r),
            SizedBox(height: spacing + 8),

            _buildCreateAccountButton(r),
          ],
        ),
      ),
    );
  }

  /// Two equal columns with a gap.
  Widget _buildRow({required Widget left, required Widget right}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  // ─── Department Dropdown ──────────────────────────────────────────────────

  Widget _buildDepartmentDropdown(Responsive r) {
    final double labelSize =
        r.choose(mobile: 12.5, tablet: 13.0, desktop: 13.5);
    final double hintSize =
        r.choose(mobile: 13.5, tablet: 14.0, desktop: 14.5);
    final double vPad = r.inputVerticalPadding;

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
          initialValue: _selectedDepartment,
          hint: Text(
            'Select your department',
            style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: hintSize),
          ),
          style: TextStyle(color: AppColors.textPrimary, fontSize: hintSize),
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
              borderRadius: BorderRadius.circular(
                  r.choose(mobile: 12.0, tablet: 14.0, desktop: 14.0)),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  r.choose(mobile: 12.0, tablet: 14.0, desktop: 14.0)),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  r.choose(mobile: 12.0, tablet: 14.0, desktop: 14.0)),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  r.choose(mobile: 12.0, tablet: 14.0, desktop: 14.0)),
              borderSide:
                  const BorderSide(color: AppColors.error, width: 1.4),
            ),
          ),
          items: _departments
              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
              .toList(),
          onChanged: (v) => setState(() => _selectedDepartment = v),
          validator: (v) => v == null ? 'Please select a department' : null,
        ),
      ],
    );
  }

  // ─── Visibility toggle button ─────────────────────────────────────────────

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

  // ─── Terms Checkbox ───────────────────────────────────────────────────────

  Widget _buildTermsCheckbox(Responsive r) {
    final double fontSize =
        r.choose(mobile: 12.5, tablet: 13.0, desktop: 13.5);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: _agreeToTerms
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: _agreeToTerms ? null : Colors.transparent,
              border: Border.all(
                color: _agreeToTerms
                    ? Colors.transparent
                    : AppColors.textSecondary.withValues(alpha: 0.5),
                width: 1.6,
              ),
            ),
            child: _agreeToTerms
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                  fontSize: fontSize, color: AppColors.textSecondary),
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

  // ─── Create Account Button ────────────────────────────────────────────────

  Widget _buildCreateAccountButton(Responsive r) {
    final double btnHeight =
        r.choose(mobile: 50.0, tablet: 52.0, desktop: 54.0);
    final double fontSize =
        r.choose(mobile: 14.0, tablet: 15.0, desktop: 15.5);
    return SizedBox(
      width: double.infinity,
      height: btnHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSignUp,
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

  // ─── Sign In Row ──────────────────────────────────────────────────────────

  Widget _buildSignInRow(Responsive r) {
    final double fontSize =
        r.choose(mobile: 13.5, tablet: 14.0, desktop: 14.0);
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
              recognizer: TapGestureRecognizer()..onTap = () {},
            ),
          ],
        ),
      ),
    );
  }
}
