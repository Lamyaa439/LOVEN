abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentInitiated extends PaymentState {
  PaymentInitiated(this.data);

  final Map<String, dynamic> data;
}

class PaymentVerified extends PaymentState {
  PaymentVerified(this.data);

  final Map<String, dynamic> data;
}

class PaymentLoaded extends PaymentState {
  PaymentLoaded(this.data);

  final Map<String, dynamic> data;
}

class PaymentError extends PaymentState {
  PaymentError(this.message);

  final String message;
}