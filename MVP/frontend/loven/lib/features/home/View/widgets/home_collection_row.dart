import 'package:flutter/material.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/home/View/widgets/home_artwork_opener.dart';

/// Scanable collection row — thumb + editorial text stack, LOVEN rhythm.
class HomeCollectionRow extends StatelessWidget {
  const HomeCollectionRow({
    super.key,
    required this.artwork,
    this.showDivider = true,
  });

  final ArtworkModel artwork;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = artwork.artworkImageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => openHomeArtwork(context, artwork),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: SizedBox(
                      width: AppSizes.collectionThumbSize,
                      height: AppSizes.collectionThumbSize,
                      child: hasImage
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const _ThumbFallback(),
                            )
                          : const _ThumbFallback(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artwork.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall,
                        ),
                        if (artwork.artistDisplayName != null &&
                            artwork.artistDisplayName!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            artwork.artistDisplayName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _formatPrice(artwork.price),
                          style: AppTextStyles.priceMuted,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.screenPadding +
                  AppSizes.collectionThumbSize +
                  AppSpacing.lg,
            ),
            child: Divider(
              height: 1,
              thickness: 1,
              color: theme.dividerColor,
            ),
          ),
      ],
    );
  }

  String _formatPrice(double? price) {
    if (price == null) {
      return 'Price on request';
    }
    return '${price.toStringAsFixed(0)} SAR';
  }
}

class _ThumbFallback extends StatelessWidget {
  const _ThumbFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceSoft,
      child: Icon(
        Icons.image_outlined,
        size: AppSizes.iconMd,
        color: AppColors.favoriteEmpty,
      ),
    );
  }
}
