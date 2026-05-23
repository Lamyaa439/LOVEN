import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';

class VerificationRequestRepository {
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, dynamic>> submitRequest({
    required String documentType,
    required String institutionName,
    required String documentNumber,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.post(
      Uri.parse(ApiConstants.verificationRequests),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'document_type': documentType,
        'institution_name': institutionName,
        'document_number': documentNumber,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }

    throw Exception(data['error'] ?? 'Failed to submit verification request');
  }
}