import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String accessTokenKey = 'access_token';

  static const String refreshTokenKey = 'refresh_token';

  // =====================================================
  // Access Token
  // =====================================================

  Future<void> saveAccessToken(
    String token,
  ) async {
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

  Future<void> saveRefreshToken(
    String token,
  ) async {
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
