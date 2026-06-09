import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';

/// Guided artist discovery — compact surface cards in a horizontal strip.
class HomeArtistStrip extends StatelessWidget {
  const HomeArtistStrip({
    super.key,
    required this.artworks,
  });

  final List<ArtworkModel> artworks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: AppSizes.artistStripHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        itemCount: artworks.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final art = artworks[index];

          return SizedBox(
            width: AppSizes.artistStripCardWidth,
            child: LovenSurfaceCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              onTap: () {
                if (art.artistProfileId.isEmpty) {
                  return;
                }
                context.push(AppRoutes.artistPath(art.artistProfileId));
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: AppSizes.avatarMd / 2,
                    backgroundImage: art.artistProfileImageUrl != null
                        ? NetworkImage(art.artistProfileImageUrl!)
                        : null,
                    backgroundColor: AppColors.surfaceSoft,
                    child: art.artistProfileImageUrl == null
                        ? Icon(
                            Icons.person_rounded,
                            color: theme.colorScheme.primary,
                            size: AppSizes.iconMd,
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                art.artistDisplayName ?? 'Artist',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall,
                              ),
                            ),
                            if (art.artistIsVerified)
                              Icon(
                                Icons.verified_rounded,
                                size: AppSizes.iconSm,
                                color: theme.colorScheme.primary,
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'View profile',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
