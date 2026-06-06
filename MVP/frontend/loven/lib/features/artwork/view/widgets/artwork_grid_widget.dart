import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/core/res/responsive/responsive_extensions.dart';
import 'package:loven/features/artist_profile/data/artist_repository.dart';

import '../../../../core/res/theme/app_colors.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/home/View/widgets/art_details_screen.dart';

class ArtworkGridWidget extends StatelessWidget {
  const ArtworkGridWidget({
    super.key,
    required this.artworks,
    this.canManage = false,
    this.onDelete,
  });

  final List<ArtworkModel> artworks;
  final bool canManage;
  final Future<void> Function(ArtworkModel artwork)? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (artworks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No artworks yet',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

return Padding(
  padding: EdgeInsets.symmetric(
    horizontal: context.responsive(mobile: 12, tablet: 16),
  ),
  child: GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: artworks.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: context.responsive(
        mobile: 2,
        tablet: 3,
        desktop: 4,
      ).toInt(),
      crossAxisSpacing: context.responsive(mobile: 10, tablet: 12),
      mainAxisSpacing: context.responsive(mobile: 10, tablet: 12),
      childAspectRatio: context.responsive(
        mobile: 0.78,
        tablet: 0.72,
        desktop: 0.76,
      ),
    ),
    itemBuilder: (context, index) {
      return _ArtworkCard(
        artwork: artworks[index],
        canManage: canManage,
        onDelete: onDelete,
      );
    },
  ),
);
  }
}

class _ArtworkCard extends StatelessWidget {
  const _ArtworkCard({
    required this.artwork,
    required this.canManage,
    this.onDelete,
  });

  final ArtworkModel artwork;
  final bool canManage;
  final Future<void> Function(ArtworkModel artwork)? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasImage =
        artwork.artworkImageUrl != null && artwork.artworkImageUrl!.isNotEmpty;

    return GestureDetector(
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
                artistRepository: context.read<ArtistRepository>(),
              ),
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.onSurface.withValues(
              alpha: 0.12,
            ),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  hasImage
                      ? Image.network(
                          artwork.artworkImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const _ImagePlaceholder(),
                        )
                      : const _ImagePlaceholder(),
                  if (canManage)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.black.withValues(
                          alpha: 0.45,
                        ),
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  title: const Text(
                                    'Delete artwork?',
                                  ),
                                  content: Text(
                                    'Are you sure you want to delete "${artwork.title}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          dialogContext,
                                          false,
                                        );
                                      },
                                      child: const Text(
                                        'Cancel',
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          dialogContext,
                                          true,
                                        );
                                      },
                                      child: const Text(
                                        'Delete',
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmed == true && onDelete != null) {
                              await onDelete!(
                                artwork,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(
  context.responsive(mobile: 8, tablet: 10),
),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: context.responsive(mobile: 12, tablet: 13),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(
                      artwork.price,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: context.responsive(mobile: 11, tablet: 12),
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepPurple,
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

  String _formatPrice(double? price) {
    if (price == null) {
      return 'Price unavailable';
    }

    return 'SAR ${price.toStringAsFixed(0)}';
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.backgroundGrey,
      child: Icon(
        Icons.image_outlined,
        size: 40,
        color: AppColors.deepPurple.withValues(
          alpha: 0.7,
        ),
      ),
    );
  }
}
