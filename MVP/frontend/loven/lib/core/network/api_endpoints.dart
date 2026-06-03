/// Centralized API path constants used by repositories and [ApiClient].
///
/// Paths are relative to the API root from [AppEnv.resolveBaseUrl]
/// (e.g. `http://host/api/v1` + `/carts/` → `…/api/v1/carts/`).
abstract final class ApiEndpoints {
  ApiEndpoints._();

  // Authentication (root-mounted on /api/v1)
  static const String register = '/register';
  static const String login = '/login';
  static const String refresh = '/refresh';
  static const String logout = '/logout';
  static const String changePassword = '/change-password';
  static const String currentUser = '/account/me';

  // Artist profiles (root-mounted: /api/v1/artist-profiles/…)
  static const String createArtistProfile = '/artist-profiles';
  static const String myArtistProfile = '/artist-profiles/me';
  static const String artistProfiles = '/artist-profiles';
  static const String artistProfileByName = '/artist-profiles/by-name';

  static String artistProfileArtworks(String profileId) =>
      '$artistProfiles/$profileId/artworks';

  static String artistProfileById(String profileId) =>
      '$artistProfiles/$profileId';

  // Cart (feature prefix: /api/v1/carts/…)
  static const String cart = '/carts/';
  static const String cartItems = '/carts/items';

  static String cartItemById(String itemId) => '$cartItems/$itemId';

  // Orders (feature prefix: /api/v1/orders/…)
  static const String orders = '/orders/';
  static const String myOrders = '/orders/mine';

  static String ordersByBuyer(String buyerId) => '${orders}buyer/$buyerId';

  static String ordersByArtist(String artistProfileId) =>
      '${orders}artist/$artistProfileId';

  static String orderStatus(String orderId) => '$orders$orderId/status';

  // Artworks (feature prefix: /api/v1/artworks/…)
  static const String artworks = '/artworks/';
  static const String artworkSearch = '/artworks/search';
  static const String myArtworks = '/artworks/mine';

  static String artworkById(String artworkId) => '$artworks$artworkId';

  // Feedback (feature prefix: /api/v1/feedback/…)
  static const String feedback = '/feedback/';

  // Reports (feature prefix: /api/v1/reports/…)
  static const String reports = '/reports/';

  // Favorites (feature prefix: /api/v1/favorites/…)
  static const String favorites = '/favorites/';
  static const String favoriteCheck = '/favorites/check';

  static String favoriteByArtworkId(String artworkId) =>
      '$favorites$artworkId';

  // Verification requests (root-mounted on /api/v1)
  static const String verificationRequests = '/verification-requests';
  static const String adminVerificationRequests = '/verification-requests';

  static String verificationRequestStatus(String requestId) =>
      '/verification-requests/$requestId/status';

  // Payments (feature prefix: /api/v1/payments/…)
  static String paymentsInitiate(String orderId) =>
      '/payments/orders/$orderId/initiate';

  static String paymentsVerify(String orderId) =>
      '/payments/orders/$orderId/verify';

  static String paymentsGet(String orderId) => '/payments/orders/$orderId';
}
