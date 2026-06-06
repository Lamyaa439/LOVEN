import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/router/app_router_deps.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/router/router_helpers.dart';
import 'package:loven/features/artist_profile/controller/artist_profile_cubit.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/artist_profile/view/screens/artist_profile_screen.dart';
import 'package:loven/features/artist_profile/view/screens/edit_artist_profile_screen.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/home/View/Screens/artists_list_screen.dart';
import 'package:loven/features/home/View/Screens/artworks_list_screen.dart';
import 'package:loven/features/home/View/Screens/settings_screen.dart';

ArtistProfileCubit _createArtistProfileCubit(
  BuildContext context,
  AppRouterDeps deps,
) {
  return ArtistProfileCubit(
    repository: deps.artistRepository,
    authCubit: context.read<AuthCubit>(),
  );
}

/// Public browsing and signed-in artist storefront routes.
List<RouteBase> buildDiscoveryRoutesBrowse(AppRouterDeps deps) {
  return [
    GoRoute(
      path: AppRoutes.myProfile,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => _createArtistProfileCubit(context, deps),
          child: const ArtistProfileScreen(),
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
          create: (context) => _createArtistProfileCubit(context, deps),
          child: ArtistProfileScreen(
            artistProfileId: artistId,
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
  ];
}

List<RouteBase> buildDiscoveryRoutesSettings(AppRouterDeps deps) {
  return [
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => _createArtistProfileCubit(context, deps),
          child: const SettingsScreen(),
        );
      },
    ),
  ];
}

List<RouteBase> buildDiscoveryRoutesArtistEdit(AppRouterDeps deps) {
  return [
    GoRoute(
      path: AppRoutes.artistProfileEdit,
      builder: (context, state) {
        final raw = state.extra;
        if (raw is! ArtistModel) {
          return invalidRouteExtraFallback(
            title: 'Edit Artist Profile',
            message: 'Artist data is missing.',
          );
        }
        final artist = raw;

        return BlocProvider(
          create: (context) => _createArtistProfileCubit(context, deps),
          child: EditArtistProfileScreen(artist: artist),
        );
      },
    ),
  ];
}
