import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight checkout session storage to avoid creating duplicate pending orders.
abstract final class PendingPaymentStore {
  static const _pendingOrderIdKey = 'pending_payment_order_id';

  static Future<void> saveOrderId(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingOrderIdKey, orderId);
  }

  static Future<String?> readOrderId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_pendingOrderIdKey);
    if (id == null || id.trim().isEmpty) {
      return null;
    }
    return id.trim();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingOrderIdKey);
  }
}
