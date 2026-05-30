import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/storage/token_storage.dart';
import 'package:loven/features/artwork/controller/cubit/artwork_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/artwork/controller/cubit/artwork_cubit.dart';
import 'package:loven/features/artwork/view/widgets/artwork_grid_widget.dart';

import '../../../../core/res/theme/app_colors.dart';
import '../../controller/artist_profile_cubit.dart';
import '../../controller/artist_profile_state.dart';
import '../../model/artist_repository.dart';
import '../widgets/artist_header_widget.dart';

class ArtistProfileScreen extends StatefulWidget {
  const ArtistProfileScreen({
    super.key,
    required this.repository,
    this.artistProfileId,
  });

  final ArtistRepository repository;
  final String? artistProfileId;

  @override
  Widget build(BuildContext context) {
    // Screen-scoped cubit uses the shared repository from app startup routing.
    final cubit = ArtistProfileCubit(
      repository: repository,
    );

    if (_isPublicView) {
      cubit.fetchPublicArtistProfile(artistProfileId!);
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

class _ArtistProfileScreenState
    extends State<ArtistProfileScreen> {
  late final ArtistProfileCubit cubit;

  bool get _isPublicView =>
      widget.artistProfileId != null;

  @override
  void initState() {
    super.initState();

    cubit = context.read<ArtistProfileCubit>();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (_isPublicView) {
        cubit.fetchPublicArtistProfile(
          widget.artistProfileId!,
        );
      } else {
        cubit.fetchMyProfileData();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _reload() {
    if (_isPublicView &&
        widget.artistProfileId != null) {
      return cubit.fetchPublicArtistProfile(
        widget.artistProfileId!,
      );
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
        backgroundColor:
            theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor:
              theme.scaffoldBackgroundColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: colorScheme.onSurface,
          ),
          title: Text(
            _isPublicView
                ? 'Artist'
                : 'My Profile',
            style: theme.textTheme.titleMedium
                ?.copyWith(
              fontWeight: FontWeight.w700,
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
        body: BlocConsumer<
            ArtistProfileCubit,
            ArtistProfileState>(
          listenWhen: (previous, current) =>
              current.status ==
                  ArtistProfileStatus.error &&
              current.errorMessage != null &&
              current.artist != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage ??
                        'Something went wrong',
                  ),
                  behavior:
                      SnackBarBehavior.floating,
                  backgroundColor:
                      colorScheme.primary,
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
                        state.errorMessage ??
                            'An unexpected error occurred',
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
    final token =
        await TokenStorage().getAccessToken();

    if (token == null || token.isEmpty) {
      return null;
    }

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
        return sub['role']?.toString() ??
            sub['system_role']
                ?.toString();
      }

      return data['role']?.toString() ??
          data['system_role']
              ?.toString();
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

        final showArtistFeatures =
            isPublicView ||
                role == 'artist';

        return RefreshIndicator(
          color: AppColors.deepPurple,
          onRefresh: onRefresh,
          child: CustomScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ArtistHeaderWidget(
                  artist: artist,
                  artworkCount:
                      state.artworks.length,
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    4,
                    20,
                    0,
                  ),
                  child: Divider(
                    height: 1,
                    color: theme.dividerColor,
                  ),
                ),
              ),

              if (!showArtistFeatures)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Center(
                      child: Text(
                        'Customer accounts do not have artist galleries.',
                        textAlign:
                            TextAlign.center,
                      ),
                    ),
                  ),
                ),

              if (showArtistFeatures)
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      24,
                      20,
                      12,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        if (!isPublicView) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _ProfileActionButton(
                                  icon: Icons.edit_outlined,
                                  label: 'Edit Profile',
                                  isPrimary: false,
                                  onPressed: () async {
                                    final updated = await context.push(
                                      '/artist-profile/edit',
                                      extra: artist,
                                    );
                                    
                                    if (updated == true && context.mounted) {
                                      context
                                      .read<ArtistProfileCubit>()
                                      .fetchMyProfileData();
                                    }
                                  },
                                ),
                              ),

                              const SizedBox(width: 12),
                              
                              Expanded(
                                child: _ProfileActionButton(
                                  icon: Icons.add_rounded,
                                  label: 'Upload',
                                  isPrimary: true,
                                  onPressed: () async {
                                    final created = await context.push(
                                      '/artworks/create',
                                    );
                                    
                                    if (created == true && context.mounted) {
                                      context
                                      .read<ArtistProfileCubit>()
                                      .fetchMyProfileData();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(
                            height: 28,
                          ),
                        ],

                        Text(
                          'Gallery',
                          style: theme
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (showArtistFeatures)
                SliverToBoxAdapter(
                  child: ArtworkGridWidget(
                    artworks: state.artworks,
                    isGuest: context
                            .read<AuthCubit>()
                            .state
                        is AuthGuest,
                    canManage:
                        !isPublicView,
                    onDelete: (artwork) async {
                      // Route through the globally provided ArtworkCubit so
                      // delete uses the shared ApiClient-backed repository
                      // instead of constructing ArtworkRepository() locally.
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

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isPrimary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 11,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        padding: const EdgeInsets.symmetric(
          vertical: 11,
        ),
        side: BorderSide(
          color: AppColors.primaryBlue.withValues(alpha: 0.35),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
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
    final colorScheme =
        theme.colorScheme;

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: colorScheme
                  .onSurface
                  .withValues(alpha: 0.45),
            ),

            const SizedBox(height: 12),

            Text(
              'Could not load profile',
              style:
                  theme.textTheme.titleMedium,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign:
                  TextAlign.center,
              style: theme
                  .textTheme.bodyMedium
                  ?.copyWith(
                color: colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: onRetry,
              child:
                  const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}