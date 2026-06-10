import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/core/error/app_exception.dart';
import 'package:loven/features/account/controller/cubit/account_cubit.dart';
import 'package:loven/features/account/data/repositories/account_repository.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/auth/data/models/auth_user.dart';

import 'account_state.dart';

/// Account/profile UI orchestration — load and update flows for `/account/me`.
///
/// **Ownership:** profile fetch/patch presentation state. [AuthCubit] owns
/// session lifecycle; successful mutations call [AuthCubit.syncSessionUser].
class AccountCubit extends Cubit<AccountState> {
  AccountCubit({
    required AccountRepository accountRepository,
    required AuthCubit authCubit,
  })  : _accountRepository = accountRepository,
        _authCubit = authCubit,
        super(const AccountInitial());

  final AccountRepository _accountRepository;
  final AuthCubit _authCubit;

  bool get _hasSession => authStateHasSession(_authCubit.state);

  AuthUser? get _sessionUser => authStateSessionUser(_authCubit.state);

  void _emit(AccountState state) {
    if (isClosed) {
      return;
    }
    emit(state);
  }

  /// Clears in-memory account UI state when the LOVEN session ends.
  void resetForSignedOut() {
    if (isClosed) {
      return;
    }
    _emit(const AccountInitial());
  }

  /// Loads the authenticated profile from `GET /account/me`.
  ///
  /// On success, refreshes [AuthCubit] session user via [AuthCubit.syncSessionUser].
  Future<void> loadAccount() async {
    if (!_hasSession) {
      resetForSignedOut();
      return;
    }

    if (isClosed) {
      return;
    }

    _emit(const AccountLoading());

    try {
      final user = await _accountRepository.getAccount();

      if (isClosed) {
        return;
      }

      _authCubit.syncSessionUser(user);
      _emit(AccountLoaded(user: user));
    } catch (e) {
      if (isClosed) {
        return;
      }

      _emit(AccountFailure(
        message: _extractMessage(e),
        user: _sessionUser,
      ));
    }
  }

  /// Persists profile changes via `PATCH /account/me`.
  ///
  /// On success, syncs the updated user into [AuthCubit] session state.
  Future<void> updateAccount({
    required String name,
    required String email,
    String? profileImageUrl,
  }) async {
    if (!_hasSession) {
      _emit(const AccountFailure(
        message: 'Session expired. Please sign in again.',
      ));
      return;
    }

    if (isClosed) {
      return;
    }

    try {
      final user = await _accountRepository.updateAccount(
        name: name,
        email: email,
        profileImageUrl: profileImageUrl,
      );

      if (isClosed) {
        return;
      }

      _authCubit.syncSessionUser(user);
      _emit(AccountLoaded(user: user));
    } catch (e) {
      if (isClosed) {
        return;
      }

      _emit(AccountFailure(
        message: _extractMessage(e),
        user: _sessionUser,
      ));
    }
  }

  String _extractMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }

    final raw = error.toString();
    const prefix = 'Exception: ';

    if (raw.startsWith(prefix)) {
      return raw.substring(prefix.length);
    }

    return raw;
  }

Future<void> updateRole({
  required String systemRole,
}) async {
  if (!_hasSession) {
    resetForSignedOut();
    return;
  }

  if (isClosed) {
    return;
  }

  try {
    final user = await _accountRepository.updateRole(
      systemRole: systemRole,
    );

    if (isClosed) {
      return;
    }

    _authCubit.syncSessionUser(user);
    _emit(AccountLoaded(user: user));
  } catch (e) {
    if (isClosed) {
      return;
    }

    _emit(AccountFailure(
      message: _extractMessage(e),
      user: _sessionUser,
    ));
  }
}
}