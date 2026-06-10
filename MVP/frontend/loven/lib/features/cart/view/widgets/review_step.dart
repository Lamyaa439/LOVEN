import 'package:flutter/material.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/features/cart/data/models/cart_model.dart';
import 'package:loven/features/cart/view/screens/checkout_screen.dart';
import 'package:loven/features/cart/view/widgets/checkout_shared.dart';
import 'package:loven/features/cart/view/widgets/checkout_stepper.dart';
import 'package:loven/features/cart/view/widgets/review_widgets.dart';

class ReviewStep extends StatelessWidget {
  const ReviewStep({
    super.key,
    required this.cart,
    required this.userLabel,
  });

  final CartModel cart;
  final String userLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CheckoutStepper(activeStep: CheckoutStep.review),
        const SizedBox(height: AppSpacing.sectionGap),
        const CheckoutSectionTitle(
          icon: Icons.person_outline,
          title: 'Order for',
        ),
        const SizedBox(height: AppSpacing.md),
        ReviewInfoCard(
          title: userLabel,
          lines: const [
            'Placed under your LOVEN account.',
          ],
          leadingIcon: Icons.account_circle_outlined,
        ),
        const SizedBox(height: AppSpacing.xl),
        CheckoutSectionTitle(
          icon: Icons.shopping_bag_outlined,
          title: 'Order · ${cart.items.length} items',
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: checkoutCardDecoration(context),
          child: Column(
            children: [
              ...cart.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: ReviewOrderItem(item: item),
                ),
              ),
              Divider(color: AppColors.borderLight, height: 1),
              const SizedBox(height: AppSpacing.lg),
              SummaryRow(
                label: 'Subtotal',
                value: 'SAR ${cart.subtotal.toStringAsFixed(2)}',
              ),
              const SizedBox(height: AppSpacing.sm),
              SummaryRow(
                label: 'Shipping',
                value: cart.shippingFee == 0
                    ? 'Free'
                    : 'SAR ${cart.shippingFee.toStringAsFixed(2)}',
                valueColor:
                    cart.shippingFee == 0 ? AppColors.success : null,
              ),
              const SizedBox(height: AppSpacing.md),
              SummaryRow(
                label: 'Total',
                value: 'SAR ${cart.totalAmount.toStringAsFixed(2)}',
                large: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
