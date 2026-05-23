import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';

class FeedbackRepository {
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, dynamic>> submitFeedback({
    required String message,
    String? subject,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.post(
      Uri.parse(ApiConstants.feedback),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (subject != null) 'subject': subject,
        'message': message,
      }),
    );

    return jsonDecode(response.body);
  }
}