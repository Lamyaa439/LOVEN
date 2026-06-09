import 'package:flutter/material.dart';

/// Semantic color tokens for the LOVEN art marketplace.
///
/// Use these names in UI code — not raw hex values or Material [Colors].
/// Legacy brand names (`primaryBlue`, etc.) are kept as aliases for migration.
class AppColors {
  AppColors._();

  // ── Brand (logo-derived) ───────────────────────────────────────────────────
  static const Color brandPrimary = Color(0xFF293CAE);
  static const Color brandSecondary = Color(0xFFBB84D4);
  static const Color brandAccent = Color(0xFFD0B1E6);

  /// Legacy aliases — prefer semantic tokens in new code.
  static const Color primaryBlue = brandPrimary;
  static const Color deepPurple = brandSecondary;
  static const Color primaryPurple = brandAccent;
  static const Color backgroundGrey = surfaceSoft;

  // ── Canvas & surfaces (light) ──────────────────────────────────────────────
  /// Warm gallery canvas — aligns with native splash `#F9F6F0`.
  static const Color canvas = Color(0xFFF6F7F9);

  /// Primary elevated surface (cards on canvas).
  static const Color surface = Color(0xFFFFFFFF);

  /// Soft tinted surface (chips, muted panels).
  static const Color surfaceSoft = Color(0xFFF2F0EF);

  /// Slightly raised panels (summary blocks, footers).
  static const Color surfaceElevated = Color(0xFFF8F7F4);

  // ── Text (light) ───────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF5C5C66);
  static const Color textMuted = Color(0xFF8E8E96);
  static const Color textOnBrand = Color(0xFFFFFFFF);

  // ── Borders & dividers (light) ───────────────────────────────────────────
  static const Color border = Color(0xFFE4E0DC);
  static const Color borderLight = Color(0xFFF0EDEA);
  static const Color divider = Color(0xFFE8E4E0);

  // ── Interactive ────────────────────────────────────────────────────────────
  /// Primary CTA — refined ink blue, calmer than pure brand on every button.
  static const Color buttonPrimaryBackground = Color(0xFF2A3568);
  static const Color buttonPrimaryForeground = textOnBrand;
  static const Color buttonSecondaryForeground = brandPrimary;

  // ── Inputs ─────────────────────────────────────────────────────────────────
  static const Color inputFill = surface;
  static const Color inputBorder = border;
  static const Color inputBorderFocused = brandPrimary;

  // ── Chips (category / filter pills) ────────────────────────────────────────
  static const Color chipBackground = surfaceElevated;
  static const Color chipBorder = border;
  static const Color chipSelectedBackground = buttonPrimaryBackground;
  static const Color chipSelectedForeground = textOnBrand;
  static const Color chipForeground = textSecondary;

  // ── Status ─────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2D7A5E);
  static const Color warning = Color(0xFFC4923A);
  static const Color error = Color(0xFFB84A42);

  // ── Favorites & badges (refined, not harsh commerce red) ───────────────────
  static const Color favorite = Color(0xFFB87A8A);
  static const Color favoriteEmpty = Color(0xFFC8C4C0);
  static const Color badgeBackground = buttonPrimaryBackground;
  static const Color badgeForeground = textOnBrand;
  static const Color notificationDot = Color(0xFFB84A42);

  // ── Shadows & overlays ─────────────────────────────────────────────────────
  static const Color shadowTint = Color(0x1A1A1A1A);
  static const Color scrim = Color(0x80000000);
  static const Color heroOverlay = Color(0x99000000);

  // ── Dark mode ──────────────────────────────────────────────────────────────
  static const Color darkCanvas = Color(0xFF141416);
  static const Color darkSurface = Color(0xFF1E1E22);
  static const Color darkSurfaceSoft = Color(0xFF26262C);
  static const Color darkSurfaceElevated = Color(0xFF2C2C32);
  static const Color darkTextPrimary = Color(0xFFF4F4F6);
  static const Color darkTextSecondary = Color(0xFFB4B4BC);
  static const Color darkTextMuted = Color(0xFF8A8A94);
  static const Color darkBorder = Color(0xFF3A3A42);
  static const Color darkDivider = Color(0xFF323238);
  static const Color darkInputFill = darkSurface;
  static const Color darkChipBackground = darkSurfaceSoft;
  static const Color darkButtonPrimaryBackground = brandAccent;
  static const Color darkButtonPrimaryForeground = darkCanvas;

  /// Bottom gradient for featured artwork heroes.
  static const LinearGradient heroBottomGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    stops: [0.0, 0.35, 1.0],
    colors: [
      Color(0xB3000000),
      Color(0x4D000000),
      Colors.transparent,
    ],
  );
}
