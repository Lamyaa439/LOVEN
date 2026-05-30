import 'package:flutter/material.dart';

import 'package:loven/core/res/theme/app_colors.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final orderId = order['id']?.toString() ?? 'Unknown';
    final status = order['status']?.toString() ?? 'pending';
    final createdAt = order['created_at']?.toString() ?? '';
    final subtotal = order['subtotal']?.toString() ?? '0';
    final shippingFee = order['shipping_fee']?.toString() ?? '0';
    final totalAmount = order['total_amount']?.toString() ?? '0';
    final shippingCompany =
        order['shipping_company']?.toString() ?? 'Not assigned yet';
    final trackingNumber =
        order['tracking_number']?.toString() ?? 'Not available yet';

    final items = order['items'] is List
        ? order['items'] as List
        : const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${orderId.substring(0, 8)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(createdAt),
                const SizedBox(height: 12),
                _StatusChip(status: status),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tracking',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  label: 'Shipping company',
                  value: shippingCompany,
                ),
                _DetailRow(
                  label: 'Tracking number',
                  value: trackingNumber,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Items',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Text(
                    'No item details available.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  )
                else
                  ...items.map((item) {
                    final map = Map<String, dynamic>.from(item as Map);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        '${map['quantity'] ?? 1} × ${map['artwork_title'] ?? map['title'] ?? 'Artwork'}',
                      ),
                    );
                  }),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _InfoCard(
            child: Column(
              children: [
                _DetailRow(label: 'Subtotal', value: '$subtotal SAR'),
                _DetailRow(label: 'Shipping', value: '$shippingFee SAR'),
                const Divider(),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: child,
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              color: isBold ? AppColors.primaryBlue : null,
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: AppColors.deepPurple,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}