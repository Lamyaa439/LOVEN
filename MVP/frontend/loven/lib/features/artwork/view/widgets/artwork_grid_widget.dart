import 'package:flutter/material.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/res/responsive/responsive_extensions.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';

class ArtworkGridWidget extends StatelessWidget {
  const ArtworkGridWidget({
    super.key,
    required this.artworks,
    this.canManage = false,
    this.onDelete,
    this.showFavorite = false,
  });

  final List<ArtworkModel> artworks;
  final bool canManage;
  final Future<void> Function(ArtworkModel artwork)? onDelete;
  final bool showFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (artworks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Center(
          child: Text(
            'No artworks yet',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsive(mobile: AppSpacing.md, tablet: AppSpacing.lg),
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
          crossAxisSpacing: context.responsive(
            mobile: AppSpacing.sm,
            tablet: AppSpacing.md,
          ),
          mainAxisSpacing: context.responsive(
            mobile: AppSpacing.sm,
            tablet: AppSpacing.md,
          ),
          childAspectRatio: context.responsive(
            mobile: 0.72,
            tablet: 0.68,
            desktop: 0.7,
          ),
        ),
        itemBuilder: (context, index) {
          return LovenArtworkCard(
            artwork: artworks[index],
            variant: LovenArtworkCardVariant.grid,
            canManage: canManage,
            onDelete: onDelete,
            showFavorite: showFavorite,
          );
        },
      ),
    );
  }
}
