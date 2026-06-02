/// Centralized route path constants used by [AppRouter].
///
/// Keep this file as the single source of truth for all route strings.
class AppRoutes {
  AppRoutes._();

  // Core app entry
  static const String splash = '/splash';
  static const String splashLegacy = '/splash_screen';
  static const String onboarding = '/onboarding';
  static const String home = '/';

  // Auth
  static const String auth = '/auth';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String signupVerifyEmail = '/signup/verify-email';
  static const String signupSuccess = '/signup/success';
  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordCode = '/forgot-password/code';
  static const String forgotPasswordNewPassword = '/forgot-password/new-password';
  static const String forgotPasswordSuccess = '/forgot-password/success';
  static const String changePassword = '/change-password';

  // Account / profile
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String myProfile = '/my-profile';
  static const String artistProfileEdit = '/artist-profile/edit';
  static const String verificationRequest = '/verification-request';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  // Orders / commerce
  static const String cart = '/cart';
  static const String confirmOrder = '/confirm-order';
  static const String ordersDetails = '/orders/details';
  static const String ordersIncoming = '/orders/incoming';
  static const String ordersHistory = '/orders/history';

  // Admin
  static const String admin = '/admin';
  static const String adminVerificationRequests = '/admin/verification-requests';
  static const String adminReports = '/admin/reports';

  // Discovery / artists / artworks
  static const String artists = '/artists';
  static const String artistById = '/artist/:artistId';
  static const String artworksListByType = '/artworks-list/:type';
  static const String artworksCreate = '/artworks/create';

  // Feedback / location
  static const String feedback = '/feedback';
  static const String location = '/location';
  static const String locationAddressForm = '/location/address-form';
}
