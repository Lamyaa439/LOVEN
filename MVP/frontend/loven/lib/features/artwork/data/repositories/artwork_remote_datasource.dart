import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';

class ArtworkRemoteDataSource {
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, dynamic>> listPublicArtworks({
    int limit = 20,
    int offset = 0,
    String status = 'available',
  }) async {
    final uri = Uri.parse(ApiConstants.artworks).replace(
      queryParameters: {
        'limit': '$limit',
        'offset': '$offset',
        'status': status,
      },
    );

    final response = await http.get(uri);

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> searchArtworks({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    final uri = Uri.parse(ApiConstants.artworkSearch).replace(
      queryParameters: {
        'q': query,
        'limit': '$limit',
        'offset': '$offset',
      },
    );

    final response = await http.get(uri);

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> listMyArtworks({
    int limit = 20,
    int offset = 0,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final uri = Uri.parse(ApiConstants.myArtworks).replace(
      queryParameters: {
        'limit': '$limit',
        'offset': '$offset',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getArtwork({
    required String artworkId,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.artworks}$artworkId'),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createArtwork({
    required String title,
    required String description,
    required double price,
    required String imageUrl,
    String? category,
    String? medium,
    String? dimensions,
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
        'image_url': imageUrl,
        'category': category,
        'medium': medium,
        'dimensions': dimensions,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateArtwork({
    required String artworkId,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    String? medium,
    String? dimensions,
    String? status,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.patch(
      Uri.parse('${ApiConstants.artworks}$artworkId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'category': category,
        'medium': medium,
        'dimensions': dimensions,
        'status': status,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteArtwork({
    required String artworkId,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.delete(
      Uri.parse('${ApiConstants.artworks}$artworkId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }
}