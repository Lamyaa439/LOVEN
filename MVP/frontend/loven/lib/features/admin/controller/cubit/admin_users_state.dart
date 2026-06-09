abstract class AdminUsersState {}

class AdminUsersInitial extends AdminUsersState {}

class AdminUsersLoading extends AdminUsersState {}

class AdminUsersLoaded extends AdminUsersState {
  AdminUsersLoaded(this.users);

  final List<dynamic> users;
}

class AdminUsersFailure extends AdminUsersState {
  AdminUsersFailure(this.message);

  final String message;
}