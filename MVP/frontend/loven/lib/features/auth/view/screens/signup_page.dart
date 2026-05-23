import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/router/app_router.dart';
import '../../controller/cubit/auth_cubit.dart';
import '../../controller/cubit/auth_state.dart';

class SignupPage extends StatefulWidget {
  final bool fromGuest;

  const SignupPage({
    super.key,
    this.fromGuest = false,
  });

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  bool acceptedTerms = false;
  bool obscurePassword = true;

  String selectedRole = 'customer';

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _signup() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final theme = Theme.of(context);

    if (!acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please accept the terms and privacy policy',
          ),
          backgroundColor: theme.colorScheme.error,
        ),
      );

      return;
    }

    context.read<AuthCubit>().signup(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          systemRole: selectedRole,
        );
  }

  InputDecoration inputDecoration(
    String hint,
    ThemeData theme,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
      ),
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          10,
        ),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
    );
  }

  void _handleCloseAction() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  void _goToLoggedInHome() {
    if (!mounted) return;

    GoRouter.of(context).go('/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (
        context,
        state,
      ) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                'Account created successfully',
              ),
            ),
          );

          _goToLoggedInHome();
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
              ),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      builder: (
        context,
        state,
      ) {
        final isLoading = state is AuthLoading;

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Image.asset(
                          'assets/images/loven-logo.png',
                          width: 72,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Create your LOVEN account',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      const Text(
                        'Join as a customer or artist',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(
                            30,
                            14,
                            30,
                            8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(
                                32,
                              ),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Full Name',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                TextFormField(
                                  controller: nameController,
                                  enabled: !isLoading,
                                  decoration: inputDecoration(
                                    'Type your full name',
                                    theme,
                                  ),
                                  validator: (
                                    value,
                                  ) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Name is required';
                                    }

                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                TextFormField(
                                  controller: emailController,
                                  enabled: !isLoading,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: inputDecoration(
                                    'Type your email',
                                    theme,
                                  ),
                                  validator: (
                                    value,
                                  ) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Email is required';
                                    }

                                    if (!value.contains(
                                      '@',
                                    )) {
                                      return 'Enter a valid email';
                                    }

                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  'Password',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                TextFormField(
                                  controller: passwordController,
                                  enabled: !isLoading,
                                  obscureText: obscurePassword,
                                  decoration: inputDecoration(
                                    'Type your password',
                                    theme,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              setState(
                                                () {
                                                  obscurePassword =
                                                      !obscurePassword;
                                                },
                                              );
                                            },
                                    ),
                                  ),
                                  validator: (
                                    value,
                                  ) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }

                                    if (value.length < 8) {
                                      return 'Password must be at least 8 characters';
                                    }

                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  'Role',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedRole,
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'customer',
                                          child: Text(
                                            'Customer',
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'artist',
                                          child: Text(
                                            'Artist',
                                          ),
                                        ),
                                      ],
                                      onChanged: isLoading
                                          ? null
                                          : (
                                              value,
                                            ) {
                                              setState(
                                                () {
                                                  selectedRole = value!;
                                                },
                                              );
                                            },
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: acceptedTerms,
                                        visualDensity: VisualDensity.compact,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        onChanged: isLoading
                                            ? null
                                            : (
                                                value,
                                              ) {
                                                setState(
                                                  () {
                                                    acceptedTerms =
                                                        value ?? false;
                                                  },
                                                );
                                              },
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                            fontSize: 12,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: 'I agree to the ',
                                            ),
                                            WidgetSpan(
                                              child: GestureDetector(
                                                onTap: () {
                                                  context.push(
                                                    '/terms',
                                                  );
                                                },
                                                child: Text(
                                                  'terms',
                                                  style: TextStyle(
                                                    color: theme
                                                        .colorScheme.primary,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const TextSpan(
                                              text: ' and ',
                                            ),
                                            WidgetSpan(
                                              child: GestureDetector(
                                                onTap: () {
                                                  context.push(
                                                    '/privacy-policy',
                                                  );
                                                },
                                                child: Text(
                                                  'privacy policy',
                                                  style: TextStyle(
                                                    color: theme
                                                        .colorScheme.primary,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _signup,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primaryContainer,
                                      foregroundColor:
                                          theme.colorScheme.onPrimaryContainer,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          30,
                                        ),
                                      ),
                                    ),
                                    child: isLoading
                                        ? const Text(
                                            'Creating account...',
                                          )
                                        : const Text(
                                            'Create Account',
                                          ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Already have an account? ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: isLoading
                                          ? null
                                          : () {
                                              context.go(
                                                '/login',
                                              );
                                            },
                                      child: Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.primary,
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
                  top: 4,
                  right: 4,
                  child: SafeArea(
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 28,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: isLoading ? null : _handleCloseAction,
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
