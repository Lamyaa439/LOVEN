/// ========================================================================
/// Authentication Cubit
///
/// Orchestrates authentication state transitions for the UI layer.
///
/// Architectural decisions:
/// - Accepts [AuthRepository] via constructor injection — never
///   instantiates its own data-layer dependencies.
/// - FCM token retrieval is kept here (platform concern, not data concern)
///   and passed through to the repository as an optional field.
/// - Firebase Auth anonymous sign-in is used solely for guest browsing;
///   the real session is the JWT managed by [AuthRepository].
/// - Error messages from [ApiClient] arrive as `Exception("...")`.
///   [_extractMessage] unwraps them into clean UI strings.
/// ========================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:loven/features/auth/data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(AuthInitial());

  // =====================================================================
  // Session Bootstrap
  // =====================================================================

  Future<void> checkAuthStatus() async {
    final isLoggedIn =
        await _authRepository.isLoggedIn();

    if (isLoggedIn) {
      emit(AuthSuccess());
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.isAnonymous) {
      emit(AuthGuest());
      return;
    }

    emit(AuthInitial());
  }

  /// Signs in anonymously via Firebase to enable guest browsing.
  Future<void> continueAsGuest() async {
    emit(AuthLoading());

    try {
      await FirebaseAuth.instance.signInAnonymously();

      emit(AuthGuest());
    } catch (e) {
      debugPrint('Guest sign-in error: $e');

      emit(
        AuthFailure(
          'Could not enter guest mode.',
        ),
      );
    }
  }

  // =====================================================================
  // Core Auth Operations
  // =====================================================================

  /// Authenticates via the backend API and transitions to [AuthSuccess].
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      final fcmToken =
          await _getFcmTokenSafely();

      await _authRepository.login(
        email: email,
        password: password,
        fcmToken: fcmToken,
      );

      emit(AuthSuccess());
    } catch (e) {
      debugPrint('Login error: $e');

      emit(
        AuthFailure(
          _extractMessage(e),
        ),
      );
    }
  }

  /// Registers a new account via the backend API.
  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String systemRole,
  }) async {
    emit(AuthLoading());

    try {
      final fcmToken =
          await _getFcmTokenSafely();

      await _authRepository.register(
        name: name,
        email: email,
        password: password,
        systemRole: systemRole,
        fcmToken: fcmToken,
      );

      emit(AuthSuccess());
    } catch (e) {
      debugPrint('Signup error: $e');

      emit(
        AuthFailure(
          _extractMessage(e),
        ),
      );
    }
  }

  /// Logs out from the backend, clears local tokens,
  /// and signs out of Firebase.
  Future<void> logout() async {
    emit(AuthLoading());

    try {
      await _authRepository.logout();

      await FirebaseAuth.instance.signOut();

      emit(AuthGuest());
    } catch (_) {
      await FirebaseAuth.instance.signOut();

      emit(AuthGuest());
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(AuthLoading());

    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      emit(AuthSuccess());
    } catch (e) {
      emit(
        AuthFailure(
          _extractMessage(e),
        ),
      );
    }
  }

  // =====================================================================
  // Async Email Validation (used by signup page debounce)
  // =====================================================================

  /// Checks whether [email] is already registered on the backend.
  Future<bool> checkEmailExists(
    String email,
  ) async {
    try {
      return await _authRepository
          .checkEmailDuplication(email);
    } catch (e) {
      debugPrint('Email check error: $e');

      return false;
    }
  }

  // =====================================================================
  // Helpers
  // =====================================================================

  /// Retrieves the FCM device token safely.
  Future<String?> _getFcmTokenSafely() async {
    try {
      await FirebaseMessaging.instance
          .requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (!kIsWeb &&
          defaultTargetPlatform ==
              TargetPlatform.iOS) {
        final apnsToken =
            await FirebaseMessaging.instance
                .getAPNSToken();

        if (apnsToken == null) {
          return null;
        }
      }

      return await FirebaseMessaging.instance
          .getToken();
    } catch (e) {
      debugPrint('FCM token error: $e');

      return null;
    }
  }

  /// Unwraps the message from an Exception.
  String _extractMessage(
    Object error,
  ) {
    final raw = error.toString();

    const prefix = 'Exception: ';

    if (raw.startsWith(prefix)) {
      return raw.substring(prefix.length);
    }

    return raw;
  }
}