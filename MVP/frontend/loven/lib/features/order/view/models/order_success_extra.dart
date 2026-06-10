/// Route extra for [OrderSuccessScreen] after checkout completes.
class OrderSuccessExtra {
  const OrderSuccessExtra({
    required this.userLabel,
    required this.totalAmount,
    required this.itemCount,
    this.orderId,
  });

  final String userLabel;
  final double totalAmount;
  final int itemCount;
  final String? orderId;
}
