import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/res/theme/app_colors.dart';

/// Signup completion screen shown after account creation.
class SignupSuccessPage extends StatelessWidget {
  const SignupSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),

              Image.asset(
                'assets/icons/password-success.png',
                height: 175,
              ),

              const SizedBox(height: 28),

              Text(
                'Congratulations!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Your account is complete. Please enjoy the best art from us.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 34),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.go(AppRoutes.home);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text('Get Started'),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}