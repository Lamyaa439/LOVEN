import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

import 'package:loven/core/storage/token_storage.dart';

/// ========================================================================
/// API Client Configuration & Endpoints
/// 
/// This file contains the core API networking layer using Dio.
/// It implements Clean Architecture principles by separating the 
/// endpoints (ApiEndpoints) from the networking logic (ApiClient).
/// Base URLs are securely loaded from environment variables (.env).
///
/// Authentication:
/// An [InterceptorsWrapper] automatically reads the JWT from
/// [TokenStorage] and attaches it as a Bearer token on every outgoing
/// request. Public endpoints (login, register) simply have no stored
/// token, so the header is skipped — no per-route opt-out needed.
/// ========================================================================


/// Holds only the URI paths. The BaseUrl is automatically prepended by Dio.
class ApiConstants {
  // =====================================================
  // Authentication
  // =====================================================

  static const String register = '/register';
  static const String login = '/login';
  static const String refresh = '/refresh';
  static const String logout = '/logout';

  // =====================================================
  // Artist Profiles
  // Current backend routes are mounted directly on /api/v1
  // =====================================================

  static const String createArtistProfile = '/';
  static const String myArtistProfile = '/me';
  static const String artistProfiles = '/';
  static const String artistProfileByName = '/by-name';

  // =====================================================
  // Cart
  // =====================================================

  static const String cart = '/carts/';
  static const String cartItems = '/carts/items';

  // =====================================================
  // Orders
  // =====================================================

  static const String orders = '/orders/';
  static const String myOrders = '/orders/mine';

  // =====================================================
  // Artworks
  // =====================================================

  static const String artworks = '/artworks/';
  static const String artworkSearch = '/artworks/search';

  static const String myArtworks = '/artworks/mine';

  // =====================================================
  // Feedback
  // =====================================================

  static const String feedback = '/feedback/';

  // =====================================================
  // Reports
  // =====================================================

  static const String reports = '/reports/';

// =====================================================
// Favorites
// =====================================================

  static const String favorites = '/favorites/';
  static const String favoriteCheck = '/favorites/check';

// =====================================================
// Verification Requests
// =====================================================

  static const String verificationRequests = '/verification-requests';
  
  static String verificationRequestStatus(String requestId) =>
    '$verificationRequests/$requestId/status';
}

/// Centralized Dio client for handling all network requests safely.
///
/// Accepts a [TokenStorage] instance to power the automatic auth interceptor.
/// Create once at app startup and inject into all repositories.
class ApiClient {
  late final Dio _dio;
  final TokenStorage _tokenStorage;

  ApiClient({required TokenStorage tokenStorage})
      : _tokenStorage = tokenStorage {
    final String baseUrl =
        dotenv.env['BASE_URL'] ?? 'http://16.170.246.241:5000/api/v1';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // =====================================================================
    // Auth Interceptor
    // Reads the JWT from secure storage before every request and attaches
    // it as a Bearer token. For unauthenticated endpoints (login, register)
    // the token will be null and the header is simply not added.
    // =====================================================================
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        error: true,
      ));
    }
  }

  // =======================================================================
  // Core HTTP Methods
  // =======================================================================

  /// Generic POST request method with centralized error handling
  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Generic PATCH request method with centralized error handling
  Future<Response> patch(
  String path, {
  Map<String, dynamic>? data,
  }) async {
    try {
      final response =
      await _dio.patch(
        path,
        data: data,
      );

    return response;
    } on DioException catch (e) {
      throw Exception(
        _handleError(e),
    );
  }
}

  /// Generic GET request method with centralized error handling
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // =======================================================================
  // Error Handler
  // =======================================================================

  /// Extracts backend error messages safely to be displayed in the UI.
  ///
  /// The Flask backend returns errors under either the `"error"` key
  /// (auth/validation) or the `"message"` key (general responses).
  /// This handler checks both to ensure no error string is lost.
  String _handleError(DioException error) {
    if (error.response != null && error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map) {
        if (data.containsKey('error')) return data['error'];
        if (data.containsKey('message')) return data['message'];
      }
    }
    return "Network error occurred. Please try again later.";
    }
}