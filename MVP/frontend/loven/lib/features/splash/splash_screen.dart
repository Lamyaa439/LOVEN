import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 1400),
    );

    fadeAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    );

    scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ),
    );

    controller.forward();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  Future<void>
      _checkAuthAndNavigate() async {
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    await context
        .read<AuthCubit>()
        .checkAuthStatus();

    if (!mounted) return;

    final authState =
        context.read<AuthCubit>().state;

    if (authState is AuthSuccess ||
        authState is AuthGuest) {
      context.go('/');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
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