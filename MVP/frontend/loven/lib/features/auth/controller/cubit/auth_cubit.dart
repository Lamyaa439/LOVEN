import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:loven/core/error/app_exception.dart';
import 'package:loven/features/auth/data/models/user_model.dart';
import 'package:loven/features/auth/data/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Auth/session orchestration for the app UI and router.
///
/// **Session ownership:**
/// - [restoreSession] — single boot entry (from [main]); emits [AuthState] only.
/// - [AuthRepository] — token presence ([isLoggedIn]), profile load, credentials.
/// - [ApiClient] — JWT refresh on 401; calls [handleSessionExpired] when refresh fails.
///
/// This cubit does not read [TokenStorage] or call refresh endpoints directly.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  /// Ensures [restoreSession] runs at most once per app launch.
  Future<void>? _bootstrapFuture;

  AuthCubit({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthInitial());

  /// Boot-time session restore — invoke once per app launch from [main].
  ///
  /// [SplashScreen] must not call this; routing waits on [AuthCubit.stream].
  Future<void> restoreSession() {
    _bootstrapFuture ??= _restoreSession();
    return _bootstrapFuture!;
  }

  /// @deprecated Use [restoreSession].
  Future<void> checkAuthStatus() => restoreSession();

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

  /// Hydrates [AuthSuccess] after login, register, or profile-changing operations.
  Future<void> _completeAuthenticatedSession() async {
    final user = await _authRepository.getCurrentUser();
    emit(AuthSuccess(user: user));
  }

  UserModel? get _sessionUser {
    final current = state;
    if (current is AuthSuccess) {
      return current.user;
    }
    if (current is AuthOperationFailure) {
      return current.sessionUser;
    }
    return null;
  }

  /// Invoked by [ApiClient] when refresh fails after a 401.
  Future<void> handleSessionExpired() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // Best-effort Firebase cleanup.
    }

    await _authRepository.clearLocalSession();
    emit(const AuthGuest());
  }

  Future<void> continueAsGuest() async {
    emit(const AuthLoading());

    try {
      await FirebaseAuth.instance.signInAnonymously();
      emit(const AuthGuest());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Guest sign-in error: $e');
      }
      emit(const AuthFailure('Could not enter guest mode.'));
    }
  }

  Future<void> login({
    required String email,
    required String password,
    String? systemRole,
  }) async {
    emit(const AuthLoading());

    try {
      final fcmToken = await _getFcmTokenSafely();

      await _authRepository.login(
        email: email,
        password: password,
        fcmToken: fcmToken,
      );

      await _completeAuthenticatedSession();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Login error: $e');
      }
      emit(AuthFailure(_extractMessage(e)));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(
      const AuthFailure(
        'Sign in with Google is coming soon.',
      ),
    );
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String systemRole,
  }) async {
    emit(const AuthLoading());

    try {
      final fcmToken = await _getFcmTokenSafely();

      await _authRepository.register(
        name: name,
        email: email,
        password: password,
        systemRole: systemRole,
        fcmToken: fcmToken,
      );

      await _completeAuthenticatedSession();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Signup error: $e');
      }
      emit(AuthFailure(_extractMessage(e)));
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading());

    try {
      await _authRepository.logout();
      await FirebaseAuth.instance.signOut();
      emit(const AuthGuest());
    } catch (_) {
      await _authRepository.clearLocalSession();
      await FirebaseAuth.instance.signOut();
      emit(const AuthGuest());
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(const AuthLoading());

    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      await _completeAuthenticatedSession();
    } catch (e) {
      emit(_operationFailure(_extractMessage(e)));
    }
  }

  Future<void> loadCurrentUser() async {
    emit(const AuthLoading());

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
    emit(const AuthLoading());

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
}
