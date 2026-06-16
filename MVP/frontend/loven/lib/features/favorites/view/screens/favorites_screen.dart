import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_cubit.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_state.dart';
import 'package:loven/l10n/generated/app_localizations.dart';

/// Saved gallery — personal collection of favorited artworks.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FavoritesCubit>().loadFavorites();
    });
  }

  ArtworkModel _artworkFromFavorite(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return ArtworkModel.fromJson(raw);
    }
    return ArtworkModel.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return GalleryLoadingState(
                message: l10n.loadingCollection,
              );
            }

            if (state is FavoritesError) {
              return GalleryEmptyState(
                backgroundColor: Theme.of(context).colorScheme.surface,
                icon: Icons.error_outline,
                title: l10n.couldNotLoadFavorites,
                subtitle: state.message,
                actionLabel: l10n.tryAgain,
                onAction: () {
                  context.read<FavoritesCubit>().loadFavorites();
                },
              );
            }

            if (state is FavoritesLoaded) {
              final favorites = state.favorites;

              if (favorites.isEmpty) {
                return GalleryEmptyState(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  icon: Icons.favorite_border_rounded,
                  title: l10n.noFavoritesYet,
                  subtitle: l10n.noFavoritesSubtitle,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.lg,
                      AppSpacing.screenPadding,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.yourCollection,
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          l10n.savedWorksCount(favorites.length),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        AppSpacing.none,
                        AppSpacing.screenPadding,
                        AppSpacing.bottomNavClearance,
                      ),
                      itemCount: favorites.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final artwork = _artworkFromFavorite(favorites[index]);

                        return _FavoriteItemCard(artwork: artwork);
                      },
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _FavoriteItemCard extends StatelessWidget {
  const _FavoriteItemCard({required this.artwork});

  final ArtworkModel artwork;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LovenSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () => openArtworkDetail(context, artwork),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SizedBox(
              width: AppSizes.listThumbSize + AppSpacing.sm,
              height: AppSizes.listThumbSize + AppSpacing.lg,
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
                  maxLines: 2,
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
          LovenArtworkFavoriteButton(artworkId: artwork.id),
        ],
      ),
    );
  }
}
