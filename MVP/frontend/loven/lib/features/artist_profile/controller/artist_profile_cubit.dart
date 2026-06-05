import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/artist_model.dart';
import '../data/artist_repository.dart';
import 'artist_profile_state.dart';

/// Controller (ViewModel) for the logged-in artist's profile screen.
///
/// The View calls methods here; this class talks to [ArtistRepository] and
/// emits [ArtistProfileState] snapshots. The UI rebuilds via [BlocBuilder].
class ArtistProfileCubit extends Cubit<ArtistProfileState> {
  final ArtistRepository _repository;

  ArtistProfileCubit({required ArtistRepository repository})
      : _repository = repository,
        super(const ArtistProfileState());

  /// Loads profile + artworks in parallel for faster first paint.
  ///
  /// Why [Future.wait]: `getMyProfile` and `listMyArtworks` are independent;
  /// running them together cuts wait time vs awaiting sequentially.
  Future<void> fetchMyProfileData() async {
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
      // Keep any previously loaded data visible while showing the error banner.
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
    emit(
      state.copyWith(
        status: ArtistProfileStatus.error,
        errorMessage: _safeErrorMessage(e),
      ),
    );
  }
}
  /// Normalizes thrown objects to a user-visible string (Exception, HTTP errors, etc.).
  String _safeErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }
}
