import 'package:loven/features/auth/data/models/auth_user.dart';

/// Account/profile UI state for [AccountCubit].
///
/// Session presence is owned by [AuthCubit]; this cubit manages profile load
/// and update operations only.
abstract class AccountState {
  const AccountState();
}

class AccountInitial extends AccountState {
  const AccountInitial();
}

class AccountLoading extends AccountState {
  const AccountLoading();
}

class AccountLoaded extends AccountState {
  const AccountLoaded({required this.user});

  final AuthUser user;
}

class AccountFailure extends AccountState {
  const AccountFailure({
    required this.message,
    this.user,
  });

  final String message;

  /// Previous profile when the operation failed mid-session.
  final AuthUser? user;
}
