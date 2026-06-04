import 'package:loven/features/auth/data/models/user_model.dart';

/// Application auth/session states consumed by the router and auth-aware UI.
///
/// Session vs error:
/// - [AuthGuest] — no LOVEN JWT session (browse as guest or signed out).
/// - [AuthSuccess] — authenticated; [user] is always present.
/// - [AuthFailure] — credential/sign-up flow failed; **no** active session.
/// - [AuthOperationFailure] — action failed while a session may still exist;
///   router treats [sessionUser] like [AuthSuccess] for guards.
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

  final UserModel user;
}

/// Guest or signed-out — no authenticated LOVEN account session.
class AuthGuest extends AuthState {
  const AuthGuest();
}

/// Login/register/guest-entry failure when there is no authenticated session.
///
/// Do not use for change-password or profile errors while tokens remain valid;
/// use [AuthOperationFailure] instead so the router does not treat this as guest.
class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;
}

/// Recoverable failure during an authenticated (or in-flight) operation.
///
/// When [sessionUser] is non-null, redirect policy keeps treating the user as
/// signed in even though UI should surface [message].
class AuthOperationFailure extends AuthState {
  const AuthOperationFailure({
    required this.message,
    this.sessionUser,
  });

  final String message;

  /// Non-null when JWT session is still valid after the failed operation.
  final UserModel? sessionUser;
}

/// Whether [state] represents an authenticated session for routing guards.
bool authStateHasSession(AuthState state) {
  return switch (state) {
    AuthSuccess() => true,
    AuthOperationFailure(:final sessionUser) => sessionUser != null,
    _ => false,
  };
}

/// Account profile when [state] carries an authenticated session.
UserModel? authStateSessionUser(AuthState state) {
  return switch (state) {
    AuthSuccess(:final user) => user,
    AuthOperationFailure(:final sessionUser) => sessionUser,
    _ => null,
  };
}
