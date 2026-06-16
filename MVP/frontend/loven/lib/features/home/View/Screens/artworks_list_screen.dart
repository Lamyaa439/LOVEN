import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/artwork/view/widgets/artwork_grid_widget.dart';
import 'package:loven/features/home/View/widgets/category_filter_bar.dart';
import 'package:loven/features/home/controller/bloc/home_bloc.dart';
import 'package:loven/features/home/controller/bloc/home_event.dart';
import 'package:loven/features/home/controller/bloc/home_state.dart';
import 'package:loven/l10n/generated/app_localizations.dart';

class ArtworksListScreen extends StatelessWidget {
  const ArtworksListScreen({
    super.key,
    required this.type,
  });

  final String type;

  bool _hasActiveFilter(HomeLoaded state) {
    return state.selectedCategory != 'All' ||
        state.searchQuery.trim().isNotEmpty;
  }

  List<ArtworkModel> _trendingArtworks(List<ArtworkModel> all) {
    if (all.length <= 3) {
      return all;
    }

    return all.skip(all.length ~/ 3).toList();
  }

  String _title(AppLocalizations l10n) {
    if (type == 'browse') {
      return l10n.browseByStyle;
    }
    if (type == 'new-arrivals') {
      return 'New Arrivals';
    }
    if (type == 'trending') {
      return 'Trending Works';
    }

    return 'Featured Artworks';
  }

  List<ArtworkModel> _artworksForType(HomeLoaded state) {
    if (_hasActiveFilter(state)) {
      return state.artPieces;
    }

    if (type == 'new-arrivals') {
      return state.allArtworks.skip(1).toList();
    }
    if (type == 'trending') {
      return _trendingArtworks(state.allArtworks);
    }

    return state.allArtworks;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final title = _title(l10n);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return GalleryLoadingState(
              message: 'Loading $title…',
            );
          }

          if (state is HomeError) {
            return GalleryEmptyState(
              backgroundColor: Theme.of(context).colorScheme.surface,
              icon: Icons.error_outline,
              title: 'Could not load artworks',
              subtitle: state.message,
              actionLabel: 'Try again',
              onAction: () {
                context.read<HomeBloc>().add(FetchHomeData());
              },
            );
          }

          if (state is! HomeLoaded) {
            return GalleryEmptyState(
              backgroundColor: Theme.of(context).colorScheme.surface,
              icon: Icons.palette_outlined,
              title: 'No artworks found',
              subtitle: 'Check back soon for new works.',
            );
          }

          final artworks = _artworksForType(state);
          final hasActiveFilter = _hasActiveFilter(state);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                  AppSpacing.screenPadding,
                  AppSpacing.md,
                ),
                child: CategoryFilterBar(
                  categories: state.categories,
                  selectedCategory: state.selectedCategory,
                  onCategorySelected: (category) {
                    context.read<HomeBloc>().add(
                          FilterArtworks(category: category),
                        );
                  },
                ),
              ),
              Expanded(
                child: artworks.isEmpty
                    ? GalleryEmptyState(
                        backgroundColor:
                            Theme.of(context).colorScheme.surface,
                        icon: Icons.search_off_rounded,
                        title: hasActiveFilter
                            ? l10n.noMatchingWorks
                            : 'No artworks found',
                        subtitle: hasActiveFilter
                            ? l10n.noResultsSubtitle
                            : 'New pieces will appear here as artists publish.',
                        actionLabel: hasActiveFilter ? l10n.reset : null,
                        onAction: hasActiveFilter
                            ? () {
                                context.read<HomeBloc>().add(
                                      FilterArtworks(
                                        searchText: '',
                                        category: 'All',
                                      ),
                                    );
                              }
                            : null,
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenPadding,
                          AppSpacing.none,
                          AppSpacing.screenPadding,
                          AppSpacing.bottomNavClearance,
                        ),
                        child: ArtworkGridWidget(
                          artworks: artworks,
                          canManage: false,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
