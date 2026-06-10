import 'package:flutter/material.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/cart/view/screens/checkout_screen.dart';
import 'package:loven/features/cart/view/widgets/checkout_shared.dart';
import 'package:loven/features/cart/view/widgets/checkout_stepper.dart';

class PaymentStep extends StatelessWidget {
  const PaymentStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CheckoutStepper(activeStep: CheckoutStep.payment),
        const SizedBox(height: AppSpacing.sectionGap),
        const CheckoutSectionTitle(
          icon: Icons.receipt_long_outlined,
          title: 'Checkout confirmation',
        ),
        const SizedBox(height: AppSpacing.xl),
        LovenSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: AppSizes.iconMd,
                    color: AppColors.brandPrimary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'How checkout works today',
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
  'Secure online payment is being connected through Moyasar. You will review your order before payment is confirmed.',
  style: theme.textTheme.bodyMedium?.copyWith(
    color: AppColors.textSecondary,
    height: 1.5,
  ),
),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Payment and delivery will be arranged separately when those '
                'features are available. No card or billing details are collected '
                'at this step.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
