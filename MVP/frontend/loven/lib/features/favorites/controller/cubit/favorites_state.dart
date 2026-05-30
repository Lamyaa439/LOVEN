abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final Set<String> favoriteArtworkIds;
  final List<dynamic> favorites;

  FavoritesLoaded({
    required this.favoriteArtworkIds,
    required this.favorites,
  });
}

class FavoritesError extends FavoritesState {
  final String message;

  FavoritesError(this.message);
}