import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/router_helpers.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/l10n/generated/app_localizations.dart';

/// Authenticated password change — Firebase owns credentials for email/password users.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await context.read<AuthCubit>().changePassword(
            currentPassword: currentPasswordController.text.trim(),
            newPassword: newPasswordController.text.trim(),
          );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.passwordChangedSuccess),
            ),
          );
          context.pop();
        }

        if (state is AuthFailure || state is AuthOperationFailure) {
          final message = state is AuthFailure
              ? state.message
              : (state as AuthOperationFailure).message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            leading: lovenPushedScreenBackLeading(context),
            centerTitle: true,
            title: Text(l10n.changePasswordTitle),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              AppSpacing.xxxl,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _PasswordField(
                    label: l10n.currentPassword,
                    controller: currentPasswordController,
                    obscure: obscureCurrent,
                    onToggle: () {
                      setState(() => obscureCurrent = !obscureCurrent);
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PasswordField(
                    label: l10n.newPassword,
                    controller: newPasswordController,
                    obscure: obscureNew,
                    onToggle: () {
                      setState(() => obscureNew = !obscureNew);
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PasswordField(
                    label: l10n.confirmPassword,
                    controller: confirmPasswordController,
                    obscure: obscureConfirm,
                    onToggle: () {
                      setState(() => obscureConfirm = !obscureConfirm);
                    },
                    validator: (value) {
                      if (value != newPasswordController.text) {
                        return l10n.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  LovenPrimaryButton(
                    label: l10n.saveChanges,
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LovenTextField(
      controller: controller,
      labelText: label,
      hintText: label,
      obscureText: obscure,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return l10n.fieldRequired(label);
            }
            if (value.length < 8) {
              return l10n.min8Characters;
            }
            return null;
          },
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
