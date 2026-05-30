import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/res/theme/app_colors.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({
    super.key,
  });

  @override
  State<NewPasswordPage> createState() =>
      _NewPasswordPageState();
}

class _NewPasswordPageState
    extends State<NewPasswordPage> {
  final passwordController =
      TextEditingController();

  final confirmController =
      TextEditingController();

  bool obscure1 = true;
  bool obscure2 = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    context.go(
      '/forgot-password/success',
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

              const SizedBox(height: 28),

              Text(
                'New Password',
                style: theme.textTheme
                    .displayLarge
                    ?.copyWith(
                  fontSize: 32,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Create your new password so you can login again.',
                style: theme
                    .textTheme.bodyMedium
                    ?.copyWith(
                  fontSize: 13,
                  color: theme.colorScheme
                      .onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 30),

              _Label('New Password'),

              TextField(
                controller:
                    passwordController,
                obscureText: obscure1,
                decoration:
                    _inputDecoration(
                  context,
                  hint:
                      'Your password',
                  obscure: obscure1,
                  onTap: () {
                    setState(() {
                      obscure1 =
                          !obscure1;
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              _Label(
                'Confirm Password',
              ),

              TextField(
                controller:
                    confirmController,
                obscureText: obscure2,
                decoration:
                    _inputDecoration(
                  context,
                  hint:
                      'Confirm password',
                  obscure: obscure2,
                  onTap: () {
                    setState(() {
                      obscure2 =
                          !obscure2;
                    });
                  },
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton
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
                  child:
                      const Text('Send'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    required bool obscure,
    required VoidCallback onTap,
  }) {
    return InputDecoration(
      hintText: hint,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      filled: true,
      fillColor: Theme.of(context)
          .colorScheme
          .surface,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        borderSide: BorderSide.none,
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        borderSide:
            const BorderSide(
          color:
              AppColors.primaryBlue,
          width: 1.3,
        ),
      ),
      suffixIcon: IconButton(
        onPressed: onTap,
        icon: Icon(
          obscure
              ? Icons
                  .visibility_off_outlined
              : Icons
                  .visibility_outlined,
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 6,
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(
          fontWeight:
              FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}