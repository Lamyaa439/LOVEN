import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/router/app_routes.dart';
import 'package:loven/features/admin/controller/cubit/admin_dashboard_cubit.dart';
import 'package:loven/features/admin/controller/cubit/admin_dashboard_state.dart';
import 'package:loven/features/admin/view/widgets/admin_action_tile.dart';
import 'package:loven/features/admin/view/widgets/admin_dashboard_header.dart';
import 'package:loven/features/admin/view/widgets/admin_section_header.dart';
import 'package:loven/features/admin/view/widgets/admin_stat_card.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminDashboardCubit>().loadStats();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
        builder: (context, state) {
          if (state is AdminDashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is AdminDashboardFailure) {
            return Center(
              child: Text(state.message),
            );
          }

          final stats = state is AdminDashboardLoaded
              ? state.stats
              : <String, dynamic>{};

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<AdminDashboardCubit>().loadStats();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const AdminDashboardHeader(),
                const SizedBox(height: 24),
                const AdminSectionHeader(
                  title: 'Platform Statistics',
                  subtitle: 'Live overview of LOVEN activity',
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.45,
                  children: [
                    AdminStatCard(
                      title: 'Total Users',
                      value: '${stats['total_users'] ?? 0}',
                      icon: Icons.people_outline,
                    ),
                    AdminStatCard(
                      title: 'Total Artists',
                      value: '${stats['total_artists'] ?? 0}',
                      icon: Icons.palette_outlined,
                    ),
                    AdminStatCard(
                      title: 'Verified Artists',
                      value: '${stats['verified_artists'] ?? 0}',
                      icon: Icons.verified_outlined,
                    ),
                    AdminStatCard(
                      title: 'Total Artworks',
                      value: '${stats['total_artworks'] ?? 0}',
                      icon: Icons.image_outlined,
                    ),
                    AdminStatCard(
                      title: 'Open Reports',
                      value: '${stats['open_reports'] ?? 0}',
                      icon: Icons.report_problem_outlined,
                    ),
                    AdminStatCard(
                      title: 'Pending Requests',
                      value:
                          '${stats['pending_verification_requests'] ?? 0}',
                      icon: Icons.hourglass_empty_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const AdminSectionHeader(
                  title: 'Management',
                  subtitle: 'Administrative actions and moderation',
                ),
                const SizedBox(height: 16),
                AdminActionTile(
                  icon: Icons.verified_user_outlined,
                  title: 'Verification Requests',
                  subtitle: 'Review artist verification submissions',
                  onTap: () {
                    context.push(AppRoutes.adminVerificationRequests);
                  },
                ),
                const SizedBox(height: 12),
                AdminActionTile(
                  icon: Icons.report_outlined,
                  title: 'Reports',
                  subtitle: 'Review reported artworks',
                  onTap: () {
                    context.push(AppRoutes.adminReports);
                  },
                ),
                AdminActionTile(
  icon: Icons.people_outline,
  title: 'Users',
  subtitle: 'Manage platform users',
  onTap: () {
    context.push(AppRoutes.adminUsers);
  },
),
              ],
            ),
          );
        },
      ),
    );
  }
}