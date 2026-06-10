import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';

/// Horizontal artist row — circular portrait + serif name + quiet meta.
class HomeDiscoverArtistRow extends StatelessWidget {
  const HomeDiscoverArtistRow({
    super.key,
    required this.artworks,
  });

  final List<ArtworkModel> artworks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: AppSizes.avatarLg + AppSpacing.xxl,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        itemCount: artworks.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xl),
        itemBuilder: (context, index) {
          final art = artworks[index];

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (art.artistProfileId.isEmpty) {
                  return;
                }
                context.push(AppRoutes.artistPath(art.artistProfileId));
              },
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: SizedBox(
                width: AppSizes.artistRowWidth,
                child: Row(
                  children: [
                    LovenCircleAvatar(
                      imageUrl: art.artistProfileImageUrl,
                      radius: AppSizes.avatarLg / 2,
                      fallbackLabel: art.artistDisplayName,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            art.artistDisplayName ?? 'Artist',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            _artistMeta(art),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _artistMeta(ArtworkModel art) {
    if (art.artistIsVerified) {
      return 'Verified artist on LOVEN';
    }
    return 'Contemporary artist';
  }
}
