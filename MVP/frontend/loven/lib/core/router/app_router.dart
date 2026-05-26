import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/auth/view/screens/login_page.dart';
import 'package:loven/features/auth/view/screens/profile_screen.dart';
import 'package:loven/features/auth/view/screens/signup_page.dart';
import 'package:loven/features/verification_request/controller/cubit/verification_request_cubit.dart';
import 'package:loven/features/verification_request/data/repositories/verification_request_repository.dart';
import 'package:loven/features/artist_profile/controller/artist_profile_cubit.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/artist_profile/model/artist_repository.dart';
import 'package:loven/features/artist_profile/view/screens/artist_profile_screen.dart';
import 'package:loven/features/artist_profile/view/screens/edit_artist_profile_screen.dart';
import 'package:loven/features/verification_request/view/screens/verification_request_screen.dart';
import 'package:loven/features/artwork/view/screens/create_artwork_screen.dart';
import 'package:loven/features/navigation/view/screens/navigation_screen.dart';
import 'package:loven/features/splash/splash_screen.dart';
import 'package:loven/features/admin/view/screens/admin_dashboard_screen.dart';
import 'package:loven/features/admin/view/screens/admin_verification_requests_screen.dart';
import 'package:loven/features/splash/onboarding_screen.dart';
import 'package:loven/features/home/View/Screens/artists_list_screen.dart';
import 'package:loven/features/home/View/Screens/artworks_list_screen.dart';
import 'package:loven/features/home/View/Screens/settings_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  final AuthCubit authCubit;
  AppRouter(this.authCubit);
  
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
      path.startsWith('/art-details') ||
      path.startsWith('/artworks/create') ||
      path.startsWith('/admin') ||
      path.startsWith('/verification-request');
      
      if (isGuest && isProtectedPath) {
        return '/auth';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          final extra =
          state.extra as Map<String, dynamic>?;
          
          final isGuest =
          extra?['isGuest'] as bool? ??
          (authCubit.state is AuthGuest);
          
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
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
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
        path: '/splash_screen',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/my-profile',
        builder: (context, state) => BlocProvider(
          create: (context) => ArtistProfileCubit(repository: ArtistRepository()),
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
            create: (context) => ArtistProfileCubit(repository: ArtistRepository()),
            child: ArtistProfileScreen(artistProfileId: artistId),
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
        path: '/admin/verification-requests',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => VerificationRequestCubit(
              VerificationRequestRepository(),
              )..fetchAllRequests(),
              child: const AdminVerificationRequestsScreen(),
            );
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
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
          final extra =
          state.extra as Map<String, dynamic>?;
          
          final isGuest =
          extra?['isGuest'] as bool? ??
          (authCubit.state is AuthGuest);
          
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
              repository: ArtistRepository(),
            ),
            child: EditArtistProfileScreen(artist: artist),
          );
        },
      ),
      GoRoute(
        path: '/verification-request',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => VerificationRequestCubit(
              VerificationRequestRepository(),
            ),
            child: const VerificationRequestScreen(),
          );
        },
      ),
    ],
  );
}