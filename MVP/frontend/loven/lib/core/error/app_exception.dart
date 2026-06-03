import 'package:dio/dio.dart';

/// Unified application-level exceptions used across repositories and services.
///
/// Implements [Exception] so existing `catch (e)` / `toString()` flows keep working.
class AppException implements Exception {
  const AppException(
    this.message, {
    this.statusCode,
    this.cause,
  });

  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() => message;

  /// Maps a [DioException] to a user-facing [AppException].
  factory AppException.fromDio(
    DioException error, {
    String fallback = 'Network error occurred. Please try again later.',
  }) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // Backendهنا عشان نستقبل الاخطاء من ال
    // message ومرة يرسله داخل  errorمره يرسل الخطأ داخل مفتاح  Backendال
    // طبعاً سوينا كذا بالغلط نحتاج نعدله في الباك بعدين
    if (data is Map) {
      if (data.containsKey('error')) {
        return AppException(
          data['error'].toString(),
          statusCode: statusCode,
          cause: error,
        );
      }
      if (data.containsKey('message')) {
        return AppException(
          data['message'].toString(),
          statusCode: statusCode,
          cause: error,
        );
      }
    }

    return AppException(
      fallback,
      statusCode: statusCode,
      cause: error,
    );
  }
}
