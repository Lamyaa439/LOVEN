import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';

class ReportRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  ReportRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

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

    return Map<String, dynamic>.from(
      response.data,
    );
  }
}