// lib/features/profile/widgets/guest_profile_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GuestProfileView extends StatelessWidget {
  const GuestProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.account_circle, size: 100, color: Colors.grey),
        const SizedBox(height: 16),
        const Text("Guest User",
            textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.login),
          title: const Text("Sign In / Sign Up"),
          onTap: () => context.push('/auth'), // Your auth route
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.dark_mode),
          title: const Text("Theme Settings"),
          onTap: () {/* Add your theme toggle logic here */},
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text("Language"),
          onTap: () {/* Add your language toggle logic here */},
        ),
      ],
    );
  }
}
