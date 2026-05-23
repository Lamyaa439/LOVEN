import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../controller/cubit/auth_state.dart';
import 'package:loven/core/router/app_router.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  final bool fromGuest;

  const LoginPage({
    super.key,
    this.fromGuest = false,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool rememberPassword = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().login(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
  }

  void _goToGuestHome() {
    context.go('/');
  }

  void _goToLoggedInHome() {
    if (!mounted) return;

    GoRouter.of(context).go('/');
  }

  InputDecoration inputDecoration(String hint, ThemeData theme) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: theme.colorScheme.outline,
        fontSize: 14,
      ),
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful'),
            ),
          );

          _goToLoggedInHome();
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: theme.colorScheme.surface,
            body: Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Center(
                        child: Image.asset(
                          'assets/images/loven-logo.png',
                          width: 105,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Welcome back to LOVEN!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Login to continue',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(40),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Email',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: inputDecoration(
                                    'Type your email',
                                    theme,
                                  ),
                                  enabled: !isLoading,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Email is required';
                                    }

                                    if (!value.contains('@')) {
                                      return 'Enter a valid email';
                                    }

                                    return null;
                                  },
                                ),
                                const SizedBox(height: 22),
                                const Text(
                                  'Password',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: obscurePassword,
                                  enabled: !isLoading,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  decoration: inputDecoration(
                                    'Type your password',
                                    theme,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              setState(() {
                                                obscurePassword =
                                                    !obscurePassword;
                                              });
                                            },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }

                                    if (value.length < 8) {
                                      return 'Password must be at least 8 characters';
                                    }

                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                InkWell(
                                  onTap: isLoading
                                      ? null
                                      : () {
                                          setState(() {
                                            rememberPassword =
                                                !rememberPassword;
                                          });
                                        },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Checkbox(
                                            value: rememberPassword,
                                            visualDensity:
                                                VisualDensity.compact,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            onChanged: isLoading
                                                ? null
                                                : (value) {
                                                    setState(() {
                                                      rememberPassword =
                                                          value ?? false;
                                                    });
                                                  },
                                          ),
                                        ),
                                        const Text(
                                          'Remember me',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      foregroundColor:
                                          theme.colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: isLoading ? null : _login,
                                    child: isLoading
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color:
                                                  theme.colorScheme.onPrimary,
                                            ),
                                          )
                                        : const Text(
                                            'Login',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: TextStyle(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: isLoading
                                          ? null
                                          : () {
                                              context.pushReplacement('/auth');
                                            },
                                      child: Text(
                                        'Sign up!',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: SafeArea(
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 28,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: _goToGuestHome,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
