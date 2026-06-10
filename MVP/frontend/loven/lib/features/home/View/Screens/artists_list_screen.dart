import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/home/controller/bloc/home_bloc.dart';
import 'package:loven/features/home/controller/bloc/home_state.dart';

class ArtistsListScreen extends StatelessWidget {
  const ArtistsListScreen({super.key});

  List<ArtworkModel> _uniqueArtistsFromArtworks(
    List<ArtworkModel> artworks,
  ) {
    final seenArtistIds = <String>{};
    final artists = <ArtworkModel>[];

    for (final artwork in artworks) {
      final artistId = artwork.artistProfileId;

      if (artistId.isEmpty) continue;

      if (!seenArtistIds.contains(artistId)) {
        seenArtistIds.add(artistId);
        artists.add(artwork);
      }
    }

    return artists;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Artists'),
        centerTitle: true,
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const GalleryLoadingState(message: 'Loading artists…');
          }

          if (state is HomeError) {
            return GalleryEmptyState(
              icon: Icons.error_outline,
              title: 'Could not load artists',
              subtitle: state.message,
            );
          }

          if (state is! HomeLoaded) {
            return const GalleryEmptyState(
              icon: Icons.person_outline,
              title: 'No artists found',
            );
          }

          final artists = _uniqueArtistsFromArtworks(state.allArtworks);

          if (artists.isEmpty) {
            return const GalleryEmptyState(
              icon: Icons.person_outline,
              title: 'No artists found',
              subtitle: 'Artists will appear here as works are published.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              AppSpacing.bottomNavClearance,
            ),
            itemCount: artists.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              return _ArtistListTile(artwork: artists[index]);
            },
          );
        },
      ),
    );
  }
}

class _ArtistListTile extends StatelessWidget {
  const _ArtistListTile({required this.artwork});

  final ArtworkModel artwork;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final artistId = artwork.artistProfileId;
    final artistName = artwork.artistDisplayName ?? 'Artist';
    final imageUrl = artwork.artistProfileImageUrl;
    final isVerified = artwork.artistIsVerified;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () {
          if (artistId.isEmpty) return;
          context.push(AppRoutes.artistPath(artistId));
        },
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderLight),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              LovenCircleAvatar(
                imageUrl: imageUrl,
                radius: AppSizes.avatarLg / 2,
                fallbackLabel: artistName,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            artistName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: AppSpacing.xxs),
                          Icon(
                            Icons.verified_rounded,
                            size: AppSizes.iconSm,
                            color: AppColors.brandPrimary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Artist',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
