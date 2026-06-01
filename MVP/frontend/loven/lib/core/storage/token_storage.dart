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
  static const String userRoleKey = 'user_role';

  // =====================================================
  // Session helpers
  // =====================================================

  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> isAccessTokenExpired() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return true;
    return _isJwtExpired(token);
  }

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

  Future<void> clearAllTokens() async {
    await _storage.deleteAll();
  }
}