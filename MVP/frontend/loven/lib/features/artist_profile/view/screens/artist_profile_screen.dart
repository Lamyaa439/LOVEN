import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/storage/token_storage.dart';
import 'package:loven/features/artist_profile/view/widgets/artist_portfolio_filter.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/artwork/controller/cubit/artwork_cubit.dart';
import 'package:loven/features/artwork/view/widgets/artwork_grid_widget.dart';

import '../../../../core/res/theme/app_colors.dart';
import '../../controller/artist_profile_cubit.dart';
import '../../controller/artist_profile_state.dart';
import '../../data/artist_repository.dart';
import '../widgets/artist_about_card.dart';
import '../widgets/artist_profile_hero_widget.dart';

class ArtistProfileScreen extends StatefulWidget {
  const ArtistProfileScreen({
    super.key,
    required this.repository,
    this.artistProfileId,
  });

  final ArtistRepository repository;
  final String? artistProfileId;

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen> {
  late final ArtistProfileCubit cubit;

  bool get _isPublicView => widget.artistProfileId != null;

  @override
  void initState() {
    super.initState();

    cubit = ArtistProfileCubit(
      repository: widget.repository,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isPublicView) {
        cubit.fetchPublicArtistProfile(widget.artistProfileId!);
      } else {
        cubit.fetchMyProfileData();
      }
    });
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  Future<void> _reload() {
    if (_isPublicView && widget.artistProfileId != null) {
      return cubit.fetchPublicArtistProfile(widget.artistProfileId!);
    }

    return cubit.fetchMyProfileData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F7F8),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F7F8),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: colorScheme.onSurface,
          ),
          title: Text(
            _isPublicView ? 'Artist' : 'My Profile',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            if (!_isPublicView)
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  context.push('/settings');
                },
              ),
          ],
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
                  backgroundColor: colorScheme.primary,
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

                return Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                );

              case ArtistProfileStatus.error:
                if (state.artist == null) {
                  return _ErrorView(
                    message:
                        state.errorMessage ?? 'An unexpected error occurred',
                    onRetry: _reload,
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

  Future<String?> _getRoleFromToken() async {
    final token = await TokenStorage().getAccessToken();

    if (token == null || token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = utf8.decode(
        base64Url.decode(
          base64Url.normalize(parts[1]),
        ),
      );

      final data = jsonDecode(payload);
      final sub = data['sub'];

      if (sub is Map<String, dynamic>) {
        return sub['role']?.toString() ?? sub['system_role']?.toString();
      }

      return data['role']?.toString() ?? data['system_role']?.toString();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final artist = state.artist!;

    return FutureBuilder<String?>(
      future: _getRoleFromToken(),
      builder: (context, snapshot) {
        final role = snapshot.data;
        final showArtistFeatures = isPublicView || role == 'artist';

        return RefreshIndicator(
          color: AppColors.deepPurple,
          onRefresh: onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ArtistProfileHeroWidget(
                  artist: artist,
                  artworkCount: state.artworks.length,
                  isOwner: !isPublicView,
                  onUpload: () async {
                    final created = await context.push('/artworks/create');

                    if (created == true && context.mounted) {
                      context.read<ArtistProfileCubit>().fetchMyProfileData();
                    }
                  },
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
                child: ArtistAboutCard(
                  artist: artist,
                ),
              ),

              if (!showArtistFeatures)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Center(
                      child: Text(
                        'Customer accounts do not have artist galleries.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

              if (showArtistFeatures)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Portfolio',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const ArtistPortfolioFilter(),
                      ],
                    ),
                  ),
                ),

              if (showArtistFeatures)
                SliverToBoxAdapter(
                  child: ArtworkGridWidget(
                    artworks: state.artworks,
                    isGuest: context.read<AuthCubit>().state is AuthGuest,
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

              const SliverToBoxAdapter(
                child: SizedBox(height: 30),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: colorScheme.onSurface.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 12),
            Text(
              'Could not load profile',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}