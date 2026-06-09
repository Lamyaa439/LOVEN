import 'package:loven/core/network/api_client.dart';
import 'package:loven/core/network/api_endpoints.dart';

class AdminUsersRepository {
  AdminUsersRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<dynamic>> getUsers() async {
    final response = await _apiClient.get(
      ApiEndpoints.adminUsers,
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return data['users'] ?? [];
    }

    return [];
  }

  Future<Map<String, dynamic>> updateUserStatus({
    required String userId,
    required bool isActive,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.adminUserStatus(userId),
      data: {
        'is_active': isActive,
      },
    );

    return Map<String, dynamic>.from(response.data as Map);
  }
}