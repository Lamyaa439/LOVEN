import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/res/theme/app_colors.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';

/// Login screen for email/password auth.
///
/// Post-login navigation is owned by [resolveRedirect] in the app router,
/// not by this screen.
class LoginPage extends StatefulWidget {
  final bool fromGuest;

  const LoginPage({
    super.key,
    this.fromGuest = false,
  });

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Firebase sign-in → reload (emailVerified) → LOVEN JWT exchange.
  ///
  /// Navigation after success is owned by [resolveRedirect] once [AuthSuccess]
  /// is emitted — this screen only surfaces [AuthFailure] snackbars.
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<AuthCubit>().loginWithFirebase(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
  }

  InputDecoration _inputDecoration({
    required String hint,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);

    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: theme.colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primaryBlue,
          width: 1.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    IconButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRoutes.home);
                              }
                            },
                      icon: Icon(
                        Icons.arrow_back,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Welcome Back 👋',
                      style: theme.textTheme.displayLarge
                          ?.copyWith(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Sign in to your account',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(
                        color:
                            theme.colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _FieldLabel('Email'),

                    TextFormField(
                      controller: emailController,
                      enabled: !isLoading,
                      keyboardType:
                          TextInputType.emailAddress,
                      decoration: _inputDecoration(
                        hint: 'Your email',
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Email is required';
                        }

                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    _FieldLabel('Password'),

                    TextFormField(
                      controller: passwordController,
                      enabled: !isLoading,
                      obscureText: obscurePassword,
                      decoration: _inputDecoration(
                        hint: 'Your password',
                        suffixIcon: IconButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  setState(() {
                                    obscurePassword =
                                        !obscurePassword;
                                  });
                                },
                          icon: Icon(
                            obscurePassword
                                ? Icons
                                    .visibility_off_outlined
                                : Icons
                                    .visibility_outlined,
                            color: theme.colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Password is required';
                        }

                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: isLoading
                        ? null
                        : () {
                          context.push(AppRoutes.forgotPassword);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          foregroundColor:
                              AppColors.primaryBlue,
                        ),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(26),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Login'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don’t have an account? ",
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(
                            color: theme.colorScheme
                                .onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: isLoading
                              ? null
                              : () {
                                  context.pushReplacement(
                                    AppRoutes.auth,
                                  );
                                },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}