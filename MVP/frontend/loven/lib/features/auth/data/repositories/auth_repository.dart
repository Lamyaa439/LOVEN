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

class AuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  /// Persists access and refresh tokens returned by login/register.
  ///
  /// Both tokens are required for a complete session — access for API
  /// calls (via [ApiClient]'s interceptor) and refresh for future renewal.
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

    await _persistSessionTokens(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  /// Registers a new user account and persists JWT session tokens.
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

    await _persistSessionTokens(
      Map<String, dynamic>.from(response.data as Map),
    );
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
      await _apiClient.post(ApiConstants.logout, data: {});
    } catch (_) {
      // Best-effort server call; local cleanup always proceeds.
    }

    await _tokenStorage.clearAllTokens();
  }

  /// Checks whether the given [email] is already registered.
  ///
  /// Returns `true` if the email is taken, `false` otherwise.
  ///
  /// TODO: Wire this to a dedicated backend endpoint (e.g. GET /check-email)
  /// once it is implemented. Currently returns `false` as a safe default
  /// so the signup page's async validation infrastructure compiles and the
  /// user is never blocked by a phantom "email taken" error.
  Future<bool> checkEmailDuplication(String email) async {
    // Placeholder until the backend exposes a lightweight email-check route.
    return false;
  }
}
