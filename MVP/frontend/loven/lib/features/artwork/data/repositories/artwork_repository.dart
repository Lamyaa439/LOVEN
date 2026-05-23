import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';

class ArtworkRepository {
  final TokenStorage _tokenStorage = TokenStorage();

  Future<List<dynamic>> getArtworks() async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse(ApiConstants.artworks),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data is List) return data;

      if (data['artworks'] is List) {
        return data['artworks'];
      }

      return [];
    }

    throw Exception(data['error'] ?? 'Failed to load artworks');
  }

  Future<Map<String, dynamic>> getArtworkById(
    String artworkId,
  ) async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse('${ApiConstants.artworks}/$artworkId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['error'] ?? 'Failed to load artwork');
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
    final token = await _tokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse(
        '${ApiConstants.artworkSearch}?q=$query&limit=$limit&offset=$offset',
      ),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['error'] ?? 'Failed to search artworks');
  }

  Future<Map<String, dynamic>> listMyArtworks({
    int limit = 20,
    int offset = 0,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse('${ApiConstants.myArtworks}?limit=$limit&offset=$offset'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['error'] ?? 'Failed to load my artworks');
  }

  Future<Map<String, dynamic>> getArtwork({
    required String artworkId,
  }) async {
    return await getArtworkById(artworkId);
  }

  Future<Map<String, dynamic>> createArtwork({
    required String title,
    String? description,
    required double price,
    required int quantityAvailable,
    required double shippingFee,
    String? artworkImageUrl,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.post(
      Uri.parse(ApiConstants.artworks),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'price': price,
        'quantity_available': quantityAvailable,
        'shipping_fee': shippingFee,
        'artwork_image_url': artworkImageUrl,
      }),
    );

    print('CREATE ARTWORK STATUS: ${response.statusCode}');
    print('CREATE ARTWORK BODY: ${response.body}');
    
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }

    throw Exception(data['error'] ?? 'Failed to create artwork');
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
    final token = await _tokenStorage.getAccessToken();

    final body = <String, dynamic>{};

    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (price != null) body['price'] = price;
    if (quantityAvailable != null) {
      body['quantity_available'] = quantityAvailable;
    }
    if (shippingFee != null) body['shipping_fee'] = shippingFee;
    if (artworkImageUrl != null) {
      body['artwork_image_url'] = artworkImageUrl;
    }
    if (status != null) body['status'] = status;

    final response = await http.patch(
      Uri.parse('${ApiConstants.artworks}/$artworkId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['error'] ?? 'Failed to update artwork');
  }

  Future<void> deleteArtwork({
    required String artworkId,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.delete(
      Uri.parse('${ApiConstants.artworks}/$artworkId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    final data = jsonDecode(response.body);
    throw Exception(data['error'] ?? 'Failed to delete artwork');
  }
}