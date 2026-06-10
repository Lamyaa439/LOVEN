import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/session/app_session.dart';
import 'package:loven/core/widgets/artwork_detail_opener.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_cubit.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_state.dart';

/// Visual variants for the shared LOVEN artwork presentation layer.
enum LovenArtworkCardVariant {
  /// Image-led card with gradient overlay — Discover rails and collections.
  overlay,

  /// Grid cell — image dominant with quiet metadata below.
  grid,

  /// Horizontal list row — thumbnail plus title and price.
  compact,
}

/// Shared artwork preview card used across Home, grids, and future browse surfaces.
///
/// Provide [artwork] for artwork-driven surfaces, or [title] + optional [imageUrl]
/// for editorial overlay promos (e.g. genre tiles).
class LovenArtworkCard extends StatelessWidget {
  LovenArtworkCard({
    super.key,
    this.artwork,
    required this.variant,
    this.title,
    this.imageUrl,
    this.badge,
    this.onTap,
    this.width,
    this.height,
    this.showFavorite = false,
    this.canManage = false,
    this.onDelete,
  }) : assert(
          artwork != null || (title != null && title.isNotEmpty),
          'Provide artwork or a non-empty title',
        );

  final ArtworkModel? artwork;
  final LovenArtworkCardVariant variant;
  final String? title;
  final String? imageUrl;
  final String? badge;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool showFavorite;
  final bool canManage;
  final Future<void> Function(ArtworkModel artwork)? onDelete;

  String get _displayTitle => title ?? artwork!.title;

  String? get _displayImageUrl => imageUrl ?? artwork?.artworkImageUrl;

  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }
    if (artwork != null) {
      openArtworkDetail(context, artwork!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      LovenArtworkCardVariant.overlay => _OverlayArtworkCard(
          title: _displayTitle,
          imageUrl: _displayImageUrl,
          badge: badge,
          width: width ?? AppSizes.discoverRailCardWidth,
          height: height ?? AppSizes.discoverRailCardHeight,
          onTap: () => _handleTap(context),
        ),
      LovenArtworkCardVariant.grid => _GridArtworkCard(
          artwork: artwork!,
          onTap: () => _handleTap(context),
          showFavorite: showFavorite,
          canManage: canManage,
          onDelete: onDelete,
        ),
      LovenArtworkCardVariant.compact => _CompactArtworkCard(
          artwork: artwork!,
          onTap: () => _handleTap(context),
          showFavorite: showFavorite,
        ),
    };
  }
}

class _OverlayArtworkCard extends StatelessWidget {
  const _OverlayArtworkCard({
    required this.title,
    required this.onTap,
    this.imageUrl,
    this.badge,
    required this.width,
    required this.height,
  });

  final String title;
  final VoidCallback onTap;
  final String? imageUrl;
  final String? badge;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LovenArtworkImage(imageUrl: imageUrl),
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

class _GridArtworkCard extends StatelessWidget {
  const _GridArtworkCard({
    required this.artwork,
    required this.onTap,
    required this.showFavorite,
    required this.canManage,
    this.onDelete,
  });

  final ArtworkModel artwork;
  final VoidCallback onTap;
  final bool showFavorite;
  final bool canManage;
  final Future<void> Function(ArtworkModel artwork)? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    LovenArtworkImage(imageUrl: artwork.artworkImageUrl),
                    if (canManage)
                      Positioned(
                        top: AppSpacing.xs,
                        right: AppSpacing.xs,
                        child: _ArtworkDeleteButton(
                          artwork: artwork,
                          onDelete: onDelete,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.sm,
                left: AppSpacing.xxs,
                right: AppSpacing.xxs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  if (artwork.artistDisplayName != null &&
                      artwork.artistDisplayName!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      artwork.artistDisplayName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatArtworkPrice(artwork.price),
                          style: AppTextStyles.priceMuted,
                        ),
                      ),
                      if (showFavorite)
                        LovenArtworkFavoriteButton(artworkId: artwork.id),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactArtworkCard extends StatelessWidget {
  const _CompactArtworkCard({
    required this.artwork,
    required this.onTap,
    required this.showFavorite,
  });

  final ArtworkModel artwork;
  final VoidCallback onTap;
  final bool showFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: SizedBox(
                width: AppSizes.listThumbSize,
                height: AppSizes.listThumbSize,
                child: LovenArtworkImage(imageUrl: artwork.artworkImageUrl),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    formatArtworkPrice(artwork.price),
                    style: AppTextStyles.priceMuted,
                  ),
                ],
              ),
            ),
            if (showFavorite)
              LovenArtworkFavoriteButton(artworkId: artwork.id),
          ],
        ),
      ),
    );
  }
}

/// Shared network image with gallery placeholder fallback.
class LovenArtworkImage extends StatelessWidget {
  const LovenArtworkImage({
    super.key,
    required this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    if (!hasImage) {
      return const LovenArtworkImagePlaceholder();
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const LovenArtworkImagePlaceholder(),
    );
  }
}

class LovenArtworkImagePlaceholder extends StatelessWidget {
  const LovenArtworkImagePlaceholder({super.key});

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

class LovenArtworkFavoriteButton extends StatelessWidget {
  const LovenArtworkFavoriteButton({
    super.key,
    required this.artworkId,
  });

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

class _ArtworkDeleteButton extends StatelessWidget {
  const _ArtworkDeleteButton({
    required this.artwork,
    this.onDelete,
  });

  final ArtworkModel artwork;
  final Future<void> Function(ArtworkModel artwork)? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.scrim.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: IconButton(
        icon: const Icon(
          Icons.delete_outline,
          color: AppColors.textOnBrand,
          size: AppSizes.iconSm,
        ),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Delete artwork?'),
                content: Text(
                  'Are you sure you want to delete "${artwork.title}"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          );

          if (confirmed == true && onDelete != null) {
            await onDelete!(artwork);
          }
        },
      ),
    );
  }
}

String formatArtworkPrice(double? price) {
  if (price == null) {
    return 'Price on request';
  }
  return '${price.toStringAsFixed(0)} SAR';
}
