import 'package:flutter/material.dart';

import '../dimensions/app_spacing.dart';
import 'responsive_extensions.dart';

class ResponsivePage extends StatelessWidget {
  final Widget child;
  final bool scrollable;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment crossAxisAlignment;

  const ResponsivePage({
    super.key,
    required this.child,
    this.scrollable = true,
    this.maxWidth = 720,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedPadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: context.responsive(
            mobile: AppSpacing.lg,
            tablet: AppSpacing.xxl,
            desktop: AppSpacing.xxxl,
          ),
          vertical: context.responsive(
            mobile: AppSpacing.lg,
            tablet: AppSpacing.xxl,
            desktop: AppSpacing.xxxl,
          ),
        );

    final content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: resolvedPadding,
          child: child,
        ),
      ),
    );

    if (!scrollable) return content;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: content,
    );
  }
}