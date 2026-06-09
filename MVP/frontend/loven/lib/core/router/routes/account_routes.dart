import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/router/app_router_deps.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/features/account/view/screens/account_screen.dart';
import 'package:loven/features/account/view/screens/edit_account_screen.dart';
import 'package:loven/features/artist_profile/controller/artist_profile_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/navigation/view/Screens/navigation_screen.dart';

Widget _accountHubWithArtistCubit(
  BuildContext context,
  AppRouterDeps deps,
) {
  return BlocProvider(
    create: (context) => ArtistProfileCubit(
      repository: deps.artistRepository,
      authCubit: context.read<AuthCubit>(),
    ),
    child: const AccountScreen(),
  );
}

/// Account hub (`/profile`) — guest and signed-in; sole account/settings surface.
List<RouteBase> buildAccountRoutesHub(AppRouterDeps deps) {
  return [
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => _accountHubWithArtistCubit(context, deps),
    ),
    GoRoute(
      path: AppRoutes.settings,
      redirect: (context, state) => AppRoutes.profile,
    ),
  ];
}

/// Account profile editor (`/profile/edit`).
List<RouteBase> buildAccountRoutesEdit(AppRouterDeps deps) {
  return [
    GoRoute(
  path: AppRoutes.profileEdit,
  builder: (context, state) {
    return const NavigationScreen(
      initialIndex: 3,
      accountChild: EditAccountScreen(),
    );
  },
),
  ];
}
