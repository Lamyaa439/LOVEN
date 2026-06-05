import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/router/app_router_deps.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/features/admin/view/screens/admin_dashboard_screen.dart';
import 'package:loven/features/admin/view/screens/admin_reports_screen.dart';
import 'package:loven/features/admin/view/screens/admin_verification_requests_screen.dart';
import 'package:loven/features/verification_request/controller/cubit/verification_request_cubit.dart';

/// System administrator dashboards.
List<RouteBase> buildAdminRoutes(AppRouterDeps deps) {
  return [
    GoRoute(
      path: AppRoutes.admin,
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminVerificationRequests,
      builder: (context, state) {
        return BlocProvider(
          create: (_) => VerificationRequestCubit(
            deps.verificationRequestRepository,
          )..fetchAllRequests(),
          child: const AdminVerificationRequestsScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.adminReports,
      builder: (context, state) => const AdminReportsScreen(),
    ),
  ];
}
