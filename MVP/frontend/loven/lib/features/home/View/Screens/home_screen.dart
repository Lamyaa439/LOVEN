import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/theme/theme_bloc.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/home/View/widgets/home_discover_artist_row.dart';
import 'package:loven/features/home/View/widgets/home_discover_hero.dart';
import 'package:loven/features/home/View/widgets/home_discover_masterpieces_mosaic.dart';
import 'package:loven/features/home/View/widgets/home_discover_overlay_card.dart';
import 'package:loven/features/home/View/widgets/home_discover_section_header.dart';
import 'package:loven/features/home/controller/bloc/home_bloc.dart';
import 'package:loven/features/home/controller/bloc/home_event.dart';
import 'package:loven/features/home/controller/bloc/home_state.dart';
import 'package:loven/features/notifications/controller/cubit/notifications_cubit.dart';
import 'package:loven/features/notifications/controller/cubit/notifications_state.dart';

/// LOVEN Discover home — editorial layout aligned with reference composition.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const GalleryLoadingState(message: 'Preparing discovery…');
        }

        if (state is HomeError) {
          return GalleryEmptyState(
            icon: Icons.wifi_off_rounded,
            title: 'Could not load artworks',
            subtitle: state.message,
            actionLabel: 'Try again',
            onAction: () => context.read<HomeBloc>().add(FetchHomeData()),
            usePrimaryAction: true,
          );
        }

        if (state is HomeLoaded) {
          return _HomeDiscoverBody(
            state: state,
            searchController: _searchController,
            onClearAllFilters: _clearAllFilters,
          );
        }

        return const GalleryEmptyState(
          icon: Icons.palette_outlined,
          title: 'The gallery awaits',
          subtitle: 'Original works from our artists will appear here soon.',
        );
      },
    );
  }

  void _clearAllFilters() {
    _searchController.clear();
    context.read<HomeBloc>().add(
          FilterArtworks(searchText: '', category: 'All'),
        );
  }
}

class _HomeDiscoverBody extends StatelessWidget {
  const _HomeDiscoverBody({
    required this.state,
    required this.searchController,
    required this.onClearAllFilters,
  });

  final HomeLoaded state;
  final TextEditingController searchController;
  final VoidCallback onClearAllFilters;

  bool get _isFiltered =>
      state.searchQuery.isNotEmpty || state.selectedCategory != 'All';

  @override
  Widget build(BuildContext context) {
    final artworks = state.artPieces;
    final allArtworks = state.allArtworks;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: _DiscoverPageHeader(
              onSearchTap: () => _openSearchSheet(context),
            ),
          ),
          if (_isFiltered)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GalleryChip(
                    label: state.selectedCategory == 'All'
                        ? 'Clear filters'
                        : '${state.selectedCategory} · Clear',
                    selected: true,
                    onTap: onClearAllFilters,
                  ),
                ),
              ),
            ),
          if (artworks.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: GalleryEmptyState(
                icon: Icons.search_off_rounded,
                title: _isFiltered ? 'No matching works' : 'Gallery is quiet',
                subtitle: _isFiltered
                    ? 'Try a different search or style.'
                    : 'New artworks will be added soon.',
                actionLabel: _isFiltered ? 'Reset' : null,
                onAction: _isFiltered ? onClearAllFilters : null,
              ),
            )
          else if (_isFiltered)
            ..._buildFilteredSlivers(context, artworks)
          else
            ..._buildDiscoverSlivers(context, artworks, allArtworks),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.bottomNavClearance),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilteredSlivers(
    BuildContext context,
    List<ArtworkModel> artworks,
  ) {
    return [
      SliverToBoxAdapter(
        child: HomeDiscoverSectionHeader(
          label: 'Results',
          onSeeAll: () => context.push(AppRoutes.artworksListPath('featured')),
        ),
      ),
      SliverToBoxAdapter(
        child: _DiscoverHorizontalRail(
          artworks: artworks,
          badge: 'Match',
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            mainAxisExtent: AppSizes.discoverRailCardHeight,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final art = artworks[index];
              return HomeDiscoverOverlayCard(
                title: art.title,
                imageUrl: art.artworkImageUrl,
                artwork: art,
                width: double.infinity,
                height: AppSizes.discoverRailCardHeight,
                onTap: () {},
              );
            },
            childCount: artworks.length.clamp(0, 12),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildDiscoverSlivers(
    BuildContext context,
    List<ArtworkModel> artworks,
    List<ArtworkModel> allArtworks,
  ) {
    final heroItems = artworks.take(5).toList();
    final mosaicItems = artworks.take(4).toList();
    final artists = _uniqueArtists(allArtworks);
    final genres = state.categories.where((c) => c != 'All').toList();
    final collections = artworks.skip(4).take(8).toList();
    final trending = _trendingWorks(artworks);

    return [
      SliverToBoxAdapter(child: HomeDiscoverHero(artworks: heroItems)),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sectionGap)),
      SliverToBoxAdapter(
        child: HomeDiscoverSectionHeader(
          label: 'Masterpieces',
          onSeeAll: () => context.push(AppRoutes.artworksListPath('featured')),
        ),
      ),
      SliverToBoxAdapter(
        child: HomeDiscoverMasterpiecesMosaic(artworks: mosaicItems),
      ),
      if (artists.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: HomeDiscoverSectionHeader(
            label: 'Artists',
            onSeeAll: () => context.push(AppRoutes.artists),
          ),
        ),
        SliverToBoxAdapter(child: HomeDiscoverArtistRow(artworks: artists)),
      ],
      if (genres.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: HomeDiscoverSectionHeader(
            label: 'Genres',
            showDivider: true,
            onSeeAll: () => _openGenreSheet(context),
          ),
        ),
        SliverToBoxAdapter(
          child: _GenreRail(
            genres: genres,
            allArtworks: allArtworks,
            onGenreTap: (genre) {
              context.read<HomeBloc>().add(FilterArtworks(category: genre));
            },
          ),
        ),
      ],
      if (collections.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: HomeDiscoverSectionHeader(
            label: 'Collections',
            onSeeAll: () => context.push(AppRoutes.artworksListPath('featured')),
          ),
        ),
        SliverToBoxAdapter(
          child: _DiscoverHorizontalRail(
            artworks: collections,
            badge: 'Collection',
          ),
        ),
      ],
      if (trending.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: HomeDiscoverSectionHeader(
            label: 'Trending works',
            onSeeAll: () => context.push(AppRoutes.artworksListPath('trending')),
          ),
        ),
        SliverToBoxAdapter(
          child: _DiscoverHorizontalRail(
            artworks: trending,
            badge: 'Trending',
          ),
        ),
      ],
    ];
  }

  List<ArtworkModel> _uniqueArtists(List<ArtworkModel> all) {
    final seen = <String>{};
    final result = <ArtworkModel>[];

    for (final art in all) {
      if (art.artistProfileId.isEmpty) {
        continue;
      }
      if (seen.add(art.artistProfileId)) {
        result.add(art);
      }
      if (result.length >= 10) {
        break;
      }
    }

    return result;
  }

  List<ArtworkModel> _trendingWorks(List<ArtworkModel> all) {
    if (all.length <= 3) {
      return all;
    }
    return all.skip(all.length ~/ 3).take(8).toList();
  }

  void _openSearchSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Search the gallery',
                    style: Theme.of(sheetContext).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  LovenSearchField(
                    controller: searchController,
                    hintText: 'Artworks, artists, styles…',
                    onChanged: (text) {
                      context.read<HomeBloc>().add(
                            FilterArtworks(searchText: text),
                          );
                    },
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.tune_rounded),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _openGenreSheet(context);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openGenreSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browse by style',
                  style: Theme.of(sheetContext).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.chipGap,
                  runSpacing: AppSpacing.chipGap,
                  children: state.categories.map((category) {
                    return GalleryChip(
                      label: category,
                      selected: category == state.selectedCategory,
                      onTap: () {
                        context.read<HomeBloc>().add(
                              FilterArtworks(category: category),
                            );
                        Navigator.pop(sheetContext);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DiscoverPageHeader extends StatelessWidget {
  const _DiscoverPageHeader({required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.lg,
        AppSpacing.screenPadding,
        AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              'Discovery',
              style: theme.textTheme.displayLarge,
            ),
          ),
          IconButton(
            tooltip: 'Search',
            visualDensity: VisualDensity.compact,
            onPressed: onSearchTap,
            icon: Icon(
              Icons.search_rounded,
              color: theme.colorScheme.onSurface,
            ),
          ),
          IconButton(
            tooltip: 'Toggle theme',
            visualDensity: VisualDensity.compact,
            onPressed: () => context.read<ThemeBloc>().toggleTheme(),
            icon: Icon(
              context.watch<ThemeBloc>().state == ThemeMode.light
                  ? Icons.nightlight_outlined
                  : Icons.light_mode_outlined,
              color: theme.colorScheme.onSurface,
            ),
          ),
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, notificationsState) {
              final hasSession = authStateHasSession(
                context.read<AuthCubit>().state,
              );
              final unreadCount = notificationsState is NotificationsLoaded
                  ? notificationsState.unreadCount
                  : 0;
              final showBadge = hasSession && unreadCount > 0;
              final badgeLabel =
                  unreadCount > 99 ? '99+' : unreadCount.toString();

              return IconButton(
                tooltip: 'Notifications',
                visualDensity: VisualDensity.compact,
                onPressed: () => context.push(AppRoutes.notifications),
                icon: Badge(
                  isLabelVisible: showBadge,
                  label: Text(badgeLabel),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DiscoverHorizontalRail extends StatelessWidget {
  const _DiscoverHorizontalRail({
    required this.artworks,
    this.badge,
  });

  final List<ArtworkModel> artworks;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.discoverRailCardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        itemCount: artworks.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final art = artworks[index];
          return HomeDiscoverOverlayCard(
            title: art.title,
            imageUrl: art.artworkImageUrl,
            badge: badge,
            artwork: art,
            onTap: () {},
          );
        },
      ),
    );
  }
}

class _GenreRail extends StatelessWidget {
  const _GenreRail({
    required this.genres,
    required this.allArtworks,
    required this.onGenreTap,
  });

  final List<String> genres;
  final List<ArtworkModel> allArtworks;
  final ValueChanged<String> onGenreTap;

  ArtworkModel? _sampleForGenre(String genre) {
    for (final art in allArtworks) {
      final haystack =
          '${art.title} ${art.description ?? ''}'.toLowerCase();
      final normalized = genre.toLowerCase();
      if (haystack.contains(normalized)) {
        return art;
      }
      for (final word in normalized.split(RegExp(r'\s+'))) {
        if (word.length >= 4 && haystack.contains(word)) {
          return art;
        }
      }
    }
    return allArtworks.isNotEmpty ? allArtworks.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.discoverRailCardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        itemCount: genres.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final genre = genres[index];
          final sample = _sampleForGenre(genre);

          return HomeDiscoverOverlayCard(
            title: genre,
            imageUrl: sample?.artworkImageUrl,
            badge: 'Genre',
            onTap: () => onGenreTap(genre),
          );
        },
      ),
    );
  }
}
