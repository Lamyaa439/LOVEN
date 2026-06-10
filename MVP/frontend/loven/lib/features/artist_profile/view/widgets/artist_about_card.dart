import 'package:flutter/material.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';

/// Readable about section — bio and shipping policy when available.
class ArtistAboutCard extends StatelessWidget {
  const ArtistAboutCard({
    super.key,
    required this.artist,
  });

  final ArtistModel artist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasBio = artist.bio != null && artist.bio!.trim().isNotEmpty;
    final hasShipping = artist.shippingPolicy != null &&
        artist.shippingPolicy!.trim().isNotEmpty;

    if (!hasBio && !hasShipping) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          if (hasBio)
            Text(
              artist.bio!,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            )
          else if (!hasShipping)
            Text(
              'This artist has not added a bio yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          if (hasShipping) ...[
            const SizedBox(height: AppSpacing.lg),
            Divider(color: theme.dividerColor, height: 1),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: AppSizes.iconSm,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    artist.shippingPolicy!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
        ],
      ),
    );
  }
}
