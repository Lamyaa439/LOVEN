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
import 'package:loven/features/home/View/widgets/art_details_screen.dart';
import 'package:loven/features/navigation/view/screens/navigation_screen.dart';
import 'package:loven/features/splash/splash_screen.dart';
import 'package:loven/features/splash/onboarding_screen.dart';

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
          path.startsWith('/verification-request');

      if (isGuest && isProtectedPath) {
        return '/auth';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => NavigationScreen(
          isGuest: authCubit.state is AuthGuest,
        ),
      ),
      GoRoute(
          path: '/profile', builder: (context, state) => const ProfileScreen()),
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
        path: '/cart',
        builder: (context, state) => const SizedBox.shrink(),
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
      GoRoute(
        path: '/art-details',
        builder: (context, state) {
          final extra = state.extra;
          try {
            final artItem = extra is ArtworkModel
              ? extra
              : ArtworkModel.fromJson(extra as Map<String, dynamic>);
            return ArtDetailsScreen(
            artItem: artItem,
          );
          } catch (e) {
            return const Scaffold(
              body: Center(child: Text('Failed to load artwork details')));
          }
        },
      ),
    ],
  );
}