import 'package:flutter/material.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/widgets/loven_widgets.dart';

/// Parsed order line item for display — tolerant of API shape variations.
class OrderItemDisplay {
  const OrderItemDisplay({
    required this.quantity,
    required this.title,
    this.imageUrl,
    this.price,
    this.artworkId,
  });

  final int quantity;
  final String title;
  final String? imageUrl;
  final double? price;
  final String? artworkId;

  factory OrderItemDisplay.fromJson(Map<String, dynamic> json) {
    final artwork = json['artwork'];
    final artworkMap =
        artwork is Map ? Map<String, dynamic>.from(artwork) : null;

    return OrderItemDisplay(
      quantity: _toInt(json['quantity']),
      title: json['artwork_title']?.toString() ??
          artworkMap?['title']?.toString() ??
          json['title']?.toString() ??
          'Artwork',
      imageUrl: json['artwork_image_url']?.toString() ??
          artworkMap?['artwork_image_url']?.toString() ??
          artworkMap?['image_url']?.toString() ??
          json['image_url']?.toString(),
      price: _toDouble(json['price_at_purchase'] ?? json['price']),
      artworkId: json['artwork_id']?.toString() ??
          artworkMap?['id']?.toString(),
    );
  }

  static List<OrderItemDisplay> listFromOrder(Map<String, dynamic> order) {
    final rawItems = order['items'];
    if (rawItems is! List || rawItems.isEmpty) {
      return const [];
    }

    return rawItems
        .whereType<Map>()
        .map((item) => OrderItemDisplay.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  static int itemCountFromOrder(Map<String, dynamic> order) {
    final items = listFromOrder(order);
    if (items.isEmpty) {
      return 0;
    }

    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 1;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

/// Horizontal preview strip for order history cards.
class OrderItemPreviewStrip extends StatelessWidget {
  const OrderItemPreviewStrip({
    super.key,
    required this.items,
    this.thumbnailSize = AppSizes.listThumbSize,
  });

  final List<OrderItemDisplay> items;
  final double thumbnailSize;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: thumbnailSize,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final item = items[index];
          return _OrderItemThumbnail(
            item: item,
            size: thumbnailSize,
          );
        },
      ),
    );
  }
}

class OrderItemRow extends StatelessWidget {
  const OrderItemRow({
    super.key,
    required this.item,
    this.thumbnailSize = AppSizes.listThumbSize + AppSpacing.sm,
  });

  final OrderItemDisplay item;
  final double thumbnailSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineTotal = item.price != null ? item.price! * item.quantity : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrderItemThumbnail(item: item, size: thumbnailSize),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Qty ${item.quantity}'
                  '${item.price != null ? ' · SAR ${item.price!.toStringAsFixed(2)} each' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (lineTotal != null)
            Text(
              'SAR ${lineTotal.toStringAsFixed(2)}',
              style: theme.textTheme.titleSmall,
            ),
        ],
      ),
    );
  }
}

class _OrderItemThumbnail extends StatelessWidget {
  const _OrderItemThumbnail({
    required this.item,
    required this.size,
  });

  final OrderItemDisplay item;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        width: size,
        height: size,
        child: LovenArtworkImage(imageUrl: item.imageUrl),
      ),
    );
  }
}
