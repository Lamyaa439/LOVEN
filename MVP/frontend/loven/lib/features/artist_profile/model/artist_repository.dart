import '../../../core/network/api_constants.dart';
import '../../../core/storage/token_storage.dart';
import 'artist_model.dart';

class ArtistRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  ArtistRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  Future<ArtistModel> getArtistById(
    String profileId,
  ) async {
    final response = await _apiClient.get(
      '${ApiConstants.artistProfiles}/$profileId',
    );

    return ArtistModel.fromJson(
      Map<String, dynamic>.from(
        response.data,
      ),
    );
  }

  Future<ArtistModel> getMyProfile() async {
    final response = await _apiClient.get(
      ApiConstants.myArtistProfile,
    );

    return ArtistModel.fromJson(
      Map<String, dynamic>.from(
        response.data,
      ),
    );
  }

  Future<ArtistModel> updateMyProfile({
    String? displayName,
    String? bio,
    String? city,
    String? shippingPolicy,
    String? profileImageUrl,
  }) async {
    final Map<String, dynamic> body = {};

    if (displayName != null) {
      body['display_name'] = displayName;
    }

    if (bio != null) {
      body['bio'] = bio;
    }

    if (city != null) {
      body['city'] = city;
    }

    if (shippingPolicy != null) {
      body['shipping_policy'] =
          shippingPolicy;
    }

    if (profileImageUrl != null) {
      body['profile_image_url'] =
          profileImageUrl;
    }

    if (body.isEmpty) {
      throw Exception(
        'No fields provided.',
      );
    }

    final response = await _apiClient.patch(
      ApiConstants.myArtistProfile,
      data: body,
    );

    return ArtistModel.fromJson(
      Map<String, dynamic>.from(
        response.data,
      ),
    );
  }

  Future<List<ArtworkModel>>
      listArtworksForProfile(
    String profileId, {
    int limit = 20,
    int offset = 0,
    String? status,
  }) async {
    final path =
        '${ApiConstants.artistProfiles}/$profileId/artworks'
        '?limit=$limit'
        '&offset=$offset'
        '${status != null ? '&status=$status' : ''}';

    final response =
        await _apiClient.get(path);

    return ArtistModel.parseArtworkList(
      Map<String, dynamic>.from(
        response.data,
      ),
    );
  }

  Future<List<ArtworkModel>>
      listMyArtworks({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _apiClient.get(
      '${ApiConstants.myArtworks}'
      '?limit=$limit'
      '&offset=$offset',
    );

    return ArtistModel.parseArtworkList(
      Map<String, dynamic>.from(
        response.data,
      ),
    );
  }

  Future<ArtworkModel> getArtworkById(
    String artworkId,
  ) async {
    final response = await _apiClient.get(
      '${ApiConstants.artworks}$artworkId',
    );

    return ArtworkModel.fromJson(
      Map<String, dynamic>.from(
        response.data,
      ),
    );
  }

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

    if (body.isEmpty) {
      throw Exception(
        'No fields provided.',
      );
    }

    final response = await _apiClient.patch(
      '${ApiConstants.artworks}$artworkId',
      data: body,
    );

    return ArtworkModel.fromJson(
      Map<String, dynamic>.from(
        response.data,
      ),
    );
  }
}