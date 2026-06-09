import 'package:flutter/material.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/home/View/widgets/home_artwork_opener.dart';

/// Image-led discover card — title on gradient overlay (genres, collections, rails).
class HomeDiscoverOverlayCard extends StatelessWidget {
  const HomeDiscoverOverlayCard({
    super.key,
    required this.title,
    required this.onTap,
    this.imageUrl,
    this.badge,
    this.width = AppSizes.discoverRailCardWidth,
    this.height = AppSizes.discoverRailCardHeight,
    this.artwork,
  });

  final String title;
  final VoidCallback onTap;
  final String? imageUrl;
  final String? badge;
  final double width;
  final double height;

  /// When set, tap opens artwork detail.
  final ArtworkModel? artwork;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: artwork != null
            ? () => openHomeArtwork(context, artwork!)
            : onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _Fallback(),
                  )
                else
                  const _Fallback(),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.heroBottomGradient,
                  ),
                ),
                if (badge != null && badge!.isNotEmpty)
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.scrim.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        badge!.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textOnBrand,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.textOnBrand,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceSoft,
      child: Icon(
        Icons.image_outlined,
        size: AppSizes.iconLg,
        color: AppColors.favoriteEmpty,
      ),
    );
  }
}
