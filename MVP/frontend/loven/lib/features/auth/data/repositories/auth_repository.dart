import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';

class AuthRepository {
  final TokenStorage _tokenStorage = TokenStorage();

  Future<void> login({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        if (fcmToken != null) 'fcm_token': fcmToken,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await _tokenStorage.saveAccessToken(
        data['access_token'],
      );
      return;
    }

    throw Exception(data['error'] ?? 'Login failed');
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String systemRole,
    String? fcmToken,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'system_role': systemRole,
        if (fcmToken != null) 'fcm_token': fcmToken,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 ||
        response.statusCode == 200) {
      await _tokenStorage.saveAccessToken(
        data['access_token'],
      );
      return;
    }

    throw Exception(data['error'] ?? 'Registration failed');
  }

  Future<void> logout() async {
    final token = await _tokenStorage.getAccessToken();

    await http.post(
      Uri.parse(ApiConstants.logout),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    await _tokenStorage.clearAccessToken();
  }
}