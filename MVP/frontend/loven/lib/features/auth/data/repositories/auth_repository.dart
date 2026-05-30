/// ========================================================================
/// Authentication Repository
///
/// Data-access layer for auth session lifecycle and account profile calls.
///
/// Architectural decisions:
/// - Accepts [ApiClient] and [TokenStorage] via constructor injection.
/// - Delegates HTTP and error extraction to [ApiClient]; this repository
///   does not catch or translate exceptions except for best-effort logout.
/// - Login/register persist both JWT tokens via [_persistSessionTokens].
/// - Account reads/writes use `GET/PATCH /account/me` ([ApiConstants.currentUser]).
/// ========================================================================

import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';
import 'package:loven/features/auth/data/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  Map<String, dynamic> _asMap(dynamic data) {
    return Map<String, dynamic>.from(data as Map);
  }

  /// Persists access and refresh tokens returned by login/register.
  Future<void> _persistSessionTokens(Map<String, dynamic> data) async {
    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Server did not return an access token');
    }
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Server did not return a refresh token');
    }

    await _tokenStorage.saveAccessToken(accessToken);
    await _tokenStorage.saveRefreshToken(refreshToken);
  }

  /// Authenticates an existing user and persists JWT session tokens.
  Future<void> login({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
        if (fcmToken != null) 'fcm_token': fcmToken,
      },
    );

    await _persistSessionTokens(_asMap(response.data));
  }

  /// Registers a new user account and persists JWT session tokens.
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String systemRole,
    String? fcmToken,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'system_role': systemRole,
        if (fcmToken != null) 'fcm_token': fcmToken,
      },
    );

    await _persistSessionTokens(_asMap(response.data));
  }

  /// Invalidates the session on the backend and clears local tokens.
  ///
  /// Network failures are swallowed — local cleanup always proceeds.
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout, data: {});
    } catch (_) {
      // Best-effort server call.
    }

    await _tokenStorage.clearAllTokens();
  }

  /// Exchanges the stored refresh JWT for a new access token (`POST /refresh`).
  Future<void> refreshAccessToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token available');
    }

    final response = await _apiClient.postWithBearerToken(
      ApiConstants.refresh,
      bearerToken: refreshToken,
      data: {},
    );

    final data = _asMap(response.data);
    final accessToken = data['access_token'] as String?;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Server did not return an access token');
    }

    await _tokenStorage.saveAccessToken(accessToken);
  }

  /// Updates the authenticated user's password (`PATCH /change-password`).
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.patch(
      ApiConstants.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  /// Fetches the authenticated user's account profile (`GET /account/me`).
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(ApiConstants.currentUser);

    return UserModel.fromJson(_asMap(response.data));
  }

  /// Updates the authenticated user's account profile (`PATCH /account/me`).
  Future<UserModel> updateProfile({
    required String name,
    required String email,
    String? profileImageUrl,
  }) async {
    final response = await _apiClient.patch(
      ApiConstants.currentUser,
      data: {
        'name': name,
        'email': email,
        if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
      },
    );

    return UserModel.fromJson(_asMap(response.data));
  }

  /// Returns whether a non-empty access token is stored locally.
  Future<bool> isLoggedIn() => _tokenStorage.hasValidSession();

  /// Checks whether [email] is already registered.
  ///
  /// TODO: Wire to a backend endpoint once available. Returns `false` as a
  /// safe default so signup validation is never blocked by a missing route.
  Future<bool> checkEmailDuplication(String email) async {
    return false;
  }
}
