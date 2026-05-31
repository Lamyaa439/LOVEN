/// ========================================================================
/// Favorites Repository
///
/// Data-access layer for a user's favorited artworks.
///
/// Architectural decisions:
/// - Accepts [ApiClient] via constructor injection so auth headers, base URL,
///   and error handling stay centralized and mockable.
/// - Delegates HTTP to [ApiClient]; non-2xx responses throw [Exception]s
///   with backend messages — this repository does not catch them.
/// - Uses [ApiConstants] path helpers for list, check, add, and remove routes.
/// ========================================================================

import 'package:loven/core/network/api_constants.dart';

class FavoritesRepository {
  final ApiClient _apiClient;

  /// Creates a repository backed by the shared [apiClient] instance.
  FavoritesRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Map<String, dynamic> _asMap(dynamic data) {
    return Map<String, dynamic>.from(data as Map);
  }

  /// Lists the authenticated user's favorites (`GET /favorites/`).
  Future<Map<String, dynamic>> listFavorites() async {
    final response = await _apiClient.get(ApiConstants.favorites);

    return _asMap(response.data);
  }

  /// Returns whether [artworkId] is in the user's favorites.
  Future<bool> checkFavorite(String artworkId) async {
    final response = await _apiClient.get(
      '${ApiConstants.favoriteCheck}/$artworkId',
    );

    final data = _asMap(response.data);
    return data['is_favorited'] == true;
  }

  /// Adds an artwork to favorites (`POST /favorites/{artworkId}`).
  Future<void> addFavorite(String artworkId) async {
    await _apiClient.post(ApiConstants.favoriteByArtworkId(artworkId));
  }

  /// Removes an artwork from favorites (`DELETE /favorites/{artworkId}`).
  Future<void> removeFavorite(String artworkId) async {
    await _apiClient.delete(ApiConstants.favoriteByArtworkId(artworkId));
  }
}
