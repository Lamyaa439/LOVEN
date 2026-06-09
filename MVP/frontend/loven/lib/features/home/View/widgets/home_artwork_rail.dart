import 'package:flutter/material.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/home/View/widgets/art_card.dart';

/// Horizontal browse rail — intrinsic card height, no overflow clipping.
class HomeArtworkRail extends StatelessWidget {
  const HomeArtworkRail({
    super.key,
    required this.artworks,
  });

  final List<ArtworkModel> artworks;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.artworkCardTotalHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        itemCount: artworks.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, index) => ArtCard(artwork: artworks[index]),
      ),
    );
  }
}
