/// ========================================================================
/// Verification Request Repository
///
/// Data-access layer for artist identity verification submissions.
///
/// Architectural decisions:
/// - Accepts [ApiClient] via constructor injection so auth headers, base URL,
///   and error handling stay centralized and mockable.
/// - Delegates HTTP to [ApiClient]; non-2xx responses throw [Exception]s
///   with backend messages — this repository does not catch them.
/// - Posts to the root-mounted `/verification-requests` route on `/api/v1`.
/// ========================================================================

import 'package:loven/core/network/api_constants.dart';

class VerificationRequestRepository {
  final ApiClient _apiClient;

  VerificationRequestRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  Map<String, dynamic> _asMap(dynamic data) {
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> submitRequest({
    required String documentType,
    required String institutionName,
    required String documentNumber,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.verificationRequests,
      data: {
        'document_type': documentType,
        'institution_name': institutionName,
        'document_number': documentNumber,
      },
    );

    return _asMap(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchAllRequests() async {
    final response = await _apiClient.get(
      ApiConstants.adminVerificationRequests,
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      final requests =
          data['requests'] ?? data['data'] ?? [];

      return List<Map<String, dynamic>>.from(
        requests,
      );
    }

    if (data is List) {
      return List<Map<String, dynamic>>.from(
        data,
      );
    }

    return [];
  }

  Future<Map<String, dynamic>> updateRequestStatus({
    required String requestId,
    required String status,
  }) async {
    final response = await _apiClient.patch(
      ApiConstants.verificationRequestStatus(
        requestId,
      ),
      data: {
        'status': status,
      },
    );

    return _asMap(response.data);
  }
}