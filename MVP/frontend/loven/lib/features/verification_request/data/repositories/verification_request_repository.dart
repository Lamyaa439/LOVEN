import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';

class VerificationRequestRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  VerificationRequestRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

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

    return Map<String, dynamic>.from(
      response.data,
    );
  }

  Future<List<Map<String, dynamic>>> fetchAllRequests() async {
    final response = await _apiClient.get(
      ApiConstants.verificationRequests,
    );

    final data = response.data;

    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }

    if (data['requests'] is List) {
      return (data['requests'] as List)
          .cast<Map<String, dynamic>>();
    }

    return [];
  }

  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
  }) async {
    await _apiClient.patch(
      ApiConstants.verificationRequestStatus(
        requestId,
      ),
      data: {
        'status': status,
      },
    );
  }
}