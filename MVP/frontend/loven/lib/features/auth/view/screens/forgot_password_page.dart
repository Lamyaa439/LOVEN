import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/l10n/generated/app_localizations.dart';

/// Password-reset entry screen — Firebase link-based only.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _emailSent = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting || _emailSent) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await context.read<AuthCubit>().sendPasswordResetEmail(
            email: _emailController.text.trim(),
          );
    } catch (_) {
      // Always show generic success — do not reveal whether the email exists.
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _emailSent = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.login);
                          }
                        },
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.forgotPasswordTitle,
                    style: theme.textTheme.displaySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _emailSent
                      ? l10n.emailSentSubtitle
                      : l10n.forgotPasswordSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                LovenTextField(
                  controller: _emailController,
                  labelText: l10n.email,
                  hintText: l10n.hintEmail,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: _emailSent,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.emailRequired;
                    }
                    if (!value.contains('@')) {
                      return l10n.invalidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                LovenPrimaryButton(
                  label: _emailSent ? l10n.backToLogin : l10n.sendResetLink,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting
                      ? null
                      : (_emailSent
                          ? () => context.go(AppRoutes.login)
                          : _submit),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
