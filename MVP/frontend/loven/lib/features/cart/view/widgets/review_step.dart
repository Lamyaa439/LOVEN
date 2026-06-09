import 'package:flutter/material.dart';

import 'package:loven/features/cart/data/models/cart_model.dart';
import 'package:loven/features/cart/view/screens/checkout_screen.dart';
import 'package:loven/features/cart/view/widgets/checkout_shared.dart';
import 'package:loven/features/cart/view/widgets/checkout_stepper.dart';
import 'package:loven/features/cart/view/widgets/review_widgets.dart';

class ReviewStep extends StatelessWidget {
  const ReviewStep({
    super.key,
    required this.cart,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.region,
    required this.zipCode,
    required this.country,
  });

  final CartModel cart;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String region;
  final String zipCode;
  final String country;

  @override
  Widget build(BuildContext context) {
    final locationLine = [
      if (city.isNotEmpty) city,
      if (region.isNotEmpty) region,
      if (zipCode.isNotEmpty) zipCode,
      if (country.isNotEmpty) country,
    ].join(', ');

    final contactLine = [
      if (email.isNotEmpty) email,
      if (phone.isNotEmpty) phone,
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CheckoutStepper(activeStep: CheckoutStep.review),
        const SizedBox(height: 24),
        const SectionTitle(
          icon: Icons.location_on_outlined,
          title: 'Shipping To',
        ),
        const SizedBox(height: 12),
        ReviewInfoCard(
          title: name.isEmpty ? 'Shipping details' : name,
          lines: [
            if (address.isNotEmpty) address,
            if (locationLine.trim().isNotEmpty) locationLine,
            if (contactLine.trim().isNotEmpty) contactLine,
          ],
        ),
        const SizedBox(height: 22),
        const SectionTitle(
          icon: Icons.credit_card_outlined,
          title: 'Payment',
        ),
        const SizedBox(height: 12),
        const ReviewInfoCard(
          title: 'Moyasar secure payment',
          lines: [
            'Payment will be completed securely after placing the order.',
          ],
          leadingIcon: Icons.credit_card_outlined,
        ),
        const SizedBox(height: 22),
        SectionTitle(
          icon: Icons.shopping_bag_outlined,
          title: 'Order (${cart.items.length} items)',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: checkoutCardDecoration(),
          child: Column(
            children: [
              ...cart.items.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: ReviewOrderItem(
                        item: entry.value,
                        variant: entry.key,
                      ),
                    ),
                  ),
              Divider(
                color: Colors.black.withValues(alpha: 0.06),
              ),
              const SizedBox(height: 8),
              SummaryRow(
                label: 'Subtotal',
                value: 'SAR ${cart.subtotal.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 8),
              SummaryRow(
                label: 'Shipping',
                value: cart.shippingFee == 0
                    ? 'Free'
                    : 'SAR ${cart.shippingFee.toStringAsFixed(2)}',
                valueColor:
                    cart.shippingFee == 0 ? Colors.green.shade600 : null,
              ),
              const SizedBox(height: 12),
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