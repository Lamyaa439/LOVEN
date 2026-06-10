import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Typography primitives used to build [ThemeData.textTheme].
///
/// Prefer `Theme.of(context).textTheme` in widgets.
/// Use named getters here only when building themes or rare semantic one-offs.
class AppTextStyles {
  AppTextStyles._();

  static const String serif = 'PT Serif';
  static const String sans = 'Almarai';
  static const List<String> serifFallback = [sans];
  static const List<String> sansFallback = [serif];

  // ── Display (editorial / exhibition) ───────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: serif,
    fontFamilyFallback: serifFallback,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.4,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: serif,
    fontFamilyFallback: serifFallback,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.22,
    letterSpacing: -0.3,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: serif,
    fontFamilyFallback: serifFallback,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  // ── Headlines (section titles) ─────────────────────────────────────────────
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: serif,
    fontFamilyFallback: serifFallback,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: serif,
    fontFamilyFallback: serifFallback,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.32,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: serif,
    fontFamilyFallback: serifFallback,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  // ── Titles (artwork names, UI headings) ────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontFamily: sans,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: sans,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: sans,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ── Body ───────────────────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: sans,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: sans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: sans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  // ── Labels & metadata ──────────────────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: sans,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: sans,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: sans,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: 0.2,
  );

  // ── Semantic supplements (use with `.copyWith(color: ...)`) ────────────────
  static const TextStyle exhibitionLabel = TextStyle(
    fontFamily: sans,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    height: 1.2,
  );

  static const TextStyle artworkTitle = titleSmall;
  static const TextStyle artistName = bodySmall;
  static const TextStyle priceMuted = TextStyle(
    fontFamily: sans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.textMuted,
  );

  static const TextStyle link = TextStyle(
    fontFamily: sans,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  /// Builds a full Material 3 [TextTheme] for the given brightness.
  static TextTheme textTheme({required bool isDark}) {
    final primary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return TextTheme(
      displayLarge: displayLarge.copyWith(color: primary),
      displayMedium: displayMedium.copyWith(color: primary),
      displaySmall: displaySmall.copyWith(color: primary),
      headlineLarge: headlineLarge.copyWith(color: primary),
      headlineMedium: headlineMedium.copyWith(color: primary),
      headlineSmall: headlineSmall.copyWith(color: primary),
      titleLarge: titleLarge.copyWith(color: primary),
      titleMedium: titleMedium.copyWith(color: primary),
      titleSmall: titleSmall.copyWith(color: primary),
      bodyLarge: bodyLarge.copyWith(color: primary),
      bodyMedium: bodyMedium.copyWith(color: secondary),
      bodySmall: bodySmall.copyWith(color: muted),
      labelLarge: labelLarge.copyWith(color: primary),
      labelMedium: labelMedium.copyWith(color: secondary),
      labelSmall: labelSmall.copyWith(color: muted),
    );
  }
}
