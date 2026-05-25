import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

/// ========================================================================
/// API Client Configuration & Endpoints
/// 
/// This file contains the core API networking layer using Dio.
/// It implements Clean Architecture principles by separating the 
/// endpoints (ApiEndpoints) from the networking logic (ApiClient).
/// Base URLs are securely loaded from environment variables (.env).
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
}

/// Centralized Dio client for handling all network requests safely.
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    // Load Base URL from .env, fallback to AWS IP if not found
    final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://16.170.246.241:5000/api/v1';

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

    // Add logging interceptor only in Debug mode to track requests/responses
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

  /// Extracts backend error messages safely to be displayed in the UI
  String _handleError(DioException error) {
    if (error.response != null && error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
    }
    return "Network error occurred. Please try again later.";
  }
}