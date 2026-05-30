import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';

import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/auth/view/screens/edit_profile_screen.dart';
import 'package:loven/features/auth/view/screens/login_page.dart';
import 'package:loven/features/auth/view/screens/new_password_page.dart';
import 'package:loven/features/auth/view/screens/password_changed_page.dart';
import 'package:loven/features/auth/view/screens/profile_screen.dart';
import 'package:loven/features/auth/view/screens/signup_page.dart';
import 'package:loven/features/auth/view/screens/signup_success_page.dart';
import 'package:loven/features/auth/view/screens/signup_verification_email_page.dart';
import 'package:loven/features/auth/view/screens/verification_code_page.dart';
import 'package:loven/features/notifications/view/screens/notifications_screen.dart';
import 'package:loven/features/order/controller/cubit/order_cubit.dart';
import 'package:loven/features/order/data/repositories/order_repository.dart';
import 'package:loven/features/order/view/screens/incoming_orders_screen.dart';
import 'package:loven/features/order/view/screens/order_details_screen.dart';

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
import 'package:loven/features/auth/view/screens/forgot_password_page.dart';
import 'package:loven/features/cart/view/screens/confirm_order_screen.dart';
import 'package:loven/features/location/view/screens/location_screen.dart';
import 'package:loven/features/location/view/screens/address_form_screen.dart';
import 'package:loven/features/order/view/screens/order_history_screen.dart';
import 'package:loven/features/auth/view/screens/change_password_screen.dart';
import 'package:loven/features/feedback/controller/cubit/feedback_cubit.dart';
import 'package:loven/features/feedback/data/repositories/feedback_repository.dart';
import 'package:loven/features/feedback/view/screens/feedback_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
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

      final isProtectedPath = path.startsWith('/cart') ||
          path.startsWith('/my-profile') ||
          path.startsWith('/artist') ||
          path.startsWith('/artworks/create') ||
          path.startsWith('/admin') ||
          path.startsWith('/verification-request') ||
          path.startsWith('/settings');

      if (isGuest && isProtectedPath) {
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

          return NavigationScreen(
            isGuest: isGuest,
          );
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
          final order = Map<String, dynamic>.from(
            state.extra as Map,
          );
          
          return OrderDetailsScreen(order: order);
        },
      ),

      GoRoute(
        path: '/orders/incoming',
        builder: (context, state) {
          final artistProfileId = state.extra as String;
          
          return BlocProvider(
            create: (_) => OrderCubit(
              OrderRepository(
                apiClient: apiClient,
                tokenStorage: tokenStorage,
              ),
            ),
            child: IncomingOrdersScreen(
              artistProfileId: artistProfileId,
            ),
          );
        },
      ),

      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      GoRoute(
        path: '/auth',
        builder: (context, state) => const SignupPage(),
      ),

      GoRoute(
        path: '/orders/history',
        builder: (context, state) => BlocProvider(
          create: (_) => OrderCubit(
            OrderRepository(
              apiClient: apiClient,
              tokenStorage: tokenStorage,
            ),
          ),
          child: const OrderHistoryScreen(),
        ),
      ),

      GoRoute(
        path: '/forgot-password',
        builder: (context, state) =>
        const ForgotPasswordPage(),
      ),

      GoRoute(
        path: '/change-password',
        builder: (context, state) =>
        const ChangePasswordScreen(),
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(
          fromGuest: true,
        ),
      ),

      GoRoute(
        path: '/my-profile',
        builder: (context, state) => BlocProvider(
          create: (context) => ArtistProfileCubit(
            repository: artistRepository,
          ),
          child: ArtistProfileScreen(repository: artistRepository),
          ),
          child: const ArtistProfileScreen(),
        ),
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
            create: (context) => ArtistProfileCubit(
              repository: artistRepository,
            ),
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

          return ArtworksListScreen(
            type: type,
          );
        },
      ),

      GoRoute(
        path: '/feedback',
        builder: (context, state) => BlocProvider(
          create: (_) => FeedbackCubit(
            FeedbackRepository(
              apiClient: apiClient,
              tokenStorage: tokenStorage,
            ),
          ),
          child: const FeedbackScreen(),
        ),
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
        path: '/admin/verification-requests',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => VerificationRequestCubit(
              _verificationRequestRepository,
            )..fetchAllRequests(),
            child: const AdminVerificationRequestsScreen(),
          );
        },
      ),

      GoRoute(
        path: '/settings',
        builder: (context, state) => BlocProvider(
          create: (_) => ArtistProfileCubit(
            repository: _artistRepository,
            )..fetchMyProfileData(),
            child: const SettingsScreen(),
          ),
        ),

      GoRoute(
        path: '/profile/edit',
        builder: (context, state) =>
        const EditProfileScreen(),
      ),

      GoRoute(
        path: '/admin/reports',
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('Admin Reports'),
          ),
          body: const Center(
            child: Text('Admin Reports'),
          ),
        ),
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

      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      
      GoRoute(
        path: '/forgot-password/code',
        builder: (context, state) {
          final extra = state.extra;
          try {
            final artItem = extra is ArtworkModel
              ? extra
              : ArtworkModel.fromJson(extra as Map<String, dynamic>);
            return ArtDetailsScreen(
              artItem: artItem,
              artistRepository: artistRepository,
            );
          } catch (e) {
            return const Scaffold(
              body: Center(child: Text('Failed to load artwork details')));
          }
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
      path: '/profile/edit',
      builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );
}