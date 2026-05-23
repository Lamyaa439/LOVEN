abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final Map<String, dynamic> cart;

  CartLoaded(this.cart);
}

class CartError extends CartState {
  final String message;

  CartError(this.message);
}
