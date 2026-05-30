/// Secure persistence for JWT session tokens.
///
/// Access and refresh tokens are stored separately so [ApiClient] can attach
/// the short-lived access JWT on every request while [AuthRepository] keeps
/// the refresh JWT for silent renewal via `POST /refresh`.
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String accessTokenKey = 'access_token';

  static const String refreshTokenKey = 'refresh_token';

  // =====================================================
  // Session helpers
  // =====================================================

  /// True when a non-empty access token is stored locally.
  ///
  /// Used at app launch ([AuthCubit.checkAuthStatus]) to distinguish
  /// authenticated users from guests without calling the network.
  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// True when the stored access token's `exp` claim is in the past.
  ///
  /// Decodes the JWT payload client-side (no signature verification — the
  /// backend remains authoritative). Returns `true` when no token exists or
  /// the payload cannot be parsed.
  Future<bool> isAccessTokenExpired() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return true;
    return _isJwtExpired(token);
  }

  /// Parses the `exp` claim from [jwt] and compares it to the current time.
  bool _isJwtExpired(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length < 2) return true;

      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      switch (payload.length % 4) {
        case 1:
          payload += '===';
        case 2:
          payload += '==';
        case 3:
          payload += '=';
      }

      final decoded = utf8.decode(base64.decode(payload));
      final claims = json.decode(decoded) as Map<String, dynamic>;
      final exp = claims['exp'];

      if (exp is! num) return false;

      final expiry = DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
      return DateTime.now().isAfter(expiry);
    } catch (_) {
      return true;
    }
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
  // Clear All
  // =====================================================

  Future<void> clearAllTokens() async {
    await _storage.deleteAll();
  }
}
