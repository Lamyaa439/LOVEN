import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/res/theme/app_colors.dart';

/// Displays the initial animated splash screen with the LOVEN logo.
/// 
/// This screen utilizes the centralized [AppColors.primaryPurple] from the 
/// application's design system to maintain architectural consistency across platforms.


// إنشاء شاشة متغيرة 
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      );

    _fadeAnimation = Tween<double>(begin: 0.0, end:1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
        ),
    );
    
    _executeSplashSequence();
  }

  void _executeSplashSequence() async {
    await _animationController.forward();

    // إبقاء الشعار ظاهر لمدة نصف ثانية
    await Future.delayed(const Duration(milliseconds: 500));

    await _animationController.reverse();

    if (mounted) {
      context.go('/onboarding');
    }
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
          'assets/images/loven-logo.png',
          width: 180, 
          ),
        ),
      ),
    );
  }
}