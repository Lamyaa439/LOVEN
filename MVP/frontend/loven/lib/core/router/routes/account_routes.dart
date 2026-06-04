import 'package:go_router/go_router.dart';
import 'package:loven/core/router/app_router_deps.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/features/account/view/screens/account_screen.dart';
import 'package:loven/features/account/view/screens/edit_account_screen.dart';

/// Account hub (`/profile`) — guest and signed-in.
List<RouteBase> buildAccountRoutesHub(AppRouterDeps deps) {
  return [
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const AccountScreen(),
    ),
  ];
}

/// Account profile editor (`/profile/edit`).
List<RouteBase> buildAccountRoutesEdit(AppRouterDeps deps) {
  return [
    GoRoute(
      path: AppRoutes.profileEdit,
      builder: (context, state) => const EditAccountScreen(),
    ),
  ];
}
