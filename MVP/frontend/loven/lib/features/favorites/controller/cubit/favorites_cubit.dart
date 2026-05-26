import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/favorites_repository.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesCubit(this._repository) : super(FavoritesInitial());

  Future<void> loadFavorites() async {
    emit(FavoritesLoading());

    try {
      final data = await _repository.listFavorites();
      final favorites = data['favorites'] as List? ?? [];
      
      final ids = favorites
      .map((item) =>
        item['artwork_id']?.toString() ??
        item['artwork']?['id']?.toString() ??
        item['id']?.toString() ??
        '')
      .where((id) => id.isNotEmpty)
      .toSet();

      emit(
        FavoritesLoaded(
          favoriteArtworkIds: ids,
          favorites: favorites,
        ),
      );
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

Future<void> toggleFavorite(String artworkId) async {
  final currentState = state;

  final currentIds = currentState is FavoritesLoaded
      ? Set<String>.from(currentState.favoriteArtworkIds)
      : <String>{};

  final currentFavorites = currentState is FavoritesLoaded
      ? List<dynamic>.from(currentState.favorites)
      : <dynamic>[];

  try {
    if (currentIds.contains(artworkId)) {
      await _repository.removeFavorite(artworkId);
      currentIds.remove(artworkId);

      currentFavorites.removeWhere(
        (item) =>
        item['artwork_id']?.toString() == artworkId ||
        item['artwork']?['id']?.toString() == artworkId ||
        item['id']?.toString() == artworkId,
        );
      } else {
        await _repository.addFavorite(artworkId);
        currentIds.add(artworkId);
        await loadFavorites();
        return;
      }

    emit(
      FavoritesLoaded(
        favoriteArtworkIds: currentIds,
        favorites: currentFavorites,
      ),
    );
  } catch (e) {
    emit(FavoritesError(e.toString()));

    emit(
      FavoritesLoaded(
        favoriteArtworkIds: currentIds,
        favorites: currentFavorites,
      ),
    );
  }
}
}