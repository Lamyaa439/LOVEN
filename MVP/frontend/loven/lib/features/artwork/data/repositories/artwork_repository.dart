import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';

class ArtworkRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  ArtworkRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  Future<List<dynamic>> getArtworks() async {
    final response = await _apiClient.get(
      ApiConstants.artworks,
    );

    final data = response.data;

    if (data is List) return data;

    if (data['artworks'] is List) {
      return data['artworks'];
    }

    return [];
  }

  Future<Map<String, dynamic>> getArtworkById(
    String artworkId,
  ) async {
    final response = await _apiClient.get(
      '${ApiConstants.artworks}$artworkId',
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }

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

  Future<Map<String, dynamic>> searchArtworks({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _apiClient.get(
      '${ApiConstants.artworkSearch}?q=$query&limit=$limit&offset=$offset',
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }

  Future<Map<String, dynamic>> listMyArtworks({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _apiClient.get(
      '${ApiConstants.myArtworks}?limit=$limit&offset=$offset',
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }

  Future<Map<String, dynamic>> getArtwork({
    required String artworkId,
  }) async {
    return await getArtworkById(
      artworkId,
    );
  }

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

    return Map<String, dynamic>.from(
      response.data,
    );
  }

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

    if (quantityAvailable != null) {
      body['quantity_available'] =
          quantityAvailable;
    }

    if (shippingFee != null) {
      body['shipping_fee'] = shippingFee;
    }

    if (artworkImageUrl != null) {
      body['artwork_image_url'] =
          artworkImageUrl;
    }

    if (status != null) {
      body['status'] = status;
    }

    final response = await _apiClient.patch(
      '${ApiConstants.artworks}$artworkId',
      data: body,
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }

  Future<void> deleteArtwork({
    required String artworkId,
  }) async {
    await _apiClient.delete(
      '${ApiConstants.artworks}$artworkId',
    );
  }
}