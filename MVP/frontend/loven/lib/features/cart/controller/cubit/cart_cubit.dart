import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:loven/features/cart/data/repositories/cart_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _repository;

  CartCubit(this._repository) : super(CartInitial());

  Future<void> getCart() async {
    emit(CartLoading());

    try {
      final cart = await _repository.getCart();

      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> addItem({
    required String artworkId,
    int quantity = 1,
  }) async {
    try {
      await _repository.addToCart(
        artworkId: artworkId,
        quantity: quantity,
      );

      await getCart();
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> updateItem({
    required String itemId,
    required int quantity,
  }) async {
    try {
      await _repository.updateCartItem(
        itemId: itemId,
        quantity: quantity,
      );

      await getCart();
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> removeItem({
    required String itemId,
  }) async {
    try {
      await _repository.removeCartItem(
        itemId: itemId,
      );

      await getCart();
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> clearCart() async {
    try {
      await _repository.clearCart();

      await getCart();
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
}
