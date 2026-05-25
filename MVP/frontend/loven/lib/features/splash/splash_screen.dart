import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Displays the initial splash screen with the LOVEN logo.
/// 
/// This screen uses the primary theme color as its background and implements 
/// a 2-second timer before safely navigating the user to the Onboarding screen.


// إنشاء شاشة متغيرة 
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the onboarding screen after a 2-second delay
    Future.delayed(const Duration(seconds: 2), () {
      // شرط يتحقق إذا ماكان المستخدم يرى الشاشة ام خرج من التطبيق
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Fetch the primary color from app_theme.dart
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 180, 
        ),
      ),
    );
  }
}