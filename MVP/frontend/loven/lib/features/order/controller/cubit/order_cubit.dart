import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/order/data/repositories/order_repository.dart';

import 'order_state.dart';

/// Checkout and order-listing presentation logic.
///
/// Delegates data access to [OrderRepository] and gates all protected order
/// operations behind the active LOVEN session.
class OrderCubit extends Cubit<OrderState> {
  OrderCubit(
    this._repository, {
    required AuthCubit authCubit,
  })  : _authCubit = authCubit,
        super(OrderInitial());

  final OrderRepository _repository;
  final AuthCubit _authCubit;

  /// Backend rejects checkout when client totals diverge from DB artwork prices.
  static const _pricingMismatchPattern = 'does not match server pricing';

  bool get _hasSession => authStateHasSession(_authCubit.state);

  void _emit(OrderState state) {
    if (isClosed) {
      return;
    }

    emit(state);
  }

  void resetForSignedOut() {
    if (isClosed) {
      return;
    }

    emit(OrderInitial());
  }

  bool _guardSession() {
    if (_hasSession) {
      return true;
    }

    resetForSignedOut();
    return false;
  }

  /// Returns true when [message] is a server-side pricing validation failure.
  bool _isPricingMismatchError(String message) {
    return message.contains(_pricingMismatchPattern);
  }

  /// Converts raw [ApiClient] exceptions into user-facing checkout errors.
  ///
  /// Pricing mismatches mean the cart UI showed stale totals — prompt a
  /// refresh rather than surfacing the raw backend string.
  String _mapCreateOrderError(Object error) {
    final raw = error.toString();

    if (_isPricingMismatchError(raw)) {
      return 'Prices updated — refresh cart';
    }

    return raw;
  }

  /// Creates an order from the current cart.
  ///
  /// [subtotal], [shippingFee], and [totalAmount] are validated server-side
  /// against artwork prices; line items need only `artwork_id` and `quantity`
  /// (see [OrderRepository.createOrder]).
  Future<Map<String, dynamic>?> createOrder({
    required double subtotal,
    required double shippingFee,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    if (!_guardSession()) {
      return null;
    }

    _emit(OrderLoading());

    try {
      final order = await _repository.createOrder(
        subtotal: subtotal,
        shippingFee: shippingFee,
        totalAmount: totalAmount,
        items: items,
      );

      _emit(OrderLoaded(order));
return order;
    } catch (e) {
      final message = _mapCreateOrderError(e);

      _emit(
        OrderError(
          message,
          shouldRefreshCart: _isPricingMismatchError(e.toString()),
        ),
      );
      return null;
    }
  }

  Future<void> getMyOrders() async {
    if (!_guardSession()) {
      return;
    }

    _emit(OrderLoading());

    try {
      final data = await _repository.getMyOrders();

      _emit(OrdersLoaded(data['orders'] ?? data['data'] ?? []));
    } catch (e) {
      _emit(OrderError(e.toString()));
    }
  }

  Future<void> getBuyerOrders({
    required String buyerId,
  }) async {
    if (!_guardSession()) {
      return;
    }

    _emit(OrderLoading());

    try {
      final data = await _repository.getBuyerOrders(
        buyerId: buyerId,
      );

      _emit(OrdersLoaded(data['orders'] ?? data['data'] ?? []));
    } catch (e) {
      _emit(OrderError(e.toString()));
    }
  }

  Future<void> getArtistOrders({
    required String artistProfileId,
  }) async {
    if (!_guardSession()) {
      return;
    }

    _emit(OrderLoading());

    try {
      final data = await _repository.getArtistOrders(
        artistProfileId: artistProfileId,
      );

      _emit(OrdersLoaded(data['orders'] ?? data['data'] ?? []));
    } catch (e) {
      _emit(OrderError(e.toString()));
    }
  }

Future<void> updateOrderStatus({
  required String orderId,
  required String status,
  String? shippingCompany,
  String? trackingNumber,
}) async {
  if (!_guardSession()) {
    return;
  }

  try {
    final order = await _repository.updateOrderStatus(
      orderId: orderId,
      status: status,
      shippingCompany: shippingCompany,
      trackingNumber: trackingNumber,
    );

    _emit(OrderLoaded(order));
  } catch (e) {
    _emit(OrderError(e.toString()));
  }
}
}