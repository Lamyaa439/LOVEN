// Pure redirect policy for [AppRouter] — no widgets, no side effects.
//
// Returns the path to navigate to, or `null` to stay on the current location.
// Route classification is delegated to [AppRoutes]; session rules use
// [authStateHasSession]. See the contract matrix at the bottom of this file.
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/router/splash_min_duration_notifier.dart';
import 'package:loven/core/storage/app_preferences.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';

/// Resolves the next route for [GoRouter.redirect] from session and app state.
///
/// [matchedLocation] is [GoRouterState.matchedLocation] (full path match).
String? resolveRedirect({
  required AuthState authState,
  required AppPreferences appPreferences,
  required SplashMinDurationNotifier splashMinDuration,
  required String matchedLocation,
}) {
  final path = matchedLocation;

  if (path == AppRoutes.splashLegacy) {
    return AppRoutes.splash;
  }

  if (path == AppRoutes.splash) {
    if (_isBootstrapping(authState) || !splashMinDuration.isReady) {
      return null;
    }
    return _resolvePostBootstrapLocation(
      authState: authState,
      appPreferences: appPreferences,
    );
  }

  if (_isBootstrapping(authState)) {
    if (AppRoutes.requiresAuthenticatedSession(path) &&
        path != AppRoutes.splash) {
      return AppRoutes.splash;
    }
    return null;
  }

  if (_isGuestSession(authState) &&
      AppRoutes.requiresAuthenticatedSession(path)) {
    return AppRoutes.auth;
  }

  if (_isGuestSession(authState) &&
      appPreferences.hasCompletedOnboarding &&
      path == AppRoutes.onboarding) {
    return AppRoutes.home;
  }

  if (authStateHasSession(authState) && path == AppRoutes.onboarding) {
    return _resolveAuthenticatedLanding(authState);
  }

  if (authStateHasSession(authState) &&
      AppRoutes.isUnauthenticatedAuthEntryPath(path)) {
    return _resolveAuthenticatedLanding(authState);
  }

  return null;
}

bool _isBootstrapping(AuthState state) =>
    state is AuthInitial || state is AuthLoading;

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
// Redirect contract matrix (evaluated in order; first match wins)
// -----------------------------------------------------------------------------
//
// | Location / condition                                      | Redirect target        |
// |-----------------------------------------------------------|------------------------|
// | Any: path == splashLegacy                                 | splash                 |
// | On splash: bootstrapping OR splash min duration !ready    | null (stay)            |
// | On splash: ready + has session                            | admin or home (role)   |
// | On splash: ready + guest + !onboarding completed          | onboarding             |
// | On splash: ready + guest + onboarding completed           | home (guest browse)    |
// | Bootstrapping + session-required path (not splash)        | splash                 |
// | Bootstrapping + other paths                               | null (stay)            |
// | AuthGuest + session-required path                         | auth                   |
// | AuthGuest + onboarding + onboarding done                  | home                   |
// | Has session + onboarding                                  | admin or home (role)   |
// | Has session + auth entry ([AppRoutes.isUnauthenticatedAuthEntryPath]) | admin or home |
// | All other cases                                           | null (stay)            |
//
// Session-required paths: [AppRoutes.requiresAuthenticatedSession] (registry).
// Guest-accessible account hub: [AppRoutes.profile] only ([isGuestAccessiblePath]).
// Public recovery: [AppRoutes.isPasswordRecoveryPath] (not session-gated).
// Auth entry: [AppRoutes.isUnauthenticatedAuthEntryPath] (includes /signup/*).
