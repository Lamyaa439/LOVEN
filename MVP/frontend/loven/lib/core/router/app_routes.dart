// Constants-only registry of application route paths and guard classification.
//
// **Ownership (frozen contract):**
// - Path constants for [AppRouter], features, and [redirect_policy]
// - [isUnauthenticatedAuthEntryPath] — login/sign-up entry (signed-in users leave)
// - [requiresAuthenticatedSession] — LOVEN JWT session required
//
// This file must not import widgets, build routes, or emit redirects.
// [splash] is the canonical boot route; [splashLegacy] is a deep-link alias.
abstract final class AppRoutes {
  AppRoutes._();

  // ---------------------------------------------------------------------------
  // Startup
  // ---------------------------------------------------------------------------

  static const String splash = '/splash';

  /// Legacy boot path — kept for deep links; router redirects to [splash].
  static const String splashLegacy = '/splash_screen';

  static const String home = '/';

  // ---------------------------------------------------------------------------
  // Onboarding
  // ---------------------------------------------------------------------------

  static const String onboarding = '/onboarding';

  // ---------------------------------------------------------------------------
  // Auth — credentials, recovery, password change
  // ---------------------------------------------------------------------------

  static const String auth = '/auth';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String signupVerifyEmail = '/signup/verify-email';
  static const String signupSuccess = '/signup/success';

  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordSuccess = '/forgot-password/success';

  /// Authenticated password change (session required).
  static const String changePassword = '/change-password';

  // ---------------------------------------------------------------------------
  // Account — hub, settings, notifications
  // ---------------------------------------------------------------------------

  /// Account hub — guest and signed-in ([AccountScreen]); not session-gated.
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
/// Legacy settings path — redirects to [profile] (single account hub).
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String verificationRequest = '/verification-request';

  // ---------------------------------------------------------------------------
  // Admin
  // ---------------------------------------------------------------------------

  static const String admin = '/admin';
  static const String adminVerificationRequests =
      '/admin/verification-requests';
  static const String adminReports = '/admin/reports';

  // ---------------------------------------------------------------------------
  // Discovery — public browsing (guests allowed)
  // ---------------------------------------------------------------------------

  static const String artists = '/artists';
  static const String artistById = '/artist/:artistId';
  static const String artworksListByType = '/artworks-list/:type';

  /// Signed-in artist storefront (not the account hub at [profile]).
  static const String myProfile = '/my-profile';
  static const String artistProfileEdit = '/artist-profile/edit';

  // ---------------------------------------------------------------------------
  // Commerce & fulfillment — session required
  // ---------------------------------------------------------------------------

  static const String cart = '/cart';
  static const String confirmOrder = '/confirm-order';

  static const String ordersPrefix = '/orders/';
  static const String ordersDetails = '/orders/details';
  static const String ordersIncoming = '/orders/incoming';
  static const String ordersHistory = '/orders/history';

  static const String artworksCreate = '/artworks/create';
  static const String feedback = '/feedback';
  static const String location = '/location';
  static const String locationAddressForm = '/location/address-form';

  // ---------------------------------------------------------------------------
  // Path builders (parameterized navigation — same values as route table)
  // ---------------------------------------------------------------------------

  static String artistPath(String artistId) => '/artist/$artistId';

  static String artworksListPath(String type) => '/artworks-list/$type';

  /// Sign-up with guest funnel query (matches [signup] route builder).
  static String signupFromGuest({bool fromGuest = true}) =>
      fromGuest ? '$signup?fromGuest=true' : signup;

  // ---------------------------------------------------------------------------
  // Route guard registry
  // ---------------------------------------------------------------------------
  // Single source of truth for [redirect_policy]. Add new paths here first.

  /// Login / sign-up entry screens — signed-in users are redirected away.
  static const Set<String> unauthenticatedAuthEntryPaths = {
    auth,
    login,
    signup,
  };

  /// Nested sign-up steps ([signupVerifyEmail], [signupSuccess], …).
  static const String signupRoutePrefix = '/signup/';

  /// Password recovery — public; no session required (not auth-entry redirects).
  static const Set<String> passwordRecoveryExactPaths = {
    forgotPassword,
    forgotPasswordSuccess,
  };

  /// Account hub reachable without a LOVEN JWT ([AuthGuest] profile UI).
  static const Set<String> guestAccessibleExactPaths = {
    profile,
    settings,
  };

  /// Exact paths that require [authStateHasSession].
  static const Set<String> sessionRequiredExactPaths = {
    // Account (signed-in only)
    profileEdit,
    notifications,
    verificationRequest,
    changePassword,
    // Artist storefront & catalog management
    myProfile,
    artistProfileEdit,
    artworksCreate,
    // Commerce & fulfillment
    confirmOrder,
    location,
    locationAddressForm,
    feedback,
    // Order detail/history (prefix covers other `/orders/*` routes)
    ordersDetails,
    ordersIncoming,
    ordersHistory,
  };

  /// Path prefixes that require [authStateHasSession].
  static const List<String> sessionRequiredPrefixes = [
    cart,
    admin,
    ordersPrefix,
  ];

  /// True when [path] is login/sign-up entry (including [signupRoutePrefix]).
  static bool isUnauthenticatedAuthEntryPath(String path) {
    if (unauthenticatedAuthEntryPaths.contains(path)) {
      return true;
    }
    return path.startsWith(signupRoutePrefix);
  }

  /// True when [path] is part of the forgot-password flow (always public).
  static bool isPasswordRecoveryPath(String path) {
    if (passwordRecoveryExactPaths.contains(path)) {
      return true;
    }
    return path.startsWith('$forgotPassword/');
  }

  /// True when [path] is the guest account hub ([profile] only today).
  static bool isGuestAccessiblePath(String path) {
    return guestAccessibleExactPaths.contains(path);
  }

  /// True when [path] requires [authStateHasSession].
  ///
  /// Public: [home], [onboarding], [artists], [artistById], [artworksListByType],
  /// [profile] (guest hub), and [isPasswordRecoveryPath] routes.
  /// Admin routes require session via [admin] prefix (role checks are separate).
  static bool requiresAuthenticatedSession(String path) {
    if (isGuestAccessiblePath(path) || isPasswordRecoveryPath(path)) {
      return false;
    }
    if (sessionRequiredExactPaths.contains(path)) {
      return true;
    }
    for (final prefix in sessionRequiredPrefixes) {
      if (path.startsWith(prefix)) {
        return true;
      }
    }
    return false;
  }
}
