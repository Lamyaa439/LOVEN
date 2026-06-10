import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';

import '../model/artist_model.dart';
import '../data/artist_repository.dart';
import 'artist_profile_state.dart';

/// Controller (ViewModel) for the logged-in artist's profile screen.
///
/// The View calls methods here; this class talks to [ArtistRepository] and
/// emits [ArtistProfileState] snapshots. The UI rebuilds via [BlocBuilder].
///
/// [authCubit] gates protected API calls ([fetchMyProfileData],
/// [updateProfileInfo]). Public profile loads do not require a session.
class ArtistProfileCubit extends Cubit<ArtistProfileState> {
  ArtistProfileCubit({
    required ArtistRepository repository,
    AuthCubit? authCubit,
  })  : _repository = repository,
        _authCubit = authCubit,
        super(const ArtistProfileState());

  final ArtistRepository _repository;
  final AuthCubit? _authCubit;

  bool get _hasSession {
    final auth = _authCubit;
    if (auth == null) {
      return false;
    }
    return authStateHasSession(auth.state);
  }

  /// Loads profile + artworks in parallel for faster first paint.
  ///
  /// Requires a valid LOVEN session; no-ops when session is absent or cubit
  /// is closed.
  Future<void> fetchMyProfileData() async {
    if (!_hasSession || isClosed) {
      return;
    }

    emit(
      state.copyWith(
        status: ArtistProfileStatus.loading,
        clearErrorMessage: true,
      ),
    );

    try {
      final results = await Future.wait<dynamic>([
        _repository.getMyProfile(),
        _repository.listMyArtworks(),
      ]);

      if (isClosed) {
        return;
      }

      final artist = results[0] as ArtistModel;
      var artworks = results[1] as List<ArtworkModel>;

      artworks = await _publishHiddenPortfolioArtworksIfVerified(
        artist: artist,
        artworks: artworks,
      );

      emit(
        state.copyWith(
          status: ArtistProfileStatus.success,
          artist: artist,
          artworks: artworks,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      if (isClosed) {
        return;
      }

      emit(
        state.copyWith(
          status: ArtistProfileStatus.error,
          errorMessage: _safeErrorMessage(e),
        ),
      );
    }
  }

  /// Public profile page — no JWT; uses profile UUID from the route.
  Future<void> fetchPublicArtistProfile(String artistProfileId) async {
    if (isClosed) {
      return;
    }

    emit(
      state.copyWith(
        status: ArtistProfileStatus.loading,
        clearErrorMessage: true,
      ),
    );

    try {
      final results = await Future.wait<dynamic>([
        _repository.getArtistById(artistProfileId),
        _repository.listArtworksForProfile(artistProfileId),
      ]);

      if (isClosed) {
        return;
      }

      final artist = results[0] as ArtistModel;
      final artworks = results[1] as List<ArtworkModel>;

      emit(
        state.copyWith(
          status: ArtistProfileStatus.success,
          artist: artist,
          artworks: artworks,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      if (isClosed) {
        return;
      }

      emit(
        state.copyWith(
          status: ArtistProfileStatus.error,
          errorMessage: _safeErrorMessage(e),
        ),
      );
    }
  }

  /// PATCHes editable profile fields, then merges the new [ArtistModel] into state.
  ///
  /// [artworks] are intentionally untouched so the grid does not flicker/reload.
  Future<void> updateProfileInfo({
    String? displayName,
    String? bio,
    String? city,
    String? shippingPolicy,
    String? profileImageUrl,
    String? coverImageUrl,
  }) async {
    if (!_hasSession || isClosed) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: ArtistProfileStatus.error,
            errorMessage: 'Session expired. Please sign in again.',
          ),
        );
      }
      return;
    }

    final previousArtist = state.artist;

    emit(
      state.copyWith(
        status: ArtistProfileStatus.loading,
        clearErrorMessage: true,
      ),
    );

    try {
      final updatedArtist = await _repository.updateMyProfile(
        displayName: displayName,
        bio: bio,
        city: city,
        shippingPolicy: shippingPolicy,
        profileImageUrl: profileImageUrl,
        coverImageUrl: coverImageUrl,
      );

      if (isClosed) {
        return;
      }

      final mergedArtist = ArtistModel(
        id: updatedArtist.id.isNotEmpty
            ? updatedArtist.id
            : previousArtist?.id ?? '',
        userId: updatedArtist.userId.isNotEmpty
            ? updatedArtist.userId
            : previousArtist?.userId ?? '',
        displayName: updatedArtist.displayName.isNotEmpty
            ? updatedArtist.displayName
            : previousArtist?.displayName ?? '',
        city: updatedArtist.city ?? previousArtist?.city,
        bio: updatedArtist.bio ?? previousArtist?.bio,
        profileImageUrl: updatedArtist.profileImageUrl ??
            profileImageUrl ??
            previousArtist?.profileImageUrl,
        coverImageUrl: updatedArtist.coverImageUrl ??
            coverImageUrl ??
            previousArtist?.coverImageUrl,
        isVerified: updatedArtist.isVerified,
        shippingPolicy:
            updatedArtist.shippingPolicy ?? previousArtist?.shippingPolicy,
        createdAt: updatedArtist.createdAt ?? previousArtist?.createdAt,
        updatedAt: updatedArtist.updatedAt ?? previousArtist?.updatedAt,
      );

      emit(
        state.copyWith(
          status: ArtistProfileStatus.success,
          artist: mergedArtist,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      if (isClosed) {
        return;
      }

      emit(
        state.copyWith(
          status: ArtistProfileStatus.error,
          errorMessage: _safeErrorMessage(e),
        ),
      );
    }
  }

  /// Verified artists may still have portfolio uploads saved as `hidden`
  /// before approval. Publish them so they appear on the public home feed.
  Future<List<ArtworkModel>> _publishHiddenPortfolioArtworksIfVerified({
    required ArtistModel artist,
    required List<ArtworkModel> artworks,
  }) async {
    if (!artist.isVerified) {
      return artworks;
    }

    final hiddenArtworks =
        artworks.where((artwork) => artwork.status == 'hidden').toList();

    if (hiddenArtworks.isEmpty) {
      return artworks;
    }

    for (final artwork in hiddenArtworks) {
      try {
        await _repository.updateArtwork(
          artwork.id,
          status: 'available',
        );
      } catch (_) {
        // Keep other listings publishable even if one update fails.
      }
    }

    return _repository.listMyArtworks();
  }

  /// Normalizes thrown objects to a user-visible string (Exception, HTTP errors, etc.).
  String _safeErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }
}
