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
import 'package:loven/features/order/view/models/order_success_extra.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moyasar/moyasar.dart';
import 'package:loven/features/payment/controller/cubit/payment_cubit.dart';
import 'package:loven/features/payment/controller/cubit/payment_state.dart';
import 'package:loven/features/payment/pending_payment_store.dart';
import 'package:loven/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final pendingOrderId = await PendingPaymentStore.readOrderId();
    if (pendingOrderId != null) {
      final resumed = await _initiateAndOpenPayment(orderId: pendingOrderId);
      if (resumed) {
        return;
      }

      if (_shouldResetPendingOrder()) {
        await PendingPaymentStore.clear();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.paymentExpired)),
        );
      } else {
        return;
      }
    }

    final items = widget.cart.items.map((item) {
      return {
        'artwork_id': item.artworkId,
        'quantity': item.quantity,
      };
    }).toList();

    final orderResponse = await context.read<OrderCubit>().createOrder(
          subtotal: widget.cart.subtotal,
          shippingFee: widget.cart.shippingFee,
          totalAmount: widget.cart.totalAmount,
          items: items,
        );

    if (!mounted || orderResponse == null) return;

    final orderId = _orderIdFromResponse(orderResponse);

    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotReadOrderId)),
      );
      return;
    }

    await PendingPaymentStore.saveOrderId(orderId);
    await _initiateAndOpenPayment(orderId: orderId);
  }

  Future<bool> _initiateAndOpenPayment({
    required String orderId,
  }) async {
    final paymentResponse = await context.read<PaymentCubit>().initiatePayment(
          orderId: orderId,
        );

    if (!mounted || paymentResponse == null) return false;

    final amountHalalah = paymentResponse['expected_amount_halalah'] as int? ??
        (widget.cart.totalAmount * 100).round();

    await _openMoyasarPaymentSheet(
      orderId: orderId,
      amountHalalah: amountHalalah,
    );
    return true;
  }

  String? _orderIdFromResponse(Map<String, dynamic> orderResponse) {
    final orderPayload = orderResponse['order'];

    if (orderPayload is! Map) {
      return null;
    }

    final id = Map<String, dynamic>.from(orderPayload)['id'];
    return id?.toString();
  }

  Future<void> _openMoyasarPaymentSheet({
    required String orderId,
    required int amountHalalah,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final publishableKey = dotenv.env['MOYASAR_PUBLISHABLE_KEY'] ?? '';

    if (publishableKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Moyasar publishable key is missing')),
      );
      return;
    }

    final config = PaymentConfig(
      publishableApiKey: publishableKey,
      amount: amountHalalah,
      currency: 'SAR',
      description: 'LOVEN order $orderId',
      metadata: {
        'order_id': orderId,
        'source': 'loven_flutter',
      },
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: CreditCard(
              config: config,
              onPaymentResult: (result) async {
                if (result is PaymentResponse) {
                  if (_shouldAttemptVerification(result)) {
                    Navigator.of(sheetContext).pop();

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.confirmingPayment)),
                    );

                    await _verifyMoyasarPayment(
                      orderId: orderId,
                      moyasarPaymentId: result.id,
                    );
                    return;
                  }

                  if (result.status == PaymentStatus.failed) {
                    Navigator.of(sheetContext).pop();

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.paymentFailed)),
                    );
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _verifyMoyasarPayment({
    required String orderId,
    required String moyasarPaymentId,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final verifyResponse = await context.read<PaymentCubit>().verifyPayment(
          orderId: orderId,
          moyasarPaymentId: moyasarPaymentId,
        );

    if (!mounted || verifyResponse == null) return;

    final paymentPayload = verifyResponse['payment'];
    final payment = paymentPayload is Map
        ? Map<String, dynamic>.from(paymentPayload)
        : <String, dynamic>{};

    final paymentStatus = payment['status']?.toString().toLowerCase();
    final verified = paymentStatus == 'paid' ||
        verifyResponse['message']
                ?.toString()
                .toLowerCase()
                .contains('verified') ==
            true;

    if (!verified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.paymentNotConfirmed)),
      );
      return;
    }

    await context.read<CartCubit>().clearCart();
    await PendingPaymentStore.clear();

    if (!mounted) return;

    context.read<HomeBloc>().add(FetchHomeData());

    final authState = context.read<AuthCubit>().state;
    final userLabel = checkoutUserDisplayLabel(authState);

    context.go(
      AppRoutes.confirmOrder,
      extra: OrderSuccessExtra(
        userLabel: userLabel,
        totalAmount: widget.cart.totalAmount,
        itemCount: widget.cart.items.length,
        orderId: orderId,
      ),
    );
  }

  bool _isSuccessfulPaymentStatus(PaymentStatus status) {
    return status == PaymentStatus.paid ||
        status == PaymentStatus.captured ||
        status == PaymentStatus.authorized;
  }

  bool _shouldAttemptVerification(PaymentResponse result) {
    if (_isSuccessfulPaymentStatus(result.status)) {
      return result.id.isNotEmpty;
    }

    // In 3DS sandbox flows, SDK may surface "failed" while gateway state is paid.
    // Backend verification is the source of truth whenever we have a payment id.
    return result.status == PaymentStatus.failed && result.id.isNotEmpty;
  }

  bool _shouldResetPendingOrder() {
    final paymentState = context.read<PaymentCubit>().state;
    if (paymentState is! PaymentError) {
      return false;
    }

    final message = paymentState.message.toLowerCase();
    return message.contains('order not found') ||
        message.contains('forbidden') ||
        message.contains('invalid order') ||
        message.contains('invalid order or buyer id format');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocListener(
      listeners: [
        BlocListener<OrderCubit, OrderState>(
          listener: (context, state) async {
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
        ),
        BlocListener<PaymentCubit, PaymentState>(
          listener: (context, state) {
            if (state is PaymentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final userLabel = checkoutUserDisplayLabel(authState);

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              centerTitle: true,
              title: Text(l10n.checkout),
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
