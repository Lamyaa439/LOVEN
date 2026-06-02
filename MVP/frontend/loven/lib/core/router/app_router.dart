import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/router/splash_min_duration_notifier.dart';
import 'package:loven/core/storage/app_preferences.dart';

import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/auth/view/screens/change_password_screen.dart';
import 'package:loven/features/auth/view/screens/edit_profile_screen.dart';
import 'package:loven/features/auth/view/screens/forgot_password_page.dart';
import 'package:loven/features/auth/view/screens/login_page.dart';
import 'package:loven/features/auth/view/screens/new_password_page.dart';
import 'package:loven/features/auth/view/screens/password_changed_page.dart';
import 'package:loven/features/auth/view/screens/profile_screen.dart';
import 'package:loven/features/auth/view/screens/signup_page.dart';
import 'package:loven/features/auth/view/screens/signup_success_page.dart';
import 'package:loven/features/auth/view/screens/signup_verification_email_page.dart';
import 'package:loven/features/auth/view/screens/verification_code_page.dart';
import 'package:loven/features/notifications/view/screens/notifications_screen.dart';
import 'package:loven/features/order/view/screens/incoming_orders_screen.dart';
import 'package:loven/features/order/view/screens/order_details_screen.dart';
import 'package:loven/features/order/view/screens/order_history_screen.dart';

import 'package:loven/features/verification_request/controller/cubit/verification_request_cubit.dart';
import 'package:loven/features/verification_request/data/repositories/verification_request_repository.dart';
import 'package:loven/features/verification_request/view/screens/verification_request_screen.dart';

import 'package:loven/features/artist_profile/controller/artist_profile_cubit.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/artist_profile/data/artist_repository.dart';
import 'package:loven/features/artist_profile/view/screens/artist_profile_screen.dart';
import 'package:loven/features/artist_profile/view/screens/edit_artist_profile_screen.dart';

import 'package:loven/features/artwork/view/screens/create_artwork_screen.dart';
import 'package:loven/features/navigation/view/Screens/navigation_screen.dart';
import 'package:loven/features/splash/splash_screen.dart';
import 'package:loven/features/admin/view/screens/admin_dashboard_screen.dart';
import 'package:loven/features/admin/view/screens/admin_reports_screen.dart';
import 'package:loven/features/admin/view/screens/admin_verification_requests_screen.dart';
import 'package:loven/features/splash/onboarding_screen.dart';
import 'package:loven/features/home/View/Screens/artists_list_screen.dart';
import 'package:loven/features/home/View/Screens/artworks_list_screen.dart';
import 'package:loven/features/home/View/Screens/settings_screen.dart';
import 'package:loven/features/cart/view/screens/confirm_order_screen.dart';
import 'package:loven/features/location/view/screens/location_screen.dart';
import 'package:loven/features/location/view/screens/address_form_screen.dart';
import 'package:loven/features/feedback/view/screens/feedback_screen.dart';

/// Application router configuration for the Loven app.
///
/// Defines routes via `go_router`, wires feature dependencies, and owns
/// startup redirect policy (splash → home / onboarding / guest home) using
/// [AuthCubit] session state and [AppPreferences.hasCompletedOnboarding].


Widget _invalidRouteExtraFallback({
  required String title,
  required String message,
}) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text(message)),
  );
}

/// Validates a required non-empty [String] passed via [GoRouterState.extra].
Widget _routeWithRequiredStringExtra({
  required GoRouterState state,
  required String title,
  required String missingMessage,
  required Widget Function(String value) builder,
}) {
  final raw = state.extra;
  if (raw is! String || raw.trim().isEmpty) {
    return _invalidRouteExtraFallback(
      title: title,
      message: missingMessage,
    );
  }
  return builder(raw.trim());
}

bool _isBootstrapping(AuthState state) =>
    state is AuthInitial || state is AuthLoading;

bool _isUnauthenticated(AuthState state) =>
    state is AuthGuest || state is AuthFailure;

/// Entry screens meant for guests only; authenticated users are sent home.
bool _isGuestAuthEntryPath(String path) {
  const guestAuthEntry = {
    AppRoutes.login,
    AppRoutes.auth,
  };
  return guestAuthEntry.contains(path);
}

/// Post-bootstrap destination from splash (auth + onboarding policy).
String _resolvePostBootstrapLocation({
  required AuthState authState,
  required AppPreferences appPreferences,
}) {
  if (authState is AuthSuccess) {
    return AppRoutes.home;
  }
  if (!appPreferences.hasCompletedOnboarding) {
    return AppRoutes.onboarding;
  }
  // Returning guest: home uses [AuthGuest] for guest mode (no extra required).
  return AppRoutes.home;
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Returns true when [path] requires an authenticated (non-guest) session.
///
/// Public artist browsing (`/artists`, `/artist/:id`) is intentionally excluded.
bool _requiresAuthenticatedSession(String path) {
  const protectedExact = {
    AppRoutes.myProfile,
    AppRoutes.settings,
    AppRoutes.verificationRequest,
    AppRoutes.artworksCreate,
    AppRoutes.changePassword,
    AppRoutes.confirmOrder,
    AppRoutes.profileEdit,
    AppRoutes.artistProfileEdit,
    AppRoutes.feedback,
  };

  if (protectedExact.contains(path)) {
    return true;
  }

  const protectedPrefixes = [
    AppRoutes.cart,
    AppRoutes.admin,
    AppRoutes.ordersPrefix,
  ];

  for (final prefix in protectedPrefixes) {
    if (path.startsWith(prefix)) {
      return true;
    }
  }

  return false;
}

class AppRouter {
  final AuthCubit authCubit;
  final AppPreferences appPreferences;
  final SplashMinDurationNotifier splashMinDurationNotifier;

  /// Shared profile repository — injected from [LovenApp] startup.
  final ArtistRepository artistRepository;

  /// Verification submissions — injected from [LovenApp] startup.
  final VerificationRequestRepository verificationRequestRepository;

  AppRouter(
    this.authCubit, {
    required this.appPreferences,
    required this.splashMinDurationNotifier,
    required this.artistRepository,
    required this.verificationRequestRepository,
  });

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: Listenable.merge([
      GoRouterRefreshStream(authCubit.stream),
      splashMinDurationNotifier,
    ]),
    redirect: (context, state) {
      final authState = authCubit.state;
      final path = state.matchedLocation;

      // Legacy deep links → canonical splash route.
      if (path == AppRoutes.splashLegacy) {
        return AppRoutes.splash;
      }

      // Startup funnel: one-way exit from splash (never home/onboarding → splash).
      if (path == AppRoutes.splash) {
        if (_isBootstrapping(authState) ||
            !splashMinDurationNotifier.isReady) {
          return null;
        }
        final destination = _resolvePostBootstrapLocation(
          authState: authState,
          appPreferences: appPreferences,
        );
        // Destination is always home or onboarding — avoids a splash redirect loop.
        return destination;
      }

      // Session restore in progress — send protected deep links to splash only.
      if (_isBootstrapping(authState)) {
        if (_requiresAuthenticatedSession(path) &&
            path != AppRoutes.splash) {
          return AppRoutes.splash;
        }
        return null;
      }

      if (_isUnauthenticated(authState) &&
          _requiresAuthenticatedSession(path)) {
        return AppRoutes.auth;
      }

      // Onboarding only for first-time users without a session.
      if (_isUnauthenticated(authState) &&
          appPreferences.hasCompletedOnboarding &&
          path == AppRoutes.onboarding) {
        return AppRoutes.home;
      }

      if (authState is AuthSuccess && path == AppRoutes.onboarding) {
        return AppRoutes.home;
      }

      // Logged-in users should not re-enter guest login/signup entry screens.
      if (authState is AuthSuccess && _isGuestAuthEntryPath(path)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      // Transitional deep-link alias only — not a startup owner; global redirect applies.
      GoRoute(
        path: AppRoutes.splashLegacy,
        redirect: (context, state) => AppRoutes.splash,
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          // Guest home after onboarding: [AuthGuest] sets isGuest without extra.
          final isGuest =
              extra?['isGuest'] as bool? ?? authCubit.state is AuthGuest;

          return NavigationScreen(isGuest: isGuest);
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.ordersDetails,
        builder: (context, state) {
          final raw = state.extra;
          if (raw is! Map) {
            return _invalidRouteExtraFallback(
              title: 'Order Details',
              message: 'Unable to open order details.',
            );
          }
          final order = Map<String, dynamic>.from(raw);
          return OrderDetailsScreen(order: order);
        },
      ),
      GoRoute(
        path: AppRoutes.ordersIncoming,
        builder: (context, state) {
          final raw = state.extra;
          if (raw is! String || raw.isEmpty) {
            return _invalidRouteExtraFallback(
              title: 'Incoming Orders',
              message: 'Artist profile ID is missing.',
            );
          }
          final artistProfileId = raw;
          return IncomingOrdersScreen(artistProfileId: artistProfileId);
        },
      ),
      GoRoute(
        path: AppRoutes.ordersHistory,
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminVerificationRequests,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => VerificationRequestCubit(
              verificationRequestRepository,
            )..fetchAllRequests(),
            child: const AdminVerificationRequestsScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.adminReports,
        builder: (context, state) => const AdminReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(fromGuest: true),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordCode,
        builder: (context, state) {
          return _routeWithRequiredStringExtra(
            state: state,
            title: 'Verification Code',
            missingMessage: 'Email is required to verify your code.',
            builder: (email) => VerificationCodePage(email: email),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordNewPassword,
        builder: (context, state) => const NewPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordSuccess,
        builder: (context, state) => const PasswordChangedPage(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.myProfile,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => ArtistProfileCubit(
              repository: artistRepository,
            )..fetchMyProfileData(),
            child: ArtistProfileScreen(repository: artistRepository),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.artists,
        builder: (context, state) => const ArtistsListScreen(),
      ),
      GoRoute(
        path: AppRoutes.artistById,
        builder: (context, state) {
          final artistId = state.pathParameters['artistId']!;

          return BlocProvider(
            create: (_) => ArtistProfileCubit(
              repository: artistRepository,
            )..fetchPublicArtistProfile(artistId),
            child: ArtistProfileScreen(
              artistProfileId: artistId,
              repository: artistRepository,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.artworksListByType,
        builder: (context, state) {
          final type = state.pathParameters['type'] ?? 'featured';
          return ArtworksListScreen(type: type);
        },
      ),
      GoRoute(
        path: AppRoutes.feedback,
        builder: (context, state) => const FeedbackScreen(),
      ),
      GoRoute(
        path: AppRoutes.confirmOrder,
        builder: (context, state) => const ConfirmOrderScreen(),
      ),
      GoRoute(
        path: AppRoutes.location,
        builder: (context, state) => const LocationScreen(),
      ),
      GoRoute(
        path: AppRoutes.locationAddressForm,
        builder: (context, state) => const AddressFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => ArtistProfileCubit(
              repository: artistRepository,
            )..fetchMyProfileData(),
            child: const SettingsScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.profileEdit,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isGuest =
              extra?['isGuest'] as bool? ?? authCubit.state is AuthGuest;

          return NavigationScreen(
            isGuest: isGuest,
            initialIndex: 2,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.artworksCreate,
        builder: (context, state) => const CreateArtworkScreen(),
      ),
      GoRoute(
        path: AppRoutes.artistProfileEdit,
        builder: (context, state) {
          final raw = state.extra;
          if (raw is! ArtistModel) {
            return _invalidRouteExtraFallback(
              title: 'Edit Artist Profile',
              message: 'Artist data is missing.',
            );
          }
          final artist = raw;

          return BlocProvider(
            create: (_) => ArtistProfileCubit(
              repository: artistRepository,
            ),
            child: EditArtistProfileScreen(artist: artist),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) {
          final fromGuest =
              state.uri.queryParameters['fromGuest'] == 'true';
          return SignupPage(fromGuest: fromGuest);
        },
      ),
      GoRoute(
        path: AppRoutes.signupVerifyEmail,
        builder: (context, state) {
          return _routeWithRequiredStringExtra(
            state: state,
            title: 'Verify Email',
            missingMessage: 'Email is required to continue signup verification.',
            builder: (email) => SignupVerificationEmailPage(email: email),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.signupSuccess,
        builder: (context, state) => const SignupSuccessPage(),
      ),
      GoRoute(
        path: AppRoutes.verificationRequest,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => VerificationRequestCubit(
              verificationRequestRepository,
            ),
            child: const VerificationRequestScreen(),
          );
        },
      ),
    ],
  );
}
