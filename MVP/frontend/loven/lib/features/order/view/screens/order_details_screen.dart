import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/router_helpers.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/order/data/repositories/order_repository.dart';
import 'package:loven/features/order/view/widgets/order_item_display.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  final String orderId;
  final Map<String, dynamic>? initialOrder;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Map<String, dynamic>? _order;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _order = widget.initialOrder;
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await context.read<OrderRepository>().getOrderById(
            widget.orderId,
          );
      final payload = response['order'];

      if (!mounted) return;

      if (payload is! Map) {
        setState(() {
          _loading = false;
          _error = 'Order data is unavailable.';
        });
        return;
      }

      setState(() {
        _order = Map<String, dynamic>.from(payload);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: lovenPushedScreenBackLeading(context),
        title: const Text('Order Details'),
        centerTitle: true,
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading && _order == null) {
      return const GalleryLoadingState(message: 'Loading order…');
    }

    if (_error != null && _order == null) {
      return GalleryEmptyState(
          backgroundColor: Theme.of(context).colorScheme.surface,
        icon: Icons.error_outline_rounded,
        title: 'Could not load order',
        subtitle: _error!,
        actionLabel: 'Try again',
        onAction: _loadOrder,
      );
    }

    final order = _order;
    if (order == null) {
      return GalleryEmptyState(
          backgroundColor: Theme.of(context).colorScheme.surface,
        icon: Icons.receipt_long_outlined,
        title: 'Order not found',
      );
    }

    final orderId = order['id']?.toString() ?? widget.orderId;
    final status = order['status']?.toString() ?? 'pending';
    final createdAt = order['created_at']?.toString() ?? '';
    final subtotal = order['subtotal']?.toString() ?? '0';
    final shippingFee = order['shipping_fee']?.toString() ?? '0';
    final totalAmount = order['total_amount']?.toString() ?? '0';
    final shippingCompany =
        order['shipping_company']?.toString() ?? 'Not assigned yet';
    final trackingNumber =
        order['tracking_number']?.toString() ?? 'Not available yet';
    final items = OrderItemDisplay.listFromOrder(order);

    return RefreshIndicator(
      onRefresh: _loadOrder,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.md,
          AppSpacing.screenPadding,
          AppSpacing.xxl,
        ),
        children: [
          LovenSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
                  style: theme.textTheme.titleMedium,
                ),
                if (createdAt.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    createdAt,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                _StatusChip(status: status),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LovenSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Items', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.md),
                if (items.isEmpty)
                  Text(
                    'No item details available.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  )
                else
                  ...items.map(
                    (item) => OrderItemRow(
                      item: item,
                      thumbnailSize: AppSizes.listThumbSize + AppSpacing.lg,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LovenSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tracking', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.md),
                _DetailRow(label: 'Shipping company', value: shippingCompany),
                _DetailRow(label: 'Tracking number', value: trackingNumber),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LovenSurfaceCard(
            child: Column(
              children: [
                _DetailRow(label: 'Subtotal', value: '$subtotal SAR'),
                _DetailRow(label: 'Shipping', value: '$shippingFee SAR'),
                const Divider(height: AppSpacing.xl),
                _DetailRow(
                  label: 'Total',
                  value: '$totalAmount SAR',
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: isBold
                  ? theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.brandPrimary,
                    )
                  : theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
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
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
