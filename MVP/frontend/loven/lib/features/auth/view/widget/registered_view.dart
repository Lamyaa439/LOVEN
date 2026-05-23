// lib/features/profile/widgets/registered_profile_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/controller/cubit/auth_cubit.dart';

class RegisteredProfileView extends StatelessWidget {
  const RegisteredProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Welcome back!"),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text("Logout"),
          onTap: () => context.read<AuthCubit>().logout(),
        ),
        // Add more registered-only features here...
      ],
    );
  }
}
