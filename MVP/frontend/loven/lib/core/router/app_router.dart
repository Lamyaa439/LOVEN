import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'dart:async';

<<<<<<< HEAD
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/features/artist_profile/controller/artist_profile_cubit.dart';
import 'package:loven/features/artist_profile/model/artist_repository.dart';
=======
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
>>>>>>> 769f0e1291d83b23ddae30d63ca27cabe596496f
import 'package:loven/features/auth/view/screens/login_page.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/artwork/view/screens/create_artwork_screen.dart';
import 'package:loven/features/auth/view/screens/profile_screen.dart';
import 'package:loven/features/splash/splash_screen.dart';
import 'package:loven/features/home/View/art_details_screen.dart';
import 'package:loven/features/auth/view/screens/signup_page.dart';
import 'package:loven/features/navigation/view/screens/navigation_screen.dart';
import 'package:loven/features/artist_profile/view/screens/artist_profile_screen.dart';
import 'package:loven/features/artist_profile/view/screens/edit_artist_profile_screen.dart';

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

GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
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
          path.startsWith('/artworks/create');

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
        path: '/my-profile',
        builder: (context, state) => const ArtistProfileScreen(),
      ),
      GoRoute(
        path: '/artist/:artistId',
        builder: (context, state) {
          final artistId = state.pathParameters['artistId']!;
          return ArtistProfileScreen(artistProfileId: artistId);
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
        path: '/art-details',
        builder: (context, state) {
          final extra = state.extra;
          final artItem = extra is ArtworkModel
              ? extra
              : ArtworkModel.fromJson(extra as Map<String, dynamic>);

<<<<<<< HEAD
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          NavigationScreen(isGuest: isUserBrowsingAsGuest),
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
      path: '/my-profile',
      builder: (context, state) => const ArtistProfileScreen(),
    ),

    GoRoute(
      path: '/profile',
      builder: (context, state) => const ArtistProfileScreen(),
    ),

    GoRoute(
      path: '/artist/:artistId',
      builder: (context, state) {
        final artistId = state.pathParameters['artistId']!;
        return ArtistProfileScreen(artistProfileId: artistId);
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
      path: '/art-details',
      builder: (context, state) {
        final extra = state.extra;
        final artItem = extra is ArtworkModel
        ? extra
        : ArtworkModel.fromJson(extra as Map<String, dynamic>);
        
        return ArtDetailsScreen(
          artItem: artItem,
        );
      },
    ),
  ],
);
=======
          return ArtDetailsScreen(
            artItem: artItem,
          );
        },
      ),
    ],
  );
}
>>>>>>> 769f0e1291d83b23ddae30d63ca27cabe596496f
