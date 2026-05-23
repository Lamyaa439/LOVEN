class CartItemModel {
  final String id;
  final String artworkId;
  final String title;
  final String? imageUrl;
  final double price;
  final double shippingFee;
  final int quantity;

  CartItemModel({
    required this.id,
    required this.artworkId,
    required this.title,
    this.imageUrl,
    required this.price,
    required this.shippingFee,
    required this.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final artwork = json['artwork'] ?? {};

    return CartItemModel(
      id: json['id'].toString(),
      artworkId: json['artwork_id']?.toString() ??
          artwork['id']?.toString() ??
          '',
      title: artwork['title']?.toString() ??
          json['title']?.toString() ??
          'Artwork',
      imageUrl: artwork['artwork_image_url']?.toString() ??
          artwork['image_url']?.toString() ??
          json['artwork_image_url']?.toString() ??
          json['image_url']?.toString(),
      price: _toDouble(
        json['price_at_purchase'] ??
            artwork['price'] ??
            json['price'],
      ),
      shippingFee: _toDouble(
        artwork['shipping_fee'] ??
            json['shipping_fee'],
      ),
      quantity: _toInt(json['quantity']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is int) {
      return value.toDouble();
    }

    if (value is double) {
      return value;
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 1;

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString()) ?? 1;
  }
}