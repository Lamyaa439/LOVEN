import 'package:flutter/material.dart';
import 'package:loven/core/res/dimensions/app_spacing.dart';

/// Editorial section header — serif title, optional subtitle, quiet "View all".
class GallerySectionHeader extends StatelessWidget {
  const GallerySectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onViewAll,
    this.viewAllLabel = 'View all',
    this.padding,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onViewAll;
  final String viewAllLabel;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.headlineSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(subtitle!, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(viewAllLabel),
                  const SizedBox(width: AppSpacing.xxs),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
