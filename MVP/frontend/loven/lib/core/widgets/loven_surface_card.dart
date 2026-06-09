import 'package:flutter/material.dart';
import 'package:loven/core/res/dimensions/app_radius.dart';
import 'package:loven/core/res/dimensions/app_spacing.dart';

/// Flat gallery card container — uses [CardTheme] colors, optional tap.
class LovenSurfaceCard extends StatelessWidget {
  const LovenSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      child: child,
    );

    final card = Card(
      margin: margin ?? EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: content,
            )
          : content,
    );

    return card;
  }
}
