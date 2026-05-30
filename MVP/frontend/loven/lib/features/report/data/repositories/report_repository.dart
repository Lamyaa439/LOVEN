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

import 'package:loven/core/network/api_constants.dart';

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
      ApiConstants.reports,
      data: {
        'target_type': targetType,
        'target_id': targetId,
        'reason': reason,
        if (details != null) 'details': details,
      },
    );

    return _asMap(response.data);
  }
}
