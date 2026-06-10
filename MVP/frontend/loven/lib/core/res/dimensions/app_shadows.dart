import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Elevation tokens — gallery UI stays mostly flat; shadows are subtle.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> none = [];

  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: AppColors.shadowTint,
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: AppColors.shadowTint,
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  /// Floating bottom navigation — lighter, airier lift.
  static const List<BoxShadow> floatingNavBar = [
    BoxShadow(
      color: Color(0x121A1A1A),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x081A1A1A),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// Center artist FAB — primary elevation.
  static const List<BoxShadow> floatingNavFab = [
    BoxShadow(
      color: Color(0x388838AE),
      blurRadius: 14,
      offset: Offset(0, 6),
    ),
  ];

  /// Soft purple halo behind the artist FAB.
  static const List<BoxShadow> floatingNavFabHalo = [
    BoxShadow(
      color: AppColors.navFabHaloInner,
      blurRadius: 20,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.navFabHaloOuter,
      blurRadius: 32,
      spreadRadius: 6,
    ),
  ];
}
