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
import 'package:loven/features/home/View/widgets/home_discover_section_header.dart';
import 'package:loven/features/home/controller/bloc/home_bloc.dart';
import 'package:loven/features/home/controller/bloc/home_event.dart';
import 'package:loven/features/home/controller/bloc/home_state.dart';
import 'package:loven/features/notifications/controller/cubit/notifications_cubit.dart';
import 'package:loven/features/notifications/controller/cubit/notifications_state.dart';
import 'package:loven/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return GalleryLoadingState(message: l10n.preparingDiscovery);
        }

        if (state is HomeError) {
          return GalleryEmptyState(
            backgroundColor: Theme.of(context).colorScheme.surface,
            icon: Icons.wifi_off_rounded,
            title: l10n.couldNotLoadArtworks,
            subtitle: state.message,
            actionLabel: l10n.tryAgain,
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

        return GalleryEmptyState(
          backgroundColor: Theme.of(context).colorScheme.surface,
          icon: Icons.palette_outlined,
          title: l10n.galleryAwaitsTitle,
          subtitle: l10n.galleryAwaitsSubtitle,
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
    final l10n = AppLocalizations.of(context)!;

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
                        ? l10n.clearFilters
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
                backgroundColor: Theme.of(context).colorScheme.surface,
                icon: Icons.search_off_rounded,
                title: _isFiltered ? l10n.noMatchingWorks : l10n.galleryIsQuiet,
                subtitle:
                    _isFiltered ? l10n.noResultsSubtitle : l10n.emptySubtitle,
                actionLabel: _isFiltered ? l10n.reset : null,
                onAction: _isFiltered ? onClearAllFilters : null,
              ),
            )
          else if (_isFiltered)
            ..._buildFilteredSlivers(context, artworks, l10n)
          else
            ..._buildDiscoverSlivers(context, artworks, allArtworks, l10n),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.bottomNavClearance + 40.0),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilteredSlivers(BuildContext context,
      List<ArtworkModel> artworks, AppLocalizations l10n) {
    return [
      SliverToBoxAdapter(
        child: HomeDiscoverSectionHeader(
          label: l10n.results,
          onSeeAll: () => context.push(AppRoutes.artworksListPath('featured')),
        ),
      ),
      SliverToBoxAdapter(
        child: _DiscoverHorizontalRail(
          artworks: artworks,
          badge: l10n.match,
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
              return LovenArtworkCard(
                artwork: art,
                variant: LovenArtworkCardVariant.overlay,
                width: double.infinity,
                height: AppSizes.discoverRailCardHeight,
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
      AppLocalizations l10n) {
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
          label: l10n.masterpieces,
          onSeeAll: () => context.push(AppRoutes.artworksListPath('featured')),
        ),
      ),
      SliverToBoxAdapter(
        child: HomeDiscoverMasterpiecesMosaic(artworks: mosaicItems),
      ),
      if (artists.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: HomeDiscoverSectionHeader(
            label: l10n.artists,
            onSeeAll: () => context.push(AppRoutes.artists),
          ),
        ),
        SliverToBoxAdapter(child: HomeDiscoverArtistRow(artworks: artists)),
      ],
      if (genres.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: HomeDiscoverSectionHeader(
            label: l10n.genre,
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
            label: l10n.collection,
            onSeeAll: () =>
                context.push(AppRoutes.artworksListPath('featured')),
          ),
        ),
        SliverToBoxAdapter(
          child: _DiscoverHorizontalRail(
            artworks: collections,
            badge: l10n.collection,
          ),
        ),
      ],
      if (trending.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: HomeDiscoverSectionHeader(
            label: l10n.trendingWorks,
            onSeeAll: () =>
                context.push(AppRoutes.artworksListPath('trending')),
          ),
        ),
        SliverToBoxAdapter(
          child: _DiscoverHorizontalRail(
            artworks: trending,
            badge: l10n.trending,
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
    final l10n = AppLocalizations.of(context)!;

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
                    l10n.searchGallery,
                    style: Theme.of(sheetContext).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  LovenSearchField(
                    controller: searchController,
                    hintText: l10n.searchHint,
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
    final l10n = AppLocalizations.of(context)!;

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
                  l10n.browseByStyle,
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
    final l10n = AppLocalizations.of(context)!;

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
              l10n.homeTitle,
              style: theme.textTheme.displayLarge,
            ),
          ),
          IconButton(
            tooltip: l10n.searchTooltip,
            visualDensity: VisualDensity.compact,
            onPressed: onSearchTap,
            icon: Icon(
              Icons.search_rounded,
              color: theme.colorScheme.onSurface,
            ),
          ),
          IconButton(
            tooltip: l10n.themeTooltip,
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
                tooltip: l10n.notificationTooltip,
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
          return LovenArtworkCard(
            artwork: art,
            variant: LovenArtworkCardVariant.overlay,
            badge: badge,
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

  ArtworkModel? _sampleForGenre(String genre, int index) {
    if (allArtworks.isEmpty) return null;

    for (final art in allArtworks) {
      final haystack = '${art.title} ${art.description ?? ''}'.toLowerCase();
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

    return allArtworks[index % allArtworks.length];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          final sample = _sampleForGenre(genre, index);

          return LovenArtworkCard(
            title: genre,
            imageUrl: sample?.artworkImageUrl,
            variant: LovenArtworkCardVariant.overlay,
            badge: l10n.genres,
            onTap: () => onGenreTap(genre),
          );
        },
      ),
    );
  }
}
