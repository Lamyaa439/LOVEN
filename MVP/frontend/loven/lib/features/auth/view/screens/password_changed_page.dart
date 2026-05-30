import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/res/theme/app_colors.dart';

class PasswordChangedPage
    extends StatelessWidget {
  const PasswordChangedPage({
    super.key,
  });

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
            children: [
              const Spacer(),

              Image.asset(
                'assets/icons/password-success.png',
                height: 190,
              ),

              const SizedBox(height: 28),

              Text(
                'Password Changed!',
                style: theme.textTheme
                    .headlineMedium
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Your password has been updated successfully.',
                textAlign:
                    TextAlign.center,
                style: theme
                    .textTheme.bodyMedium
                    ?.copyWith(
                  color: theme.colorScheme
                      .onSurfaceVariant,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 34),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.go(
                      '/login',
                    );
                  },
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
                      const Text('Login'),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}