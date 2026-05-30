import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/res/theme/app_colors.dart';

class SignupVerificationEmailPage extends StatefulWidget {
  final String email;

  const SignupVerificationEmailPage({
    super.key,
    required this.email,
  });

  @override
  State<SignupVerificationEmailPage> createState() =>
      _SignupVerificationEmailPageState();
}

class _SignupVerificationEmailPageState
    extends State<SignupVerificationEmailPage> {
  final controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final focusNodes = List.generate(
    4,
    (_) => FocusNode(),
  );

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }

    for (final node in focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  void _continue() {
    context.go('/signup/success');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),

              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),

              const SizedBox(height: 30),

              Center(
                child: Text(
                  'Verification Email',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  'Please enter the code we just sent to email',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              Center(
                child: Text(
                  widget.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 34),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  4,
                  (index) => _CodeBox(
                    controller: controllers[index],
                    focusNode: focusNodes[index],
                    onChanged: (value) {
                      if (value.length == 1 && index < 3) {
                        FocusScope.of(context).requestFocus(
                          focusNodes[index + 1],
                        );
                      }

                      if (value.isEmpty && index > 0) {
                        FocusScope.of(context).requestFocus(
                          focusNodes[index - 1],
                        );
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'If you didn’t receive a code? ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Resend',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 34),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _CodeBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
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
        ),
      ),
    );
  }
}