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
  
  Future<List<Map<String, dynamic>>> getAllFeedback() async {
  final response = await _apiClient.get(
    ApiEndpoints.feedback,
  );

  final data = response.data as Map<String, dynamic>;
  final feedback = data['feedback'] as List? ?? [];

  return feedback
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();
}
}