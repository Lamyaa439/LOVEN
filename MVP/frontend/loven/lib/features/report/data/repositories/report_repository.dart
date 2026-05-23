import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';

class ReportRepository {
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, dynamic>> submitReport({
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.post(
      Uri.parse(ApiConstants.reports),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'target_type': targetType,
        'target_id': targetId,
        'reason': reason,
        if (details != null) 'details': details,
      }),
    );

    return jsonDecode(response.body);
  }
}