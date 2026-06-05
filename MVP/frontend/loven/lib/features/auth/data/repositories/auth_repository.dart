import 'package:loven/core/error/app_exception.dart';
import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';
import 'package:loven/features/auth/data/models/auth_user.dart';

/// Data-access layer for auth credentials and session tokens.
///
/// `GET/PATCH /account/me` remain here for session hydration; account UI lives
/// under `features/account/`.
///
/// **Session ownership:**
/// - Persists JWTs on login/register; clears on [logout] / [clearLocalSession].
/// - [isLoggedIn] — local access token present (no expiry check).
/// - [restoreAuthenticatedUser] — boot profile load (`GET /account/me`); used by
///   [AuthCubit.restoreSession] after [isLoggedIn] is true.
/// - Does **not** refresh tokens — [ApiClient] interceptors own `POST /refresh`.
///
/// **Errors:** throws [AppException] for validation and propagated HTTP failures.
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

  Future<void> _persistSessionTokens(Map<String, dynamic> data) async {
    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;

    if (accessToken == null || accessToken.isEmpty) {
      throw const AppException('Server did not return an access token');
    }
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const AppException('Server did not return a refresh token');
    }

    await _tokenStorage.saveAccessToken(accessToken);
    await _tokenStorage.saveRefreshToken(refreshToken);
  }

  /// True when a non-empty access token is stored locally.
  Future<bool> isLoggedIn() => _tokenStorage.hasValidSession();

  /// Clears local JWT credentials (e.g. logout fallback or failed restore).
  Future<void> clearLocalSession() => _tokenStorage.clearAllTokens();

  /// Loads the authenticated profile during boot restore.
  ///
  /// Call only when [isLoggedIn] is true. Expired access tokens are refreshed by
  /// [ApiClient] before this throws; irrecoverable auth failures clear tokens via
  /// the session-expired handler.
  Future<UserModel> restoreAuthenticatedUser() async {
    return getCurrentUser();
  }

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
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout, data: {});
    } catch (_) {
      // Best-effort server call.
    }

    await clearLocalSession();
  }

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

    return UserModel.fromJson(_asMap(response.data));
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
        if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
      },
    );

    return UserModel.fromJson(_asMap(response.data));
  }

  Future<bool> checkEmailDuplication(String email) async {
    return false;
  }
}
