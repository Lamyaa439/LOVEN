abstract class AdminFeedbackState {}

class AdminFeedbackInitial extends AdminFeedbackState {}

class AdminFeedbackLoading extends AdminFeedbackState {}

class AdminFeedbackLoaded extends AdminFeedbackState {
  AdminFeedbackLoaded(this.feedback);

  final List<Map<String, dynamic>> feedback;
}

class AdminFeedbackError extends AdminFeedbackState {
  AdminFeedbackError(this.message);

  final String message;
}