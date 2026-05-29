/// ========================================================================
/// Cart Repository
///
/// Data-access layer for the authenticated user's shopping cart.
///
/// Architectural decisions:
/// - Accepts [ApiClient] via constructor injection so networking is shared
///   across the app and easily mocked in tests.
/// - Delegates all HTTP work to [ApiClient], which attaches the JWT,
///   resolves paths against `BASE_URL`, and surfaces backend errors as
///   [Exception]s — this repository does not catch or translate them.
/// - Maps successful GET responses into [CartModel]; mutation methods
///   rely on [CartCubit] to refetch the cart after each write.
/// - Endpoint paths come from [ApiConstants] and are relative to the
///   API root configured in [ApiClient].
/// ========================================================================

import 'package:loven/core/network/api_constants.dart';
import 'package:loven/features/cart/data/models/cart_model.dart';

class CartRepository {
  final ApiClient _apiClient;

  /// Creates a repository backed by the shared [apiClient] instance.
  CartRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetches the current user's cart and its line items.
  ///
  /// [includeArtwork] controls whether the backend embeds full artwork
  /// details in each item (needed for display in the cart UI).
  ///
  /// Returns a parsed [CartModel]. Throws an [Exception] from [ApiClient]
  /// on non-2xx responses (e.g. 401 unauthenticated, 404 user not found).
  Future<CartModel> getCart({bool includeArtwork = true}) async {
    final response = await _apiClient.get(
      ApiConstants.cart,
      queryParameters: {'include_artwork': includeArtwork},
    );

    return CartModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  /// Adds an artwork to the cart or increments quantity if already present.
  ///
  /// [artworkId] — UUID of the artwork to add.
  /// [quantity] — units to add (defaults to 1 at the call site).
  ///
  /// Errors (out of stock, invalid artwork) propagate from [ApiClient].
  Future<void> addToCart({
    required String artworkId,
    required int quantity,
  }) async {
    await _apiClient.post(
      ApiConstants.cartItems,
      data: {
        'artwork_id': artworkId,
        'quantity': quantity,
      },
    );
  }

  /// Updates the quantity of an existing cart line item.
  ///
  /// [itemId] — UUID of the [CartItemModel] row, not the artwork.
  /// [quantity] — new quantity; backend validates against stock.
  ///
  /// Errors propagate from [ApiClient]; callers should refetch via [getCart].
  Future<void> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    await _apiClient.patch(
      ApiConstants.cartItemById(itemId),
      data: {'quantity': quantity},
    );
  }

  /// Removes a single line item from the cart.
  ///
  /// [itemId] — UUID of the cart item to delete.
  ///
  /// Errors propagate from [ApiClient]; callers should refetch via [getCart].
  Future<void> removeCartItem({required String itemId}) async {
    await _apiClient.delete(ApiConstants.cartItemById(itemId));
  }

  /// Empties the entire cart for the authenticated user.
  ///
  /// Errors propagate from [ApiClient]; callers should refetch via [getCart].
  Future<void> clearCart() async {
    await _apiClient.delete(ApiConstants.cart);
  }
}
