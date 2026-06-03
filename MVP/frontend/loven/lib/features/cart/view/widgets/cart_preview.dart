import 'package:flutter/material.dart';

import '../../../../core/res/theme/app_colors.dart';

class CartPreview extends StatelessWidget {
  const CartPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      const _CartItem(
        title: 'Ephemeral Bloom I',
        artist: 'Aria Chen',
        price: 450,
        quantity: 1,
        variant: 0,
      ),
      const _CartItem(
        title: 'Luminary Veil',
        artist: 'Aria Chen',
        price: 690,
        quantity: 2,
        variant: 1,
      ),
      const _CartItem(
        title: 'Seraphic Bloom',
        artist: 'Aria Chen',
        price: 620,
        quantity: 1,
        variant: 2,
      ),
    ];

    final subtotal = items.fold<int>(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cart',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${items.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _CartItemCard(
                  item: items[index],
                );
              },
            ),
          ),
          _CartSummary(
            subtotal: subtotal,
            shipping: 0,
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
  });

  final _CartItem item;

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
          _ArtworkThumb(variant: item.variant),
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
                      Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.black.withValues(alpha: 0.24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.artist,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _QuantityControl(quantity: item.quantity),
                      const Spacer(),
                      if (item.quantity > 1) ...[
                        Text(
                          'SAR ${item.price} each',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.black38,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        'SAR $total',
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
  });

  final int quantity;

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
          Icon(
            Icons.remove,
            size: 15,
            color: AppColors.deepPurple,
          ),
          const SizedBox(width: 16),
          Text(
            '$quantity',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.add,
            size: 15,
            color: AppColors.deepPurple,
          ),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.subtotal,
    required this.shipping,
  });

  final int subtotal;
  final int shipping;

  @override
  Widget build(BuildContext context) {
    final total = subtotal + shipping;

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
              value: 'SAR $subtotal',
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Shipping',
              value: shipping == 0 ? 'Free' : 'SAR $shipping',
              valueColor: shipping == 0 ? Colors.green.shade600 : null,
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              label: 'Total',
              value: 'SAR $total.00',
              large: true,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                label: Text('Checkout — SAR $total.00'),
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
    required this.variant,
  });

  final int variant;

  @override
  Widget build(BuildContext context) {
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
        gradient: LinearGradient(
          colors: gradients[variant % gradients.length],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
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

class _CartItem {
  const _CartItem({
    required this.title,
    required this.artist,
    required this.price,
    required this.quantity,
    required this.variant,
  });

  final String title;
  final String artist;
  final int price;
  final int quantity;
  final int variant;
}