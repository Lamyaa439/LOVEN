import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';

import 'package:loven/features/cart/data/repositories/cart_repository.dart';
import 'cart_state.dart';

/// Cart presentation controller — CRUD orchestration only; session gating via [AuthCubit].
class CartCubit extends Cubit<CartState> {
  CartCubit(
    this._repository, {
    AuthCubit? authCubit,
  })  : _authCubit = authCubit,
        super(CartInitial());

  final CartRepository _repository;
  final AuthCubit? _authCubit;

  bool get _hasSession {
    final auth = _authCubit;
    if (auth == null) {
      return false;
    }
    return authStateHasSession(auth.state);
  }

  /// Clears in-memory cart UI state when the LOVEN session ends.
  void resetForSignedOut() {
    if (isClosed) {
      return;
    }
    emit(CartInitial());
  }

  Future<void> getCart() async {
    if (!_hasSession) {
      resetForSignedOut();
      return;
    }

    if (isClosed) {
      return;
    }

    final hadCartLoaded = state is CartLoaded;

if (!hadCartLoaded) {
  emit(CartLoading());
}

    try {
      final cart = await _repository.getCart();

      if (isClosed) {
        return;
      }

      emit(CartLoaded(cart));
    } catch (e) {
      if (isClosed) {
        return;
      }

      if (!hadCartLoaded) {
  emit(CartError(e.toString()));
}
    }
  }

Future<void> addItem({
  required String artworkId,
  int quantity = 1,
}) async {
  if (!_hasSession || isClosed) return;

  final previousCart = state is CartLoaded ? (state as CartLoaded).cart : null;

  try {
    if (previousCart != null) {
      emit(CartLoaded(previousCart, isMutating: true));
    }

    final cart = await _repository.addToCart(
      artworkId: artworkId,
      quantity: quantity,
    );

    if (!isClosed) emit(CartLoaded(cart));
  } catch (e) {
    if (isClosed) return;

    if (previousCart != null) {
      emit(CartLoaded(previousCart));
    }

    emit(CartError(e.toString(), previousCart: previousCart));
  }
}

Future<void> updateItem({
  required String itemId,
  required int quantity,
}) async {
  if (!_hasSession || isClosed) return;

  final previousCart = state is CartLoaded ? (state as CartLoaded).cart : null;

  try {
    if (previousCart != null) {
      emit(CartLoaded(previousCart, isMutating: true));
    }

    final cart = await _repository.updateCartItem(
      itemId: itemId,
      quantity: quantity,
    );

    if (!isClosed) emit(CartLoaded(cart));
  } catch (e) {
    if (isClosed) return;

    if (previousCart != null) {
      emit(CartLoaded(previousCart));
    }

    emit(CartError(e.toString(), previousCart: previousCart));
  }
}

Future<void> removeItem({
  required String itemId,
}) async {
  if (!_hasSession || isClosed) return;

  final previousCart = state is CartLoaded ? (state as CartLoaded).cart : null;

  try {
    if (previousCart != null) {
      emit(CartLoaded(previousCart, isMutating: true));
    }

    final cart = await _repository.removeCartItem(itemId: itemId);

    if (!isClosed) emit(CartLoaded(cart));
  } catch (e) {
    if (isClosed) return;

    if (previousCart != null) {
      emit(CartLoaded(previousCart));
    }

    emit(CartError(e.toString(), previousCart: previousCart));
  }
}

Future<void> clearCart() async {
  if (!_hasSession || isClosed) return;

  final previousCart = state is CartLoaded ? (state as CartLoaded).cart : null;

  try {
    if (previousCart != null) {
      emit(CartLoaded(previousCart, isMutating: true));
    }

    final cart = await _repository.clearCart();

    if (!isClosed) emit(CartLoaded(cart));
  } catch (e) {
    if (isClosed) return;

    if (previousCart != null) {
      emit(CartLoaded(previousCart));
    }

    emit(CartError(e.toString(), previousCart: previousCart));
  }
}
}
