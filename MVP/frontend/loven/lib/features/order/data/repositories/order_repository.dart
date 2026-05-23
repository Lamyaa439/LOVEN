import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';

class OrderRepository {
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, dynamic>> createOrder({
    required double subtotal,
    required double shippingFee,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.post(
      Uri.parse(ApiConstants.orders),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'subtotal': subtotal,
        'shipping_fee': shippingFee,
        'total_amount': totalAmount,
        'items': items,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getMyOrders() async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse(ApiConstants.myOrders),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getBuyerOrders({
    required String buyerId,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse('${ApiConstants.orders}buyer/$buyerId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getArtistOrders({
    required String artistProfileId,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse('${ApiConstants.orders}artist/$artistProfileId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.patch(
      Uri.parse('${ApiConstants.orders}$orderId/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status': status,
      }),
    );

    return jsonDecode(response.body);
  }
}