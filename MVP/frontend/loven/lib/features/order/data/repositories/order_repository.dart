/// ========================================================================
/// Order Repository
///
/// Data-access layer for buyer checkout and order lifecycle (list, status).
///
/// Architectural decisions:
/// - Accepts [ApiClient] via constructor injection so auth headers, base URL,
///   and error handling stay centralized and mockable.
/// - Delegates all HTTP work to [ApiClient]; this repository does not catch
///   or translate exceptions.
/// - [createOrder] sends client-computed totals for server-side validation
///   but strips item-level prices — the backend always prices line items
///   from artwork records in the database.
/// - `buyer_id` is never sent; the Flask route derives it from the JWT.
/// - Endpoint paths come from [ApiConstants] relative to [ApiClient]'s base.
/// ========================================================================

import 'package:loven/core/network/api_constants.dart';

class OrderRepository {
  final ApiClient _apiClient;

  /// Creates a repository backed by the shared [apiClient] instance.
  OrderRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Reduces checkout line items to the fields the backend accepts.
  ///
  /// The API expects only `artwork_id` and `quantity` per item. Any
  /// client-supplied `price_at_purchase` values are discarded so pricing
  /// authority remains on the server.
  List<Map<String, dynamic>> _normalizeOrderItems(
    List<Map<String, dynamic>> items,
  ) {
    return items
        .map(
          (item) => {
            'artwork_id': item['artwork_id'],
            'quantity': item['quantity'],
          },
        )
        .toList();
  }

  Map<String, dynamic> _asMap(dynamic data) {
    return Map<String, dynamic>.from(data as Map);
  }

  /// Creates an order for the authenticated buyer.
  ///
  /// [subtotal], [shippingFee], and [totalAmount] are sent so the backend
  /// can reject tampered totals against server-computed artwork prices.
  /// [items] may include extra keys from the cart UI; only `artwork_id`
  /// and `quantity` are forwarded.
  ///
  /// Returns the full JSON body (typically `{"message": ..., "order": ...}`).
  /// Errors propagate from [ApiClient].
  Future<Map<String, dynamic>> createOrder({
    required double subtotal,
    required double shippingFee,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.orders,
      data: {
        'subtotal': subtotal,
        'shipping_fee': shippingFee,
        'total_amount': totalAmount,
        'items': _normalizeOrderItems(items),
      },
    );

    return _asMap(response.data);
  }

  /// Lists orders for the authenticated buyer (`GET /orders/mine`).
  Future<Map<String, dynamic>> getMyOrders() async {
    final response = await _apiClient.get(ApiConstants.myOrders);

    return _asMap(response.data);
  }

  /// Lists orders for a specific buyer (admin or self only).
  Future<Map<String, dynamic>> getBuyerOrders({
    required String buyerId,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.ordersByBuyer(buyerId),
    );

    return _asMap(response.data);
  }

  /// Lists incoming orders for an artist profile.
  Future<Map<String, dynamic>> getArtistOrders({
    required String artistProfileId,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.ordersByArtist(artistProfileId),
    );

    return _asMap(response.data);
  }

  /// Updates shipment status for an order (artist or admin).
Future<Map<String, dynamic>> updateOrderStatus({
  required String orderId,
  required String status,
  String? shippingCompany,
  String? trackingNumber,
}) async {
  final response = await _apiClient.patch(
    ApiConstants.orderStatus(orderId),
    data: {
      'status': status,
      if (shippingCompany != null && shippingCompany.isNotEmpty)
        'shipping_company': shippingCompany,
      if (trackingNumber != null && trackingNumber.isNotEmpty)
        'tracking_number': trackingNumber,
    },
  );

  return _asMap(response.data);
}
}
