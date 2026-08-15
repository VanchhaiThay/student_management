import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';

/// A reusable labeled input field for the Student Management System.
///
/// Automatically adapts its font sizes, padding, and border radius
/// to the current screen class (mobile / tablet / desktop) via [Responsive].
///
/// Example usage:
/// ```dart
/// AppInputField(
///   controller: _emailController,
///   label: 'Email Address',
///   hint: 'teacher@school.edu',
///   icon: Icons.email_outlined,
///   keyboardType: TextInputType.emailAddress,
///   validator: (v) => v!.isEmpty ? 'Required' : null,
/// )
/// ```
class AppInputField extends StatelessWidget {
  const AppInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.enabled = true,
  });

  /// The controller for reading and writing the field's text.
  final TextEditingController controller;

  /// Label shown above the text field.
  final String label;

  /// Placeholder text inside the field when empty.
  final String hint;

  /// Leading icon displayed inside the field.
  final IconData icon;

  /// Keyboard type (e.g. email, phone). Defaults to [TextInputType.text].
  final TextInputType? keyboardType;

  /// Whether to obscure the text (e.g. for passwords).
  final bool obscureText;

  /// Optional widget on the trailing side (e.g. visibility toggle button).
  final Widget? suffixIcon;

  /// Optional validator function for [Form] validation.
  final String? Function(String?)? validator;

  /// Controls the keyboard action button (next, done, etc.).
  final TextInputAction? textInputAction;

  /// Called when the user submits the field via the keyboard action.
  final void Function(String)? onFieldSubmitted;

  /// Whether the field is interactive. Defaults to `true`.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    // ── Responsive tokens ──────────────────────────────────────────────────
    final double labelSize   = r.choose(mobile: 12.5, tablet: 13.0, desktop: 13.5);
    final double textSize    = r.choose(mobile: 14.0, tablet: 14.5, desktop: 15.0);
    final double hintSize    = r.choose(mobile: 13.5, tablet: 14.0, desktop: 14.5);
    final double iconSize    = r.choose(mobile: 18.0, tablet: 20.0, desktop: 20.0);
    final double vPad        = r.inputVerticalPadding;
    final double radius      = r.choose(mobile: 12.0, tablet: 14.0, desktop: 14.0);
    final double labelGap    = r.choose(mobile: 6.0,  tablet: 8.0,  desktop: 8.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ────────────────────────────────────────────────────────────
        Text(
          label,
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: labelGap),

        // ── Text Field ───────────────────────────────────────────────────────
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          enabled: enabled,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: textSize,
          ),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              fontSize: hintSize,
            ),

            // Prefix icon
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, color: AppColors.primary, size: iconSize),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),

            // Suffix (e.g. password toggle)
            suffixIcon: suffixIcon,

            // Fill
            filled: true,
            fillColor: enabled ? AppColors.inputFill : AppColors.border,

            contentPadding: EdgeInsets.symmetric(
              vertical: vPad,
              horizontal: 16,
            ),

            // Borders
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
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.8),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.5)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide:
                  const BorderSide(color: AppColors.error, width: 1.4),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide:
                  const BorderSide(color: AppColors.error, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
