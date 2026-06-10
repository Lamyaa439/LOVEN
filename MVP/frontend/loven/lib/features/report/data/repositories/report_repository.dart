/// ========================================================================
/// Report Repository
///
/// Data-access layer for submitting moderation reports against content.
///
/// Architectural decisions:
/// - Accepts [ApiClient] via constructor injection so auth headers, base URL,
///   and error handling stay centralized and mockable.
/// - Delegates HTTP to [ApiClient]; non-2xx responses throw [Exception]s
///   with backend messages — this repository does not catch them.
/// - Endpoint paths come from [ApiConstants] relative to [ApiClient]'s base.
/// ========================================================================

import 'package:loven/core/network/api_endpoints.dart';
import 'package:loven/core/network/api_client.dart';

class ReportRepository {
  final ApiClient _apiClient;

  /// Creates a repository backed by the shared [apiClient] instance.
  ReportRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Map<String, dynamic> _asMap(dynamic data) {
    return Map<String, dynamic>.from(data as Map);
  }

  /// Submits a report (`POST /reports/`).
  ///
  /// [targetType] and [targetId] identify the reported entity; [reason]
  /// describes the violation. Optional [details] adds free-form context.
  Future<Map<String, dynamic>> submitReport({
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.reports,
      data: {
        'target_artwork_id': targetId,
        'reason': reason,
        if (details != null) 'details': details,
      },
    );

    return _asMap(response.data);
  }

  Future<List<dynamic>> getReports() async {
  final response = await _apiClient.get(
    ApiEndpoints.reports,
  );

  final data = response.data;

  if (data is Map<String, dynamic>) {
    return data['reports'] ?? [];
  }

  return [];
}

Future<Map<String, dynamic>> updateReportStatus({
  required String reportId,
  required String status,
}) async {
  final response = await _apiClient.patch(
    ApiEndpoints.reportStatus(reportId),
    data: {
      'status': status,
    },
  );

  return _asMap(response.data);
}

Future<Map<String, dynamic>> updateArtworkStatus({
  required String artworkId,
  required String status,
}) async {
  final response = await _apiClient.patch(
    ApiEndpoints.adminArtworkStatus(artworkId),
    data: {
      'status': status,
    },
  );

  return _asMap(response.data);
}
}
