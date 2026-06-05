import 'package:flutter/material.dart';

import 'package:loven/features/cart/data/models/cart_item_model.dart';
import 'package:loven/core/res/responsive/responsive_extensions.dart';

class CartItemWidget extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final imageSize = context.responsive(
      mobile: 72,
      tablet: 80,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(
          context.responsive(
            mobile: 10,
            tablet: 12,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.imageUrl == null || item.imageUrl!.isEmpty
                  ? Container(
                      width: imageSize,
                      height: imageSize,
                      color: theme.colorScheme.surface,
                      child: const Icon(Icons.image_not_supported_outlined),
                    )
                  : Image.network(
                      item.imageUrl!,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: context.responsive(
                        mobile: 14,
                        tablet: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.price.toStringAsFixed(2)} SAR',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: item.quantity > 1 ? onDecrease : null,
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          size: 20,
                        ),
                      ),
                      Text(item.quantity.toString()),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: onIncrease,
                        icon: const Icon(
                          Icons.add_circle_outline,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              onPressed: onRemove,
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}