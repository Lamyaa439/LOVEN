import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:convert';
import 'package:loven/core/storage/token_storage.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import '../../../../core/res/theme/app_colors.dart';
import '../../controller/artist_profile_cubit.dart';
import '../../controller/artist_profile_state.dart';
import '../../model/artist_repository.dart';
import '../widgets/artist_header_widget.dart';
import 'package:loven/features/artwork/view/widgets/artwork_grid_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/features/artwork/data/repositories/artwork_repository.dart';

class ArtistProfileScreen extends StatelessWidget {
  const ArtistProfileScreen({
    super.key,
    this.artistProfileId,
  });

  final String? artistProfileId;

  bool get _isPublicView => artistProfileId != null;

  @override
  Widget build(BuildContext context) {
    final cubit = ArtistProfileCubit(
      repository: ArtistRepository(),
    );

    if (_isPublicView) {
      cubit.fetchPublicArtistProfile(
        artistProfileId!,
      );
    } else {
      cubit.fetchMyProfileData();
    }

    return BlocProvider.value(
      value: cubit,
      child: _ArtistProfileBody(
        isPublicView: _isPublicView,
        artistProfileId: artistProfileId,
      ),
    );
  }
}

class _ArtistProfileBody extends StatelessWidget {
  const _ArtistProfileBody({
    required this.isPublicView,
    this.artistProfileId,
  });

  final bool isPublicView;
  final String? artistProfileId;

  Future<void> _reload(ArtistProfileCubit cubit) {
    if (isPublicView && artistProfileId != null) {
      return cubit.fetchPublicArtistProfile(artistProfileId!);
    }

    return cubit.fetchMyProfileData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isPublicView ? 'Artist Profile' : 'My Profile',
          style: theme.textTheme.titleMedium,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
        ),
        actions: [
          if (!isPublicView)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthCubit>().logout();
              
              if (context.mounted) {
                context.go('/auth');
              }
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
                  isPublicView: isPublicView,
                  onRefresh: () => _reload(
                    context.read<ArtistProfileCubit>(),
                  ),
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
                  message: state.errorMessage ?? 'An unexpected error occurred',
                  onRetry: () => _reload(
                    context.read<ArtistProfileCubit>(),
                  ),
                );
              }

              return _SuccessContent(
                state: state,
                isPublicView: isPublicView,
                onRefresh: () => _reload(
                  context.read<ArtistProfileCubit>(),
                ),
              );

            case ArtistProfileStatus.success:
              return _SuccessContent(
                state: state,
                isPublicView: isPublicView,
                onRefresh: () => _reload(
                  context.read<ArtistProfileCubit>(),
                ),
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

  Future<String?> _getRoleFromToken() async {
    final token = await TokenStorage().getAccessToken();
    if (token == null || token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
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
                child: ArtistHeaderWidget(
                  artist: artist,
                  artworkCount: state.artworks.length,
                ),
              ),
              SliverToBoxAdapter(
                child: Divider(
                  height: 1,
                  color: theme.dividerColor,
                ),
              ),
              if (!showArtistFeatures)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isPublicView) ...[
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final updated = await context.push(
                                      '/artist-profile/edit',
                                      extra: artist,
                                    );
                                    if (updated == true && context.mounted) {
                                      context.read<ArtistProfileCubit>().fetchMyProfileData();
                                    }
                                  },
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text('Edit Profile'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final created = await context.push('/artworks/create');
                                    if (created == true && context.mounted) {
                                      context.read<ArtistProfileCubit>().fetchMyProfileData();
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Upload'),
                                ),
                              ),
                            ],
                          ),

                          if (!artist.isVerified) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final submitted = await context.push('/verification-request');
                                  
                                  if (submitted == true && context.mounted) {
                                    context.read<ArtistProfileCubit>().fetchMyProfileData();
                                  }
                                },
                                icon: const Icon(Icons.verified_outlined),
                                label: const Text('Request Verification'),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                        ],
                        Text(
                          isPublicView ? 'Artworks' : 'My Artworks',
                          style: theme.textTheme.titleMedium,
                        ),
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
                      await ArtworkRepository().deleteArtwork(
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
                child: SizedBox(height: 24),
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
  final VoidCallback onRetry;

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
