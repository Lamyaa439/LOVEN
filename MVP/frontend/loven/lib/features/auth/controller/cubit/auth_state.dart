import 'package:loven/features/auth/data/models/auth_user.dart';

/// Router and UI session contract for [AuthCubit] emissions.
///
/// **Ownership (frozen contract):**
/// - Discriminated auth/session states below
/// - [authStateHasSession] — whether redirect guards treat the user as signed in
/// - [authStateSessionUser] — profile for signed-in routing (when applicable)
///
/// **Guest vs role:** [AuthGuest] means no LOVEN JWT session. `customer` /
/// `artist` / `admin` live on [AuthUser.systemRole] inside [AuthSuccess], not
/// as separate auth states. Role is never read from [TokenStorage] — use
/// [authStateSessionUser] for routing and authorization checks.
///
/// Session matrix (redirect policy and guards):
///
/// | State                 | authStateHasSession | authStateSessionUser |
/// |-----------------------|--------------------|----------------------|
/// | AuthInitial           | false              | null                 |
/// | AuthLoading           | false              | null                 |
/// | AuthGuest             | false              | null                 |
/// | AuthFailure           | false              | null                 |
/// | AuthSuccess           | true               | user                 |
/// | AuthOperationFailure  | sessionUser != null| sessionUser          |
abstract class AuthState {
  const AuthState();
}

/// App launch default before [AuthCubit.restoreSession] completes.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Auth operation or session restore in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated session with a loaded account profile.
class AuthSuccess extends AuthState {
  const AuthSuccess({required this.user});

  final AuthUser user;
}

/// Guest or signed-out — no authenticated LOVEN account session.
class AuthGuest extends AuthState {
  const AuthGuest();
}

/// Login/register failure when there is no authenticated session.
///
/// Router must not treat this as [AuthGuest]. Use [AuthOperationFailure] for
/// change-password, profile, or other errors while tokens remain valid.
class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;
}

/// Recoverable failure during an authenticated (or in-flight) operation.
///
/// When [sessionUser] is non-null, redirect policy keeps the user signed in
/// while UI surfaces [message].
class AuthOperationFailure extends AuthState {
  const AuthOperationFailure({
    required this.message,
    this.sessionUser,
  });

  final String message;

  /// Non-null when JWT session is still valid after the failed operation.
  final AuthUser? sessionUser;
}

/// Whether [state] represents an authenticated session for routing guards.
///
/// Prefer this over checking concrete types in router code.
bool authStateHasSession(AuthState state) {
  return switch (state) {
    AuthSuccess() => true,
    AuthOperationFailure(:final sessionUser) => sessionUser != null,
    _ => false,
  };
}

/// Account profile when [state] carries an authenticated session; else null.
AuthUser? authStateSessionUser(AuthState state) {
  return switch (state) {
    AuthSuccess(:final user) => user,
    AuthOperationFailure(:final sessionUser) => sessionUser,
    _ => null,
  };
}
