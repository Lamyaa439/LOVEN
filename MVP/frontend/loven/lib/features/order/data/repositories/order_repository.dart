import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';

class OrderRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  OrderRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

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
        'items': items,
      },
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }

  Future<Map<String, dynamic>> getMyOrders() async {
    final response = await _apiClient.get(
      ApiConstants.myOrders,
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }

  Future<Map<String, dynamic>> getBuyerOrders({
    required String buyerId,
  }) async {
    final response = await _apiClient.get(
      '${ApiConstants.orders}buyer/$buyerId',
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }

  Future<Map<String, dynamic>> getArtistOrders({
    required String artistProfileId,
  }) async {
    final response = await _apiClient.get(
      '${ApiConstants.orders}artist/$artistProfileId',
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }

Future<Map<String, dynamic>> updateOrderStatus({
  required String orderId,
  required String status,
  String? shippingCompany,
  String? trackingNumber,
}) async {
  final response = await _apiClient.patch(
    '${ApiConstants.orders}$orderId/status',
    data: {
      'status': status,
      if (shippingCompany != null)
        'shipping_company': shippingCompany,
      if (trackingNumber != null)
        'tracking_number': trackingNumber,
    },
  );

  return Map<String, dynamic>.from(response.data);
}
}