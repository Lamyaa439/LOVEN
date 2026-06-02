import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/router/app_routes.dart';

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
/// This file defines all app navigation routes using `go_router`,
/// applies auth-based redirection, and wires route-level dependencies
/// such as feature cubits and repositories.
///
/// Notes:
/// - Route paths are centralized in `AppRoutes`.
/// - Protected routes are guarded for guest users.
/// - Selected routes validate `state.extra` and fall back safely
///   instead of crashing on invalid navigation arguments.


Widget _invalidRouteExtraFallback({
  required String title,
  required String message,
}) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text(message)),
  );
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
    '/orders/',
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

  /// Shared profile repository — injected from [LovenApp] startup.
  final ArtistRepository artistRepository;

  /// Verification submissions — injected from [LovenApp] startup.
  final VerificationRequestRepository verificationRequestRepository;

  AppRouter(
    this.authCubit, {
    required this.artistRepository,
    required this.verificationRequestRepository,
  });

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splashLegacy,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final authState = authCubit.state;
      final isGuest = authState is AuthGuest;
      final path = state.matchedLocation;

      if (isGuest && _requiresAuthenticatedSession(path)) {
        return AppRoutes.auth;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splashLegacy,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
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
          final email = state.extra as String? ?? '';
          return VerificationCodePage(email: email);
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
          final email = state.extra as String? ?? '';
          return SignupVerificationEmailPage(email: email);
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
