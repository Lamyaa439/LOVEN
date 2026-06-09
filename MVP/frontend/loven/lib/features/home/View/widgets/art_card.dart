import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/session/app_session.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_cubit.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_state.dart';
import 'package:loven/features/home/View/widgets/home_artwork_opener.dart';

/// Gallery browse card — image-led with quiet metadata below the art.
class ArtCard extends StatelessWidget {
  const ArtCard({
    super.key,
    required this.artwork,
    this.compact = false,
  });

  final ArtworkModel artwork;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageHeight = compact
        ? AppSizes.discoverRailCardHeight
        : AppSizes.artworkCardImageHeight;
    final cardWidth = compact
        ? AppSizes.discoverRailCardWidth
        : AppSizes.artworkCardWidth;

    return SizedBox(
      width: cardWidth,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => openHomeArtwork(context, artwork),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: cardWidth,
                  height: imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _ArtworkImage(
                        imageUrl: artwork.artworkImageUrl,
                        width: cardWidth,
                        height: imageHeight,
                      ),
                      if (compact)
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppColors.heroBottomGradient,
                          ),
                        ),
                      if (compact)
                        Positioned(
                          left: AppSpacing.md,
                          right: AppSpacing.md,
                          bottom: AppSpacing.md,
                          child: Text(
                            artwork.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: AppColors.textOnBrand,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!compact)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artwork.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall,
                        ),
                        if (artwork.artistDisplayName != null &&
                            artwork.artistDisplayName!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            artwork.artistDisplayName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatPrice(artwork.price),
                                style: AppTextStyles.priceMuted,
                              ),
                            ),
                            _FavoriteAction(artworkId: artwork.id),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(double? price) {
    if (price == null) {
      return 'Price on request';
    }
    return '${price.toStringAsFixed(0)} SAR';
  }
}

class _ArtworkImage extends StatelessWidget {
  const _ArtworkImage({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  final String? imageUrl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return hasImage
        ? Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            width: width,
            height: height,
            errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
          )
        : const _ImagePlaceholder();
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

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

class _FavoriteAction extends StatelessWidget {
  const _FavoriteAction({required this.artworkId});

  final String artworkId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final favoriteIds =
            state is FavoritesLoaded ? state.favoriteArtworkIds : <String>{};
        final isFavorited = favoriteIds.contains(artworkId);

        return IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: AppSizes.touchTargetMin,
            minHeight: AppSizes.touchTargetMin,
          ),
          tooltip:
              isFavorited ? 'Remove from favourites' : 'Add to favourites',
          onPressed: () {
            if (!AppSession.hasSessionFromContext(context)) {
              context.push(AppRoutes.auth);
              return;
            }
            context.read<FavoritesCubit>().toggleFavorite(artworkId);
          },
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            size: AppSizes.iconSm,
            color: isFavorited ? AppColors.favorite : AppColors.favoriteEmpty,
          ),
        );
      },
    );
  }
}
