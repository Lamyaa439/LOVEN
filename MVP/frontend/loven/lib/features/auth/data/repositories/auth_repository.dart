import 'package:dio/dio.dart';

import 'package:loven/core/error/app_exception.dart';
import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';
import 'package:loven/features/auth/data/models/auth_error_codes.dart';
import 'package:loven/features/auth/data/models/auth_user.dart';
import 'package:loven/features/auth/data/models/register_sync_result.dart';

/// LOVEN session and profile data access for authenticated users.
///
/// **Credential ownership:** Firebase Auth owns email/password. This repository
/// exchanges verified Firebase ID tokens for LOVEN JWTs and manages session storage.
///
/// **Session ownership:**
/// - Persists JWTs on [loginWithFirebase]; clears on [logout] / [clearLocalSession].
/// - [isLoggedIn] — local access token present (no expiry check).
/// - [restoreAuthenticatedUser] — boot profile load (`GET /account/me`).
/// - Does **not** refresh tokens — [ApiClient] interceptors own `POST /refresh`.
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
  Future<UserModel> restoreAuthenticatedUser() async {
    return getCurrentUser();
  }

  /// Syncs a newly created Firebase user with LOVEN after client-side signup.
  ///
  /// Does **not** persist LOVEN JWT — user stays guest until [loginWithFirebase].
  Future<RegisterSyncResult> registerSync({
    required String idToken,
    required String name,
    required String systemRole,
    String? fcmToken,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.firebaseRegisterSync,
      data: {
        'id_token': idToken,
        'name': name,
        'system_role': systemRole,
        if (fcmToken != null) 'fcm_token': fcmToken,
      },
    );

    return RegisterSyncResult.fromJson(_asMap(response.data));
  }

  /// Exchanges a verified Firebase ID token for LOVEN JWT credentials.
  ///
  /// Throws [EmailNotVerifiedException] on `403` + `email_not_verified`.
  Future<void> loginWithFirebase({
    required String idToken,
    String? fcmToken,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.firebaseLogin,
        data: {
          'id_token': idToken,
          if (fcmToken != null) 'fcm_token': fcmToken,
        },
      );

      await _persistSessionTokens(_asMap(response.data));
    } on AppException catch (e) {
      if (_isEmailNotVerifiedError(e)) {
        throw EmailNotVerifiedException(_emailNotVerifiedMessage(e));
      }
      rethrow;
    }
  }

  bool _isEmailNotVerifiedError(AppException error) {
    if (error.statusCode != 403) {
      return false;
    }

    if (error.message == AuthErrorCodes.emailNotVerified) {
      return true;
    }

    final cause = error.cause;
    if (cause is DioException) {
      final data = cause.response?.data;
      if (data is Map && data['error'] == AuthErrorCodes.emailNotVerified) {
        return true;
      }
    }

    return false;
  }

  String _emailNotVerifiedMessage(AppException error) {
    final cause = error.cause;
    if (cause is DioException) {
      final data = cause.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    }

    if (error.message != AuthErrorCodes.emailNotVerified) {
      return error.message;
    }

    return 'Please verify your email before signing in.';
  }

  /// Invalidates the LOVEN session on the backend and clears local tokens.
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout, data: {});
    } catch (_) {
      // Best-effort server call.
    }

    await clearLocalSession();
  }

  /// TODO(future-phase): Remove when [ChangePasswordScreen] uses
  /// [FirebaseAuthService.updatePassword] for email/password users.
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
