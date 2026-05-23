import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Text(
            'Terms and Conditions\n\n'
            'Welcome to LOVEN. By creating an account, you agree to use the app responsibly.\n\n'
            'Users must provide accurate account information and must not misuse the platform.\n\n'
            'Artists are responsible for the accuracy of artwork details, pricing, and availability.\n\n'
            'Customers agree to follow LOVEN purchasing and order policies.\n\n'
            'LOVEN may update these terms as the platform develops.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      ),
    );
  }
}
