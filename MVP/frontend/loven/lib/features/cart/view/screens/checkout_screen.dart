import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/cart/controller/cubit/cart_cubit.dart';
import 'package:loven/features/cart/data/models/cart_model.dart';
import 'package:loven/features/cart/view/widgets/checkout_account_step.dart';
import 'package:loven/features/cart/view/widgets/checkout_footer.dart';
import 'package:loven/features/cart/view/widgets/checkout_shared.dart';
import 'package:loven/features/cart/view/widgets/payment_step.dart';
import 'package:loven/features/cart/view/widgets/review_step.dart';
import 'package:loven/features/home/controller/bloc/home_bloc.dart';
import 'package:loven/features/home/controller/bloc/home_event.dart';
import 'package:loven/features/order/controller/cubit/order_cubit.dart';
import 'package:loven/features/order/controller/cubit/order_state.dart';
<<<<<<< HEAD
import 'package:loven/features/payment/controller/cubit/payment_cubit.dart';
=======
import 'package:loven/features/order/view/models/order_success_extra.dart';
>>>>>>> 9f02d84a284267ff8822af9136379e2bd9b99522

enum CheckoutStep {
  account,
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
  CheckoutStep step = CheckoutStep.account;

  void _nextStep() {
    if (step == CheckoutStep.account) {
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
      setState(() => step = CheckoutStep.account);
      return;
    }

    _leaveCheckout();
  }

  void _leaveCheckout() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.cart);
  }

  void _handleAppBarBack() {
    if (step != CheckoutStep.account) {
      _previousStep();
      return;
    }

    _leaveCheckout();
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

<<<<<<< HEAD
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

=======
  String? _orderIdFromResponse(Map<String, dynamic> orderResponse) {
    final orderPayload = orderResponse['order'];
    if (orderPayload is! Map) {
      return null;
    }

    final id = Map<String, dynamic>.from(orderPayload)['id'];
    if (id == null) {
      return null;
    }

    return id.toString();
  }

>>>>>>> 9f02d84a284267ff8822af9136379e2bd9b99522
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
<<<<<<< HEAD
=======

          await context.read<CartCubit>().clearCart();

          if (!context.mounted) return;

          context.read<HomeBloc>().add(FetchHomeData());

          final authState = context.read<AuthCubit>().state;
          final userLabel = checkoutUserDisplayLabel(authState);

          context.go(
            AppRoutes.confirmOrder,
            extra: OrderSuccessExtra(
              userLabel: userLabel,
              totalAmount: widget.cart.totalAmount,
              itemCount: widget.cart.items.length,
              orderId: _orderIdFromResponse(state.order),
            ),
          );
>>>>>>> 9f02d84a284267ff8822af9136379e2bd9b99522
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
<<<<<<< HEAD
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
=======
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final userLabel = checkoutUserDisplayLabel(authState);

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Checkout'),
              leading: BackButton(onPressed: _handleAppBarBack),
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.md,
                      AppSpacing.screenPadding,
                      AppSpacing.xxl,
                    ),
                    child: switch (step) {
                      CheckoutStep.account => const CheckoutAccountStep(),
                      CheckoutStep.payment => const PaymentStep(),
                      CheckoutStep.review => ReviewStep(
                          cart: widget.cart,
                          userLabel: userLabel,
                        ),
                    },
                  ),
>>>>>>> 9f02d84a284267ff8822af9136379e2bd9b99522
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
          );
        },
      ),
    );
  }
}
