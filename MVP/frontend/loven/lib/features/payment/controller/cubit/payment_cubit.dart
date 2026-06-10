import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/payment/data/repositories/payment_repository.dart';

import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit(
    this._repository, {
    required AuthCubit authCubit,
  })  : _authCubit = authCubit,
        super(PaymentInitial());

  final PaymentRepository _repository;
  final AuthCubit _authCubit;

  bool get _hasSession => authStateHasSession(_authCubit.state);

  bool _guardSession() {
    if (_hasSession) return true;

    emit(PaymentInitial());
    return false;
  }

  Future<Map<String, dynamic>?> initiatePayment({
    required String orderId,
  }) async {
    if (!_guardSession()) return null;

    emit(PaymentLoading());

    try {
      final data = await _repository.initiatePayment(orderId: orderId);
      emit(PaymentInitiated(data));
      return data;
    } catch (e) {
      emit(PaymentError(e.toString()));
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyPayment({
    required String orderId,
    required String moyasarPaymentId,
  }) async {
    if (!_guardSession()) return null;

    emit(PaymentLoading());

    try {
      final data = await _repository.verifyPayment(
        orderId: orderId,
        moyasarPaymentId: moyasarPaymentId,
      );

      emit(PaymentVerified(data));
      return data;
    } catch (e) {
      emit(PaymentError(e.toString()));
      return null;
    }
  }

  Future<void> getPayment({
    required String orderId,
  }) async {
    if (!_guardSession()) return;

    emit(PaymentLoading());

    try {
      final data = await _repository.getPayment(orderId: orderId);
      emit(PaymentLoaded(data));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  void reset() {
    emit(PaymentInitial());
  }
}