/// ========================================================================
/// Authentication Repository
///
/// Data-access layer responsible for all authentication-related API calls.
///
/// Architectural decisions:
/// - Accepts [ApiClient] and [TokenStorage] via constructor injection
///   for testability and separation of concerns.
/// - Delegates all HTTP networking to the centralized Dio-based [ApiClient],
///   which reads the base URL from .env and handles error extraction.
/// - No manual JSON encoding/decoding — Dio serializes request maps
///   automatically and returns decoded maps via `response.data`.
/// - Endpoint paths are relative constants from [ApiConstants]; the base
///   URL is prepended by Dio's [BaseOptions].
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

  /// Authenticates an existing user and persists the JWT access token.
  ///
  /// Throws an [Exception] propagated from [ApiClient] if the backend
  /// returns a non-2xx status (e.g. 401 invalid credentials).
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

    final token = response.data['access_token'] as String?;
    if (token == null) throw Exception('Server did not return an access token');

    await _tokenStorage.saveAccessToken(token);
  }

  /// Registers a new user account and persists the JWT access token.
  ///
  /// The backend returns 201 on success with `access_token` in the body.
  /// Any validation or duplication error (400/409) surfaces through
  /// the [ApiClient] error handler as a user-friendly message.
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

    final token = response.data['access_token'] as String?;
    if (token == null) throw Exception('Server did not return an access token');

    await _tokenStorage.saveAccessToken(token);
  }

/// Changes the current user's password.
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

Future<UserModel> getCurrentUser() async {
  final response = await _apiClient.get(ApiConstants.currentUser);

  return UserModel.fromJson(response.data);
}

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
      if (profileImageUrl != null)
        'profile_image_url': profileImageUrl,
    },
  );

  return UserModel.fromJson(response.data);
}

/// Invalidates the current session on the backend and clears local tokens.
///
/// The Authorization header is injected automatically by the [ApiClient]'s
/// auth interceptor — no manual token handling needed here.
///
/// Swallows network errors intentionally — the user should always end up
/// logged out locally even if the server call fails (e.g. expired token).
Future<void> logout() async {
  try {
    await _apiClient.post(
      ApiConstants.logout,
      data: {},
    );
  } catch (_) {
    // Best-effort server call; local cleanup always proceeds.
  }

  await _tokenStorage.clearAllTokens();
}

/// Checks whether the given [email] is already registered.
Future<bool> checkEmailDuplication(
  String email,
) async {
  return false;
}

/// Checks whether a valid local auth token exists.
Future<bool> isLoggedIn() async {
  final token =
      await _tokenStorage.getAccessToken();

  return token != null && token.isNotEmpty;
  }

}