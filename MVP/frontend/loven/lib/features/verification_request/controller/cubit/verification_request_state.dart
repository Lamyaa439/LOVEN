abstract class VerificationRequestState {}

class VerificationRequestInitial extends VerificationRequestState {}

class VerificationRequestLoading extends VerificationRequestState {}

class VerificationRequestSuccess extends VerificationRequestState {
  final String message;

  VerificationRequestSuccess(this.message);
}

class VerificationRequestError extends VerificationRequestState {
  final String message;

  VerificationRequestError(this.message);
}

class VerificationMyRequestLoaded extends VerificationRequestState {
  final Map<String, dynamic>? request;

  VerificationMyRequestLoaded(this.request);
}

class VerificationRequestsLoaded extends VerificationRequestState {
  final List<Map<String, dynamic>> requests;

  VerificationRequestsLoaded(this.requests);
}