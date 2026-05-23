abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final Map<String, dynamic> order;

  OrderLoaded(this.order);
}

class OrdersLoaded extends OrderState {
  final List<dynamic> orders;

  OrdersLoaded(this.orders);
}

class OrderSuccess extends OrderState {
  final String message;

  OrderSuccess(this.message);
}

class OrderError extends OrderState {
  final String message;

  OrderError(this.message);
}