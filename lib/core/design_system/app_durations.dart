import 'package:flutter/material.dart';

/// Static animation duration constants for use outside the widget tree.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration xSlow = Duration(milliseconds: 1000);
}

/// ThemeExtension for animation duration tokens.
class AppDurationsTheme extends ThemeExtension<AppDurationsTheme> {
  const AppDurationsTheme({
    this.fast = AppDurations.fast,
    this.normal = AppDurations.normal,
    this.slow = AppDurations.slow,
    this.xSlow = AppDurations.xSlow,
  });

  final Duration fast;
  final Duration normal;
  final Duration slow;
  final Duration xSlow;

  static const defaults = AppDurationsTheme();

  @override
  AppDurationsTheme copyWith({
    Duration? fast,
    Duration? normal,
    Duration? slow,
    Duration? xSlow,
  }) =>
      AppDurationsTheme(
        fast: fast ?? this.fast,
        normal: normal ?? this.normal,
        slow: slow ?? this.slow,
        xSlow: xSlow ?? this.xSlow,
      );

  @override
  AppDurationsTheme lerp(AppDurationsTheme? other, double t) {
    // Durations are discrete — snap at midpoint.
    if (other == null) return this;
    return t < 0.5 ? this : other;
  }
}

/// BuildContext accessor for [AppDurationsTheme].
extension AppDurationsThemeX on BuildContext {
  AppDurationsTheme get appDurations =>
      Theme.of(this).extension<AppDurationsTheme>() ??
      AppDurationsTheme.defaults;
}
