import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/l10n/generated/app_localizations.dart';

/// Post-verification confirmation before the user signs in for a LOVEN JWT.
class SignupSuccessPage extends StatelessWidget {
  const SignupSuccessPage({super.key});

  void _continueToLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _continueToLogin(context);
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
                Container(
                  width: AppSizes.avatarXl + AppSpacing.xxl,
                  height: AppSizes.avatarXl + AppSpacing.xxl,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceElevated,
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Icon(
                    Icons.verified_rounded,
                    size: AppSizes.avatarLg,
                    color: AppColors.brandPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  l10n.verifiedTitle,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.verifiedSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                LovenPrimaryButton(
                  label: l10n.continueToLogin,
                  onPressed: () => _continueToLogin(context),
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
