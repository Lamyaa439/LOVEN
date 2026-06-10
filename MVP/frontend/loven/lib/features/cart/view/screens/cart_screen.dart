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
<<<<<<< HEAD
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/res/theme/app_colors.dart';
=======
>>>>>>> 9f02d84a284267ff8822af9136379e2bd9b99522

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
<<<<<<< HEAD
          actions: [
  BlocBuilder<CartCubit, CartState>(
    builder: (context, state) {
      if (state is! CartLoaded || state.cart.items.isEmpty) {
        return const SizedBox.shrink();
      }

      return TextButton(
        onPressed: () {
          context.read<CartCubit>().clearCart();
        },
        child: const Text('Clear'),
      );
    },
  ),
],
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
=======
>>>>>>> 9f02d84a284267ff8822af9136379e2bd9b99522
          centerTitle: true,
          title: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final itemCount =
                  state is CartLoaded ? state.cart.items.length : 0;

<<<<<<< HEAD
              return Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Row(
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
              color: colorScheme.primary.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.18),
              ),
            ),
            child: Text(
              '$itemCount',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ],
    ),
    const SizedBox(height: 2),
    Text(
      'Review your selected artworks',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
    ),
  ],
);
=======
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
>>>>>>> 9f02d84a284267ff8822af9136379e2bd9b99522
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
<<<<<<< HEAD
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 150),
=======
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        AppSpacing.lg,
                        AppSpacing.screenPadding,
                        AppSpacing.xxl,
                      ),
>>>>>>> 9f02d84a284267ff8822af9136379e2bd9b99522
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

<<<<<<< HEAD
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
  BoxShadow(
    color: Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.35)
        : AppColors.shadowTint,
    blurRadius: 22,
    offset: const Offset(0, 10),
  ),
],
      ),
=======
    return LovenSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
>>>>>>> 9f02d84a284267ff8822af9136379e2bd9b99522
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SizedBox(
<<<<<<< HEAD
              height: 118,
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
=======
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
>>>>>>> 9f02d84a284267ff8822af9136379e2bd9b99522
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
<<<<<<< HEAD
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
=======
>>>>>>> 9f02d84a284267ff8822af9136379e2bd9b99522
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
<<<<<<< HEAD
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, orderState) {
        final isLoading = orderState is OrderLoading;

        return Container(
  margin: const EdgeInsets.fromLTRB(16, 0, 16, 110),
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
  color: colorScheme.surface,
  borderRadius: BorderRadius.circular(24),
  border: Border(
    top: BorderSide(
      color: colorScheme.outlineVariant,
    ),
  ),
  boxShadow: [
    BoxShadow(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.black.withValues(alpha: 0.55)
          : AppColors.shadowTint,
      blurRadius: 28,
      offset: const Offset(0, 8),
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
                  valueColor: cart.shippingFee == 0 ? AppColors.success : null,
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
                      backgroundColor: AppColors.buttonPrimaryBackground,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
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
              ],
=======
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
>>>>>>> 9f02d84a284267ff8822af9136379e2bd9b99522
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
<<<<<<< HEAD

class _ArtworkThumb extends StatelessWidget {
  const _ArtworkThumb({
    required this.imageUrl,
    required this.variant,
  });

  final String? imageUrl;
  final int variant;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    final gradients = [
      [
        colorScheme.primary,
        colorScheme.secondary,
      ],
      [
        colorScheme.tertiary.withValues(alpha: 0.35),
        colorScheme.primary,
      ],
      [
        colorScheme.secondary.withValues(alpha: 0.35),
        colorScheme.primary,
      ],
    ];

    return Container(
      width: 96,
      height: 118,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.14),
              child: Icon(
                icon,
                color: colorScheme.primary,
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
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
=======
>>>>>>> 9f02d84a284267ff8822af9136379e2bd9b99522
