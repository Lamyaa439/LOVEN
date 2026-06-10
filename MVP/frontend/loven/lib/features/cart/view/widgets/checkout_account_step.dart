import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/cart/view/screens/checkout_screen.dart';
import 'package:loven/features/cart/view/widgets/checkout_shared.dart';
import 'package:loven/features/cart/view/widgets/checkout_stepper.dart';

class CheckoutAccountStep extends StatelessWidget {
  const CheckoutAccountStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authStateSessionUser(authState);
        final displayLabel = checkoutUserDisplayLabel(authState);
        final email = user?.email ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CheckoutStepper(activeStep: CheckoutStep.account),
            const SizedBox(height: AppSpacing.sectionGap),
            const CheckoutSectionTitle(
              icon: Icons.person_outline,
              title: 'Your account',
            ),
            const SizedBox(height: AppSpacing.xl),
            LovenSurfaceCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: AppSizes.iconLg,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayLabel,
                          style: theme.textTheme.titleSmall,
                        ),
                        if (email.isNotEmpty &&
                            displayLabel.trim().toLowerCase() !=
                                email.trim().toLowerCase()) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            email,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Your order will be placed under this LOVEN account. '
              'Shipping and delivery details are not collected at checkout yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        );
      },
    );
  }
}
