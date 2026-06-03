import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized access to environment and runtime configuration values.
///
/// Load via [load] in [main] before constructing [ApiClient]. Features must
/// not read `dotenv` directly — use [resolveBaseUrl] or inject the resolved URL.
abstract final class AppEnv {
  AppEnv._();

  /// Bundled env asset path — must match `pubspec.yaml` `flutter.assets`.
  static const String envAssetPath = 'assets/.env';

  /// Version-controlled fallback when [load] fails or `BASE_URL` is unset.
  static const String defaultBaseUrl = 'http://34.224.37.128:5000/api/v1';

  // التطبيق ينتظر ١٥ ثانية كأقصى حد إذا ما اشتغل نعتبر انه فيه مشكلة في النت
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // .env اسم المتغير اللي بنبحث عنه في ملف ال 
  static const String _baseUrlKey = 'BASE_URL';

  /// Loads dotenv from the bundled asset; safe to call if the file is missing.
  static Future<void> load({String fileName = envAssetPath}) async {
    try {
      await dotenv.load(fileName: fileName);
    } catch (_) {
      // ApiClient falls back to [defaultBaseUrl] via [resolveBaseUrl].
    }
  }

  /// Resolved API root (`host/api/v1`) used as Dio [BaseOptions.baseUrl].
  static String resolveBaseUrl() {
    final fromEnv = dotenv.env[_baseUrlKey]?.trim();

    if (fromEnv != null && fromEnv.isNotEmpty) {
      return _normalizeBaseUrl(fromEnv);
    }

    if (kDebugMode) {
      debugPrint(
        '[AppEnv] BASE_URL is unset — using defaultBaseUrl ($defaultBaseUrl). '
        'Add BASE_URL to $envAssetPath for team/staging hosts.',
      );
    }

    return defaultBaseUrl;
  }

  static String _normalizeBaseUrl(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}
