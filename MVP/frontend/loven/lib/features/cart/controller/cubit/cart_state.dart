import 'package:loven/features/cart/data/models/cart_model.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final CartModel cart;
  final bool isMutating;

  CartLoaded(
    this.cart, {
    this.isMutating = false,
  });
}

class CartError extends CartState {
  final String message;
  final CartModel? previousCart;

  CartError(
    this.message, {
    this.previousCart,
  });
}