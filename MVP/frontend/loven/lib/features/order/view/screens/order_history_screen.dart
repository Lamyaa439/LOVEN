import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/router/router_helpers.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/order/controller/cubit/order_cubit.dart';
import 'package:loven/features/order/controller/cubit/order_state.dart';
import 'package:loven/features/order/view/widgets/order_item_display.dart';
import 'package:flutter/cupertino.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().getMyOrders();
  }

  Future<void> _refreshOrders() {
    return context.read<OrderCubit>().getMyOrders();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: lovenPushedScreenBackLeading(context),
        centerTitle: true,
        title: const Text('Order History'),
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const GalleryLoadingState(message: 'Loading orders…');
          }

          if (state is OrderError) {
            return GalleryEmptyState(
                backgroundColor: Theme.of(context).colorScheme.surface,
              icon: Icons.error_outline_rounded,
              title: 'Could not load orders',
              subtitle: state.message,
            );
          }

          if (state is OrdersLoaded) {
            if (state.orders.isEmpty) {
              return GalleryEmptyState(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet',
                subtitle:
                    'Your order history will appear here once you place an order.',
              );
            }

            return CustomScrollView(
  physics: const BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  ),
  slivers: [
    CupertinoSliverRefreshControl(
      onRefresh: _refreshOrders,
    ),
    SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSizes.shellFloatingNavClearance + AppSpacing.lg,
      ),
      sliver: SliverList.separated(
        itemCount: state.orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final order = Map<String, dynamic>.from(
            state.orders[index] as Map,
          );
          return _OrderCard(order: order);
        },
      ),
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

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final orderId =
        order['id']?.toString() ?? order['order_id']?.toString() ?? 'Unknown';
    final status = order['status']?.toString() ?? 'pending';
    final total =
        order['total_amount']?.toString() ?? order['total']?.toString() ?? '0';
    final createdAt =
        order['created_at']?.toString() ?? order['createdAt']?.toString() ?? '';
    final items = OrderItemDisplay.listFromOrder(order);
    final itemCount = items.isEmpty
        ? 0
        : items.fold<int>(0, (sum, item) => sum + item.quantity);

    return LovenSurfaceCard(
      onTap: () => context.push(
        AppRoutes.ordersDetails,
        extra: {'id': orderId},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${_shortId(orderId)}',
                      style: theme.textTheme.titleSmall,
                    ),
                    if (createdAt.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        createdAt,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _StatusChip(status: status),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            OrderItemPreviewStrip(
              items: items,
              thumbnailSize: AppSizes.listThumbSize + AppSpacing.sm,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                itemCount == 1 ? '1 item' : '$itemCount items',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                '$total SAR',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.brandPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _shortId(String id) {
    if (id.length <= 8) return id;
    return id.substring(0, 8);
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final Color color;

    if (normalized.contains('complete') || normalized.contains('delivered')) {
      color = AppColors.success;
    } else if (normalized.contains('cancel')) {
      color = AppColors.error;
    } else {
      color = AppColors.brandSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
