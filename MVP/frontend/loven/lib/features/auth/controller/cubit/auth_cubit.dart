import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:loven/core/error/app_exception.dart';
import 'package:loven/features/auth/data/models/auth_error_codes.dart';
import 'package:loven/features/auth/data/models/auth_user.dart';
import 'package:loven/features/auth/data/repositories/auth_repository.dart';
import 'package:loven/features/auth/data/services/firebase_auth_service.dart';
import 'auth_state.dart';

/// LOVEN session orchestration — JWT state only; Firebase owns credentials.
///
/// **Session ownership:**
/// - [restoreSession] — boot entry; reads stored LOVEN JWT via [AuthRepository].
/// - [loginWithFirebase] / [signupWithFirebase] — Firebase credential flows.
/// - [ApiClient] — JWT refresh; calls [handleSessionExpired] when refresh fails.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final FirebaseAuthService _firebaseAuthService;

  Future<void>? _bootstrapFuture;

  AuthCubit({
    required AuthRepository authRepository,
    FirebaseAuthService? firebaseAuthService,
  })  : _authRepository = authRepository,
        _firebaseAuthService = firebaseAuthService ?? FirebaseAuthService(),
        super(const AuthInitial());

  /// Boot-time session restore — invoke once per app launch from [main].
  Future<void> restoreSession() {
    _bootstrapFuture ??= _restoreSession();
    return _bootstrapFuture!;
  }

  Future<void> _restoreSession() async {
    if (!await _authRepository.isLoggedIn()) {
      emit(const AuthGuest());
      return;
    }

    emit(const AuthLoading());

    try {
      final user = await _authRepository.restoreAuthenticatedUser();
      emit(AuthSuccess(user: user));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Session restore failed: $e');
      }
      await _authRepository.clearLocalSession();
      emit(const AuthGuest());
    }
  }

  Future<void> _completeAuthenticatedSession() async {
    final user = await _authRepository.getCurrentUser();
    emit(AuthSuccess(user: user));
  }

  AuthUser? get _sessionUser {
    final current = state;
    if (current is AuthSuccess) {
      return current.user;
    }
    if (current is AuthOperationFailure) {
      return current.sessionUser;
    }
    return null;
  }

  Future<void> handleSessionExpired() async {
    try {
      await _firebaseAuthService.signOut();
    } catch (_) {
      // Best-effort Firebase cleanup.
    }

    await _authRepository.clearLocalSession();
    emit(const AuthGuest());
  }

  /// Guest browsing — LOVEN unauthenticated state only; no Firebase credentials.
  ///
  /// Best-effort [FirebaseAuthService.signOut] clears a stale Firebase session
  /// from a partial login/signup without creating an anonymous Firebase user.
  Future<void> continueAsGuest() async {
    try {
      await _firebaseAuthService.signOut();
    } catch (_) {
      // Guest mode does not depend on Firebase; ignore cleanup failures.
    }
    emit(const AuthGuest());
  }

  /// Firebase sign-in → verification check → LOVEN JWT exchange → [AuthSuccess].
  Future<void> loginWithFirebase({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    try {
      await _firebaseAuthService.signIn(
        email: email,
        password: password,
      );

      final user = await _firebaseAuthService.reloadUser();
      if (!(user?.emailVerified ?? false)) {
        await _firebaseAuthService.signOut();
        emit(const AuthFailure(
          'Please verify your email. Check your inbox for the verification link.',
        ));
        return;
      }

      final idToken = await _firebaseAuthService.getIdToken();
      final fcmToken = await _getFcmTokenSafely();

      try {
        await _authRepository.loginWithFirebase(
          idToken: idToken,
          fcmToken: fcmToken,
        );
      } on EmailNotVerifiedException catch (e) {
        await _firebaseAuthService.signOut();
        emit(AuthFailure(e.message));
        return;
      }

      await _completeAuthenticatedSession();
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      await _firebaseAuthService.signOut();
      if (kDebugMode) {
        debugPrint('Login error: $e');
      }
      emit(AuthFailure(_extractMessage(e)));
    }
  }

  /// Firebase signup + LOVEN register-sync without issuing a LOVEN session.
  ///
  /// Returns email for verification navigation; re-emits [AuthGuest] on success.
  Future<String?> signupWithFirebase({
    required String name,
    required String email,
    required String password,
    required String systemRole,
  }) async {
    emit(const AuthLoading());

    try {
      await _firebaseAuthService.signUp(
        email: email,
        password: password,
      );
      await _firebaseAuthService.sendEmailVerification();

      final idToken = await _firebaseAuthService.getIdToken();
      final fcmToken = await _getFcmTokenSafely();

      final result = await _authRepository.registerSync(
        idToken: idToken,
        name: name,
        systemRole: systemRole,
        fcmToken: fcmToken,
      );

      emit(const AuthGuest());
      return result.email.isNotEmpty ? result.email : email;
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapFirebaseAuthError(e)));
      return null;
    } catch (e) {
      await _firebaseAuthService.signOut();
      if (kDebugMode) {
        debugPrint('Signup error: $e');
      }
      emit(AuthFailure(_extractMessage(e)));
      return null;
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await _firebaseAuthService.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapFirebaseAuthError(e));
    }
  }

  Future<bool> checkEmailVerified() async {
    final user = await _firebaseAuthService.reloadUser();
    return user?.emailVerified ?? false;
  }

  Future<void> signOutFirebaseOnly() => _firebaseAuthService.signOut();

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      await _firebaseAuthService.signOut();
      emit(const AuthGuest());
    } catch (_) {
      await _authRepository.clearLocalSession();
      await _firebaseAuthService.signOut();
      emit(const AuthGuest());
    }
  }

  /// Updates password via Firebase (re-auth + [FirebaseAuthService.changePassword]).
  ///
  /// LOVEN JWT session is unchanged; emits [AuthSuccess] on success for UI feedback.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final sessionUser = _sessionUser;
    if (sessionUser == null) {
      emit(const AuthFailure('You must be signed in to change your password.'));
      return;
    }

    try {
      await _firebaseAuthService.changePassword(
        email: sessionUser.email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      emit(AuthSuccess(user: sessionUser));
    } on FirebaseAuthException catch (e) {
      emit(_operationFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      emit(_operationFailure(_extractMessage(e)));
    }
  }

  Future<void> loadCurrentUser() async {
    try {
      await _completeAuthenticatedSession();
    } catch (e) {
      emit(_operationFailure(_extractMessage(e)));
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    String? profileImageUrl,
  }) async {
    try {
      final user = await _authRepository.updateProfile(
        name: name,
        email: email,
        profileImageUrl: profileImageUrl,
      );

      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(_operationFailure(_extractMessage(e)));
    }
  }

  AuthState _operationFailure(String message) {
    final sessionUser = _sessionUser;
    if (sessionUser != null) {
      return AuthOperationFailure(
        message: message,
        sessionUser: sessionUser,
      );
    }
    return AuthFailure(message);
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      return await _authRepository.checkEmailDuplication(email);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Email check error: $e');
      }
      return false;
    }
  }

  Future<String?> _getFcmTokenSafely() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();

        if (apnsToken == null) {
          return null;
        }
      }

      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM token error: $e');
      }
      return null;
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

  String _mapFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'requires-recent-login':
        return 'Please sign in again, then retry changing your password.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}
