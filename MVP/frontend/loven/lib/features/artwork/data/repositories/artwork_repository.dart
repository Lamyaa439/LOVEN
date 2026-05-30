/// ========================================================================
/// Artwork Repository
///
/// Data-access layer for marketplace artwork listings (browse, search,
/// create, update, delete).
///
/// Architectural decisions:
/// - Accepts [ApiClient] via constructor injection so networking, auth
///   headers, and base URL resolution are centralized and mockable.
/// - Delegates HTTP and error handling to [ApiClient]; this repository
///   does not catch or translate exceptions.
/// - List endpoints on the Flask backend wrap results in an `artworks` key
///   alongside pagination metadata — [_parseArtworksList] normalizes that
///   shape for callers such as [HomeBloc].
/// - Endpoint paths come from [ApiConstants] and are relative to the API
///   root configured in [ApiClient].
/// ========================================================================

import 'package:loven/core/network/api_constants.dart';

class ArtworkRepository {
  final ApiClient _apiClient;

  /// Creates a repository backed by the shared [apiClient] instance.
  ArtworkRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Unwraps a list of artwork JSON objects from the backend response.
  ///
  /// The API returns paginated payloads shaped as
  /// `{"artworks": [...], "limit": N, "offset": M}` rather than a bare
  /// array. This helper extracts the inner list so [HomeBloc] and similar
  /// callers receive iterable artwork maps without duplicating parsing logic.
  /// Falls back to an empty list when the key is absent.
  List<dynamic> _parseArtworksList(dynamic data) {
    if (data is List) return data;

    if (data is Map) {
      final artworks = data['artworks'];
      if (artworks is List) return artworks;
    }

    return [];
  }

  Map<String, dynamic> _asMap(dynamic data) {
    return Map<String, dynamic>.from(data as Map);
  }

  /// Fetches the public marketplace feed and returns raw artwork JSON maps.
  ///
  /// Errors propagate from [ApiClient].
  Future<List<dynamic>> getArtworks() async {
    final response = await _apiClient.get(ApiConstants.artworks);

    return _parseArtworksList(response.data);
  }

  /// Fetches a single artwork by ID (`{"artwork": {...}}` response).
  Future<Map<String, dynamic>> getArtworkById(String artworkId) async {
    final response = await _apiClient.get(
      ApiConstants.artworkById(artworkId),
    );

    return _asMap(response.data);
  }

  /// Returns available artworks for the home/marketplace feed.
  Future<Map<String, dynamic>> listPublicArtworks({
    int limit = 20,
    int offset = 0,
    String status = 'available',
  }) async {
    final artworks = await getArtworks();

    return {
      'artworks': artworks,
    };
  }

  /// Searches artworks by title; response includes the `artworks` wrapper.
  Future<Map<String, dynamic>> searchArtworks({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.artworkSearch,
      queryParameters: {
        'q': query,
        'limit': limit,
        'offset': offset,
      },
    );

    return _asMap(response.data);
  }

  /// Lists artworks owned by the authenticated artist.
  Future<Map<String, dynamic>> listMyArtworks({
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

    return _asMap(response.data);
  }

  /// Alias for [getArtworkById]; used by [ArtworkCubit].
  Future<Map<String, dynamic>> getArtwork({
    required String artworkId,
  }) async {
    return getArtworkById(artworkId);
  }

  /// Creates a new artwork listing for the authenticated artist.
  Future<Map<String, dynamic>> createArtwork({
    required String title,
    String? description,
    required double price,
    required int quantityAvailable,
    required double shippingFee,
    String? artworkImageUrl,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.artworks,
      data: {
        'title': title,
        'description': description,
        'price': price,
        'quantity_available': quantityAvailable,
        'shipping_fee': shippingFee,
        'artwork_image_url': artworkImageUrl,
      },
    );

    return _asMap(response.data);
  }

  /// Partially updates an existing artwork owned by the caller.
  Future<Map<String, dynamic>> updateArtwork({
    required String artworkId,
    String? title,
    String? description,
    double? price,
    int? quantityAvailable,
    double? shippingFee,
    String? artworkImageUrl,
    String? status,
  }) async {
    final body = <String, dynamic>{};

    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (price != null) body['price'] = price;

    final response = await _apiClient.patch(
      ApiConstants.artworkById(artworkId),
      data: body,
    );

    return _asMap(response.data);
  }

  /// Soft-deletes an artwork. Errors propagate from [ApiClient].
  Future<void> deleteArtwork({
    required String artworkId,
  }) async {
    await _apiClient.delete(ApiConstants.artworkById(artworkId));
  }
}
