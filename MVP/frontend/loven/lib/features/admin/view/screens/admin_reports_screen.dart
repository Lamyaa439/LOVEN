import 'package:flutter/material.dart';
/// A simple placeholder screen for the admin reports section.
///
/// This screen is used as a temporary route target until the
/// full admin reports feature is implemented.
class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Reports'),
      ),
      body: const Center(
        child: Text('Admin Reports'),
      ),
    );
  }
}
