import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Text(
            'Privacy Policy\n\n'
            'LOVEN respects your privacy.\n\n'
            'We may collect account information such as your name, email, role, and login details to provide authentication and app services.\n\n'
            'Your password is stored securely as a hashed value and is not saved as plain text.\n\n'
            'Authentication tokens are stored securely on your device.\n\n'
            'We do not sell your personal information.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      ),
    );
  }
}
