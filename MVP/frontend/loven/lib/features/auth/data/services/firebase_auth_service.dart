import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper over [FirebaseAuth] for LOVEN email/password flows.
///
/// **Architectural role:** Firebase owns credentials and verification emails.
/// This service must not call the LOVEN backend or persist LOVEN JWTs.
class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  /// Creates a Firebase Auth user (email/password credentials live in Firebase).
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Signs in with Firebase email/password credentials.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sends the Firebase link-based verification email to [currentUser].
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in Firebase user to verify.',
      );
    }
    await user.sendEmailVerification();
  }

  /// Reloads the current Firebase user and returns the refreshed record.
  Future<User?> reloadUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return null;
    }
    await user.reload();
    return _firebaseAuth.currentUser;
  }

  /// Whether Firebase reports a verified email for the current user.
  bool get isEmailVerified => _firebaseAuth.currentUser?.emailVerified ?? false;

  /// Returns a fresh Firebase ID token for backend register-sync / login exchange.
  Future<String> getIdToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in Firebase user.',
      );
    }
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw FirebaseAuthException(
        code: 'no-id-token',
        message: 'Could not obtain Firebase ID token.',
      );
    }
    return token;
  }

  /// Sends a Firebase link-based password reset email.
  ///
  /// Callers should always show a generic success message regardless of outcome
  /// to avoid email enumeration (Firebase may throw for unknown addresses).
  Future<void> sendPasswordResetEmail({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  /// Signs out the Firebase session (LOVEN JWT is separate).
  Future<void> signOut() => _firebaseAuth.signOut();

  /// Re-authenticates then updates password for the signed-in email/password user.
  ///
  /// If no Firebase session exists (LOVEN JWT-only restore), signs in with the
  /// current password first, then updates — Firebase owns credential storage.
  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    var user = _firebaseAuth.currentUser;

    if (user == null) {
      await signIn(email: email, password: currentPassword);
      user = _firebaseAuth.currentUser;
    }

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Could not establish a Firebase session to change password.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email.trim(),
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}
