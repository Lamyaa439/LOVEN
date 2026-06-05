// Barrel file for network layer imports.
//
// Prefer:
// - [ApiClient] from api_client.dart
// - [ApiEndpoints] from api_endpoints.dart
import 'api_endpoints.dart';

export 'api_client.dart' show ApiClient, kRetriedAfterRefreshKey;
export 'api_endpoints.dart' show ApiEndpoints;

/// Backward-compatible alias — prefer [ApiEndpoints].
typedef ApiConstants = ApiEndpoints;
