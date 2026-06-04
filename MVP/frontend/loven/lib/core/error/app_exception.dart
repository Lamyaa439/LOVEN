import 'package:dio/dio.dart';

/// Canonical application exception for repositories, services, and UI error text.
///
/// **Ownership (frozen contract):**
/// - User-facing [message] (also returned by [toString])
/// - Optional HTTP [statusCode] and underlying [cause]
/// - Dio → [AppException] mapping via [fromDio]
///
/// Repositories should surface failures as [AppException] (not raw [Exception] or
/// [DioException]) so cubits/screens handle one type. Implements [Exception] so
/// existing `catch (e)` flows keep working.
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
  ///
  /// Backend error bodies may use `error` or `message` keys (both are checked).
  /// When neither is present, [fallback] is used.
  factory AppException.fromDio(
    DioException error, {
    String fallback = 'Network error occurred. Please try again later.',
  }) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

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
