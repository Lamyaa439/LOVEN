/// Spacing scale for LOVEN — 4pt base with 8pt rhythm for layout.
///
/// Prefer semantic aliases (`screenPadding`, `sectionGap`) in new screens.
/// Avoid magic numbers like 18, 22, or 26 in feature code.
class AppSpacing {
  AppSpacing._();

  // ── Scale (numeric tokens — existing values preserved) ───────────────────
  static const double none = 0;
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double massive = 48;
  static const double giant = 64;

  // ── Semantic layout (recommended for new screens) ────────────────────────
  /// Horizontal gutter for screen content.
  static const double screenPadding = 24;

  /// Vertical gap between major sections.
  static const double sectionGap = 32;

  /// Inner padding for cards and list tiles.
  static const double cardPadding = 16;

  /// Gap between category/filter chips in a row.
  static const double chipGap = 8;

  /// Cross-axis gap in artwork grids.
  static const double gridCrossGap = 24;

  /// Main-axis gap in artwork grids.
  static const double gridMainGap = 32;

  /// Space below hero / above first section.
  static const double heroGap = 48;

  /// Bottom inset above floating nav (approximate; prefer SafeArea when possible).
  static const double bottomNavClearance = 88;
}
