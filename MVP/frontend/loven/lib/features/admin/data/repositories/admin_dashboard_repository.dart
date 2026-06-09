import 'package:loven/core/network/api_client.dart';
import 'package:loven/core/network/api_endpoints.dart';

class AdminDashboardRepository {
  AdminDashboardRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getStats() async {
    final response = await _apiClient.get(
      ApiEndpoints.adminDashboardStats,
    );

    return Map<String, dynamic>.from(response.data as Map);
  }
}