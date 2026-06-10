import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_cubit.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_state.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const GalleryLoadingState(
                message: 'Loading your collection…',
              );
            }

            if (state is FavoritesError) {
              return GalleryEmptyState(
                icon: Icons.error_outline,
                title: 'Could not load favorites',
                subtitle: state.message,
                actionLabel: 'Retry',
                onAction: () {
                  context.read<FavoritesCubit>().loadFavorites();
                },
              );
            }

            if (state is FavoritesLoaded) {
              final favorites = state.favorites;

              if (favorites.isEmpty) {
                return const GalleryEmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: 'No favorites yet',
                  subtitle:
                      'Save artworks you love to easily find them later.',
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
                          'Your collection',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          favorites.length == 1
                              ? '1 saved work'
                              : '${favorites.length} saved works',
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

                        return LovenArtworkCard(
                          artwork: artwork,
                          variant: LovenArtworkCardVariant.compact,
                          showFavorite: true,
                        );
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
