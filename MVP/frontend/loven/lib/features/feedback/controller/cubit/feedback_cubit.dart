import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:loven/features/feedback/data/repositories/feedback_repository.dart';
import 'feedback_state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  final FeedbackRepository _repository;

  FeedbackCubit(this._repository) : super(FeedbackInitial());

  Future<void> submitFeedback({
    required String message,
    String? subject,
  }) async {
    emit(FeedbackLoading());

    try {
      await _repository.submitFeedback(
        message: message,
        subject: subject,
      );

      emit(FeedbackSuccess('Feedback submitted successfully'));
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }
}
