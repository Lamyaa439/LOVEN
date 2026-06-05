import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/res/theme/app_colors.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';

/// Authenticated password change form.
///
/// TODO(future-phase): For email/password users, call
/// [FirebaseAuthService.updatePassword] (with Firebase re-authentication)
/// instead of [AuthCubit.changePassword] → `PATCH /change-password`.
/// LOVEN backend no longer owns passwords for Firebase email users.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
  });

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final currentPasswordController =
      TextEditingController();

  final newPasswordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    context
        .read<AuthCubit>()
        .changePassword(
          currentPassword:
              currentPasswordController
                  .text
                  .trim(),
          newPassword:
              newPasswordController.text
                  .trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<
        AuthCubit,
        AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'Password changed successfully',
              ),
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
        final isLoading =
            state is AuthLoading;

        return Scaffold(
          backgroundColor:
              theme.scaffoldBackgroundColor,

          appBar: AppBar(
            centerTitle: true,
            title:
                const Text('Change Password'),
            backgroundColor:
                theme.scaffoldBackgroundColor,
            elevation: 0,
          ),

          body: SingleChildScrollView(
            padding:
                const EdgeInsets.fromLTRB(
              24,
              12,
              24,
              24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _PasswordField(
                    label:
                        'Current Password',
                    controller:
                        currentPasswordController,
                    obscure:
                        obscureCurrent,
                    onToggle: () {
                      setState(() {
                        obscureCurrent =
                            !obscureCurrent;
                      });
                    },
                  ),

                  const SizedBox(
                      height: 16),

                  _PasswordField(
                    label:
                        'New Password',
                    controller:
                        newPasswordController,
                    obscure: obscureNew,
                    onToggle: () {
                      setState(() {
                        obscureNew =
                            !obscureNew;
                      });
                    },
                  ),

                  const SizedBox(
                      height: 16),

                  _PasswordField(
                    label:
                        'Confirm Password',
                    controller:
                        confirmPasswordController,
                    obscure:
                        obscureConfirm,
                    onToggle: () {
                      setState(() {
                        obscureConfirm =
                            !obscureConfirm;
                      });
                    },
                    validator: (value) {
                      if (value !=
                          newPasswordController
                              .text) {
                        return 'Passwords do not match';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                      height: 28),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 50,
                    child:
                        ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : _submit,
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            AppColors
                                .primaryBlue,
                        foregroundColor:
                            Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            26,
                          ),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                                color: Colors
                                    .white,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                            ),
                    ),
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

class _PasswordField
    extends StatelessWidget {
  final String label;
  final TextEditingController
      controller;

  final bool obscure;

  final VoidCallback onToggle;

  final String? Function(String?)?
      validator;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme
              .textTheme.bodyMedium
              ?.copyWith(
            fontWeight:
                FontWeight.w700,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 6),

        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator ??
              (value) {
                if (value == null ||
                    value.isEmpty) {
                  return '$label is required';
                }

                if (value.length < 8) {
                  return 'Minimum 8 characters';
                }

                return null;
              },
          decoration:
              InputDecoration(
            hintText: label,
            filled: true,
            fillColor: theme
                .colorScheme.surface,
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
              borderSide:
                  BorderSide.none,
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
              borderSide:
                  const BorderSide(
                color: AppColors
                    .primaryBlue,
                width: 1.3,
              ),
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscure
                    ? Icons
                        .visibility_off_outlined
                    : Icons
                        .visibility_outlined,
              ),
            ),
          ),
        ),
      ],
    );
  }
}