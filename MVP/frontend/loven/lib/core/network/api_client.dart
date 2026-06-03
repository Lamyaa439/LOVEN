// Centralized HTTP client configuration for repositories and data sources.
//
// Uses AppEnv for base URL/timeouts, TokenStorage for auth headers,
// and AppException for failures. Endpoint paths live in ApiEndpoints.
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:loven/core/config/app_env.dart';
import 'package:loven/core/error/app_exception.dart';
import 'package:loven/core/network/api_endpoints.dart';
import 'package:loven/core/storage/token_storage.dart';

/// Dio [RequestOptions.extra] flag — prevents infinite retry loops after refresh.
const String kRetriedAfterRefreshKey = 'retried_after_refresh';

/// Dio-backed API client with auth attachment, 401 refresh, and session expiry hook.
class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    String? baseUrl,
  })  : _tokenStorage = tokenStorage,
        baseUrl = baseUrl ?? AppEnv.resolveBaseUrl() {
    _dio = Dio(
      BaseOptions(
        baseUrl: this.baseUrl,
        connectTimeout: AppEnv.connectTimeout,
        receiveTimeout: AppEnv.receiveTimeout,
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

  late final Dio _dio;
  final TokenStorage _tokenStorage;

  /// Resolved API root used by this client instance.
  final String baseUrl;

  // إذا انتهت الجلسة وفشل تجديد التوكن يطرد المستخدم إلى صفحة تسجيل الدخول 
  VoidCallback? _onSessionExpired;

  // يمنع طلب توكن آخر في نفس اللحظة
  Future<void>? _refreshInFlight;


  ///السطرين اللي تحت هذي حل مؤقت تحتاج تعديل بعدين  
  /// @deprecated Use [AppEnv.defaultBaseUrl].
  static const String defaultBaseUrl = AppEnv.defaultBaseUrl;

  /// @deprecated Use [AppEnv.resolveBaseUrl].
  static String resolveBaseUrl() => AppEnv.resolveBaseUrl();

  /// Called when refresh fails after a 401 — wire [AuthCubit.handleSessionExpired] here.
  void attachSessionExpiredHandler(VoidCallback onSessionExpired) {
    _onSessionExpired = onSessionExpired;
  }

  void _notifySessionExpired() {
    _onSessionExpired?.call();
  }

  // دالة تجديد التوكن
  Future<void> _refreshAccessToken() async {
    // نطلع الريفرش توكن
    final refreshToken = await _tokenStorage.getRefreshToken();

    // إذا كان الريفرش توكن مفقود او فارغ نرمي خطأ
    if (refreshToken == null || refreshToken.isEmpty) {
      throw AppException('No refresh token available');
    }
    // هنا نرسل الريفرش توكن للسيرفر عشان يرسل لنا ريفرش توكن جديد
    final response = await postWithBearerToken(
      ApiEndpoints.refresh,
      bearerToken: refreshToken,
      data: {}, // مانرسل بيانات
    );

    // نتأكد إن السيرفر رد علينا ببيانات صحيحة
    final data = response.data;
    if (data is! Map) {
      throw AppException('Invalid refresh response');
    }
    // نطلع الريفرش توكن الجديد من رد السيرفر
    final accessToken = data['access_token']?.toString();
    // إذا السيرفر ما ارسل توكن جديد نرمي خطأ 
    if (accessToken == null || accessToken.isEmpty) {
      throw AppException('Server did not return an access token');
    }
    // نحفظ الريفرش توكن الجديد
    await _tokenStorage.saveAccessToken(accessToken);
  }

  // هذي الدالة تضع طلبات تجديد التوكن في طابور عشان ما ينرسلون مره وحدة للسيرفر
  Future<void> _coalescedRefresh() {
    _refreshInFlight ??= _refreshAccessToken().whenComplete(() {
      _refreshInFlight = null;
    });
    return _refreshInFlight!;
  }

  Future<Response<dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<Response<dynamic>> postWithBearerToken(
    String path, {
    required String bearerToken,
    Map<String, dynamic>? data,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $bearerToken'},
        ),
      );
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<Response<dynamic>> patch(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<Response<dynamic>> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }
}

// إضافة التوكن للطلبات اللي تنرسل للسيرفر (الباك)
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
    ApiEndpoints.login,
    ApiEndpoints.register,
    ApiEndpoints.refresh,
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

    if (_publicAuthPaths.contains(options.path) ||
        options.extra[kRetriedAfterRefreshKey] == true) {
      handler.next(err);
      return;
    }

    try {
      await _refreshAccessToken();

      final newAccessToken = await _tokenStorage.getAccessToken();
      if (newAccessToken == null || newAccessToken.isEmpty) {
        throw AppException('No access token after refresh');
      }

      final retryOptions = options.copyWith(
        extra: Map<String, dynamic>.from(options.extra)
          ..[kRetriedAfterRefreshKey] = true,
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
