import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/report_repository.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportRepository _reportRepository;

  ReportCubit(this._reportRepository) : super(ReportInitial());

  Future<bool> submitReport({
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
      return true;
    } catch (e) {
      emit(ReportFailure(e.toString()));
      return false;
    }
  }

  Future<void> loadReports() async {
  emit(ReportLoading());

  try {
    final reports = await _reportRepository.getReports();

    emit(ReportsLoaded(reports));
  } catch (e) {
    emit(ReportFailure(e.toString()));
  }
}

Future<void> updateReportStatus({
  required String reportId,
  required String status,
}) async {
  emit(ReportLoading());

  try {
    await _reportRepository.updateReportStatus(
      reportId: reportId,
      status: status,
    );

    await loadReports();
  } catch (e) {
    emit(ReportFailure(e.toString()));
  }
}

Future<void> updateArtworkStatus({
  required String artworkId,
  required String status,
}) async {
  emit(ReportLoading());

  try {
    await _reportRepository.updateArtworkStatus(
      artworkId: artworkId,
      status: status,
    );

    await loadReports();
  } catch (e) {
    emit(ReportFailure(e.toString()));
  }
}
}