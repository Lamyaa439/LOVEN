import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/verification_request_repository.dart';
import 'verification_request_state.dart';

class VerificationRequestCubit extends Cubit<VerificationRequestState> {
  final VerificationRequestRepository _repository;

  VerificationRequestCubit(this._repository)
      : super(VerificationRequestInitial());

Future<void> submitRequest({
  required String documentType,
  required String institutionName,
  required String documentNumber,
}) async {
  emit(VerificationRequestLoading());

  try {
    await _repository.submitRequest(
      documentType: documentType,
      institutionName: institutionName,
      documentNumber: documentNumber,
    );

    await fetchMyRequest();
  } catch (e) {
    emit(VerificationRequestError(e.toString()));
  }
}

  Future<void> fetchAllRequests() async {
    emit(VerificationRequestLoading());

    try {
      final raw = await _repository.fetchAllRequests();

      final typedRequests =
          (raw as List).map((e) => Map<String, dynamic>.from(e)).toList();

      emit(VerificationRequestsLoaded(typedRequests));
    } catch (e) {
      emit(VerificationRequestError(e.toString()));
    }
  }

  Future<void> fetchMyRequest() async {
  emit(VerificationRequestLoading());

  try {
    final raw = await _repository.fetchAllRequests();

    final requests =
        (raw as List).map((e) => Map<String, dynamic>.from(e)).toList();

    final myRequest = requests.isNotEmpty ? requests.first : null;

    emit(VerificationMyRequestLoaded(myRequest));
  } catch (e) {
    emit(VerificationRequestError(e.toString()));
  }
}

  Future<void> approveRequest(String requestId) async {
    try {
      await _repository.updateRequestStatus(
        requestId: requestId,
        status: 'approved',
      );

      await fetchAllRequests();
    } catch (e) {
      emit(VerificationRequestError(e.toString()));
    }
  }

  Future<void> rejectRequest(String requestId) async {
    try {
      await _repository.updateRequestStatus(
        requestId: requestId,
        status: 'rejected',
      );

      await fetchAllRequests();
    } catch (e) {
      emit(VerificationRequestError(e.toString()));
    }
  }
}
