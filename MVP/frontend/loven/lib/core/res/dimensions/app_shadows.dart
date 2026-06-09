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
}
