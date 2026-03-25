import 'package:flutter/material.dart';

/// Static spacing constants for use outside the widget tree.
abstract final class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// ThemeExtension for spacing tokens — allows per-theme overrides.
class AppSpacingTheme extends ThemeExtension<AppSpacingTheme> {
  const AppSpacingTheme({
    this.xs = AppSpacing.xs,
    this.sm = AppSpacing.sm,
    this.md = AppSpacing.md,
    this.lg = AppSpacing.lg,
    this.xl = AppSpacing.xl,
    this.xxl = AppSpacing.xxl,
    this.xxxl = AppSpacing.xxxl,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;

  static const defaults = AppSpacingTheme();

  @override
  AppSpacingTheme copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
  }) =>
      AppSpacingTheme(
        xs: xs ?? this.xs,
        sm: sm ?? this.sm,
        md: md ?? this.md,
        lg: lg ?? this.lg,
        xl: xl ?? this.xl,
        xxl: xxl ?? this.xxl,
        xxxl: xxxl ?? this.xxxl,
      );

  @override
  AppSpacingTheme lerp(AppSpacingTheme? other, double t) {
    if (other == null) return this;
    return AppSpacingTheme(
      xs: _lerpDouble(xs, other.xs, t),
      sm: _lerpDouble(sm, other.sm, t),
      md: _lerpDouble(md, other.md, t),
      lg: _lerpDouble(lg, other.lg, t),
      xl: _lerpDouble(xl, other.xl, t),
      xxl: _lerpDouble(xxl, other.xxl, t),
      xxxl: _lerpDouble(xxxl, other.xxxl, t),
    );
  }

  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// BuildContext accessor for [AppSpacingTheme].
extension AppSpacingThemeX on BuildContext {
  AppSpacingTheme get spacing =>
      Theme.of(this).extension<AppSpacingTheme>() ?? AppSpacingTheme.defaults;
}
