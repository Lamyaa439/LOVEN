import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_constants.dart';
import '../../../core/storage/token_storage.dart';
import 'artist_model.dart';

class ArtistRepository {
  final http.Client _client;
  final TokenStorage _tokenStorage;

  ArtistRepository({
    http.Client? client,
    TokenStorage? tokenStorage,
  })  : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  Future<ArtistModel> getArtistById(String profileId) async {
    final uri = Uri.parse('${ApiConstants.artistProfiles}/$profileId');

    final response = await _client.get(
      uri,
      headers: const {'Content-Type': 'application/json'},
    );

    return _parseArtistOrThrow(response, context: 'getArtistById');
  }

  Future<ArtistModel> getMyProfile() async {
    final token = await _requireToken();

    final response = await _client.get(
      Uri.parse(ApiConstants.myArtistProfile),
      headers: _authHeaders(token),
    );

    return _parseArtistOrThrow(response, context: 'getMyProfile');
  }

  Future<ArtistModel> updateMyProfile({
    String? displayName,
    String? bio,
    String? city,
    String? shippingPolicy,
    String? profileImageUrl,
  }) async {
    final token = await _requireToken();

    final Map<String, dynamic> body = {};
    if (displayName != null) body['display_name'] = displayName;
    if (bio != null) body['bio'] = bio;
    if (city != null) body['city'] = city;
    if (shippingPolicy != null) body['shipping_policy'] = shippingPolicy;
    if (profileImageUrl != null) body['profile_image_url'] = profileImageUrl;

    if (body.isEmpty) {
      throw Exception('updateMyProfile: no fields provided.');
    }

    final response = await _client.patch(
      Uri.parse(ApiConstants.myArtistProfile),
      headers: _authHeaders(token),
      body: jsonEncode(body),
    );

    return _parseArtistOrThrow(response, context: 'updateMyProfile');
  }

  Future<List<ArtworkModel>> listArtworksForProfile(
    String profileId, {
    int limit = 20,
    int offset = 0,
    String? status,
  }) async {
    final query = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
      if (status != null) 'status': status,
    };

    final uri = Uri.parse('${ApiConstants.artistProfiles}/$profileId/artworks')
        .replace(queryParameters: query);

    final response = await _client.get(
      uri,
      headers: const {'Content-Type': 'application/json'},
    );

    return _parseArtworkListOrThrow(response, context: 'listArtworksForProfile');
  }

  Future<List<ArtworkModel>> listMyArtworks({
    int limit = 20,
    int offset = 0,
  }) async {
    final token = await _requireToken();

    final uri = Uri.parse(ApiConstants.myArtworks).replace(
      queryParameters: {
        'limit': '$limit',
        'offset': '$offset',
      },
    );

    final response = await _client.get(
      uri,
      headers: _authHeaders(token),
    );

    return _parseArtworkListOrThrow(response, context: 'listMyArtworks');
  }

  Future<ArtworkModel> getArtworkById(String artworkId) async {
    final uri = Uri.parse('${ApiConstants.artworks}$artworkId');

    final response = await _client.get(
      uri,
      headers: const {'Content-Type': 'application/json'},
    );

    return _parseArtworkOrThrow(response, context: 'getArtworkById');
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
    final token = await _requireToken();

    final Map<String, dynamic> body = {};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (price != null) body['price'] = price;
    if (quantityAvailable != null) {
      body['quantity_available'] = quantityAvailable;
    }
    if (shippingFee != null) body['shipping_fee'] = shippingFee;
    if (artworkImageUrl != null) body['artwork_image_url'] = artworkImageUrl;
    if (status != null) body['status'] = status;

    if (body.isEmpty) {
      throw Exception('updateArtwork: no fields provided.');
    }

    final response = await _client.patch(
      Uri.parse('${ApiConstants.artworks}$artworkId'),
      headers: _authHeaders(token),
      body: jsonEncode(body),
    );

    return _parseArtworkOrThrow(response, context: 'updateArtwork');
  }

  Future<String> _requireToken() async {
    final token = await _tokenStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Unauthorized: No token found. Please log in.');
    }

    return token;
  }

  Map<String, String> _authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  ArtistModel _parseArtistOrThrow(
    http.Response response, {
    required String context,
  }) {
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      return ArtistModel.fromJson(body);
    }

    throw Exception(_extractError(response, context));
  }

  ArtworkModel _parseArtworkOrThrow(
    http.Response response, {
    required String context,
  }) {
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      return ArtworkModel.fromJson(body);
    }

    throw Exception(_extractError(response, context));
  }

  List<ArtworkModel> _parseArtworkListOrThrow(
    http.Response response, {
    required String context,
  }) {
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      return ArtistModel.parseArtworkList(body);
    }

    throw Exception(_extractError(response, context));
  }

  String _extractError(http.Response response, String context) {
    try {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final msg = body['error'] as String?;

      if (msg != null && msg.isNotEmpty) {
        return '$context failed (${response.statusCode}): $msg';
      }
    } catch (_) {}

    return '$context failed with HTTP ${response.statusCode}.';
  }
}