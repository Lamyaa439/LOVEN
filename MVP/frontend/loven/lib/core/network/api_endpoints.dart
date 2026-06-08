/// Single registry of backend-relative API paths.
///
/// **Ownership (frozen contract):**
/// - Path strings only (no host, no `BASE_URL`, no Dio configuration)
/// - Repositories and [ApiClient] compose URLs as:
///   `AppEnv.resolveBaseUrl()` + [ApiEndpoints] constant
///
/// **Callers must not** embed path literals in repositories or features — add
/// new routes here first, then consume via import.
///
/// Paths are relative to the API root from [AppEnv.resolveBaseUrl]
/// (e.g. `http://host/api/v1` + `/carts/` → `…/api/v1/carts/`).
abstract final class ApiEndpoints {
  ApiEndpoints._();

  // ---------------------------------------------------------------------------
  // Authentication (mounted on /api/v1)
  // ---------------------------------------------------------------------------

  static const String register = '/register'; // Deprecated — backend returns 410
  static const String login = '/login'; // Deprecated — backend returns 410
  static const String firebaseRegisterSync = '/auth/firebase/register-sync';
  static const String firebaseLogin = '/auth/firebase/login';
  static const String refresh = '/refresh';
  static const String logout = '/logout';
  static const String changePassword = '/change-password'; // Backend legacy — unused by Flutter
  static const String currentUser = '/account/me';

  // ---------------------------------------------------------------------------
  // Artist profiles (mounted on /api/v1)
  // ---------------------------------------------------------------------------

  static const String createArtistProfile = '/artist-profiles';
  static const String myArtistProfile = '/artist-profiles/me';
  static const String artistProfiles = '/artist-profiles';
  static const String artistProfileByName = '/artist-profiles/by-name';

  static String artistProfileArtworks(String profileId) =>
      '$artistProfiles/$profileId/artworks';

  static String artistProfileById(String profileId) =>
      '$artistProfiles/$profileId';

  // ---------------------------------------------------------------------------
  // Cart (/api/v1/carts/…)
  // ---------------------------------------------------------------------------

  static const String cart = '/carts/';
  static const String cartItems = '/carts/items';

  static String cartItemById(String itemId) => '$cartItems/$itemId';

  // ---------------------------------------------------------------------------
  // Orders (/api/v1/orders/…)
  // ---------------------------------------------------------------------------

  static const String orders = '/orders/';
  static const String myOrders = '/orders/mine';

  static String ordersByBuyer(String buyerId) => '${orders}buyer/$buyerId';

  static String ordersByArtist(String artistProfileId) =>
      '${orders}artist/$artistProfileId';

  static String orderStatus(String orderId) => '$orders$orderId/status';

  static String orderById(String orderId) => '$orders$orderId';

  // ---------------------------------------------------------------------------
  // Notifications (/api/v1/notifications/…)
  // ---------------------------------------------------------------------------

  static const String notifications = '/notifications/';

  static String notificationRead(String notificationId) =>
      '/notifications/$notificationId/read';

  static const String notificationsReadAll = '/notifications/read-all';

  // ---------------------------------------------------------------------------
  // Artworks (/api/v1/artworks/…)
  // ---------------------------------------------------------------------------

  static const String artworks = '/artworks/';
  static const String artworkSearch = '/artworks/search';
  static const String myArtworks = '/artworks/mine';

  static String artworkById(String artworkId) => '$artworks$artworkId';

  // ---------------------------------------------------------------------------
  // Feedback (/api/v1/feedback/…)
  // ---------------------------------------------------------------------------

  static const String feedback = '/feedback/';

  // ---------------------------------------------------------------------------
  // Reports (/api/v1/reports/…)
  // ---------------------------------------------------------------------------

  static const String reports = '/reports/';

  // ---------------------------------------------------------------------------
  // Favorites (/api/v1/favorites/…)
  // ---------------------------------------------------------------------------

  static const String favorites = '/favorites/';
  static const String favoriteCheck = '/favorites/check';

  static String favoriteByArtworkId(String artworkId) =>
      '$favorites$artworkId';

  // ---------------------------------------------------------------------------
  // Verification requests (mounted on /api/v1)
  // ---------------------------------------------------------------------------

  static const String verificationRequests = '/verification-requests';
  static const String adminVerificationRequests = '/verification-requests';

  static String verificationRequestStatus(String requestId) =>
      '/verification-requests/$requestId/status';

  // ---------------------------------------------------------------------------
  // Payments (/api/v1/payments/…)
  // ---------------------------------------------------------------------------

  static String paymentsInitiate(String orderId) =>
      '/payments/orders/$orderId/initiate';

  static String paymentsVerify(String orderId) =>
      '/payments/orders/$orderId/verify';

  static String paymentsGet(String orderId) => '/payments/orders/$orderId';
}
