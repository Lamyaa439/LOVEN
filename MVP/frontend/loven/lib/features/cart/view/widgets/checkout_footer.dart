import 'package:flutter/material.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/cart/data/models/cart_model.dart';
import 'package:loven/features/cart/view/screens/checkout_screen.dart';

class CheckoutFooter extends StatelessWidget {
  const CheckoutFooter({
    super.key,
    required this.step,
    required this.cart,
    required this.isLoading,
    required this.onNext,
    required this.onBack,
  });

  final CheckoutStep step;
  final CartModel cart;
  final bool isLoading;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final buttonText = switch (step) {
      CheckoutStep.account => 'Continue',
      CheckoutStep.payment => 'Continue to review',
      CheckoutStep.review =>
        'Place order · SAR ${cart.totalAmount.toStringAsFixed(2)}',
    };

    final backText = switch (step) {
      CheckoutStep.account => 'Back to cart',
      CheckoutStep.payment => 'Back to account',
      CheckoutStep.review => 'Back to confirmation',
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            LovenPrimaryButton(
              label: isLoading ? 'Creating order…' : buttonText,
              isLoading: isLoading,
              icon: step == CheckoutStep.review
                  ? Icons.local_mall_outlined
                  : Icons.arrow_forward_rounded,
              onPressed: isLoading ? null : onNext,
            ),
            const SizedBox(height: AppSpacing.sm),
            LovenSecondaryButton(
              label: backText,
              expand: true,
              onPressed: isLoading ? null : onBack,
            ),
          ],
        ),
      ),
    );
  }
}
