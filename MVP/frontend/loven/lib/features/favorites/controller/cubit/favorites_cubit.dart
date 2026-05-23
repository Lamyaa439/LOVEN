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
          .map((item) => item['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      emit(FavoritesLoaded(ids));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> toggleFavorite(String artworkId) async {
    final currentState = state;

    final currentIds = currentState is FavoritesLoaded
        ? Set<String>.from(currentState.favoriteArtworkIds)
        : <String>{};

    try {
      if (currentIds.contains(artworkId)) {
        await _repository.removeFavorite(artworkId);
        currentIds.remove(artworkId);
      } else {
        await _repository.addFavorite(artworkId);
        currentIds.add(artworkId);
      }

      emit(FavoritesLoaded(currentIds));
    } catch (e) {
      emit(FavoritesError(e.toString()));
      emit(FavoritesLoaded(currentIds));
    }
  }
}