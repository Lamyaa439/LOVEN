import 'package:loven/core/network/api_constants.dart';
import 'package:loven/features/auth/data/models/auth_user.dart';

/// Account profile data access for authenticated LOVEN users.
///
/// **Ownership:** `GET /account/me` and `PATCH /account/me` only.
/// Session credentials (login, logout, token storage) live in [AuthRepository].
///
/// Callers must ensure a valid LOVEN JWT is present — [ApiClient] attaches it
/// from [TokenStorage]; this repository does not manage session state.
class AccountRepository {
  final ApiClient _apiClient;

  AccountRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Map<String, dynamic> _asMap(dynamic data) {
    return Map<String, dynamic>.from(data as Map);
  }

  /// Loads the authenticated user's account profile.
  Future<AuthUser> getAccount() async {
    final response = await _apiClient.get(ApiConstants.currentUser);

    return AuthUser.fromJson(_asMap(response.data));
  }

  /// Updates the authenticated user's account profile.
  Future<AuthUser> updateAccount({
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

    return AuthUser.fromJson(_asMap(response.data));
  }
}
