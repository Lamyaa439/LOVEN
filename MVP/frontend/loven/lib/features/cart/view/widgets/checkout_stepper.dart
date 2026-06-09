import 'package:flutter/material.dart';

import 'package:loven/core/res/theme/app_colors.dart';
import 'package:loven/features/cart/view/screens/checkout_screen.dart';

class CheckoutStepper extends StatelessWidget {
  const CheckoutStepper({
    super.key,
    required this.activeStep,
  });

  final CheckoutStep activeStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StepItem(
          icon: Icons.local_shipping_outlined,
          label: 'Shipping',
          active: true,
          completed: activeStep != CheckoutStep.shipping,
        ),
        const StepLine(),
        StepItem(
          icon: Icons.credit_card_outlined,
          label: 'Payment',
          active: activeStep == CheckoutStep.payment ||
              activeStep == CheckoutStep.review,
          completed: activeStep == CheckoutStep.review,
        ),
        const StepLine(),
        StepItem(
          icon: Icons.check_rounded,
          label: 'Review',
          active: activeStep == CheckoutStep.review,
        ),
      ],
    );
  }
}

class StepItem extends StatelessWidget {
  const StepItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    this.completed = false,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? AppColors.primaryBlue
        : AppColors.primaryPurple.withValues(alpha: 0.16);

    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            completed ? Icons.check_rounded : icon,
            color: active ? Colors.white : AppColors.deepPurple,
            size: 18,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: active ? Colors.black87 : Colors.black38,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}

class StepLine extends StatelessWidget {
  const StepLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 2,
      margin: const EdgeInsets.only(bottom: 22),
      color: AppColors.primaryBlue.withValues(alpha: 0.75),
    );
  }
}