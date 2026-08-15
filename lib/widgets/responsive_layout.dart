import 'package:flutter/material.dart';
import '../utils/responsive.dart';

/// A widget that renders different layouts based on the current screen size.
///
/// Uses [Responsive] breakpoints:
/// - **Mobile**  : width ≤ 599 px
/// - **Tablet**  : width 600 – 1023 px
/// - **Desktop** : width ≥ 1024 px
///
/// Fallback chain: `desktop → tablet → mobile` (only [mobile] is required).
///
/// ---
/// ### Basic example
/// ```dart
/// ResponsiveLayout(
///   mobile:  MobileSignUpView(),
///   tablet:  TabletSignUpView(),
///   desktop: DesktopSignUpView(),
/// )
/// ```
///
/// ### Builder example (gives access to [Responsive] inside the child)
/// ```dart
/// ResponsiveLayout.builder(
///   mobile:  (r) => Padding(padding: EdgeInsets.all(r.horizontalPadding), child: ...),
///   tablet:  (r) => Center(child: SizedBox(width: r.formMaxWidth, child: ...)),
///   desktop: (r) => Row(children: [...]),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  // ── Static-widget constructor ─────────────────────────────────────────────

  /// Renders [mobile], [tablet], or [desktop] widget for the current screen.
  ///
  /// If [tablet] is omitted, falls back to [mobile].
  /// If [desktop] is omitted, falls back to [tablet] (or [mobile]).
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  })  : _mobileBuilder  = null,
        _tabletBuilder  = null,
        _desktopBuilder = null;

  // ── Builder constructor ───────────────────────────────────────────────────

  /// Calls the matching builder function, passing the current [Responsive]
  /// instance so you can read layout tokens (padding, font sizes, etc.).
  const ResponsiveLayout.builder({
    super.key,
    required Widget Function(Responsive r) mobile,
    Widget Function(Responsive r)? tablet,
    Widget Function(Responsive r)? desktop,
  })  : mobile          = null,
        tablet          = null,
        desktop         = null,
        _mobileBuilder  = mobile,
        _tabletBuilder  = tablet,
        _desktopBuilder = desktop;

  // ── Fields ────────────────────────────────────────────────────────────────

  /// Static widget for mobile screens.
  final Widget? mobile;

  /// Static widget for tablet screens (optional; falls back to [mobile]).
  final Widget? tablet;

  /// Static widget for desktop screens (optional; falls back to [tablet]).
  final Widget? desktop;

  final Widget Function(Responsive r)? _mobileBuilder;
  final Widget Function(Responsive r)? _tabletBuilder;
  final Widget Function(Responsive r)? _desktopBuilder;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    // Builder mode
    if (_mobileBuilder != null) {
      final mb = _mobileBuilder;
      final tb = _tabletBuilder;
      final db = _desktopBuilder;
      if (r.isDesktop && db != null) return db(r);
      if (r.isTablet  && tb != null) return tb(r);
      return mb(r);
    }

    // Static-widget mode
    if (r.isDesktop) return desktop ?? tablet ?? mobile!;
    if (r.isTablet)  return tablet  ?? mobile!;
    return mobile!;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ResponsiveValue — pick a typed value per breakpoint
// ─────────────────────────────────────────────────────────────────────────────

/// Resolves a typed value (e.g. `double`, `EdgeInsets`, `TextStyle`) based
/// on the current screen class. Falls back: desktop → tablet → mobile.
///
/// ```dart
/// double pad = ResponsiveValue(
///   context: context,
///   mobile:  12,
///   tablet:  24,
///   desktop: 48,
/// ).value;
/// ```
class ResponsiveValue<T> {
  const ResponsiveValue({
    required this.context,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final BuildContext context;
  final T mobile;
  final T? tablet;
  final T? desktop;

  /// Returns the resolved value for the current screen class.
  T get value {
    final r = Responsive.of(context);
    if (r.isDesktop) return desktop ?? tablet ?? mobile;
    if (r.isTablet)  return tablet  ?? mobile;
    return mobile;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ResponsiveConstrainedBox — centred, max-width box
// ─────────────────────────────────────────────────────────────────────────────

/// Centers [child] and limits its width using [Responsive.formMaxWidth].
///
/// Ideal for forms, cards, and content panels on tablet/desktop.
///
/// ```dart
/// ResponsiveConstrainedBox(
///   child: MyFormCard(),
/// )
/// ```
class ResponsiveConstrainedBox extends StatelessWidget {
  const ResponsiveConstrainedBox({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: r.formMaxWidth),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ResponsivePagePadding — adaptive horizontal page padding
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps [child] with horizontal padding derived from [Responsive.horizontalPadding].
///
/// ```dart
/// ResponsivePagePadding(
///   child: MyPageContent(),
/// )
/// ```
class ResponsivePagePadding extends StatelessWidget {
  const ResponsivePagePadding({
    super.key,
    required this.child,
    this.extraVertical = 0,
  });

  final Widget child;

  /// Additional vertical padding (top & bottom) in addition to the adaptive
  /// horizontal padding.
  final double extraVertical;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: r.horizontalPadding,
        vertical: extraVertical,
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ResponsiveRow — row on tablet/desktop, column on mobile
// ─────────────────────────────────────────────────────────────────────────────

/// Lays out [children] in a [Row] on tablet/desktop, and a [Column] on mobile.
///
/// ```dart
/// ResponsiveRow(
///   spacing: 16,
///   children: [FieldA(), FieldB()],
/// )
/// ```
class ResponsiveRow extends StatelessWidget {
  const ResponsiveRow({
    super.key,
    required this.children,
    this.spacing = 16,
    this.columnSpacing,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final List<Widget> children;

  /// Horizontal gap between items in Row mode.
  final double spacing;

  /// Vertical gap between items in Column mode (defaults to [spacing]).
  final double? columnSpacing;

  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    if (r.isMobile) {
      final double gap = columnSpacing ?? spacing;
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        children: _intersperse(children, SizedBox(height: gap)).toList(),
      );
    }

    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: _intersperse(
        children.map((c) => Expanded(child: c)).toList(),
        SizedBox(width: spacing),
      ).toList(),
    );
  }

  Iterable<Widget> _intersperse(List<Widget> items, Widget separator) sync* {
    for (var i = 0; i < items.length; i++) {
      yield items[i];
      if (i < items.length - 1) yield separator;
    }
  }
}
