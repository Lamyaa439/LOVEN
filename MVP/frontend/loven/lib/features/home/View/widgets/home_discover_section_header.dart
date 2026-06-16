import 'package:flutter/material.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/l10n/generated/app_localizations.dart';

/// Discover-style section header — rule, caps label, bold "See all".
///
/// Kept separate from [GallerySectionHeader] intentionally: Discover reference
/// uses ALL-CAPS sans labels, top divider rule, and "SEE ALL" in brand accent —
/// not the serif title + "View all" arrow pattern used elsewhere in LOVEN.
class HomeDiscoverSectionHeader extends StatelessWidget {
  const HomeDiscoverSectionHeader({
    super.key,
    required this.label,
    this.onSeeAll,
    this.showDivider = true,
    this.actionLabel = 'SEE ALL',
  });

  final String label;
  final String actionLabel;
  final VoidCallback? onSeeAll;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showDivider) ...[
            Divider(height: 1, thickness: 1, color: theme.dividerColor),
            const SizedBox(height: AppSpacing.lg),
          ] else
            const SizedBox(height: AppSpacing.sectionGap),
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: Text(
                    actionLabel.toUpperCase(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
