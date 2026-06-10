import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:loven/features/admin/controller/cubit/admin_users_cubit.dart';
import 'package:loven/features/admin/controller/cubit/admin_users_state.dart';
import 'package:loven/features/admin/view/widgets/admin_section_header.dart';
import 'package:loven/features/admin/view/widgets/admin_user_card.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        centerTitle: true,
      ),
      body: BlocBuilder<AdminUsersCubit, AdminUsersState>(
        builder: (context, state) {
          if (state is AdminUsersLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is AdminUsersFailure) {
            return Center(
              child: Text(state.message),
            );
          }

          final users = state is AdminUsersLoaded
              ? state.users
              : <dynamic>[];

          if (users.isEmpty) {
            return const Center(
              child: Text('No users found'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<AdminUsersCubit>().loadUsers();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const AdminSectionHeader(
                    title: 'Users',
                    subtitle: 'Disable or reactivate platform accounts',
                  );
                }

                final user = Map<String, dynamic>.from(
                  users[index - 1] as Map,
                );

                final userId = user['id']?.toString() ?? '';
                final isActive = user['is_active'] == true;

                return AdminUserCard(
                  name: user['name']?.toString() ?? 'Unknown User',
                  email: user['email']?.toString() ?? '',
                  role: user['system_role']?.toString() ?? 'customer',
                  isActive: isActive,
                  onToggleStatus: () {
                    if (userId.isEmpty) return;

                    context.read<AdminUsersCubit>().updateUserStatus(
                          userId: userId,
                          isActive: !isActive,
                        );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}