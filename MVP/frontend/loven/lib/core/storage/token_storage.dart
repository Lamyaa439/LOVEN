/// Handles secure persistence of auth/session tokens and lightweight role cache.
///
/// Network-first / black-box model: this layer only stores and retrieves tokens.
/// It does not decode JWTs or judge expiry — validity is determined by the API
/// ([ApiClient] 401 handling and refresh interceptors).
///
/// Access and refresh JWTs are stored separately for interceptors and
/// [AuthRepository] refresh flows. Role is a non-secret session hint only.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRoleKey = 'user_role';

  // =====================================================
  // Session helpers
  // =====================================================

  /// True when a non-empty access token is present (no client-side expiry check).
  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // =====================================================
  // Access Token
  // =====================================================

  Future<void> saveAccessToken(String token) async {
    await _storage.write(
      key: accessTokenKey,
      value: token,
    );
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(
      key: accessTokenKey,
    );
  }

  Future<void> clearAccessToken() async {
    await _storage.delete(
      key: accessTokenKey,
    );
  }

  // =====================================================
  // Refresh Token
  // =====================================================

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(
      key: refreshTokenKey,
      value: token,
    );
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(
      key: refreshTokenKey,
    );
  }

  Future<void> clearRefreshToken() async {
    await _storage.delete(
      key: refreshTokenKey,
    );
  }

  // =====================================================
  // User Role
  // =====================================================

  Future<void> saveUserRole(String role) async {
    await _storage.write(
      key: userRoleKey,
      value: role,
    );
  }

  Future<String?> getUserRole() async {
    return await _storage.read(
      key: userRoleKey,
    );
  }

  Future<void> clearUserRole() async {
    await _storage.delete(
      key: userRoleKey,
    );
  }

  // =====================================================
  // Clear All
  // =====================================================

/// Clears explicitly only the auth/session keys.
  Future<void> clearAllTokens() async {
    await _storage.delete(key: accessTokenKey);
    await _storage.delete(key: refreshTokenKey);
    await _storage.delete(key: userRoleKey);
  }
}
