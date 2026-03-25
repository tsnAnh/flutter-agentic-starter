import 'package:flutter/material.dart';

/// Static shadow definitions for use outside the widget tree.
abstract final class AppShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
  ];
}

/// ThemeExtension for shadow tokens.
class AppShadowsTheme extends ThemeExtension<AppShadowsTheme> {
  const AppShadowsTheme({
    this.sm = AppShadows.sm,
    this.md = AppShadows.md,
    this.lg = AppShadows.lg,
    this.xl = AppShadows.xl,
  });

  final List<BoxShadow> sm;
  final List<BoxShadow> md;
  final List<BoxShadow> lg;
  final List<BoxShadow> xl;

  static const defaults = AppShadowsTheme();

  @override
  AppShadowsTheme copyWith({
    List<BoxShadow>? sm,
    List<BoxShadow>? md,
    List<BoxShadow>? lg,
    List<BoxShadow>? xl,
  }) =>
      AppShadowsTheme(
        sm: sm ?? this.sm,
        md: md ?? this.md,
        lg: lg ?? this.lg,
        xl: xl ?? this.xl,
      );

  @override
  AppShadowsTheme lerp(AppShadowsTheme? other, double t) {
    if (other == null) return this;
    return AppShadowsTheme(
      sm: BoxShadow.lerpList(sm, other.sm, t) ?? sm,
      md: BoxShadow.lerpList(md, other.md, t) ?? md,
      lg: BoxShadow.lerpList(lg, other.lg, t) ?? lg,
      xl: BoxShadow.lerpList(xl, other.xl, t) ?? xl,
    );
  }
}

/// BuildContext accessor for [AppShadowsTheme].
extension AppShadowsThemeX on BuildContext {
  AppShadowsTheme get appShadows =>
      Theme.of(this).extension<AppShadowsTheme>() ?? AppShadowsTheme.defaults;
}
