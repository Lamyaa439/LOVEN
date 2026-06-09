import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/session/app_session.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_cubit.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_state.dart';
import 'package:loven/features/home/View/widgets/home_artwork_opener.dart';

/// Editorial spotlight — dominant artwork with metadata beside the image, not on it.
class HomeSpotlight extends StatelessWidget {
  const HomeSpotlight({
    super.key,
    required this.artwork,
  });

  final ArtworkModel artwork;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = artwork.artworkImageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: LovenSurfaceCard(
        padding: EdgeInsets.zero,
        onTap: () => openHomeArtwork(context, artwork),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.md),
              ),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: hasImage
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _ImageFallback(),
                      )
                    : const _ImageFallback(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From the gallery',
                    style: AppTextStyles.exhibitionLabel.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    artwork.title,
                    style: theme.textTheme.headlineMedium,
                  ),
                  if (artwork.artistDisplayName != null &&
                      artwork.artistDisplayName!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      artwork.artistDisplayName!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatPrice(artwork.price),
                          style: AppTextStyles.priceMuted,
                        ),
                      ),
                      _SpotlightFavorite(artworkId: artwork.id),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  LovenSecondaryButton(
                    label: 'View work',
                    expand: false,
                    onPressed: () => openHomeArtwork(context, artwork),
                  ),
                ],
              ),
            ),
          ],
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

class _SpotlightFavorite extends StatelessWidget {
  const _SpotlightFavorite({required this.artworkId});

  final String artworkId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final favoriteIds =
            state is FavoritesLoaded ? state.favoriteArtworkIds : <String>{};
        final isFavorited = favoriteIds.contains(artworkId);

        return IconButton(
          tooltip: isFavorited ? 'Remove from favourites' : 'Add to favourites',
          onPressed: () {
            if (!AppSession.hasSessionFromContext(context)) {
              context.push(AppRoutes.auth);
              return;
            }
            context.read<FavoritesCubit>().toggleFavorite(artworkId);
          },
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? AppColors.favorite : AppColors.favoriteEmpty,
          ),
        );
      },
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceSoft,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: AppSizes.iconLg,
          color: AppColors.favoriteEmpty,
        ),
      ),
    );
  }
}
