import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:loven/core/router/splash_min_duration_notifier.dart';
import '../../core/res/theme/app_colors.dart';

/// Splash UI only; navigation is owned by [AppRouter] redirect policy.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _runMinimumSplashPresentation();
  }

  /// Branded delay only — session restore runs in [LovenApp], routing in router.
  Future<void> _runMinimumSplashPresentation() async {
    await _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    context.read<SplashMinDurationNotifier>().markReady();
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
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(
              'assets/images/loven-logo.png',
              width: 180,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
