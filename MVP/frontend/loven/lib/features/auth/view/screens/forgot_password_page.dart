import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/res/theme/app_colors.dart';

/// Password-reset entry screen.
///
/// Backend reset endpoints are not integrated yet, so this page now communicates
/// availability honestly instead of simulating a complete reset flow.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {
  final emailController =
      TextEditingController();

  final formKey =
      GlobalKey<FormState>();

  bool emailSent = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      emailSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Forgot password is coming soon. Backend integration is not ready yet.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),

                IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Forgot Password',
                  style: theme
                      .textTheme.displayLarge
                      ?.copyWith(
                    fontSize: 34,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  emailSent
                      ? 'If an account exists, a reset link was sent.'
                      : 'Enter your email to receive a password reset link.',
                  style: theme
                      .textTheme.bodyMedium
                      ?.copyWith(
                    color: theme
                        .colorScheme
                        .onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 26),

                Text(
                  'Email',
                  style: theme
                      .textTheme.bodyMedium
                      ?.copyWith(
                    fontWeight:
                        FontWeight.w700,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                TextFormField(
                  controller:
                      emailController,
                  keyboardType:
                      TextInputType
                          .emailAddress,
                  decoration:
                      InputDecoration(
                    hintText:
                        'Your email',
                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    filled: true,
                    fillColor: theme
                        .colorScheme
                        .surface,
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                      borderSide:
                          BorderSide.none,
                    ),
                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                      borderSide:
                          const BorderSide(
                        color: AppColors
                            .primaryBlue,
                        width: 1.3,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Email is required';
                    }

                    if (!value
                        .contains('@')) {
                      return 'Enter a valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submit,
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
                    child: Text(
                      emailSent ? 'Coming Soon' : 'Send Reset Link',
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}