import 'package:flutter/material.dart';
import 'package:loven/core/res/dimensions/app_spacing.dart';
import 'package:loven/core/res/theme/app_colors.dart';
import 'package:loven/core/widgets/loven_primary_button.dart';
import 'package:loven/core/widgets/loven_secondary_button.dart';

/// Calm empty / error placeholder for gallery surfaces.
class GalleryEmptyState extends StatelessWidget {
  const GalleryEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.usePrimaryAction = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// When true, uses [LovenPrimaryButton]; otherwise outlined secondary.
  final bool usePrimaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
              ),
              child: Icon(
                icon,
                size: 32,
                color: AppColors.favoriteEmpty,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              if (usePrimaryAction)
                LovenPrimaryButton(
                  label: actionLabel!,
                  onPressed: onAction,
                )
              else
                LovenSecondaryButton(
                  label: actionLabel!,
                  onPressed: onAction,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
