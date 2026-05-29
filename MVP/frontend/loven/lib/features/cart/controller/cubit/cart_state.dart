import 'package:loven/features/cart/data/models/cart_model.dart';

/// Represents the cart feature's UI state as emitted by [CartCubit].
///
/// States form a simple lifecycle: [CartInitial] → [CartLoading] →
/// [CartLoaded] or [CartError]. [CartLoaded] carries a typed [CartModel]
/// produced by [CartRepository.getCart], keeping the presentation layer
/// free of raw JSON maps.
abstract class CartState {}

/// Default state before the first fetch or after cubit creation.
class CartInitial extends CartState {}

/// Emitted while [CartRepository] is fetching or mutating cart data.
class CartLoading extends CartState {}

/// Cart successfully loaded and ready to render.
///
/// [cart] — parsed domain model with items, subtotal, shipping, and total.
class CartLoaded extends CartState {
  final CartModel cart;

  CartLoaded(this.cart);
}

/// A cart operation failed; [message] is the user-facing error string
/// (typically from [ApiClient]'s centralized error handler).
class CartError extends CartState {
  final String message;

  CartError(this.message);
}
