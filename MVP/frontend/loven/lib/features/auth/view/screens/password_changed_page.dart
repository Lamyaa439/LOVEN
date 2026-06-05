import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/res/theme/app_colors.dart';

/// Post-reset confirmation — manual login only.
///
/// **Architectural rule:** Firebase completes password change via the email link.
/// This screen never auto-logs in or exchanges a LOVEN JWT; the user must sign in.
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),
                Image.asset(
                  'assets/icons/password-success.png',
                  height: 190,
                ),
                const SizedBox(height: 28),
                Text(
                  'Password Changed!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your password has been updated. Sign in with your new password.',
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
                    onPressed: () => _goToLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Text('Login'),
                  ),
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
