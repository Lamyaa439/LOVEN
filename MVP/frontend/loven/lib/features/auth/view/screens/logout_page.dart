import 'package:flutter/material.dart';

/// Legacy placeholder screen kept for backward compatibility.
///
/// Logout is handled by [AuthCubit.logout] from profile/settings actions.
class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Logout is handled from your profile actions.'),
      ),
    );
  }
}
