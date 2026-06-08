import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/res/theme/app_colors.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/features/cart/controller/cubit/cart_cubit.dart';
import 'package:loven/features/cart/data/models/cart_item_model.dart';
import 'package:loven/features/cart/data/models/cart_model.dart';
import 'package:loven/features/order/controller/cubit/order_cubit.dart';
import 'package:loven/features/order/controller/cubit/order_state.dart';

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

    await context.read<OrderCubit>().createOrder(
          subtotal: widget.cart.subtotal,
          shippingFee: widget.cart.shippingFee,
          totalAmount: widget.cart.totalAmount,
          items: items,
        );
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

          await context.read<CartCubit>().clearCart();

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order created successfully')),
          );

          context.go(AppRoutes.home);
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
        backgroundColor: const Color(0xFFF8F7F8),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F7F8),
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
                  CheckoutStep.shipping => const _ShippingStep(),
                  CheckoutStep.payment => const _PaymentStep(),
                  CheckoutStep.review => _ReviewStep(cart: widget.cart),
                },
              ),
            ),
            BlocBuilder<OrderCubit, OrderState>(
              builder: (context, orderState) {
                return _CheckoutFooter(
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

class _ShippingStep extends StatelessWidget {
  const _ShippingStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CheckoutStepper(activeStep: CheckoutStep.shipping),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Tap any step to jump around',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black38,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 24),
        _SectionTitle(
          icon: Icons.local_shipping_outlined,
          title: 'Shipping Details',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              Icon(
                Icons.bookmark_border,
                color: AppColors.deepPurple,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved Addresses',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '3 addresses available',
                      style: TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black38),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _FieldSection(
          label: 'Full Name',
          child: TextFormField(
            initialValue: 'Aria Chen',
            decoration: _decoration(
              hint: 'Full name',
              icon: Icons.person_outline,
            ),
          ),
        ),
        _FieldSection(
          label: 'Email',
          child: TextFormField(
            initialValue: 'aria.chen@example.com',
            decoration: _decoration(
              hint: 'Email',
              icon: Icons.mail_outline,
            ),
          ),
        ),
        _FieldSection(
          label: 'Phone',
          child: TextFormField(
            initialValue: '(415) 555-0182',
            decoration: _decoration(
              hint: 'Phone',
              icon: Icons.phone_outlined,
            ),
          ),
        ),
        _FieldSection(
          label: 'Address',
          child: TextFormField(
            initialValue: '842 Mission Street, Apt 3B',
            decoration: _decoration(
              hint: 'Address',
              icon: Icons.location_on_outlined,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _FieldSection(
                label: 'City',
                child: TextFormField(
                  initialValue: 'San Francisco',
                  decoration: _decoration(
                    hint: 'City',
                    icon: Icons.apartment_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FieldSection(
                label: 'State',
                child: TextFormField(
                  initialValue: 'California',
                  decoration: _decoration(
                    hint: 'State',
                    icon: Icons.explore_outlined,
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _FieldSection(
                label: 'ZIP Code',
                child: TextFormField(
                  initialValue: '94103',
                  decoration: _decoration(
                    hint: 'ZIP code',
                    icon: Icons.markunread_mailbox_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FieldSection(
                label: 'Country',
                child: TextFormField(
                  initialValue: 'United States',
                  decoration: _decoration(
                    hint: 'Country',
                    icon: Icons.public_outlined,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PaymentStep extends StatelessWidget {
  const _PaymentStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CheckoutStepper(activeStep: CheckoutStep.payment),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Tap any step to jump around',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black38,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 24),
        _SectionTitle(
          icon: Icons.credit_card_outlined,
          title: 'Payment Method',
        ),
        const SizedBox(height: 18),
        const _CreditCardPreview(),
        const SizedBox(height: 18),
        _FieldSection(
          label: 'Card Number',
          child: TextFormField(
            decoration: _decoration(
              hint: '1234 5678 9012 3456',
              icon: Icons.credit_card_outlined,
            ),
          ),
        ),
        _FieldSection(
          label: 'Cardholder Name',
          child: TextFormField(
            decoration: _decoration(
              hint: 'Name on card',
              icon: Icons.person_outline,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _FieldSection(
                label: 'Expiry Date',
                child: TextFormField(
                  decoration: _decoration(
                    hint: 'MM/YY',
                    icon: Icons.date_range_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FieldSection(
                label: 'CVC',
                child: TextFormField(
                  decoration: _decoration(
                    hint: '123',
                    icon: Icons.lock_outline,
                  ),
                ),
              ),
            ),
          ],
        ),
        const _SecurePaymentNotice(),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.cart,
  });

  final CartModel cart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CheckoutStepper(activeStep: CheckoutStep.review),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Tap any step to jump around',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black38,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 24),
        _SectionTitle(
          icon: Icons.location_on_outlined,
          title: 'Shipping To',
        ),
        const SizedBox(height: 12),
        const _ReviewInfoCard(
          title: 'Aria Chen',
          lines: [
            '842 Mission Street, Apt 3B, San Francisco, California 94103',
            'aria.chen@example.com · (415) 555-0182',
          ],
        ),
        const SizedBox(height: 22),
        _SectionTitle(
          icon: Icons.credit_card_outlined,
          title: 'Payment',
        ),
        const SizedBox(height: 12),
        const _ReviewInfoCard(
          title: '•••• ••••',
          leadingIcon: Icons.credit_card_outlined,
        ),
        const SizedBox(height: 22),
        _SectionTitle(
          icon: Icons.shopping_bag_outlined,
          title: 'Order (${cart.items.length} items)',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              ...cart.items.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ReviewOrderItem(
                        item: entry.value,
                        variant: entry.key,
                      ),
                    ),
                  ),
              Divider(
                color: Colors.black.withValues(alpha: 0.06),
              ),
              const SizedBox(height: 8),
              _SummaryRow(
                label: 'Subtotal',
                value: 'SAR ${cart.subtotal.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 8),
              _SummaryRow(
                label: 'Shipping',
                value: cart.shippingFee == 0
                    ? 'Free'
                    : 'SAR ${cart.shippingFee.toStringAsFixed(2)}',
                valueColor: cart.shippingFee == 0 ? Colors.green.shade600 : null,
              ),
              const SizedBox(height: 12),
              _SummaryRow(
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

class _CheckoutStepper extends StatelessWidget {
  const _CheckoutStepper({
    required this.activeStep,
  });

  final CheckoutStep activeStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepItem(
          icon: Icons.local_shipping_outlined,
          label: 'Shipping',
          active: true,
          completed: activeStep != CheckoutStep.shipping,
        ),
        const _StepLine(),
        _StepItem(
          icon: Icons.credit_card_outlined,
          label: 'Payment',
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

class _StepLine extends StatelessWidget {
  const _StepLine();

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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.deepPurple, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}

class _FieldSection extends StatelessWidget {
  const _FieldSection({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 7),
          child,
        ],
      ),
    );
  }
}

class _CheckoutFooter extends StatelessWidget {
  const _CheckoutFooter({
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

class _CreditCardPreview extends StatelessWidget {
  const _CreditCardPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -42,
            top: -52,
            child: Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.credit_card, color: Colors.white, size: 22),
              const Spacer(),
              Text(
                '••••  ••••  ••••  ••••',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
              ),
              const SizedBox(height: 18),
              Row(
                children: const [
                  _CardMeta(label: 'CARD HOLDER', value: 'YOUR NAME'),
                  Spacer(),
                  _CardMeta(
                    label: 'EXPIRES',
                    value: 'MM/YY',
                    alignEnd: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardMeta extends StatelessWidget {
  const _CardMeta({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}

class _SecurePaymentNotice extends StatelessWidget {
  const _SecurePaymentNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: Colors.green.shade600,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your payment info is encrypted and secure. We never store your card details.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade700,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewInfoCard extends StatelessWidget {
  const _ReviewInfoCard({
    required this.title,
    this.lines = const [],
    this.leadingIcon,
  });

  final String title;
  final List<String> lines;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, color: Colors.black45, size: 18),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                ...lines.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      line,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewOrderItem extends StatelessWidget {
  const _ReviewOrderItem({
    required this.item,
    required this.variant,
  });

  final CartItemModel item;
  final int variant;

  @override
  Widget build(BuildContext context) {
    final total = item.price * item.quantity;

    return Row(
      children: [
        _ArtworkThumb(
          imageUrl: item.imageUrl,
          variant: variant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Qty ${item.quantity} × SAR ${item.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black38,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        Text(
          'SAR ${total.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF172033),
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}

class _ArtworkThumb extends StatelessWidget {
  const _ArtworkThumb({
    required this.imageUrl,
    required this.variant,
  });

  final String? imageUrl;
  final int variant;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    final gradients = [
      [AppColors.primaryPurple, AppColors.deepPurple],
      [const Color(0xFFFFF4F7), AppColors.primaryPurple],
      [const Color(0xFFEEF2FF), AppColors.primaryBlue],
    ];

    return Container(
      width: 58,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: hasImage
            ? null
            : LinearGradient(
                colors: gradients[variant % gradients.length],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasImage
          ? null
          : Icon(
              variant == 0
                  ? Icons.local_florist_outlined
                  : variant == 1
                      ? Icons.auto_awesome_rounded
                      : Icons.spa_outlined,
              color: Colors.white.withValues(alpha: 0.82),
              size: 28,
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.large = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
                fontWeight: large ? FontWeight.w900 : FontWeight.w600,
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor ?? const Color(0xFF172033),
                fontWeight: FontWeight.w900,
                fontSize: large ? 18 : 14,
              ),
        ),
      ],
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.black.withValues(alpha: 0.04),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.025),
        blurRadius: 14,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

InputDecoration _decoration({
  required String hint,
  required IconData icon,
}) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    prefixIcon: Icon(
      icon,
      size: 18,
      color: AppColors.deepPurple,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: Colors.black.withValues(alpha: 0.08),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: Colors.black.withValues(alpha: 0.08),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: AppColors.primaryBlue,
        width: 1.3,
      ),
    ),
  );
}