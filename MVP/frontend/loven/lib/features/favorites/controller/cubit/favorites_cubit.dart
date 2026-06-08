import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';

import '../../data/repositories/favorites_repository.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(
    this._repository, {
    AuthCubit? authCubit,
  })  : _authCubit = authCubit,
        super(FavoritesInitial());

  final FavoritesRepository _repository;
  final AuthCubit? _authCubit;

  bool get _hasSession {
    final auth = _authCubit;
    if (auth == null) {
      return false;
    }
    return authStateHasSession(auth.state);
  }

  /// Clears in-memory favorites UI state when the LOVEN session ends.
  void resetForSignedOut() {
    if (isClosed) {
      return;
    }
    emit(FavoritesInitial());
  }

  Future<void> loadFavorites() async {
    if (!_hasSession) {
      resetForSignedOut();
      return;
    }

    if (isClosed) {
      return;
    }

    emit(FavoritesLoading());

    try {
      final data = await _repository.listFavorites();
      final favorites = data['favorites'] as List? ?? [];

      if (isClosed) {
        return;
      }

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
      if (isClosed) {
        return;
      }

      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> toggleFavorite(String artworkId) async {
    if (!_hasSession || isClosed) {
      return;
    }

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

        if (isClosed) {
          return;
        }

        currentIds.remove(artworkId);

        currentFavorites.removeWhere(
          (item) =>
              item['artwork_id']?.toString() == artworkId ||
              item['artwork']?['id']?.toString() == artworkId ||
              item['id']?.toString() == artworkId,
        );
      } else {
        await _repository.addFavorite(artworkId);
        await loadFavorites();
        return;
      }

      if (isClosed) {
        return;
      }

      emit(
        FavoritesLoaded(
          favoriteArtworkIds: currentIds,
          favorites: currentFavorites,
        ),
      );
    } catch (e) {
      if (isClosed) {
        return;
      }

      emit(FavoritesError(e.toString()));

      if (isClosed) {
        return;
      }

      emit(
        FavoritesLoaded(
          favoriteArtworkIds: currentIds,
          favorites: currentFavorites,
        ),
      );
    }
  }
}
