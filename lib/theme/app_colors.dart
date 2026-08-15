import 'package:flutter/material.dart';

/// Central color palette for the Student Management System.
///
/// Use these constants throughout the app to keep the design consistent.
/// Import with: `import '../theme/app_colors.dart';`
abstract final class AppColors {
  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary   = Color(0xFF4F46E5); // Indigo 600
  static const Color secondary = Color(0xFF7C3AED); // Violet 600

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF4F6FB);
  static const Color surface    = Colors.white;
  static const Color inputFill  = Color(0xFFF8F9FC);

  // ── Borders ───────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE4E8F0);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1D27);
  static const Color textSecondary = Color(0xFF6B7280);

  // ── Feedback ──────────────────────────────────────────────────────────────
  static const Color error   = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
}
