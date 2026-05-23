import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:loven/features/order/controller/cubit/order_cubit.dart';
import 'package:loven/features/order/controller/cubit/order_state.dart';

import '../../controller/cubit/cart_cubit.dart';
import '../../controller/cubit/cart_state.dart';
import '../../data/models/cart_model.dart';
import '../widgets/cart_item_widget.dart';
import 'package:go_router/go_router.dart';

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
        'price_at_purchase': item.price,
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CartError) {
            return Center(
              child: Text(state.message),
            );
          }

          if (state is CartLoaded) {
            final cart = CartModel.fromJson(state.cart);

            if (cart.items.isEmpty) {
              return const Center(
                child: Text('Your cart is empty'),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];

                        return CartItemWidget(
                          item: item,
                          onIncrease: () {
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
                  const SizedBox(height: 12),
                  _CartSummary(
                    cart: cart,
                    onCheckout: () => _checkout(cart),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final CartModel cart;
  final VoidCallback onCheckout;

  const _CartSummary({
    required this.cart,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, orderState) {
        final isLoading = orderState is OrderLoading;

        return Column(
          children: [
            _SummaryRow(
              label: 'Subtotal',
              value: '${cart.subtotal.toStringAsFixed(2)} SAR',
            ),
            _SummaryRow(
              label: 'Shipping',
              value: '${cart.shippingFee.toStringAsFixed(2)} SAR',
            ),
            const Divider(),
            _SummaryRow(
              label: 'Total',
              value: '${cart.totalAmount.toStringAsFixed(2)} SAR',
              isBold: true,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : onCheckout,
                child: Text(
                  isLoading ? 'Creating order...' : 'Checkout',
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
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}