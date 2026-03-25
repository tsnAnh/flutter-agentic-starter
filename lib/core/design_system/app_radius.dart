import 'package:flutter/material.dart';

/// Static radius constants for use outside the widget tree.
abstract final class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;

  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderFull =
      BorderRadius.all(Radius.circular(full));
}

/// ThemeExtension for border radius tokens.
class AppRadiusTheme extends ThemeExtension<AppRadiusTheme> {
  const AppRadiusTheme({
    this.xs = AppRadius.xs,
    this.sm = AppRadius.sm,
    this.md = AppRadius.md,
    this.lg = AppRadius.lg,
    this.xl = AppRadius.xl,
    this.full = AppRadius.full,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double full;

  static const defaults = AppRadiusTheme();

  BorderRadius get borderXs => BorderRadius.all(Radius.circular(xs));
  BorderRadius get borderSm => BorderRadius.all(Radius.circular(sm));
  BorderRadius get borderMd => BorderRadius.all(Radius.circular(md));
  BorderRadius get borderLg => BorderRadius.all(Radius.circular(lg));
  BorderRadius get borderXl => BorderRadius.all(Radius.circular(xl));
  BorderRadius get borderFull => BorderRadius.all(Radius.circular(full));

  @override
  AppRadiusTheme copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? full,
  }) =>
      AppRadiusTheme(
        xs: xs ?? this.xs,
        sm: sm ?? this.sm,
        md: md ?? this.md,
        lg: lg ?? this.lg,
        xl: xl ?? this.xl,
        full: full ?? this.full,
      );

  @override
  AppRadiusTheme lerp(AppRadiusTheme? other, double t) {
    if (other == null) return this;
    return AppRadiusTheme(
      xs: _lerpDouble(xs, other.xs, t),
      sm: _lerpDouble(sm, other.sm, t),
      md: _lerpDouble(md, other.md, t),
      lg: _lerpDouble(lg, other.lg, t),
      xl: _lerpDouble(xl, other.xl, t),
      full: _lerpDouble(full, other.full, t),
    );
  }

  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// BuildContext accessor for [AppRadiusTheme].
extension AppRadiusThemeX on BuildContext {
  AppRadiusTheme get radius =>
      Theme.of(this).extension<AppRadiusTheme>() ?? AppRadiusTheme.defaults;
}
