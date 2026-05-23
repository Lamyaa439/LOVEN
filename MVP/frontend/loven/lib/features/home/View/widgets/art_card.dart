import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/res/theme/app_colors.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';

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
        context.push(
          '/art-details',
          extra: artwork,
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: artwork.id,
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      artwork.artworkImageUrl ??
                          '',
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            size: 50,
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
                      CircleAvatar(
                        backgroundColor:
                            Colors.white70,
                        child: IconButton(
                          icon: const Icon(
                            Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            if (isGuest) {
                              context.push(
                                '/auth',
                              );
                            } else {
                              onActionPressed();
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      CircleAvatar(
                        backgroundColor:
                            Colors.white70,
                        child: IconButton(
                          icon: const Icon(
                            Icons
                                .add_shopping_cart,
                            color: AppColors
                                .primaryBlue,
                          ),
                          onPressed: () {
                            if (isGuest) {
                              context.push(
                                '/auth',
                              );
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
              padding:
                  const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${artwork.price ?? 0} SAR',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight:
                          FontWeight.bold,
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