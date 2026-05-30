import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
import 'package:loven/features/artist_profile/model/artist_repository.dart';
import 'package:loven/features/artist_profile/view/screens/artist_profile_screen.dart';
import 'package:loven/features/artist_profile/view/screens/edit_artist_profile_screen.dart';

import 'package:loven/features/artwork/view/screens/create_artwork_screen.dart';
import 'package:loven/features/navigation/view/screens/navigation_screen.dart';
import 'package:loven/features/splash/splash_screen.dart';
import 'package:loven/features/admin/view/screens/admin_dashboard_screen.dart';
import 'package:loven/features/admin/view/screens/admin_verification_requests_screen.dart';
import 'package:loven/features/splash/onboarding_screen.dart';
import 'package:loven/features/home/View/Screens/artists_list_screen.dart';
import 'package:loven/features/home/View/Screens/artworks_list_screen.dart';
import 'package:loven/features/home/View/Screens/settings_screen.dart';
import 'package:loven/features/cart/view/screens/confirm_order_screen.dart';
import 'package:loven/features/location/view/screens/location_screen.dart';
import 'package:loven/features/location/view/screens/address_form_screen.dart';
import 'package:loven/features/feedback/view/screens/feedback_screen.dart';

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
    '/my-profile',
    '/settings',
    '/verification-request',
    '/artworks/create',
    '/change-password',
    '/confirm-order',
    '/profile/edit',
    '/artist-profile/edit',
    '/feedback',
  };

  if (protectedExact.contains(path)) {
    return true;
  }

  const protectedPrefixes = [
    '/cart',
    '/admin',
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
    initialLocation: '/splash_screen',
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final authState = authCubit.state;
      final isGuest = authState is AuthGuest;
      final path = state.matchedLocation;

      if (isGuest && _requiresAuthenticatedSession(path)) {
        return '/auth';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash_screen',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isGuest =
              extra?['isGuest'] as bool? ?? authCubit.state is AuthGuest;

          return NavigationScreen(isGuest: isGuest);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/orders/details',
        builder: (context, state) {
          final order = Map<String, dynamic>.from(state.extra as Map);
          return OrderDetailsScreen(order: order);
        },
      ),
      GoRoute(
        path: '/orders/incoming',
        builder: (context, state) {
          final artistProfileId = state.extra as String;
          return IncomingOrdersScreen(artistProfileId: artistProfileId);
        },
      ),
      GoRoute(
        path: '/orders/history',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/verification-requests',
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
        path: '/admin/reports',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Admin Reports')),
          body: const Center(child: Text('Admin Reports')),
        ),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(fromGuest: true),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/forgot-password/code',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return VerificationCodePage(email: email);
        },
      ),
      GoRoute(
        path: '/forgot-password/new-password',
        builder: (context, state) => const NewPasswordPage(),
      ),
      GoRoute(
        path: '/forgot-password/success',
        builder: (context, state) => const PasswordChangedPage(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/my-profile',
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
        path: '/artists',
        builder: (context, state) => const ArtistsListScreen(),
      ),
      GoRoute(
        path: '/artist/:artistId',
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
        path: '/artworks-list/:type',
        builder: (context, state) {
          final type = state.pathParameters['type'] ?? 'featured';
          return ArtworksListScreen(type: type);
        },
      ),
      GoRoute(
        path: '/feedback',
        builder: (context, state) => const FeedbackScreen(),
      ),
      GoRoute(
        path: '/confirm-order',
        builder: (context, state) => const ConfirmOrderScreen(),
      ),
      GoRoute(
        path: '/location',
        builder: (context, state) => const LocationScreen(),
      ),
      GoRoute(
        path: '/location/address-form',
        builder: (context, state) => const AddressFormScreen(),
      ),
      GoRoute(
        path: '/settings',
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
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/cart',
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
        path: '/artworks/create',
        builder: (context, state) => const CreateArtworkScreen(),
      ),
      GoRoute(
        path: '/artist-profile/edit',
        builder: (context, state) {
          final artist = state.extra as ArtistModel;

          return BlocProvider(
            create: (_) => ArtistProfileCubit(
              repository: artistRepository,
            ),
            child: EditArtistProfileScreen(artist: artist),
          );
        },
      ),
      GoRoute(
        path: '/signup/verify-email',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return SignupVerificationEmailPage(email: email);
        },
      ),
      GoRoute(
        path: '/signup/success',
        builder: (context, state) => const SignupSuccessPage(),
      ),
      GoRoute(
        path: '/verification-request',
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
