import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/features/admin/data/repositories/admin_dashboard_repository.dart';

import 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  AdminDashboardCubit(this._repository)
      : super(AdminDashboardInitial());

  final AdminDashboardRepository _repository;

  Future<void> loadStats() async {
    emit(AdminDashboardLoading());

    try {
      final stats = await _repository.getStats();
      emit(AdminDashboardLoaded(stats));
    } catch (e) {
      emit(AdminDashboardFailure(e.toString()));
    }
  }

  
}