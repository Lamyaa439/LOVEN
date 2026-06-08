import 'package:go_router/go_router.dart';
import 'package:loven/core/router/app_router_deps.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/features/navigation/view/Screens/navigation_screen.dart';
import 'package:loven/features/splash/onboarding_screen.dart';
import 'package:loven/features/splash/splash_screen.dart';

/// Boot funnel: splash, legacy alias, onboarding, home shell.
List<RouteBase> buildStartupRoutes(AppRouterDeps deps) {
  return [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.splashLegacy,
      redirect: (context, state) => AppRoutes.splash,
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const NavigationScreen(),
    ),
  ];
}
