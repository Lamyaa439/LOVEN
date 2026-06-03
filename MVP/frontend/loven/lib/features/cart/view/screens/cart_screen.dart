import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/res/theme/app_colors.dart';
import 'package:loven/features/order/controller/cubit/order_cubit.dart';
import 'package:loven/features/order/controller/cubit/order_state.dart';

import '../../controller/cubit/cart_cubit.dart';
import '../../controller/cubit/cart_state.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/cart_item_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().getCart();
  }

  Future<void> _checkout(CartModel cart) async {
    final items = cart.items.map((item) {
      return {
        'artwork_id': item.artworkId,
        'quantity': item.quantity,
      };
    }).toList();

    await context.read<OrderCubit>().createOrder(
          subtotal: cart.subtotal,
          shippingFee: cart.shippingFee,
          totalAmount: cart.totalAmount,
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
              SnackBar(
                content: Text(state.order['error'].toString()),
              ),
            );
            return;
          }

          await context.read<CartCubit>().clearCart();

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order created successfully'),
            ),
          );

          context.go('/');
        }

        if (state is OrderError) {
          if (state.shouldRefreshCart) {
            await context.read<CartCubit>().getCart();
          }

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final itemCount =
                  state is CartLoaded ? state.cart.items.length : 0;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Cart',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  if (itemCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$itemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        body: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state is CartLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryBlue,
                ),
              );
            }

            if (state is CartError) {
              return _CartMessageView(
                icon: Icons.error_outline,
                title: 'Could not load cart',
                message: state.message,
                actionLabel: 'Retry',
                onAction: () {
                  context.read<CartCubit>().getCart();
                },
              );
            }

            if (state is CartLoaded) {
              final cart = state.cart;

              if (cart.items.isEmpty) {
                return _CartMessageView(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Your cart is empty',
                  message: 'Add artworks you love and they will appear here.',
                  actionLabel: 'Explore Artworks',
                  onAction: () {
                    context.go('/');
                  },
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                      itemCount: cart.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = cart.items[index];

                        return _CartItemCard(
                          item: item,
                          variant: index,
                          onIncrease: () {
                            if (item.quantity >= item.stockQuantity) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    item.stockQuantity == 1
                                        ? 'Only 1 item is available in stock.'
                                        : 'Only ${item.stockQuantity} items are available in stock.',
                                  ),
                                ),
                              );
                              return;
                            }

                            context.read<CartCubit>().updateItem(
                                  itemId: item.id,
                                  quantity: item.quantity + 1,
                                );
                          },
                          onDecrease: () {
                            if (item.quantity <= 1) {
                              context.read<CartCubit>().removeItem(
                                    itemId: item.id,
                                  );
                              return;
                            }

                            context.read<CartCubit>().updateItem(
                                  itemId: item.id,
                                  quantity: item.quantity - 1,
                                );
                          },
                          onRemove: () {
                            context.read<CartCubit>().removeItem(
                                  itemId: item.id,
                                );
                          },
                        );
                      },
                    ),
                  ),
                  _CartSummary(
                    cart: cart,
                    onCheckout: () => _checkout(cart),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.variant,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final CartItemModel item;
  final int variant;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final total = item.price * item.quantity;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ArtworkThumb(
            imageUrl: item.imageUrl,
            variant: variant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 92,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                      InkWell(
                        onTap: onRemove,
                        borderRadius: BorderRadius.circular(999),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.black.withValues(alpha: 0.28),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Artwork',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _QuantityControl(
                        quantity: item.quantity,
                        onIncrease: onIncrease,
                        onDecrease: onDecrease,
                      ),
                      const Spacer(),
                      Text(
                        'SAR ${total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF172033),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onDecrease,
            borderRadius: BorderRadius.circular(999),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(
                Icons.remove,
                size: 15,
                color: AppColors.deepPurple,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$quantity',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: onIncrease,
            borderRadius: BorderRadius.circular(999),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(
                Icons.add,
                size: 15,
                color: AppColors.deepPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.cart,
    required this.onCheckout,
  });

  final CartModel cart;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, orderState) {
        final isLoading = orderState is OrderLoading;

        return Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.black.withValues(alpha: 0.06),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
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
                  valueColor:
                      cart.shippingFee == 0 ? Colors.green.shade600 : null,
                ),
                const SizedBox(height: 12),
                _SummaryRow(
                  label: 'Total',
                  value: 'SAR ${cart.totalAmount.toStringAsFixed(2)}',
                  large: true,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isLoading ? null : onCheckout,
                    icon: isLoading
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.shopping_bag_outlined, size: 18),
                    label: Text(
                      isLoading
                          ? 'Creating order...'
                          : 'Checkout — SAR ${cart.totalAmount.toStringAsFixed(2)}',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
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
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          context.read<CartCubit>().clearCart();
                        },
                  child: const Text('Clear Cart'),
                ),
              ],
            ),
          ),
        );
      },
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
      [
        AppColors.primaryPurple,
        AppColors.deepPurple,
      ],
      [
        const Color(0xFFFFF4F7),
        AppColors.primaryPurple,
      ],
      [
        const Color(0xFFEEF2FF),
        AppColors.primaryBlue,
      ],
    ];

    return Container(
      width: 82,
      height: 92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? null
          : Stack(
              children: [
                Positioned(
                  top: -18,
                  right: -18,
                  child: _SoftCircle(size: 72, opacity: 0.16),
                ),
                Positioned(
                  bottom: -24,
                  left: -20,
                  child: _SoftCircle(size: 92, opacity: 0.10),
                ),
                Center(
                  child: Icon(
                    variant == 0
                        ? Icons.local_florist_outlined
                        : variant == 1
                            ? Icons.auto_awesome_rounded
                            : Icons.spa_outlined,
                    color: Colors.white.withValues(alpha: 0.82),
                    size: 34,
                  ),
                ),
              ],
            ),
    );
  }
}

class _CartMessageView extends StatelessWidget {
  const _CartMessageView({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.14),
              child: Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 7),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  const _SoftCircle({
    required this.size,
    required this.opacity,
  });

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}