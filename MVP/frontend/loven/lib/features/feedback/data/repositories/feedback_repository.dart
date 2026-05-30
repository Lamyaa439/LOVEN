/// ========================================================================
/// Feedback Repository
///
/// Data-access layer for submitting user feedback to the platform.
///
/// Architectural decisions:
/// - Accepts [ApiClient] via constructor injection so auth headers, base URL,
///   and error handling stay centralized and mockable.
/// - Delegates HTTP to [ApiClient]; non-2xx responses throw [Exception]s
///   with backend messages — this repository does not catch them.
/// - Endpoint paths come from [ApiConstants] relative to [ApiClient]'s base.
/// ========================================================================

import 'package:loven/core/network/api_constants.dart';

class FeedbackRepository {
  final ApiClient _apiClient;

  /// Creates a repository backed by the shared [apiClient] instance.
  FeedbackRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Map<String, dynamic> _asMap(dynamic data) {
    return Map<String, dynamic>.from(data as Map);
  }

  /// Submits feedback (`POST /feedback/`).
  ///
  /// [message] is required; [subject] is optional context for moderators.
  /// Returns the decoded JSON body on success.
  Future<Map<String, dynamic>> submitFeedback({
    required String message,
    String? subject,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.feedback,
      data: {
        if (subject != null) 'subject': subject,
        'message': message,
      },
    );

    return _asMap(response.data);
  }
}
