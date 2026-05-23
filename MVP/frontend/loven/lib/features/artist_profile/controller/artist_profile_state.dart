import '../model/artist_model.dart';

/// High-level UI phase for the artist profile screen.
///
/// A single enum keeps [BlocBuilder] logic simple: one `switch (state.status)`
/// instead of checking multiple boolean flags.
enum ArtistProfileStatus {
  /// Cubit created; no network call has run yet.
  initial,

  /// Waiting for Flask (profile and/or artworks in flight).
  loading,

  /// Data loaded or profile patch succeeded.
  success,

  /// Request failed; see [ArtistProfileState.errorMessage].
  error,
}

/// Immutable snapshot consumed by the View layer.
///
/// One class (not separate Loading/Loaded classes) lets [copyWith] update
/// only what changed — e.g. refresh `artist` after PATCH while keeping `artworks`.
class ArtistProfileState {
  final ArtistProfileStatus status;
  final ArtistModel? artist;
  final List<ArtworkModel> artworks;
  final String? errorMessage;

  const ArtistProfileState({
    this.status = ArtistProfileStatus.initial,
    this.artist,
    this.artworks = const [],
    this.errorMessage,
  });

  /// Creates a new state without mutating the current one (required for Cubit).
  ///
  /// Pass [clearErrorMessage: true] after success so old errors do not linger
  /// on screen. Omit [artist] / [artworks] to keep the previous lists/objects.
  ArtistProfileState copyWith({
    ArtistProfileStatus? status,
    ArtistModel? artist,
    List<ArtworkModel>? artworks,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ArtistProfileState(
      status: status ?? this.status,
      artist: artist ?? this.artist,
      artworks: artworks ?? this.artworks,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
