/// هذا الملف يحتوي على مسارات صفحات التطبيق بس 
/// نخزن هنا كل عناوين شاشات التطبيق في مكان واحد كثوابت عشان مانكتبها يدوياً
/// 
// Constants-only registry of application route paths.
//
// Used by [AppRouter], redirect policy, and feature navigation. This file must
// not import widgets, define redirects, or encode guard logic — paths only.
//
// [splash] is the canonical boot route; [splashLegacy] is a deep-link alias.

abstract final class AppRoutes {
  AppRoutes._();

  // ---------------------------------------------------------------------------
  // Startup
  // ---------------------------------------------------------------------------
  // Boot funnel, shell entry, and legacy aliases.

  static const String splash = '/splash';

  /// Legacy boot path — kept for deep links; router redirects to [splash].
  static const String splashLegacy = '/splash_screen';

  static const String home = '/';

  // ---------------------------------------------------------------------------
  // Onboarding
  // ---------------------------------------------------------------------------
  // // First-launch onboarding flow.

  static const String onboarding = '/onboarding';

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------
  // Sign-in, sign-up, password recovery, and authenticated password change.

  static const String auth = '/auth';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String signupVerifyEmail = '/signup/verify-email';
  static const String signupSuccess = '/signup/success';

  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordCode = '/forgot-password/code';
  static const String forgotPasswordNewPassword =
      '/forgot-password/new-password';
  static const String forgotPasswordSuccess = '/forgot-password/success';

  static const String changePassword = '/change-password';

  // ---------------------------------------------------------------------------
  // Account
  // ---------------------------------------------------------------------------
  // Authenticated user account hub, settings, and in-app notifications.

  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String verificationRequest = '/verification-request';

  // ---------------------------------------------------------------------------
  // Admin
  // ---------------------------------------------------------------------------
  // System administrator dashboards and moderation tools.

  static const String admin = '/admin';
  static const String adminVerificationRequests =
      '/admin/verification-requests';
  static const String adminReports = '/admin/reports';

  // ---------------------------------------------------------------------------
  // Discovery
  // ---------------------------------------------------------------------------
  // Public and signed-in browsing: artist listings, profiles, and artworks.

  static const String artists = '/artists';
  static const String artistById = '/artist/:artistId';
  static const String artworksListByType = '/artworks-list/:type';

  /// Signed-in artist's own storefront profile (not the account hub at [profile]).
  static const String myProfile = '/my-profile';
  static const String artistProfileEdit = '/artist-profile/edit';

  // ---------------------------------------------------------------------------
  // Protected
  // ---------------------------------------------------------------------------
  // Routes that require an authenticated session (see router guard policy).

  static const String cart = '/cart';
  static const String confirmOrder = '/confirm-order';

  /// Prefix for all order sub-routes (used by session guards).
  static const String ordersPrefix = '/orders/';
  static const String ordersDetails = '/orders/details';
  static const String ordersIncoming = '/orders/incoming';
  static const String ordersHistory = '/orders/history';

  static const String artworksCreate = '/artworks/create';
  static const String feedback = '/feedback';
  static const String location = '/location';
  static const String locationAddressForm = '/location/address-form';
}
