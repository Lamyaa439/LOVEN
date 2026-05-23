import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/report_repository.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportRepository _reportRepository;

  ReportCubit(this._reportRepository) : super(ReportInitial());

  Future<void> submitReport({
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
  }) async {
    emit(ReportLoading());

    try {
      await _reportRepository.submitReport(
        targetType: targetType,
        targetId: targetId,
        reason: reason,
        details: details,
      );

      emit(ReportSuccess());
    } catch (e) {
      emit(ReportFailure(e.toString()));
    }
  }
}