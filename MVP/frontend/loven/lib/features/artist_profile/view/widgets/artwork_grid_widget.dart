import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/res/theme/app_colors.dart';
import '../../model/artist_model.dart';

/// Grid of artworks — uses theme card surfaces and primary accent for price.
class ArtworkGridWidget extends StatelessWidget {
  const ArtworkGridWidget({
    super.key,
    required this.artworks,
    required this.isGuest,
  });

  final List<ArtworkModel> artworks;
  final bool isGuest;

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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: artworks.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          return _ArtworkCard(
            artwork: artworks[index],
            isGuest: isGuest,
          );
        },
      ),
    );
  }
}

class _ArtworkCard extends StatelessWidget {
  const _ArtworkCard({
    required this.artwork,
    required this.isGuest,
  });

  final ArtworkModel artwork;
  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasImage =
        artwork.artworkImageUrl != null && artwork.artworkImageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (isGuest) {
          context.push('/auth');
        } else {
          context.push(
            '/art-details',
            extra: artwork,
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: hasImage
                  ? Image.network(
                      artwork.artworkImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
                    )
                  : const _ImagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(artwork.price),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
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
    if (price == null) return 'Price unavailable';
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
        color: AppColors.deepPurple.withValues(alpha: 0.7),
      ),
    );
  }
}
