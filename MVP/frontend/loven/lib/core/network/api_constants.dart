import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

import 'package:loven/core/storage/token_storage.dart';

/// ========================================================================
/// API Client Configuration & Endpoints
///
/// This file contains the core API networking layer using Dio.
/// It implements Clean Architecture principles by separating the
/// endpoints ([ApiConstants]) from the networking logic ([ApiClient]).
///
/// Authentication:
/// - A request interceptor attaches the access JWT from [TokenStorage].
/// - A response interceptor renews expired sessions via `POST /refresh`
///   and retries the failed call once (see [_SessionInterceptor]).
/// ========================================================================

/// Dio [RequestOptions.extra] flag — prevents infinite retry loops after refresh.
const String _kRetriedAfterRefreshKey = 'retried_after_refresh';

/// Holds URI paths passed to [ApiClient] (Dio). Every path is **relative to**
/// [ApiClient.baseUrl], which must be the API root (e.g. `http://host/api/v1`
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
  static const String changePassword = '/change-password';
  static const String currentUser = '/account/me';

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

  static const String adminVerificationRequests = '/verification-requests';

  static String verificationRequestStatus(String requestId) =>
      '/verification-requests/$requestId/status';

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
  /// Single, version-controlled fallback when `.env` is missing or empty.
  static const String defaultBaseUrl =
      'http://34.224.37.128:5000/api/v1';

  late final Dio _dio;
  final TokenStorage _tokenStorage;

  /// Resolved API root used by this client instance.
  final String baseUrl;

  VoidCallback? _onSessionExpired;

  /// Coalesces parallel 401s into one refresh call (avoids token stampede).
  Future<void>? _refreshInFlight;

  ApiClient({
    required TokenStorage tokenStorage,
    String? baseUrl,
  })  : _tokenStorage = tokenStorage,
        baseUrl = baseUrl ?? resolveBaseUrl() {
    _dio = Dio(
      BaseOptions(
        baseUrl: this.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_AuthRequestInterceptor(_tokenStorage));
    _dio.interceptors.add(
      _SessionInterceptor(
        dio: _dio,
        tokenStorage: _tokenStorage,
        refreshAccessToken: _coalescedRefresh,
        onSessionExpired: _notifySessionExpired,
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          error: true,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Base URL resolution (Infrastructure / configuration boundary)
  // ---------------------------------------------------------------------------

  /// Resolves the API root from `.env`, with a single explicit dev fallback.
  ///
  /// **Clean Architecture:** Repositories must not read `dotenv` themselves.
  /// Configuration is resolved once at the infrastructure edge ([ApiClient])
  /// so the rest of the app depends on a stable, injected base URL.
  static String resolveBaseUrl() {
    final fromEnv = dotenv.env['BASE_URL']?.trim();

    if (fromEnv != null && fromEnv.isNotEmpty) {
      return _normalizeBaseUrl(fromEnv);
    }

    // Warn in debug so missing `.env` is obvious during local runs.
    if (kDebugMode) {
      debugPrint(
        '[ApiClient] BASE_URL is unset — using defaultBaseUrl ($defaultBaseUrl). '
        'Add BASE_URL to .env for team/staging hosts.',
      );
    }

    return defaultBaseUrl;
  }

  /// Ensures Dio concatenation is predictable (`host/api/v1` + `/carts/`).
  static String _normalizeBaseUrl(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // ---------------------------------------------------------------------------
  // Session lifecycle hook (presentation layer wires AuthCubit here)
  // ---------------------------------------------------------------------------

  /// Registers a callback when refresh fails after a 401 (session is invalid).
  ///
  /// **Why a callback instead of importing [AuthCubit]?** The network layer
  /// must not depend on feature/UI code. [main.dart] attaches
  /// `authCubit.handleSessionExpired` after DI is ready — inversion of control.
  void attachSessionExpiredHandler(VoidCallback onSessionExpired) {
    _onSessionExpired = onSessionExpired;
  }

  void _notifySessionExpired() {
    _onSessionExpired?.call();
  }

  // ---------------------------------------------------------------------------
  // Token refresh (used by [_SessionInterceptor], mirrors AuthRepository)
  // ---------------------------------------------------------------------------

  Future<void> _refreshAccessToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token available');
    }

    final response = await postWithBearerToken(
      ApiConstants.refresh,
      bearerToken: refreshToken,
      data: {},
    );

    final data = response.data;
    if (data is! Map) {
      throw Exception('Invalid refresh response');
    }

    final accessToken = data['access_token']?.toString();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Server did not return an access token');
    }

    await _tokenStorage.saveAccessToken(accessToken);
  }

  /// One refresh at a time; concurrent 401s await the same future.
  Future<void> _coalescedRefresh() {
    _refreshInFlight ??= _refreshAccessToken().whenComplete(() {
      _refreshInFlight = null;
    });
    return _refreshInFlight!;
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
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Sends a PATCH request to [path] (relative to [BaseOptions.baseUrl]).
  Future<Response> patch(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Sends a DELETE request to [path] (relative to [BaseOptions.baseUrl]).
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
  String _handleError(DioException error) {
    if (error.response != null && error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map) {
        if (data.containsKey('error')) return data['error'].toString();
        if (data.containsKey('message')) return data['message'].toString();
      }
    }
    return 'Network error occurred. Please try again later.';
  }
}

// =============================================================================
// Interceptors (kept private — infrastructure detail of this file)
// =============================================================================

/// Attaches the short-lived access JWT to outgoing requests.
///
/// Callers that set `Authorization` explicitly (e.g. `POST /refresh`) are
/// left untouched so the refresh token is not overwritten.
class _AuthRequestInterceptor extends Interceptor {
  _AuthRequestInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
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
  }
}

/// Handles expired access tokens: refresh once, retry once, then sign out.
///
/// **Why in the client layer?** Session renewal is a cross-cutting infrastructure
/// concern. Repositories stay thin (one responsibility: map endpoints to DTOs)
/// and do not each re-implement 401 handling.
class _SessionInterceptor extends Interceptor {
  _SessionInterceptor({
    required Dio dio,
    required TokenStorage tokenStorage,
    required Future<void> Function() refreshAccessToken,
    required void Function() onSessionExpired,
  })  : _dio = dio,
        _tokenStorage = tokenStorage,
        _refreshAccessToken = refreshAccessToken,
        _onSessionExpired = onSessionExpired;

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final Future<void> Function() _refreshAccessToken;
  final void Function() _onSessionExpired;

  static const _publicAuthPaths = {
    ApiConstants.login,
    ApiConstants.register,
    ApiConstants.refresh,
  };

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    if (statusCode != 401) {
      handler.next(err);
      return;
    }

    final options = err.requestOptions;

    // Do not refresh for auth endpoints or after we already retried.
    if (_publicAuthPaths.contains(options.path) ||
        options.extra[_kRetriedAfterRefreshKey] == true) {
      handler.next(err);
      return;
    }

    try {
      await _refreshAccessToken();

      final newAccessToken = await _tokenStorage.getAccessToken();
      if (newAccessToken == null || newAccessToken.isEmpty) {
        throw Exception('No access token after refresh');
      }

      final retryOptions = options.copyWith(
        extra: Map<String, dynamic>.from(options.extra)
          ..[_kRetriedAfterRefreshKey] = true,
        headers: Map<String, dynamic>.from(options.headers)
          ..['Authorization'] = 'Bearer $newAccessToken',
      );

      final response = await _dio.fetch(retryOptions);
      handler.resolve(response);
    } catch (_) {
      await _tokenStorage.clearAllTokens();
      _onSessionExpired();
      handler.next(err);
    }
  }
}
