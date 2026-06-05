import 'package:flutter/material.dart';
import 'app_breakpoints.dart';

extension ResponsiveExtensions on BuildContext {
  double get width => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;

  bool get isMobile => width < AppBreakpoints.mobile;

  bool get isTablet =>
      width >= AppBreakpoints.mobile &&
      width < AppBreakpoints.tablet;

  bool get isDesktop =>
      width >= AppBreakpoints.tablet;

  double responsive({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }
}