import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/features/admin/data/repositories/admin_users_repository.dart';

import 'admin_users_state.dart';

class AdminUsersCubit extends Cubit<AdminUsersState> {
  AdminUsersCubit(this._repository) : super(AdminUsersInitial());

  final AdminUsersRepository _repository;

  Future<void> loadUsers() async {
    emit(AdminUsersLoading());

    try {
      final users = await _repository.getUsers();
      emit(AdminUsersLoaded(users));
    } catch (e) {
      emit(AdminUsersFailure(e.toString()));
    }
  }

  Future<void> updateUserStatus({
    required String userId,
    required bool isActive,
  }) async {
    emit(AdminUsersLoading());

    try {
      await _repository.updateUserStatus(
        userId: userId,
        isActive: isActive,
      );

      await loadUsers();
    } catch (e) {
      emit(AdminUsersFailure(e.toString()));
    }
  }
}