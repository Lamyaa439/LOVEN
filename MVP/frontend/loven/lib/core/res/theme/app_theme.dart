import 'package:flutter/material.dart';
import 'package:loven/core/res/dimensions/app_radius.dart';
import 'package:loven/core/res/dimensions/app_sizes.dart';
import 'package:loven/core/res/dimensions/app_spacing.dart';
import 'package:loven/core/res/typography/app_text_styles.dart';

import 'app_colors.dart';

/// Central theme configuration for LOVEN.
///
/// Widgets should consume styling via `Theme.of(context)` — not inline values.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _buildTheme(isDark: false);

  static ThemeData get darkTheme => _buildTheme(isDark: true);

  static ThemeData _buildTheme({required bool isDark}) {
    final canvas = isDark ? AppColors.darkCanvas : AppColors.canvas;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final surfaceSoft =
        isDark ? AppColors.darkSurfaceSoft : AppColors.surfaceSoft;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;
    final inputFill = isDark ? AppColors.darkInputFill : AppColors.inputFill;

    final primary = isDark
        ? AppColors.brandAccent
        : AppColors.brandPrimary;
    final onPrimary = isDark
        ? AppColors.darkButtonPrimaryForeground
        : AppColors.buttonPrimaryForeground;
    final buttonBg = isDark
        ? AppColors.darkButtonPrimaryBackground
        : AppColors.buttonPrimaryBackground;

    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      secondary: AppColors.brandSecondary,
      onSecondary: AppColors.textOnBrand,
      tertiary: AppColors.brandAccent,
      onTertiary: textPrimary,
      error: AppColors.error,
      onError: AppColors.textOnBrand,
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: border,
      outlineVariant: isDark ? AppColors.darkSurfaceElevated : AppColors.borderLight,
      shadow: AppColors.shadowTint,
      scrim: AppColors.scrim,
      inverseSurface: textPrimary,
      onInverseSurface: canvas,
      inversePrimary: AppColors.brandAccent,
      surfaceTint: Colors.transparent,
    );

    final textTheme = AppTextStyles.textTheme(isDark: isDark);

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.sans,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: canvas,
      colorScheme: colorScheme,
      dividerColor: divider,
      shadowColor: AppColors.shadowTint,
      splashColor: textMuted.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      textTheme: textTheme,
      iconTheme: IconThemeData(
        color: textSecondary,
        size: AppSizes.iconMd,
      ),
      primaryIconTheme: IconThemeData(
        color: primary,
        size: AppSizes.iconMd,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: AppSizes.appBarHeight,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: textPrimary, size: AppSizes.iconMd),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: border.withValues(alpha: isDark ? 0.6 : 1)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceSoft,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: isDark ? AppColors.brandAccent : AppColors.buttonPrimaryBackground,
        unselectedItemColor: textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: const IconThemeData(size: AppSizes.iconMd),
        unselectedIconTheme: const IconThemeData(size: AppSizes.iconMd),
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.labelSmall,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBg,
          foregroundColor: onPrimary,
          disabledBackgroundColor: surfaceSoft,
          disabledForegroundColor: textMuted,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: buttonBg,
          foregroundColor: onPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? AppColors.brandAccent : AppColors.brandPrimary,
          side: BorderSide(color: border),
          elevation: 0,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textSecondary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          textStyle: AppTextStyles.link.copyWith(color: textSecondary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textMuted),
        labelStyle: textTheme.labelMedium,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: isDark ? AppColors.brandAccent : AppColors.inputBorderFocused,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? AppColors.darkChipBackground : AppColors.chipBackground,
        selectedColor:
            isDark ? AppColors.brandAccent : AppColors.chipSelectedBackground,
        disabledColor: surfaceSoft,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: isDark ? AppColors.darkTextSecondary : AppColors.chipForeground,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: isDark
              ? AppColors.darkButtonPrimaryForeground
              : AppColors.chipSelectedForeground,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.chipBorder,
          ),
        ),
        showCheckmark: false,
        side: BorderSide.none,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: buttonBg,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textOnBrand,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor:
            isDark ? AppColors.brandAccent : AppColors.badgeBackground,
        textColor: isDark
            ? AppColors.darkButtonPrimaryForeground
            : AppColors.badgeForeground,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
    );
  }
}
