import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:loven/core/res/theme/app_colors.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/features/order/controller/cubit/order_cubit.dart';
import 'package:loven/features/order/controller/cubit/order_state.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() =>
      _OrderHistoryScreenState();
}

class _OrderHistoryScreenState
    extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();

    context.read<OrderCubit>().getMyOrders();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Order History'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is OrderError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state is OrdersLoaded) {
            if (state.orders.isEmpty) {
              return const _EmptyOrders();
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                24,
              ),
              itemCount: state.orders.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = Map<String, dynamic>.from(
                  state.orders[index] as Map,
                );

                return _OrderCard(order: order);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const _OrderCard({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final orderId =
        order['id']?.toString() ??
        order['order_id']?.toString() ??
        'Unknown';

    final status =
        order['status']?.toString() ?? 'pending';

    final total =
        order['total_amount']?.toString() ??
        order['total']?.toString() ??
        '0';

    final createdAt =
        order['created_at']?.toString() ??
        order['createdAt']?.toString() ??
        '';

    final items = order['items'];

    final itemCount = items is List
        ? items.length
        : 0;

    return InkWell(
  borderRadius: BorderRadius.circular(18),
  onTap: () {
    context.push(
      AppRoutes.ordersDetails,
      extra: order,
    );
  },
  child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor:
                  AppColors.primaryPurple.withValues(
                alpha: 0.25,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.primaryBlue,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${_shortId(orderId)}',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    createdAt.isEmpty
                        ? '$itemCount item(s)'
                        : createdAt,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(
                      color: theme.colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        
            _StatusChip(status: status),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$itemCount item(s)',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              '\$$total',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);
  }
  String _shortId(String id) {
    if (id.length <= 8) return id;
    return id.substring(0, 8);
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    Color color;

    if (normalized.contains('complete') ||
        normalized.contains('delivered')) {
      color = Colors.green;
    } else if (normalized.contains('cancel')) {
      color = Colors.red;
    } else {
      color = AppColors.deepPurple;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor:
                  AppColors.primaryPurple.withValues(
                alpha: 0.22,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No orders yet',
              style: theme.textTheme.titleMedium
                  ?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your order history will appear here once you place an order.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(
                color: theme.colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}