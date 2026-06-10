import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import '../../controller/cubit/auth_cubit.dart';

/// Link-based email verification after Firebase signup.
class SignupVerificationEmailPage extends StatefulWidget {
  const SignupVerificationEmailPage({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<SignupVerificationEmailPage> createState() =>
      _SignupVerificationEmailPageState();
}

class _SignupVerificationEmailPageState
    extends State<SignupVerificationEmailPage> {
  bool _isResending = false;
  bool _isChecking = false;

  Future<void> _resendVerificationEmail() async {
    if (_isResending) return;

    setState(() => _isResending = true);

    try {
      await context.read<AuthCubit>().resendVerificationEmail();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent. Check your inbox.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _checkVerification() async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    try {
      final isVerified =
          await context.read<AuthCubit>().checkEmailVerified();

      if (!mounted) return;

      if (isVerified) {
        await context.read<AuthCubit>().signOutFirebaseOnly();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully.'),
          ),
        );
        context.go(AppRoutes.signupSuccess);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email not verified yet. Open the link in your inbox, then tap Continue.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = _isResending || _isChecking;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: isBusy
                    ? null
                    : () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.auth);
                        }
                      },
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              Center(
                child: Text(
                  'Verify your email',
                  style: theme.textTheme.displaySmall,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Text(
                  'We sent a verification link to',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Center(
                child: Text(
                  widget.email,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Center(
                child: Icon(
                  Icons.mark_email_unread_outlined,
                  size: AppSizes.avatarXl,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Center(
                child: Text(
                  'Open the link in your email, then return here and tap Continue.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: TextButton(
                  onPressed: isBusy ? null : _resendVerificationEmail,
                  child: _isResending
                      ? const SizedBox(
                          width: AppSizes.iconMd,
                          height: AppSizes.iconMd,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text.rich(
                          TextSpan(
                            text: "Didn't receive the email? ",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                            children: const [
                              TextSpan(
                                text: 'Resend',
                                style: TextStyle(
                                  color: AppColors.brandPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              LovenPrimaryButton(
                label: 'Continue',
                isLoading: _isChecking,
                onPressed: isBusy ? null : _checkVerification,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
