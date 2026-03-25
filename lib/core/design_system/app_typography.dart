import 'package:flutter/material.dart';

/// Static typography constants — font sizes following Material 3 type scale.
abstract final class AppTypography {
  static const double displayLargeSize = 57.0;
  static const double displayMediumSize = 45.0;
  static const double displaySmallSize = 36.0;
  static const double headlineLargeSize = 32.0;
  static const double headlineMediumSize = 28.0;
  static const double headlineSmallSize = 24.0;
  static const double titleLargeSize = 22.0;
  static const double titleMediumSize = 16.0;
  static const double titleSmallSize = 14.0;
  static const double bodyLargeSize = 16.0;
  static const double bodyMediumSize = 14.0;
  static const double bodySmallSize = 12.0;
  static const double labelLargeSize = 14.0;
  static const double labelMediumSize = 12.0;
  static const double labelSmallSize = 11.0;
}

/// ThemeExtension for custom typography tokens beyond Material's TextTheme.
class AppTypographyTheme extends ThemeExtension<AppTypographyTheme> {
  const AppTypographyTheme({
    this.displayLarge = const TextStyle(
        fontSize: AppTypography.displayLargeSize, fontWeight: FontWeight.w400),
    this.displayMedium = const TextStyle(
        fontSize: AppTypography.displayMediumSize, fontWeight: FontWeight.w400),
    this.displaySmall = const TextStyle(
        fontSize: AppTypography.displaySmallSize, fontWeight: FontWeight.w400),
    this.headlineLarge = const TextStyle(
        fontSize: AppTypography.headlineLargeSize, fontWeight: FontWeight.w600),
    this.headlineMedium = const TextStyle(
        fontSize: AppTypography.headlineMediumSize, fontWeight: FontWeight.w600),
    this.headlineSmall = const TextStyle(
        fontSize: AppTypography.headlineSmallSize, fontWeight: FontWeight.w600),
    this.titleLarge = const TextStyle(
        fontSize: AppTypography.titleLargeSize, fontWeight: FontWeight.w500),
    this.titleMedium = const TextStyle(
        fontSize: AppTypography.titleMediumSize, fontWeight: FontWeight.w500),
    this.titleSmall = const TextStyle(
        fontSize: AppTypography.titleSmallSize, fontWeight: FontWeight.w500),
    this.bodyLarge = const TextStyle(
        fontSize: AppTypography.bodyLargeSize, fontWeight: FontWeight.w400),
    this.bodyMedium = const TextStyle(
        fontSize: AppTypography.bodyMediumSize, fontWeight: FontWeight.w400),
    this.bodySmall = const TextStyle(
        fontSize: AppTypography.bodySmallSize, fontWeight: FontWeight.w400),
    this.labelLarge = const TextStyle(
        fontSize: AppTypography.labelLargeSize, fontWeight: FontWeight.w500),
    this.labelMedium = const TextStyle(
        fontSize: AppTypography.labelMediumSize, fontWeight: FontWeight.w500),
    this.labelSmall = const TextStyle(
        fontSize: AppTypography.labelSmallSize, fontWeight: FontWeight.w500),
  });

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;

  static const defaults = AppTypographyTheme();

  @override
  AppTypographyTheme copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
  }) =>
      AppTypographyTheme(
        displayLarge: displayLarge ?? this.displayLarge,
        displayMedium: displayMedium ?? this.displayMedium,
        displaySmall: displaySmall ?? this.displaySmall,
        headlineLarge: headlineLarge ?? this.headlineLarge,
        headlineMedium: headlineMedium ?? this.headlineMedium,
        headlineSmall: headlineSmall ?? this.headlineSmall,
        titleLarge: titleLarge ?? this.titleLarge,
        titleMedium: titleMedium ?? this.titleMedium,
        titleSmall: titleSmall ?? this.titleSmall,
        bodyLarge: bodyLarge ?? this.bodyLarge,
        bodyMedium: bodyMedium ?? this.bodyMedium,
        bodySmall: bodySmall ?? this.bodySmall,
        labelLarge: labelLarge ?? this.labelLarge,
        labelMedium: labelMedium ?? this.labelMedium,
        labelSmall: labelSmall ?? this.labelSmall,
      );

  @override
  AppTypographyTheme lerp(AppTypographyTheme? other, double t) {
    if (other == null) return this;
    return AppTypographyTheme(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t)!,
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
    );
  }
}

/// BuildContext accessor for [AppTypographyTheme].
extension AppTypographyThemeX on BuildContext {
  AppTypographyTheme get appTypography =>
      Theme.of(this).extension<AppTypographyTheme>() ??
      AppTypographyTheme.defaults;
}
