import 'package:go_router/go_router.dart';
import 'package:loven/core/router/app_router_deps.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/features/account/view/screens/edit_account_screen.dart';
import 'package:loven/features/navigation/view/Screens/navigation_screen.dart';

/// Account hub (`/profile`) — shell with account tab selected.
List<RouteBase> buildAccountRoutesHub(AppRouterDeps deps) {
  return [
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const NavigationScreen(
        initialIndex: 3,
      ),
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
