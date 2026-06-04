import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Single source of truth for environment and runtime configuration.
///
/// **Ownership (frozen contract):**
/// - Bundled `.env` loading ([load])
/// - API root resolution ([resolveBaseUrl], [defaultBaseUrl])
/// - Shared HTTP timeouts ([connectTimeout], [receiveTimeout])
///
/// **Callers must not** read `package:flutter_dotenv` directly. Inject or call
/// [resolveBaseUrl] from composition root ([main]) before constructing [ApiClient].
///
/// Resolution order for base URL:
/// 1. Non-empty `BASE_URL` from loaded dotenv
/// 2. [defaultBaseUrl] (with a debug log when unset)
abstract final class AppEnv {
  AppEnv._();

  /// Bundled env asset path — must match `pubspec.yaml` `flutter.assets`.
  static const String envAssetPath = 'assets/.env';

  /// Version-controlled fallback when [load] fails or `BASE_URL` is unset.
  ///
  /// Prefer setting `BASE_URL` in [envAssetPath] for team/staging hosts.
  static const String defaultBaseUrl = 'http://34.224.37.128:5000/api/v1';

  /// Maximum wait for TCP connect before Dio reports a timeout.
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Maximum wait for response body after connect.
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String _baseUrlKey = 'BASE_URL';

  /// Loads dotenv from the bundled asset.
  ///
  /// Safe to call when the asset is missing; [resolveBaseUrl] still returns
  /// [defaultBaseUrl] in that case.
  static Future<void> load({String fileName = envAssetPath}) async {
    try {
      await dotenv.load(fileName: fileName);
    } catch (_) {
      // Missing or invalid asset — [resolveBaseUrl] uses [defaultBaseUrl].
    }
  }

  /// Resolved API root used as Dio `BaseOptions.baseUrl`.
  ///
  /// Trailing slashes are stripped so [ApiEndpoints] paths compose predictably.
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
