import 'package:loven/core/network/api_constants.dart';

class PaymentRepository {
  PaymentRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Map<String, dynamic> _asMap(dynamic data) {
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> initiatePayment({
    required String orderId,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.paymentsInitiate(orderId),
      data: {},
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String moyasarPaymentId,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.paymentsVerify(orderId),
      data: {
        'moyasar_payment_id': moyasarPaymentId,
      },
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> getPayment({
    required String orderId,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.paymentsGet(orderId),
    );

    return _asMap(response.data);
  }
}