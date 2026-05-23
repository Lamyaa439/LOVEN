abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final Set<String> favoriteArtworkIds;

  FavoritesLoaded(this.favoriteArtworkIds);
}

class FavoritesError extends FavoritesState {
  final String message;

  FavoritesError(this.message);
}