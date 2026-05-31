import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:loven/features/order/data/repositories/order_repository.dart';
import 'order_state.dart';

/// Checkout and order-listing presentation logic.
///
/// Delegates data access to [OrderRepository] and translates backend
/// pricing-validation failures into actionable UI messages so buyers
/// refresh stale cart totals instead of retrying with outdated amounts.
class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _repository;

  /// Backend rejects checkout when client totals diverge from DB artwork prices.
  static const _pricingMismatchPattern = 'does not match server pricing';

  OrderCubit(this._repository) : super(OrderInitial());

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
  Future<void> createOrder({
    required double subtotal,
    required double shippingFee,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    emit(OrderLoading());

    try {
      final order = await _repository.createOrder(
        subtotal: subtotal,
        shippingFee: shippingFee,
        totalAmount: totalAmount,
        items: items,
      );

      emit(OrderLoaded(order));
    } catch (e) {
      final message = _mapCreateOrderError(e);

      emit(
        OrderError(
          message,
          shouldRefreshCart: _isPricingMismatchError(e.toString()),
        ),
      );
    }
  }

  Future<void> getMyOrders() async {
    emit(OrderLoading());

    try {
      final data = await _repository.getMyOrders();

      emit(OrdersLoaded(data['orders'] ?? data['data'] ?? []));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> getBuyerOrders({
    required String buyerId,
  }) async {
    emit(OrderLoading());

    try {
      final data = await _repository.getBuyerOrders(
        buyerId: buyerId,
      );

      emit(OrdersLoaded(data['orders'] ?? data['data'] ?? []));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> getArtistOrders({
    required String artistProfileId,
  }) async {
    emit(OrderLoading());

    try {
      final data = await _repository.getArtistOrders(
        artistProfileId: artistProfileId,
      );

      emit(OrdersLoaded(data['orders'] ?? data['data'] ?? []));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
  
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    String? shippingCompany,
    String? trackingNumber,
    }) async {
      emit(OrderLoading());
      try {
        final order = await _repository.updateOrderStatus(
          orderId: orderId,
          status: status,
          shippingCompany: shippingCompany,
          trackingNumber: trackingNumber,
        );
        
        emit(OrderLoaded(order));
        } catch (e) {
          emit(OrderError(e.toString()));
        }
      }
    }
