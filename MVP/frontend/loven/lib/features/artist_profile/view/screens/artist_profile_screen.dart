import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/router_helpers.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/artwork/controller/cubit/artwork_cubit.dart';
import 'package:loven/features/artwork/view/widgets/artwork_grid_widget.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';

import '../../controller/artist_profile_cubit.dart';
import '../../controller/artist_profile_state.dart';
import '../widgets/artist_about_card.dart';
import '../widgets/artist_profile_hero_widget.dart';

/// Artist profile UI — consumes [ArtistProfileCubit] from an ancestor [BlocProvider].
///
/// The route or navigation shell owns cubit creation and lifecycle. This screen
/// triggers the initial fetch once on mount and must not create a second cubit.
class ArtistProfileScreen extends StatefulWidget {
  const ArtistProfileScreen({
    super.key,
    this.artistProfileId,
  });

  final String? artistProfileId;

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen> {
  bool get _isPublicView => widget.artistProfileId != null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    if (!mounted) {
      return;
    }

    final cubit = context.read<ArtistProfileCubit>();

    if (_isPublicView) {
      cubit.fetchPublicArtistProfile(widget.artistProfileId!);
      return;
    }

    cubit.fetchMyProfileData();
  }

  Future<void> _reload() {
    final cubit = context.read<ArtistProfileCubit>();

    if (_isPublicView) {
      return cubit.fetchPublicArtistProfile(widget.artistProfileId!);
    }

    return cubit.fetchMyProfileData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        leading: _isPublicView ? null : lovenPushedScreenBackLeading(context),
        title: Text(_isPublicView ? 'Artist' : 'My profile'),
      ),
      body: BlocConsumer<ArtistProfileCubit, ArtistProfileState>(
        listenWhen: (previous, current) =>
            current.status == ArtistProfileStatus.error &&
            current.errorMessage != null &&
            current.artist != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? 'Something went wrong',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
        },
        builder: (context, state) {
          switch (state.status) {
            case ArtistProfileStatus.initial:
            case ArtistProfileStatus.loading:
              if (state.artist != null) {
                return _SuccessContent(
                  state: state,
                  isPublicView: _isPublicView,
                  onRefresh: _reload,
                );
              }

              return const GalleryLoadingState(
                message: 'Loading profile…',
              );

            case ArtistProfileStatus.error:
              if (state.artist == null) {
                return GalleryEmptyState(
                  icon: Icons.error_outline,
                  title: 'Could not load profile',
                  subtitle: state.errorMessage ?? 'An unexpected error occurred',
                  actionLabel: 'Retry',
                  onAction: _reload,
                );
              }

              return _SuccessContent(
                state: state,
                isPublicView: _isPublicView,
                onRefresh: _reload,
              );

            case ArtistProfileStatus.success:
              return _SuccessContent(
                state: state,
                isPublicView: _isPublicView,
                onRefresh: _reload,
              );
          }
        },
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({
    required this.state,
    required this.isPublicView,
    required this.onRefresh,
  });

  final ArtistProfileState state;
  final bool isPublicView;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final artist = state.artist!;
    final sessionRole =
        authStateSessionUser(context.watch<AuthCubit>().state)?.systemRole;
    final showArtistFeatures = isPublicView || sessionRole == 'artist';
    final artworkCount = state.artworks.length;

    return RefreshIndicator(
      color: AppColors.brandPrimary,
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: ArtistProfileHeroWidget(
              artist: artist,
              artworkCount: artworkCount,
              isOwner: !isPublicView,
              onEdit: () async {
                final updated = await context.push(
                  '/artist-profile/edit',
                  extra: artist,
                );

                if (updated == true && context.mounted) {
                  context.read<ArtistProfileCubit>().fetchMyProfileData();
                }
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ArtistAboutCard(artist: artist),
          ),
          if (!showArtistFeatures)
            SliverFillRemaining(
              hasScrollBody: false,
              child: GalleryEmptyState(
                icon: Icons.palette_outlined,
                title: 'No artist gallery',
                subtitle:
                    'Customer accounts do not have artist portfolios.',
              ),
            ),
          if (showArtistFeatures) ...[
            SliverToBoxAdapter(
              child: GallerySectionHeader(
                title: 'Portfolio',
                subtitle: artworkCount == 0
                    ? null
                    : artworkCount == 1
                        ? '1 work'
                        : '$artworkCount works',
                padding: const EdgeInsets.only(
                  left: AppSpacing.screenPadding,
                  right: AppSpacing.screenPadding,
                  bottom: AppSpacing.md,
                ),
              ),
            ),
            if (state.artworks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: GalleryEmptyState(
                  icon: Icons.image_outlined,
                  title: 'No artworks yet',
                  subtitle: isPublicView
                      ? 'This artist has not published any works.'
                      : 'Your portfolio will appear here once you add artworks.',
                ),
              )
            else
              SliverToBoxAdapter(
                child: ArtworkGridWidget(
                  artworks: state.artworks,
                  canManage: !isPublicView,
                  onDelete: (artwork) async {
                    await context.read<ArtworkCubit>().deleteArtwork(
                          artworkId: artwork.id,
                        );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Artwork deleted'),
                        ),
                      );

                      context.read<ArtistProfileCubit>().fetchMyProfileData();
                    }
                  },
                ),
              ),
          ],
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.bottomNavClearance),
          ),
        ],
      ),
    );
  }
}
