import 'package:flutter/material.dart';
import 'package:loven/core/res/dimensions/app_radius.dart';
import 'package:loven/core/res/dimensions/app_spacing.dart';
import 'package:loven/core/res/theme/app_colors.dart';

/// Category / filter pill — token-based, not raw [Chip] defaults.
class GalleryChip extends StatelessWidget {
  const GalleryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final background = selected
        ? (isDark
            ? AppColors.brandAccent
            : AppColors.chipSelectedBackground)
        : (isDark ? AppColors.darkChipBackground : AppColors.chipBackground);

    final foreground = selected
        ? (isDark
            ? AppColors.darkButtonPrimaryForeground
            : AppColors.chipSelectedForeground)
        : (isDark ? AppColors.darkTextSecondary : AppColors.chipForeground);

    final borderColor = selected
        ? background
        : (isDark ? AppColors.darkBorder : AppColors.chipBorder);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpacing.sm : AppSpacing.md,
            vertical: compact ? AppSpacing.xxs : AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
