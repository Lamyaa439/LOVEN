import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_event.dart';
import 'home_state.dart';

import 'package:loven/features/artwork/data/repositories/artwork_repository.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ArtworkRepository _artworkRepository;

  final List<String> _categoryTags = [
    'All',
    'Oil Painting',
    'Calligraphy',
    'Photography',
    'Digital Art',
  ];

  /// [artworkRepository] is injected from app startup ([LovenApp]) so the
  /// bloc shares the same [ApiClient]-backed instance as [ArtworkCubit],
  /// rather than constructing its own repository internally.
  HomeBloc({
    required ArtworkRepository artworkRepository,
  })  : _artworkRepository = artworkRepository,
        super(HomeLoading()) {
    on<FetchHomeData>((
      event,
      emit,
    ) async {
      emit(HomeLoading());

      try {
        final rawArtworks =
            await _artworkRepository
                .getArtworks();

        final artworks = rawArtworks
            .whereType<Map>()
            .map(
              (json) => ArtworkModel.fromJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();

        emit(
          HomeLoaded(
            allArtworks: artworks,
            categories: _categoryTags,
            artPieces: artworks,
          ),
        );
      } catch (e) {
        emit(
          HomeError(
            'Failed to fetch artworks: $e',
          ),
        );
      }
    });

    on<FilterArtworks>((
      event,
      emit,
    ) {
      if (state is! HomeLoaded) {
        return;
      }

      final currentState =
          state as HomeLoaded;

      final search =
          event.searchText ??
              currentState.searchQuery;

      final category =
          event.category ??
              currentState
                  .selectedCategory;

      final filteredList =
          currentState.allArtworks.where((
        art,
      ) {
        final title =
            art.title.toLowerCase();

        final matchesSearch =
            search.isEmpty ||
                title.contains(
                  search.toLowerCase(),
                );

        final matchesCategory =
            category == 'All';

        return matchesSearch &&
            matchesCategory;
      }).toList();

      emit(
        currentState.copyWith(
          artPieces: filteredList,
          searchQuery: search,
          selectedCategory: category,
        ),
      );
    });
  }
}