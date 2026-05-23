import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';

class CartRepository {
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, dynamic>> getCart() async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse(ApiConstants.cart),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> addToCart({
    required String artworkId,
    required int quantity,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.post(
      Uri.parse(ApiConstants.cartItems),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'artwork_id': artworkId,
        'quantity': quantity,
      }),
    );

    print('ADD TO CART STATUS: ${response.statusCode}');
    print('ADD TO CART BODY: ${response.body}');

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.patch(
      Uri.parse('${ApiConstants.cartItems}/$itemId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'quantity': quantity,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> removeCartItem({
    required String itemId,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.delete(
      Uri.parse('${ApiConstants.cartItems}/$itemId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> clearCart() async {
    final token = await _tokenStorage.getAccessToken();

    final response = await http.delete(
      Uri.parse(ApiConstants.cart),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }
}