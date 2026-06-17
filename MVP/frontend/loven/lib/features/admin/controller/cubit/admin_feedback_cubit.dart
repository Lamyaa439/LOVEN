import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/features/admin/data/repositories/admin_dashboard_repository.dart';

import 'admin_feedback_state.dart';

class AdminFeedbackCubit extends Cubit<AdminFeedbackState> {
  AdminFeedbackCubit(this._repository) : super(AdminFeedbackInitial());

  final AdminDashboardRepository _repository;

  Future<void> loadFeedback() async {
    emit(AdminFeedbackLoading());

    try {
      final feedback = await _repository.getAllFeedback();

      emit(
        AdminFeedbackLoaded(
          feedback
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList(),
        ),
      );
    } catch (e) {
      emit(AdminFeedbackError(e.toString()));
    }
  }
}