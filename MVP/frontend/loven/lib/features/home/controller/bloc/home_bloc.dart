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

  HomeBloc({
    required ArtworkRepository artworkRepository,
  })  : _artworkRepository = artworkRepository,
        super(HomeLoading()) {
    on<FetchHomeData>(_onFetchHomeData);
    on<FilterArtworks>(_onFilterArtworks);
  }

  Future<void> _onFetchHomeData(
    FetchHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      final rawArtworks = await _artworkRepository.getArtworks();

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
      emit(HomeError('Failed to fetch artworks: $e'));
    }
  }

  void _onFilterArtworks(
    FilterArtworks event,
    Emitter<HomeState> emit,
  ) {
    if (state is! HomeLoaded) {
      return;
    }

    final currentState = state as HomeLoaded;

    final search = event.searchText ?? currentState.searchQuery;
    final category = event.category ?? currentState.selectedCategory;
    final query = search.trim().toLowerCase();

    final filteredList = currentState.allArtworks.where((art) {
      final matchesSearch = query.isEmpty || _matchesSearch(art, query);
      final matchesCategory = _matchesCategory(art, category);
      return matchesSearch && matchesCategory;
    }).toList();

    emit(
      currentState.copyWith(
        artPieces: filteredList,
        searchQuery: search,
        selectedCategory: category,
      ),
    );
  }

  bool _matchesSearch(ArtworkModel art, String query) {
    final haystack =
        '${art.title} ${art.description ?? ''} ${art.artistDisplayName ?? ''}'
            .toLowerCase();
    return haystack.contains(query);
  }

  bool _matchesCategory(ArtworkModel art, String category) {
    if (category == 'All') {
      return true;
    }

    final haystack =
        '${art.title} ${art.description ?? ''}'.toLowerCase();
    final normalized = category.toLowerCase();

    if (haystack.contains(normalized)) {
      return true;
    }

    // Match significant words from multi-word categories (e.g. "Oil" in "Oil Painting").
    for (final word in normalized.split(RegExp(r'\s+'))) {
      if (word.length >= 4 && haystack.contains(word)) {
        return true;
      }
    }

    return false;
  }
}
