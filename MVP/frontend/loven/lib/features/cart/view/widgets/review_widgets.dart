import 'package:flutter/material.dart';

import 'package:loven/core/res/theme/app_colors.dart';
import 'package:loven/features/cart/data/models/cart_item_model.dart';
import 'package:loven/features/cart/view/widgets/checkout_shared.dart';

class ReviewInfoCard extends StatelessWidget {
  const ReviewInfoCard({
    super.key,
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
      decoration: checkoutCardDecoration(),
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

class ReviewOrderItem extends StatelessWidget {
  const ReviewOrderItem({
    super.key,
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
        ArtworkThumb(
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

class ArtworkThumb extends StatelessWidget {
  const ArtworkThumb({
    super.key,
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

class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
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