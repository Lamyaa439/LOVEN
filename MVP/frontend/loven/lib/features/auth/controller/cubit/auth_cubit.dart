import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:loven/core/storage/token_storage.dart';
import 'package:loven/features/auth/data/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Auth/session source of truth for the app.
///
/// This cubit owns session bootstrap, login/register/logout, and account profile
/// hydration so UI/screens do not need to infer auth state from raw tokens.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;

  /// Ensures [restoreSession] runs at most once per app launch.
  Future<void>? _bootstrapFuture;

  AuthCubit({
    required AuthRepository authRepository,
    required TokenStorage tokenStorage,
  })  : _authRepository = authRepository,
        _tokenStorage = tokenStorage,
        super(AuthInitial());

  /// Boot-time session restore — single source of truth for auth bootstrap.
  ///
  /// Invoke only from [LovenApp.initState] (one call site per app launch).
  /// [SplashScreen] must not call this; routing waits on [AuthCubit.stream].
  Future<void> restoreSession() {
    _bootstrapFuture ??= _restoreSession();
    return _bootstrapFuture!;
  }

  /// @deprecated Use [restoreSession] — kept for any stale call sites.
  Future<void> checkAuthStatus() => restoreSession();

  Future<void> _restoreSession() async {
    final token = await _tokenStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      emit(AuthGuest());
      return;
    }

    emit(AuthLoading());

    try {
      await _completeAuthenticatedSession();
    } catch (_) {
      try {
        await _authRepository.refreshAccessToken();
        await _completeAuthenticatedSession();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Session restore failed: $e');
        }
        await _tokenStorage.clearAllTokens();
        emit(AuthGuest());
      }
    }
  }

  /// Loads account profile into [AuthSuccess.user] after login/register/restore.
  Future<void> _completeAuthenticatedSession() async {
    final user = await _authRepository.getCurrentUser();
    await _tokenStorage.saveUserRole(user.systemRole);
    emit(AuthSuccess(user: user));
  }

  /// Invoked by [ApiClient] when refresh fails after a 401.
  Future<void> handleSessionExpired() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // Best-effort Firebase cleanup.
    }

    // Defensive clear: ApiClient already clears tokens on refresh failure,
    // but this keeps cubit behavior safe if the callback is reused elsewhere.
    await _tokenStorage.clearAllTokens();
    emit(AuthGuest());
  }

  Future<void> continueAsGuest() async {
    emit(AuthLoading());

    try {
      await FirebaseAuth.instance.signInAnonymously();
      emit(AuthGuest());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Guest sign-in error: $e');
      }
      emit(AuthFailure('Could not enter guest mode.'));
    }
  }

  Future<void> login({
    required String email,
    required String password,
    String? systemRole,
  }) async {
    emit(AuthLoading());

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
      AuthFailure(
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
    emit(AuthLoading());

    try {
      final fcmToken = await _getFcmTokenSafely();

      await _authRepository.register(
        name: name,
        email: email,
        password: password,
        systemRole: systemRole,
        fcmToken: fcmToken,
      );

      await _tokenStorage.saveUserRole(systemRole);
      await _completeAuthenticatedSession();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Signup error: $e');
      }
      emit(AuthFailure(_extractMessage(e)));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());

    try {
      await _authRepository.logout();
      await FirebaseAuth.instance.signOut();
      await _tokenStorage.clearUserRole();
      emit(AuthGuest());
    } catch (_) {
      await FirebaseAuth.instance.signOut();
      await _tokenStorage.clearUserRole();
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

      await _completeAuthenticatedSession();
    } catch (e) {
      emit(AuthFailure(_extractMessage(e)));
    }
  }

  Future<void> loadCurrentUser() async {
    emit(AuthLoading());

    try {
      await _completeAuthenticatedSession();
    } catch (e) {
      emit(AuthFailure(_extractMessage(e)));
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    String? profileImageUrl,
  }) async {
    emit(AuthLoading());

    try {
      final user = await _authRepository.updateProfile(
        name: name,
        email: email,
        profileImageUrl: profileImageUrl,
      );

      await _tokenStorage.saveUserRole(user.systemRole);

      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(_extractMessage(e)));
    }
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
    final raw = error.toString();
    const prefix = 'Exception: ';

    if (raw.startsWith(prefix)) {
      return raw.substring(prefix.length);
    }

    return raw;
  }
}
