import 'package:flutter/material.dart';

import 'package:loven/core/res/theme/app_colors.dart';
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
    final buttonText = switch (step) {
      CheckoutStep.shipping => 'Continue to Payment',
      CheckoutStep.payment => 'Continue to Review',
      CheckoutStep.review =>
        'Place Order — SAR ${cart.totalAmount.toStringAsFixed(2)}',
    };

    final backText = switch (step) {
      CheckoutStep.shipping => '← Back to Cart',
      CheckoutStep.payment => '← Back to Shipping',
      CheckoutStep.review => '← Back to Payment',
    };

    final icon = switch (step) {
      CheckoutStep.review => Icons.local_mall_outlined,
      _ => Icons.arrow_forward_rounded,
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onNext,
                icon: isLoading
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(icon, size: 18),
                label: Text(
                  isLoading ? 'Creating order...' : buttonText,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: isLoading ? null : onBack,
              child: Text(backText),
            ),
          ],
        ),
      ),
    );
  }
}