import 'package:flutter/material.dart';
import 'package:loven/core/res/design_system.dart';
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
        _StepItem(
          icon: Icons.person_outline,
          label: 'Account',
          active: true,
          completed: activeStep != CheckoutStep.account,
        ),
        const _StepLine(),
        _StepItem(
          icon: Icons.receipt_long_outlined,
          label: 'Confirm',
          active: activeStep == CheckoutStep.payment ||
              activeStep == CheckoutStep.review,
          completed: activeStep == CheckoutStep.review,
        ),
        const _StepLine(),
        _StepItem(
          icon: Icons.check_rounded,
          label: 'Review',
          active: activeStep == CheckoutStep.review,
        ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
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
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: AppSizes.avatarMd,
          height: AppSizes.avatarMd,
          decoration: BoxDecoration(
            color: active ? AppColors.brandPrimary : AppColors.surfaceElevated,
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? AppColors.brandPrimary : AppColors.borderLight,
            ),
          ),
          child: Icon(
            completed ? Icons.check_rounded : icon,
            color: active ? AppColors.textOnBrand : AppColors.textMuted,
            size: AppSizes.iconSm,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: active ? AppColors.textPrimary : AppColors.textMuted,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.huge,
      height: 2,
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      color: AppColors.border,
    );
  }
}
