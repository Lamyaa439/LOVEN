import 'package:loven/features/cart/data/models/cart_item_model.dart';

class CartModel {
  final String? id;
  final List<CartItemModel> items;
  final double subtotal;
  final double shippingFee;
  final double totalAmount;

  CartModel({
    this.id,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.totalAmount,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final cartData = json['cart'] ?? {};

    final items = (json['items'] as List? ?? [])
        .map((item) => CartItemModel.fromJson(item))
        .toList();

    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    final shippingFee = items.fold<double>(
      0,
      (sum, item) => sum + item.shippingFee,
    );

    return CartModel(
      id: cartData['id']?.toString(),
      items: items,
      subtotal: subtotal,
      shippingFee: shippingFee,
      totalAmount: subtotal + shippingFee,
    );
  }
}