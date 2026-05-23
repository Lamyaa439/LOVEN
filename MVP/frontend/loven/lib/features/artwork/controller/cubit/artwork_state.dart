abstract class ArtworkState {}

class ArtworkInitial extends ArtworkState {}

class ArtworkLoading extends ArtworkState {}

class ArtworkLoaded extends ArtworkState {
  final Map<String, dynamic> artwork;

  ArtworkLoaded(this.artwork);
}

class ArtworksLoaded extends ArtworkState {
  final List<dynamic> artworks;

  ArtworksLoaded(this.artworks);
}

class ArtworkSuccess extends ArtworkState {
  final String message;

  ArtworkSuccess(this.message);
}

class ArtworkError extends ArtworkState {
  final String message;

  ArtworkError(this.message);
}