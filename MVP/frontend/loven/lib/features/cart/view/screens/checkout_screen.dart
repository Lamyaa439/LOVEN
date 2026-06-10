import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/router/app_routes.dart';
import 'package:loven/features/cart/controller/cubit/cart_cubit.dart';
import 'package:loven/features/cart/data/models/cart_model.dart';
import 'package:loven/features/cart/view/widgets/checkout_footer.dart';
import 'package:loven/features/cart/view/widgets/payment_step.dart';
import 'package:loven/features/cart/view/widgets/review_step.dart';
import 'package:loven/features/cart/view/widgets/shipping_step.dart';
import 'package:loven/features/order/controller/cubit/order_cubit.dart';
import 'package:loven/features/order/controller/cubit/order_state.dart';
import 'package:loven/features/payment/controller/cubit/payment_cubit.dart';

enum CheckoutStep {
  shipping,
  payment,
  review,
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.cart,
  });

  final CartModel cart;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  CheckoutStep step = CheckoutStep.shipping;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final regionController = TextEditingController();
  final zipController = TextEditingController();

  String? selectedCountry;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    regionController.dispose();
    zipController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (step == CheckoutStep.shipping) {
      setState(() => step = CheckoutStep.payment);
      return;
    }

    if (step == CheckoutStep.payment) {
      setState(() => step = CheckoutStep.review);
      return;
    }

    _placeOrder();
  }

  void _previousStep() {
    if (step == CheckoutStep.review) {
      setState(() => step = CheckoutStep.payment);
      return;
    }

    if (step == CheckoutStep.payment) {
      setState(() => step = CheckoutStep.shipping);
      return;
    }

    context.pop();
  }

Future<void> _placeOrder() async {
  final items = widget.cart.items.map((item) {
    return {
      'artwork_id': item.artworkId,
      'quantity': item.quantity,
    };
  }).toList();

  final orderResponse =
      await context.read<OrderCubit>().createOrder(
            subtotal: widget.cart.subtotal,
            shippingFee: widget.cart.shippingFee,
            totalAmount: widget.cart.totalAmount,
            items: items,
          );

  if (!mounted || orderResponse == null) {
    return;
  }

  final orderId =
      orderResponse['order']?['id']?.toString();

  if (orderId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to create order'),
      ),
    );
    return;
  }

  final paymentResponse =
      await context.read<PaymentCubit>().initiatePayment(
            orderId: orderId,
          );

  if (!mounted || paymentResponse == null) {
    return;
  }

  debugPrint('Payment initiated: $paymentResponse');

  // NEXT STEP:
  // Open Moyasar payment sheet here
}

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listener: (context, state) async {
        if (state is OrderLoaded) {
          final hasError = state.order['error'] != null;

          if (hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.order['error'].toString())),
            );
            return;
          }
        }

        if (state is OrderError) {
          if (state.shouldRefreshCart) {
            await context.read<CartCubit>().getCart();
          }

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Checkout',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                child: switch (step) {
                  CheckoutStep.shipping => ShippingStep(
                      nameController: nameController,
                      emailController: emailController,
                      phoneController: phoneController,
                      addressController: addressController,
                      cityController: cityController,
                      regionController: regionController,
                      zipController: zipController,
                      selectedCountry: selectedCountry,
                      onCountryChanged: (value) {
                        setState(() {
                          selectedCountry = value;
                        });
                      },
                    ),
                  CheckoutStep.payment => const PaymentStep(),
                  CheckoutStep.review => ReviewStep(
                      cart: widget.cart,
                      name: nameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                      address: addressController.text,
                      city: cityController.text,
                      region: regionController.text,
                      zipCode: zipController.text,
                      country: selectedCountry ?? '',
                    ),
                },
              ),
            ),
            BlocBuilder<OrderCubit, OrderState>(
              builder: (context, orderState) {
                return CheckoutFooter(
                  step: step,
                  cart: widget.cart,
                  isLoading: orderState is OrderLoading,
                  onNext: _nextStep,
                  onBack: _previousStep,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}