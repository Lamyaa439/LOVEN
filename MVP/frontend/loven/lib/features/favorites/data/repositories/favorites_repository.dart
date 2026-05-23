import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';

class FavoritesRepository {
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, dynamic>> listFavorites() async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse(ApiConstants.favorites),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) return data;

    throw Exception(data['error'] ?? 'Failed to load favorites');
  }

  Future<bool> checkFavorite(String artworkId) async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse('${ApiConstants.favoriteCheck}/$artworkId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['is_favorited'] == true;
    }

    throw Exception(data['error'] ?? 'Failed to check favorite');
  }

  Future<void> addFavorite(String artworkId) async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.post(
      Uri.parse('${ApiConstants.favorites}$artworkId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) return;

    final data = jsonDecode(response.body);
    throw Exception(data['error'] ?? 'Failed to add favorite');
  }

  Future<void> removeFavorite(String artworkId) async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.delete(
      Uri.parse('${ApiConstants.favorites}$artworkId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 || response.statusCode == 204) return;

    final data = jsonDecode(response.body);
    throw Exception(data['error'] ?? 'Failed to remove favorite');
  }
}