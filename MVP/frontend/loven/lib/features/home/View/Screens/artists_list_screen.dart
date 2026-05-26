import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/features/home/controller/bloc/home_bloc.dart';
import 'package:loven/features/home/controller/bloc/home_state.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';

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
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is HomeError) {
            return Center(
              child: Text(state.message),
            );
          }

          if (state is! HomeLoaded) {
            return const Center(
              child: Text('No artists found.'),
            );
          }

          final artists = _uniqueArtistsFromArtworks(
            state.allArtworks,
          );

          if (artists.isEmpty) {
            return const Center(
              child: Text('No artists found.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              30,
            ),
            itemCount: artists.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final artistArtwork = artists[index];

              return _ArtistListTile(
                artwork: artistArtwork,
              );
            },
          );
        },
      ),
    );
  }
}

class _ArtistListTile extends StatelessWidget {
  final ArtworkModel artwork;

  const _ArtistListTile({
    required this.artwork,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final artistId = artwork.artistProfileId;
    final artistName =
        artwork.artistDisplayName ?? 'Artist';
    final imageUrl = artwork.artistProfileImageUrl;
    final isVerified = artwork.artistIsVerified;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        if (artistId.isEmpty) return;

        context.push('/artist/$artistId');
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.onSurface.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor:
                  theme.colorScheme.primary.withOpacity(0.12),
              backgroundImage:
                  imageUrl != null && imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : null,
              child: imageUrl == null || imageUrl.isEmpty
                  ? Icon(
                      Icons.person_rounded,
                      size: 34,
                      color: theme.colorScheme.primary,
                    )
                  : null,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          artistName,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (isVerified) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.verified_rounded,
                          size: 18,
                          color:
                              theme.colorScheme.primary,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Creator',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface
                  .withOpacity(0.45),
            ),
          ],
        ),
      ),
    );
  }
}