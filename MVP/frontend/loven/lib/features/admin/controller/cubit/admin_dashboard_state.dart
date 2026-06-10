abstract class AdminDashboardState {}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  AdminDashboardLoaded(this.stats);

  final Map<String, dynamic> stats;
}

class AdminDashboardFailure extends AdminDashboardState {
  AdminDashboardFailure(this.message);

  final String message;
}