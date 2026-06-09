import 'package:flutter/material.dart';

import 'package:loven/features/cart/view/screens/checkout_screen.dart';
import 'package:loven/features/cart/view/widgets/checkout_shared.dart';
import 'package:loven/features/cart/view/widgets/checkout_stepper.dart';

class PaymentStep extends StatelessWidget {
  const PaymentStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CheckoutStepper(
          activeStep: CheckoutStep.payment,
        ),
        const SizedBox(height: 24),
        const SectionTitle(
          icon: Icons.lock_outline,
          title: 'Payment',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: checkoutCardDecoration(),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lock_outline),
                  SizedBox(width: 8),
                  Text(
                    'Secure Payment',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'LOVEN uses Moyasar for secure payment processing.',
              ),
              SizedBox(height: 8),
              Text(
                'You will be redirected to complete payment after reviewing your order.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}