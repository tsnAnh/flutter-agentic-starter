import 'package:flutter/material.dart';

/// Static semantic color constants (light theme defaults).
abstract final class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryVariant = Color(0xFF1D4ED8);
  static const Color secondary = Color(0xFF7C3AED);
  static const Color secondaryVariant = Color(0xFF6D28D9);

  // Surface / background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color background = Color(0xFFF1F5F9);

  // Semantic
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF0284C7);

  // Text
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onBackground = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
}

/// Static semantic color constants (dark theme defaults).
abstract final class AppColorsDark {
  static const Color primary = Color(0xFF3B82F6);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceVariant = Color(0xFF0F172A);
  static const Color background = Color(0xFF0F172A);
  static const Color error = Color(0xFFF87171);
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);
  static const Color info = Color(0xFF38BDF8);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFF1F5F9);
  static const Color textMuted = Color(0xFF94A3B8);
}

/// ThemeExtension for semantic color tokens beyond Material defaults.
class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  const AppColorsTheme({
    required this.success,
    required this.warning,
    required this.info,
    required this.textMuted,
    required this.surfaceVariant,
  });

  final Color success;
  final Color warning;
  final Color info;
  final Color textMuted;
  final Color surfaceVariant;

  static const light = AppColorsTheme(
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
    textMuted: AppColors.textMuted,
    surfaceVariant: AppColors.surfaceVariant,
  );

  static const dark = AppColorsTheme(
    success: AppColorsDark.success,
    warning: AppColorsDark.warning,
    info: AppColorsDark.info,
    textMuted: AppColorsDark.textMuted,
    surfaceVariant: AppColorsDark.surfaceVariant,
  );

  @override
  AppColorsTheme copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? textMuted,
    Color? surfaceVariant,
  }) =>
      AppColorsTheme(
        success: success ?? this.success,
        warning: warning ?? this.warning,
        info: info ?? this.info,
        textMuted: textMuted ?? this.textMuted,
        surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      );

  @override
  AppColorsTheme lerp(AppColorsTheme? other, double t) {
    if (other == null) return this;
    return AppColorsTheme(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
    );
  }
}

/// BuildContext accessor for [AppColorsTheme].
extension AppColorsThemeX on BuildContext {
  AppColorsTheme get appColors =>
      Theme.of(this).extension<AppColorsTheme>() ?? AppColorsTheme.light;
}
