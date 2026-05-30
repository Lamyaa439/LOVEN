import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';

class FeedbackRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  FeedbackRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

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

    return Map<String, dynamic>.from(
      response.data,
    );
  }
}