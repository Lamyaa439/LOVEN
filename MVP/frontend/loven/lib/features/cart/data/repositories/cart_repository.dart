import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';

class CartRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  CartRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  Future<Map<String, dynamic>> getCart() async {
    final response = await _apiClient.get(
      ApiConstants.cart,
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }

  Future<Map<String, dynamic>> addToCart({
    required String artworkId,
    required int quantity,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.cartItems,
      data: {
        'artwork_id': artworkId,
        'quantity': quantity,
      },
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }

  Future<Map<String, dynamic>> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    final response = await _apiClient.patch(
      '${ApiConstants.cartItems}/$itemId',
      data: {
        'quantity': quantity,
      },
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }

  Future<Map<String, dynamic>> removeCartItem({
    required String itemId,
  }) async {
    final response = await _apiClient.delete(
      '${ApiConstants.cartItems}/$itemId',
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }

  Future<Map<String, dynamic>> clearCart() async {
    final response = await _apiClient.delete(
      ApiConstants.cart,
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }
}