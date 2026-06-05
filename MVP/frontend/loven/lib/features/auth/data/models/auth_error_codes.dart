/// Stable backend auth error codes from LOVEN `POST /auth/firebase/login`.
abstract final class AuthErrorCodes {
  AuthErrorCodes._();

  static const String emailNotVerified = 'email_not_verified';
}

/// Thrown when LOVEN rejects the Firebase login exchange because email is unverified.
///
/// Caught in [AuthCubit.loginWithFirebase] to keep the user on the login screen
/// without persisting a LOVEN JWT.
class EmailNotVerifiedException implements Exception {
  const EmailNotVerifiedException([
    this.message = 'Please verify your email before signing in.',
  ]);

  final String message;

  @override
  String toString() => message;
}
