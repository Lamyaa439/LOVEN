import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/res/theme/app_colors.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/artist_profile/data/artist_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/features/home/View/widgets/art_details_screen.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_cubit.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_state.dart';

class ArtCard extends StatelessWidget {
  final ArtworkModel artwork;
  final bool isGuest;
  final VoidCallback onActionPressed;

  const ArtCard({
    super.key,
    required this.artwork,
    required this.isGuest,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) {
            return FractionallySizedBox(
              heightFactor: 0.92,
              child: ArtDetailsScreen(
                artItem: artwork,
                isGuest: isGuest,
                artistRepository: context.read<ArtistRepository>(),
              ),
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: artwork.id,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: Image.network(
                      artwork.artworkImageUrl ?? '',
                      fit: BoxFit.cover,
                      height: 155,
                      width: double.infinity,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          height: 155,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            size: 38,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Column(
                    children: [
                      BlocBuilder<FavoritesCubit, FavoritesState>(
                        builder: (context, state) {
                          final favoriteIds = state is FavoritesLoaded
                              ? state.favoriteArtworkIds
                              : <String>{};

                          final isFavorited = favoriteIds.contains(artwork.id);

                          return CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white.withOpacity(0.9),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              iconSize: 20,
                              icon: Icon(
                                isFavorited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                if (isGuest) {
                                  context.push('/auth');
                                } else {
                                  context
                                      .read<FavoritesCubit>()
                                      .toggleFavorite(artwork.id);
                                }
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 20,
                          icon: const Icon(
                            Icons.add_shopping_cart,
                            color: AppColors.primaryBlue,
                          ),
                          onPressed: () {
                            if (isGuest) {
                              context.push('/auth');
                            } else {
                              onActionPressed();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${artwork.price ?? 0} SAR',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
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
