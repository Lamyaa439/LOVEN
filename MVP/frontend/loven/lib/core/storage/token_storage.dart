import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure persistence for JWT session credentials only.
///
/// **Ownership:**
/// - Access and refresh tokens ([accessTokenKey], [refreshTokenKey])
/// - [hasValidSession] — non-empty access token present (no client-side expiry)
/// - [clearAllTokens] — wipes token keys and any legacy secure-storage entries
///
/// **Does not store user role.** Role lives on [UserModel.systemRole] inside
/// [AuthSuccess] (see `auth_state.dart` and [authStateSessionUser]). Routing and
/// authorization must use auth state, not this class.
///
/// **Network-first model:** this layer does not decode JWTs or judge expiry.
/// Validity is determined by the API ([ApiClient] 401 handling and refresh).
class TokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  /// Former role-cache key; purged on [clearAllTokens] for upgraded installs.
  static const String _legacyUserRoleKey = 'user_role';

  /// True when a non-empty access token is present (no client-side expiry check).
  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

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

  /// Clears JWT credentials and legacy `user_role` secure-storage if present.
  Future<void> clearAllTokens() async {
    await _storage.delete(key: accessTokenKey);
    await _storage.delete(key: refreshTokenKey);
    await _storage.delete(key: _legacyUserRoleKey);
  }
}
