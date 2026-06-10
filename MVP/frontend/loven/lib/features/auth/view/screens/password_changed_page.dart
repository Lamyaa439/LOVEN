import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/widgets/loven_widgets.dart';

/// Post-reset confirmation — manual login only.
class PasswordChangedPage extends StatelessWidget {
  const PasswordChangedPage({super.key});

  void _goToLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goToLogin(context);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Column(
              children: [
                const Spacer(),
                Image.asset(
                  'assets/icons/password-success.png',
                  height: 190,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Password changed',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your password has been updated. Sign in with your new password.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                LovenPrimaryButton(
                  label: 'Sign in',
                  onPressed: () => _goToLogin(context),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
