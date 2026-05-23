import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:loven/features/order/data/repositories/order_repository.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _repository;

  OrderCubit(this._repository) : super(OrderInitial());
  
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
      emit(OrderError(e.toString()));
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
  }) async {
    emit(OrderLoading());

    try {
      final order = await _repository.updateOrderStatus(
        orderId: orderId,
        status: status,
      );

      emit(OrderLoaded(order));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
