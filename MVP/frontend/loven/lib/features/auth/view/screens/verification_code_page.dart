import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/res/theme/app_colors.dart';

class VerificationCodePage extends StatefulWidget {
  final String email;

  const VerificationCodePage({
    super.key,
    required this.email,
  });

  @override
  State<VerificationCodePage> createState() =>
      _VerificationCodePageState();
}

class _VerificationCodePageState
    extends State<VerificationCodePage> {
  final codeControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final focusNodes = List.generate(
    4,
    (_) => FocusNode(),
  );

  @override
  void dispose() {
    for (final controller in codeControllers) {
      controller.dispose();
    }

    for (final node in focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  void _continue() {
    context.push(
      '/forgot-password/new-password',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: Padding(
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
                'Verification Code',
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
                'Please enter the verification code sent to',
                style: theme
                    .textTheme.bodyMedium
                    ?.copyWith(
                  fontSize: 13,
                  color: theme.colorScheme
                      .onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                widget.email,
                style: theme
                    .textTheme.bodyMedium
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 34),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: List.generate(
                  4,
                  (index) =>
                      _CodeBox(
                    controller:
                        codeControllers[
                            index],
                    focusNode:
                        focusNodes[index],
                    onChanged:
                        (value) {
                      if (value
                              .length ==
                          1 &&
                          index < 3) {
                        FocusScope.of(
                                context)
                            .requestFocus(
                          focusNodes[
                              index + 1],
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
                    text:
                        'Didn’t receive the code? ',
                    style: theme
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Resend',
                        style: TextStyle(
                          color: AppColors
                              .primaryBlue,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _continue,
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
                  child: const Text(
                    'Continue',
                  ),
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
      width: 62,
      height: 62,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType:
            TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight:
              FontWeight.w700,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor:
              Theme.of(context)
                  .colorScheme
                  .surface,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            borderSide:
                BorderSide.none,
          ),
          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            borderSide:
                const BorderSide(
              color:
                  AppColors.primaryBlue,
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}