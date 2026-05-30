import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';

class FavoritesRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  FavoritesRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  Future<Map<String, dynamic>> listFavorites() async {
    final response = await _apiClient.get(
      ApiConstants.favorites,
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }

  Future<bool> checkFavorite(String artworkId) async {
    final response = await _apiClient.get(
      '${ApiConstants.favoriteCheck}/$artworkId',
    );

    final data = response.data;

    return data['is_favorited'] == true;
  }

  Future<void> addFavorite(String artworkId) async {
    try {
      await _apiClient.post(
        '${ApiConstants.favorites}$artworkId',
      );
    } catch (e) {
      final message = e.toString();

      if (message.contains('already favorited') ||
          message.contains('Artwork already favorited')) {
        return;
      }

      rethrow;
    }
  }

  Future<void> removeFavorite(String artworkId) async {
    await _apiClient.delete(
      '${ApiConstants.favorites}$artworkId',
    );
  }
}