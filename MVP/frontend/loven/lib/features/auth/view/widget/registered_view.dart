import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:loven/core/res/theme/app_colors.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';

class RegisteredProfileView extends StatelessWidget {
  const RegisteredProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthCubit>().state;

    if (state is! AuthSuccess || state.user == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final user = state.user!;
    final hasImage =
        user.profileImageUrl != null &&
        user.profileImageUrl!.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 24),

        Center(
          child: CircleAvatar(
            radius: 56,
            backgroundColor:
                AppColors.primaryPurple.withValues(alpha: 0.25),
            backgroundImage:
                hasImage ? NetworkImage(user.profileImageUrl!) : null,
            child: hasImage
                ? null
                : Text(
                    user.name.isNotEmpty
                        ? user.name[0].toUpperCase()
                        : '?',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
          ),
        ),

        const SizedBox(height: 16),

        Center(
          child: Text(
            user.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),

        const SizedBox(height: 4),

        Center(
          child: Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),

        const SizedBox(height: 32),

        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () => context.read<AuthCubit>().logout(),
        ),
      ],
    );
  }
}