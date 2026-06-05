// Frozen redirect policy for [AppRouter] — pure, side-effect free.
//
// **Single entry:** [resolveRedirect] — returns the next path or `null` to stay.
//
// **Stable dependencies only:**
// - [AuthState] + [authStateHasSession] / [authStateSessionUser]
// - [AppPreferences.hasCompletedOnboarding]
// - [SplashMinDurationNotifier.isReady]
// - [AppRoutes] guard registry (no path literals in this file)
//
// **Do not add** widgets, cubits, or route builders here.
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/router/splash_min_duration_notifier.dart';
import 'package:loven/core/storage/app_preferences.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';

/// Resolves the next route for [GoRouter.redirect] from session and app state.
///
/// [matchedLocation] is [GoRouterState.matchedLocation] (full path match).
/// Evaluation order matches the frozen matrix below (first non-null wins).
String? resolveRedirect({
  required AuthState authState,
  required AppPreferences appPreferences,
  required SplashMinDurationNotifier splashMinDuration,
  required String matchedLocation,
}) {
  final path = matchedLocation;

  return _redirectLegacySplashAlias(path) ??
      _redirectWhileOnSplash(
        path: path,
        authState: authState,
        appPreferences: appPreferences,
        splashMinDuration: splashMinDuration,
      ) ??
      _redirectWhileBootstrapping(path: path, authState: authState) ??
      _redirectGuestFromProtectedRoute(path: path, authState: authState) ??
      _redirectGuestPastOnboarding(
        path: path,
        authState: authState,
        appPreferences: appPreferences,
      ) ??
      _redirectAuthenticatedFromOnboarding(path: path, authState: authState) ??
      _redirectAuthenticatedFromAuthEntry(path: path, authState: authState);
}

// -----------------------------------------------------------------------------
// Rule helpers (evaluated in [resolveRedirect] order)
// -----------------------------------------------------------------------------

String? _redirectLegacySplashAlias(String path) {
  if (path == AppRoutes.splashLegacy) {
    return AppRoutes.splash;
  }
  return null;
}

String? _redirectWhileOnSplash({
  required String path,
  required AuthState authState,
  required AppPreferences appPreferences,
  required SplashMinDurationNotifier splashMinDuration,
}) {
  if (path != AppRoutes.splash) {
    return null;
  }
  if (_isBootstrapping(authState) || !splashMinDuration.isReady) {
    return null;
  }
  return _resolvePostBootstrapLocation(
    authState: authState,
    appPreferences: appPreferences,
  );
}

String? _redirectWhileBootstrapping({
  required String path,
  required AuthState authState,
}) {
  if (!_isBootstrapping(authState)) {
    return null;
  }
  if (AppRoutes.requiresAuthenticatedSession(path) && path != AppRoutes.splash) {
    return AppRoutes.splash;
  }
  return null;
}

String? _redirectGuestFromProtectedRoute({
  required String path,
  required AuthState authState,
}) {
  if (!_isGuestSession(authState)) {
    return null;
  }
  if (!AppRoutes.requiresAuthenticatedSession(path)) {
    return null;
  }
  return AppRoutes.auth;
}

String? _redirectGuestPastOnboarding({
  required String path,
  required AuthState authState,
  required AppPreferences appPreferences,
}) {
  if (!_isGuestSession(authState)) {
    return null;
  }
  if (!appPreferences.hasCompletedOnboarding || path != AppRoutes.onboarding) {
    return null;
  }
  return AppRoutes.home;
}

String? _redirectAuthenticatedFromOnboarding({
  required String path,
  required AuthState authState,
}) {
  if (!authStateHasSession(authState) || path != AppRoutes.onboarding) {
    return null;
  }
  return _resolveAuthenticatedLanding(authState);
}

String? _redirectAuthenticatedFromAuthEntry({
  required String path,
  required AuthState authState,
}) {
  if (!authStateHasSession(authState)) {
    return null;
  }
  if (!AppRoutes.isUnauthenticatedAuthEntryPath(path)) {
    return null;
  }
  return _resolveAuthenticatedLanding(authState);
}

// -----------------------------------------------------------------------------
// Session / landing helpers
// -----------------------------------------------------------------------------

bool _isBootstrapping(AuthState state) =>
    state is AuthInitial || state is AuthLoading;

/// Explicit guest browse mode — not [AuthFailure] or [AuthOperationFailure].
bool _isGuestSession(AuthState state) => state is AuthGuest;

String _resolveAuthenticatedLanding(AuthState authState) {
  final user = authStateSessionUser(authState);
  if (user != null && user.systemRole == 'admin') {
    return AppRoutes.admin;
  }
  return AppRoutes.home;
}

String _resolvePostBootstrapLocation({
  required AuthState authState,
  required AppPreferences appPreferences,
}) {
  if (authStateHasSession(authState)) {
    return _resolveAuthenticatedLanding(authState);
  }
  if (!appPreferences.hasCompletedOnboarding) {
    return AppRoutes.onboarding;
  }
  return AppRoutes.home;
}

// -----------------------------------------------------------------------------
// Frozen redirect matrix (first matching rule in [resolveRedirect] wins)
// -----------------------------------------------------------------------------
//
// | # | Condition                                              | Result              |
// |---|--------------------------------------------------------|---------------------|
// | 1 | path == splashLegacy                                   | splash              |
// | 2 | path == splash AND (bootstrapping OR !splash ready)    | null (stay)         |
// | 3 | path == splash AND ready                               | post-bootstrap (*)  |
// | 4 | bootstrapping AND session-required AND path != splash  | splash              |
// | 5 | bootstrapping AND other                                | null (stay)         |
// | 6 | AuthGuest AND session-required                         | auth                |
// | 7 | AuthGuest AND onboarding done AND path == onboarding   | home                |
// | 8 | has session AND path == onboarding                     | admin or home (†)   |
// | 9 | has session AND auth-entry path                        | admin or home (†)     |
// |10 | otherwise                                              | null (stay)         |
//
// (*) Post-bootstrap: session → (†); guest + !onboarding → onboarding;
//     guest + onboarding done → home.
// (†) Admin when [authStateSessionUser].systemRole == 'admin', else home.
//
// Not redirected here (registry decides): [AppRoutes.profile] (guest hub),
// public discovery, [AppRoutes.isPasswordRecoveryPath], [AuthFailure] screens.
