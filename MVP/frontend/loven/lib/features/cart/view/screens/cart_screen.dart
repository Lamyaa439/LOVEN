import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/cart/data/models/cart_item_model.dart';

import '../../controller/cubit/cart_cubit.dart';
import '../../controller/cubit/cart_state.dart';
import '../../data/models/cart_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CartCubit>().getCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final itemCount =
                  state is CartLoaded ? state.cart.items.length : 0;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Cart'),
                  if (itemCount > 0) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Text(
                        '$itemCount',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
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
            if (state is CartInitial || state is CartLoading) {
              return const GalleryLoadingState(message: 'Loading cart…');
            }

            if (state is CartError) {
              return GalleryEmptyState(
                icon: Icons.error_outline,
                title: 'Could not load cart',
                subtitle: state.message,
                actionLabel: 'Retry',
                onAction: () => context.read<CartCubit>().getCart(),
              );
            }

            if (state is CartLoaded) {
              final cart = state.cart;

              if (cart.items.isEmpty) {
                return GalleryEmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Your cart is empty',
                  subtitle: 'Add artworks you love and they will appear here.',
                  actionLabel: 'Explore artworks',
                  onAction: () => context.go('/'),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        AppSpacing.lg,
                        AppSpacing.screenPadding,
                        AppSpacing.xxl,
                      ),
                      itemCount: cart.items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final item = cart.items[index];

                        return _CartItemCard(
                          item: item,
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
                    onCheckout: () {
                      context.push(AppRoutes.checkout, extra: cart);
                    },
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final CartItemModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = item.price * item.quantity;

    return LovenSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SizedBox(
              width: AppSizes.listThumbSize + AppSpacing.sm,
              height: AppSizes.listThumbSize + AppSpacing.lg,
              child: LovenArtworkImage(imageUrl: item.imageUrl),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: AppSizes.touchTargetMin,
                        minHeight: AppSizes.touchTargetMin,
                      ),
                      onPressed: onRemove,
                      icon: Icon(
                        Icons.delete_outline,
                        size: AppSizes.iconSm,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'SAR ${item.price.toStringAsFixed(2)} each',
                  style: AppTextStyles.priceMuted,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _QuantityStepper(
                      quantity: item.quantity,
                      onDecrease: onDecrease,
                      onIncrease: onIncrease,
                    ),
                    const Spacer(),
                    Text(
                      'SAR ${total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(AppSpacing.xs),
            constraints: const BoxConstraints(
              minWidth: AppSizes.touchTargetMin,
              minHeight: 32,
            ),
            onPressed: onDecrease,
            icon: Icon(
              Icons.remove,
              size: AppSizes.iconSm,
              color: AppColors.textMuted,
            ),
          ),
          Text('$quantity', style: theme.textTheme.titleSmall),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(AppSpacing.xs),
            constraints: const BoxConstraints(
              minWidth: AppSizes.touchTargetMin,
              minHeight: 32,
            ),
            onPressed: onIncrease,
            icon: Icon(
              Icons.add,
              size: AppSizes.iconSm,
              color: AppColors.brandPrimary,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.lg,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(
          bottom: AppSizes.shellFloatingNavClearance,
        ),
        child: Column(
          children: [
            _SummaryRow(
              label: 'Subtotal',
              value: 'SAR ${cart.subtotal.toStringAsFixed(2)}',
            ),
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(
              label: 'Shipping',
              value: cart.shippingFee == 0
                  ? 'Free'
                  : 'SAR ${cart.shippingFee.toStringAsFixed(2)}',
              valueColor: cart.shippingFee == 0 ? AppColors.success : null,
            ),
            const SizedBox(height: AppSpacing.md),
            _SummaryRow(
              label: 'Total',
              value: 'SAR ${cart.totalAmount.toStringAsFixed(2)}',
              large: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            LovenPrimaryButton(
              label: 'Checkout · SAR ${cart.totalAmount.toStringAsFixed(2)}',
              icon: Icons.shopping_bag_outlined,
              onPressed: onCheckout,
            ),
            const SizedBox(height: AppSpacing.sm),
            LovenSecondaryButton(
              label: 'Clear cart',
              expand: true,
              onPressed: () => context.read<CartCubit>().clearCart(),
            ),
          ],
        ),
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
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          label,
          style: large
              ? theme.textTheme.titleSmall
              : theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
        ),
        const Spacer(),
        Text(
          value,
          style: large
              ? theme.textTheme.titleLarge
              : theme.textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }
}
