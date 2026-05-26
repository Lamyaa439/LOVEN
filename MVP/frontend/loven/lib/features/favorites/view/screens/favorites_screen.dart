import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/features/home/View/widgets/art_details_screen.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_cubit.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is FavoritesError) {
              return Center(
                child: Text(state.message),
              );
            }

            if (state is FavoritesLoaded) {
              final favorites = state.favorites;

              if (favorites.isEmpty) {
                return _buildEmptyState(context);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
                    child: Row(
                      children: [
                        Text(
                          'Your Favorites',
                          style:
                              theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      itemCount: favorites.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 28,
                        color: theme.dividerColor.withOpacity(0.4),
                      ),
                      itemBuilder: (context, index) {
                        final artwork = favorites[index];

                        return _FavoriteTile(
                          artwork: artwork,
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

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 18),
            Text(
              'No favorites yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Save artworks you love to easily find them later.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  final Map<String, dynamic> artwork;

  const _FavoriteTile({
    required this.artwork,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final artworkId = artwork['id']?.toString() ?? '';

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        final artworkModel = ArtworkModel.fromJson(artwork);
        
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) {
            return FractionallySizedBox(
              heightFactor: 0.92,
              child: ArtDetailsScreen(
                artItem: artworkModel,
                isGuest: false,
              ),
            );
          },
        );
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              artwork['artwork_image_url'] ?? '',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 72,
                  height: 72,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artwork['title'] ?? 'Artwork',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '${artwork['price'] ?? 0} SAR',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              context
                  .read<FavoritesCubit>()
                  .toggleFavorite(artworkId);
            },
            icon: Icon(
              Icons.favorite,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}