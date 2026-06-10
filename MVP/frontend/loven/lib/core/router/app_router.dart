import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/router/app_router_deps.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/router/redirect_policy.dart';
import 'package:loven/core/router/router_refresh.dart';
import 'package:loven/core/router/routes/app_route_table.dart';
import 'package:loven/core/router/splash_min_duration_notifier.dart';
import 'package:loven/core/storage/app_preferences.dart';
import 'package:loven/features/artist_profile/data/artist_repository.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/verification_request/data/repositories/verification_request_repository.dart';
import 'package:loven/features/report/data/repositories/report_repository.dart';
import 'package:loven/features/admin/data/repositories/admin_dashboard_repository.dart';
import 'package:loven/features/admin/data/repositories/admin_users_repository.dart';

/// Application router — [GoRouter] assembly only.
///
/// **Ownership:**
/// - [router]: `initialLocation`, [refreshListenable], [redirect], route list
/// - [redirect_policy]: frozen redirect rules
/// - [buildAppRouteList]: route builders in `routes/`
/// - [router_helpers] / [router_refresh]: shared router utilities
class AppRouter {
  AppRouter(
    this.authCubit, {
    required this.appPreferences,
    required this.splashMinDurationNotifier,
    required this.artistRepository,
    required this.verificationRequestRepository,
    required this.reportRepository,
    required this.adminDashboardRepository,
    required this.adminUsersRepository,
  }) : _deps = AppRouterDeps(
          authCubit: authCubit,
          artistRepository: artistRepository,
          verificationRequestRepository: verificationRequestRepository,
          reportRepository: reportRepository,
          adminDashboardRepository: adminDashboardRepository,
          adminUsersRepository: adminUsersRepository,
        );

  final AuthCubit authCubit;
  final AppPreferences appPreferences;
  final SplashMinDurationNotifier splashMinDurationNotifier;
  final ArtistRepository artistRepository;
  final VerificationRequestRepository verificationRequestRepository;
  final ReportRepository reportRepository;
  final AdminDashboardRepository adminDashboardRepository;
  final AdminUsersRepository adminUsersRepository;

  final AppRouterDeps _deps;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: Listenable.merge([
      GoRouterRefreshStream(authCubit.stream),
      splashMinDurationNotifier,
    ]),
    redirect: (context, state) => resolveRedirect(
      authState: authCubit.state,
      appPreferences: appPreferences,
      splashMinDuration: splashMinDurationNotifier,
      matchedLocation: state.matchedLocation,
    ),
    routes: buildAppRouteList(_deps),
  );
}
