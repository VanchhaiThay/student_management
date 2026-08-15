import 'package:flutter/material.dart';

/// Responsive breakpoints and layout helpers for the Student Management System.
///
/// Usage:
/// ```dart
/// final r = Responsive.of(context);
/// if (r.isDesktop) { ... }
/// double pad = r.horizontalPadding;
/// ```
class Responsive {
  Responsive._(this._width);

  factory Responsive.of(BuildContext context) =>
      Responsive._(MediaQuery.sizeOf(context).width);

  final double _width;

  // ── Breakpoints ────────────────────────────────────────────────────────────
  static const double _mobileMax  = 599;
  static const double _tabletMax  = 1023;

  // ── Screen class ──────────────────────────────────────────────────────────
  bool get isMobile  => _width <= _mobileMax;
  bool get isTablet  => _width > _mobileMax && _width <= _tabletMax;
  bool get isDesktop => _width > _tabletMax;

  /// Readable name of the current screen class.
  String get name => isMobile ? 'mobile' : isTablet ? 'tablet' : 'desktop';

  // ── Layout values ─────────────────────────────────────────────────────────

  /// Outer horizontal padding around page content.
  double get horizontalPadding {
    if (isMobile) return 14;
    if (isTablet) return 48;
    return 0; // desktop centres with a fixed card width
  }

  /// Max width of the form card.
  double get formMaxWidth {
    if (isMobile) return double.infinity;
    if (isTablet) return 560;
    return 480;
  }

  /// Padding inside the form card.
  double get cardPadding {
    if (isMobile) return 20;
    if (isTablet) return 32;
    return 36;
  }

  /// Main heading font size.
  double get headingSize {
    if (isMobile) return 28;
    if (isTablet) return 32;
    return 34;
  }

  /// Body / subtitle font size.
  double get subtitleSize {
    if (isMobile) return 13;
    if (isTablet) return 14;
    return 14.5;
  }

  /// Input field height (content padding).
  double get inputVerticalPadding {
    if (isMobile) return 14;
    if (isTablet) return 15;
    return 16;
  }

  /// Space between form fields.
  double get fieldSpacing {
    if (isMobile) return 14;
    if (isTablet) return 16;
    return 18;
  }

  /// Whether the desktop two-panel layout should be shown.
  bool get showTwoPanel => isDesktop;

  // ── Convenience ───────────────────────────────────────────────────────────

  /// Returns [mobile], [tablet], or [desktop] depending on screen size.
  T choose<T>({required T mobile, required T tablet, required T desktop}) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }
}
