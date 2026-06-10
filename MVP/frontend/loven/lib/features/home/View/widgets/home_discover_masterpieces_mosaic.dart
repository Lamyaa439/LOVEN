import 'package:flutter/material.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/home/View/widgets/home_artwork_opener.dart';

/// Asymmetric masterpieces grid — reference-style 2×2 mosaic.
class HomeDiscoverMasterpiecesMosaic extends StatelessWidget {
  const HomeDiscoverMasterpiecesMosaic({
    super.key,
    required this.artworks,
  });

  final List<ArtworkModel> artworks;

  @override
  Widget build(BuildContext context) {
    if (artworks.isEmpty) {
      return const SizedBox.shrink();
    }

    final tiles = artworks.take(4).toList();
    while (tiles.length < 4) {
      tiles.add(tiles.last);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: SizedBox(
        height: AppSizes.discoverMosaicHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: _MosaicTile(artwork: tiles[0]),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Expanded(
                    flex: 2,
                    child: _MosaicTile(artwork: tiles[2]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: _MosaicTile(artwork: tiles[1]),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Expanded(
                    flex: 3,
                    child: _MosaicTile(artwork: tiles[3]),
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

class _MosaicTile extends StatelessWidget {
  const _MosaicTile({required this.artwork});

  final ArtworkModel artwork;

  @override
  Widget build(BuildContext context) {
    final imageUrl = artwork.artworkImageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => openHomeArtwork(context, artwork),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: hasImage
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => const _TileFallback(),
                )
              : const _TileFallback(),
        ),
      ),
    );
  }
}

class _TileFallback extends StatelessWidget {
  const _TileFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceSoft,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.favoriteEmpty,
        ),
      ),
    );
  }
}
