import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/router/app_router_deps.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/features/admin/view/screens/admin_dashboard_screen.dart';
import 'package:loven/features/admin/view/screens/admin_feedback_screen.dart';
import 'package:loven/features/admin/view/screens/admin_reports_screen.dart';
import 'package:loven/features/admin/view/screens/admin_verification_requests_screen.dart';
import 'package:loven/features/verification_request/controller/cubit/verification_request_cubit.dart';
import 'package:loven/features/report/controller/cubit/report_cubit.dart';
import 'package:loven/features/admin/controller/cubit/admin_dashboard_cubit.dart';
import 'package:loven/features/admin/controller/cubit/admin_users_cubit.dart';
import 'package:loven/features/admin/view/screens/admin_users_screen.dart';
import 'package:loven/features/admin/controller/cubit/admin_feedback_cubit.dart';

/// System administrator dashboards.
List<RouteBase> buildAdminRoutes(AppRouterDeps deps) {
  return [
    GoRoute(
  path: AppRoutes.admin,
  builder: (context, state) {
    return BlocProvider(
      create: (_) => AdminDashboardCubit(
        deps.adminDashboardRepository,
      )..loadStats(),
      child: const AdminDashboardScreen(),
    );
  },
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
  builder: (context, state) {
    return BlocProvider(
      create: (_) => ReportCubit(
        deps.reportRepository,
      )..loadReports(),
      child: const AdminReportsScreen(),
    );
  },
),
GoRoute(
  path: AppRoutes.adminFeedback,
  builder: (context, state) {
    return BlocProvider(
      create: (_) => AdminFeedbackCubit(
        deps.adminDashboardRepository,
      )..loadFeedback(),
      child: const AdminFeedbackScreen(),
    );
  },
),
GoRoute(
  path: AppRoutes.adminUsers,
  builder: (context, state) {
    return BlocProvider(
      create: (_) => AdminUsersCubit(
        deps.adminUsersRepository,
      )..loadUsers(),
      child: const AdminUsersScreen(),
    );
  },
),
  ];
}
