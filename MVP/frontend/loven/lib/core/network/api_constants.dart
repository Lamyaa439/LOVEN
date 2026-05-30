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


/// Holds URI paths passed to [ApiClient] (Dio). Every path is **relative to**
/// [ApiClient]'s `baseUrl`, which must be the API root (e.g. `http://host/api/v1`
/// from `.env` `BASE_URL`).
///
/// ## Path conventions
///
/// **Root-mounted routes** — blueprint registered at `/api/v1` only:
/// - Auth: `/register`, `/login`, `/refresh`, `/logout`
/// - Artist profiles: `/artist-profiles`, `/artist-profiles/me`, …
/// - Verification: `/verification-requests`
///
/// **Feature-prefixed routes** — blueprint adds a segment under `/api/v1`:
/// - Carts: `/carts/`, `/carts/items`
/// - Orders: `/orders/`, `/orders/mine`
/// - Artworks: `/artworks/`, `/artworks/search`, `/artworks/mine`
/// - Feedback: `/feedback/`
/// - Reports: `/reports/`
/// - Favorites: `/favorites/`
/// - Payments: `/payments/orders/{id}/…`
///
/// Dio resolves `baseUrl + path` (e.g. `…/api/v1` + `/carts/` → `…/api/v1/carts/`).
class ApiConstants {
  // =====================================================
  // Authentication (root-mounted on /api/v1)
  // =====================================================

  static const String register = '/register';
  static const String login = '/login';
  static const String refresh = '/refresh';
  static const String logout = '/logout';

  // =====================================================
  // Artist profiles (root-mounted: /api/v1/artist-profiles/…)
  // =====================================================

  /// POST — create or restore profile (`POST /artist-profiles`).
  static const String createArtistProfile = '/artist-profiles';

  /// GET/PATCH/DELETE — authenticated user's profile.
  static const String myArtistProfile = '/artist-profiles/me';

  /// GET — list profiles; append `/{profileId}` for single profile.
  static const String artistProfiles = '/artist-profiles';

  /// GET — append `/{display_name}` for public lookup by handle.
  static const String artistProfileByName = '/artist-profiles/by-name';

  /// GET — `{artistProfiles}/{profileId}/artworks`.
  static String artistProfileArtworks(String profileId) =>
      '$artistProfiles/$profileId/artworks';

  /// GET — `{artistProfiles}/{profileId}`.
  static String artistProfileById(String profileId) =>
      '$artistProfiles/$profileId';

  // =====================================================
  // Cart (feature prefix: /api/v1/carts/…)
  // =====================================================

  static const String cart = '/carts/';
  static const String cartItems = '/carts/items';

  /// PATCH/DELETE — `{cartItems}/{itemId}`.
  static String cartItemById(String itemId) => '$cartItems/$itemId';

  // =====================================================
  // Orders (feature prefix: /api/v1/orders/…)
  // =====================================================

  static const String orders = '/orders/';
  static const String myOrders = '/orders/mine';

  /// GET — `{orders}buyer/{buyerId}`.
  static String ordersByBuyer(String buyerId) => '${orders}buyer/$buyerId';

  /// GET — `{orders}artist/{artistProfileId}`.
  static String ordersByArtist(String artistProfileId) =>
      '${orders}artist/$artistProfileId';

  /// PATCH — update shipment status (artist dashboard).
  static String orderStatus(String orderId) => '${orders}$orderId/status';

  // =====================================================
  // Artworks (feature prefix: /api/v1/artworks/…)
  // =====================================================

  static const String artworks = '/artworks/';
  static const String artworkSearch = '/artworks/search';
  static const String myArtworks = '/artworks/mine';

  /// GET/PATCH/DELETE — `{artworks}{artworkId}`.
  static String artworkById(String artworkId) => '$artworks$artworkId';

  // =====================================================
  // Feedback (feature prefix: /api/v1/feedback/…)
  // =====================================================

  static const String feedback = '/feedback/';

  // =====================================================
  // Reports (feature prefix: /api/v1/reports/…)
  // =====================================================

  static const String reports = '/reports/';

  // =====================================================
  // Favorites (feature prefix: /api/v1/favorites/…)
  // =====================================================

  static const String favorites = '/favorites/';
  static const String favoriteCheck = '/favorites/check';

  /// POST/DELETE — `{favorites}{artworkId}`.
  static String favoriteByArtworkId(String artworkId) =>
      '$favorites$artworkId';

  // =====================================================
  // Verification requests (root-mounted on /api/v1)
  // =====================================================

  static const String verificationRequests = '/verification-requests';

  // =====================================================
  // Payments (feature prefix: /api/v1/payments/…)
  // =====================================================

  /// POST — create or return pending payment before Moyasar checkout.
  static String paymentsInitiate(String orderId) =>
      '/payments/orders/$orderId/initiate';

  /// POST — verify Moyasar payment after SDK capture.
  static String paymentsVerify(String orderId) =>
      '/payments/orders/$orderId/verify';

  /// GET — payment record for an order.
  static String paymentsGet(String orderId) => '/payments/orders/$orderId';
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
          // Callers that set Authorization explicitly (e.g. POST /refresh
          // with the refresh JWT) must not be overwritten by the access token.
          final existingAuth = options.headers['Authorization'];
          if (existingAuth != null && existingAuth.toString().isNotEmpty) {
            handler.next(options);
            return;
          }

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

  /// POST with an explicit Bearer token, bypassing the access-token interceptor.
  ///
  /// Used for `POST /refresh`, which must authenticate with the refresh JWT
  /// rather than the (possibly expired) access token.
  Future<Response> postWithBearerToken(
    String path, {
    required String bearerToken,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $bearerToken'},
        ),
      );
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

  /// Sends a PATCH request to [path] (relative to [BaseOptions.baseUrl]).
  ///
  /// [data] is serialized to JSON by Dio. Used by repositories for partial
  /// updates (e.g. cart item quantity). Returns the raw [Response] on
  /// success; non-2xx status codes are converted to [Exception] via
  /// [_handleError] so callers can surface backend messages in the UI.
  Future<Response> patch(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Sends a DELETE request to [path] (relative to [BaseOptions.baseUrl]).
  ///
  /// Used for resource removal (e.g. cart items, clearing a cart).
  /// Returns the raw [Response] on success; failures throw [Exception]
  /// with a message extracted from the backend response body.
  Future<Response> delete(String path) async {
    try {
      final response = await _dio.delete(path);
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