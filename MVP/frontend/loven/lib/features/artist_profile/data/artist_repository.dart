/// ========================================================================
/// Artist Profile Repository
///
/// Data-access layer for artist profiles and profile-scoped artwork CRUD.
///
/// Architectural decisions:
/// - Accepts [ApiClient] via constructor injection; JWT attachment and
///   error extraction are handled by the client interceptor, so this
///   repository never builds Authorization headers or owns [TokenStorage].
/// - Delegates all HTTP work to [ApiClient]; non-2xx responses throw
///   [Exception]s with backend messages — this layer does not catch them.
/// - Response maps are parsed through [ArtistModel] / [ArtworkModel], which
///   unwrap `{ "profile": ... }` and `{ "artwork": ... }` envelopes from Flask.
/// - Paths use [ApiConstants] helpers (root-mounted `/artist-profiles/…` and
///   feature-prefixed `/artworks/…`) relative to [ApiClient]'s base URL.
/// ========================================================================

import 'package:loven/core/network/api_constants.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';

class ArtistRepository {
  final ApiClient _apiClient;

  /// Creates a repository backed by the shared [apiClient] instance.
  ArtistRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Map<String, dynamic> _asMap(dynamic data) {
    return Map<String, dynamic>.from(data as Map);
  }

  /// Fetches a public artist profile by profile ID.
  Future<ArtistModel> getArtistById(String profileId) async {
    final response = await _apiClient.get(
      ApiConstants.artistProfileById(profileId),
    );

    return ArtistModel.fromJson(_asMap(response.data));
  }

  /// Fetches the authenticated user's artist profile (`GET /artist-profiles/me`).
  Future<ArtistModel> getMyProfile() async {
    final response = await _apiClient.get(ApiConstants.myArtistProfile);

    return ArtistModel.fromJson(_asMap(response.data));
  }

  /// Partially updates the authenticated user's profile (`PATCH /artist-profiles/me`).
  ///
  /// Only non-null parameters are sent so untouched fields are not overwritten.
  Future<ArtistModel> updateMyProfile({
    String? displayName,
    String? bio,
    String? city,
    String? shippingPolicy,
    String? profileImageUrl,
    String? coverImageUrl,
  }) async {
    final Map<String, dynamic> body = {};

      if (displayName != null) body['display_name'] = displayName;
  if (bio != null) body['bio'] = bio;
  if (city != null) body['city'] = city;
  if (shippingPolicy != null) body['shipping_policy'] = shippingPolicy;
  if (profileImageUrl != null) body['profile_image_url'] = profileImageUrl;
    if (coverImageUrl != null) body['cover_image_url'] = coverImageUrl;

    final response = await _apiClient.patch(
      ApiConstants.myArtistProfile,
      data: body,
    );

    return ArtistModel.fromJson(_asMap(response.data));
  }

  /// Lists artworks on a public artist profile page.
  Future<List<ArtworkModel>> listArtworksForProfile(
    String profileId, {
    int limit = 20,
    int offset = 0,
    String? status,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.artistProfileArtworks(profileId),
      queryParameters: {
        'limit': limit,
        'offset': offset,
        if (status != null) 'status': status,
      },
    );

    return ArtistModel.parseArtworkList(_asMap(response.data));
  }

  /// Lists artworks owned by the authenticated artist (`GET /artworks/mine`).
  Future<List<ArtworkModel>> listMyArtworks({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.myArtworks,
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    );

    return ArtistModel.parseArtworkList(_asMap(response.data));
  }

  /// Fetches a single artwork by ID (`GET /artworks/{id}`).
  Future<ArtworkModel> getArtworkById(String artworkId) async {
    final response = await _apiClient.get(
      ApiConstants.artworkById(artworkId),
    );

    return ArtworkModel.fromJson(_asMap(response.data));
  }

  /// Partially updates an artwork owned by the authenticated artist.
  Future<ArtworkModel> updateArtwork(
    String artworkId, {
    String? title,
    String? description,
    double? price,
    int? quantityAvailable,
    double? shippingFee,
    String? artworkImageUrl,
    String? status,
  }) async {
    final Map<String, dynamic> body = {};

    if (title != null) body['title'] = title;
    if (description != null) {
      body['description'] = description;
    }
    if (price != null) body['price'] = price;

    if (quantityAvailable != null) {
      body['quantity_available'] = quantityAvailable;
    }

    if (shippingFee != null) {
      body['shipping_fee'] = shippingFee;
    }

    if (artworkImageUrl != null) {
      body['artwork_image_url'] = artworkImageUrl;
    }

    if (status != null) {
      body['status'] = status;
    }

    if (body.isEmpty) {
      throw Exception(
        'No fields provided.',
      );
    }

    final response = await _apiClient.patch(
      ApiConstants.artworkById(artworkId),
      data: body,
    );

    return ArtworkModel.fromJson(_asMap(response.data));
  }
}
