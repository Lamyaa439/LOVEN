/// ========================================================================
/// Authentication Cubit
///
/// Orchestrates authentication state transitions for the UI layer.
///
/// Architectural decisions:
/// - Accepts [AuthRepository] and [TokenStorage] via constructor injection.
/// - **Session truth is the JWT** in [TokenStorage], not Firebase Auth state.
///   [checkAuthStatus] reads `access_token` to decide [AuthSuccess] vs
///   [AuthGuest]; route guards in [AppRouter] follow this cubit state.
/// - Firebase anonymous sign-in is **opt-in** via [continueAsGuest] only
///   (e.g. "Browse as guest") — used for Firebase Storage, not routing.
/// - FCM token retrieval stays here (platform concern) and is passed to
///   the repository as an optional field on login/register.
/// - Error messages from [ApiClient] arrive as `Exception("...")`.
///   [_extractMessage] unwraps them into clean UI strings.
/// ========================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:loven/core/storage/token_storage.dart';
import 'package:loven/features/auth/data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;

  AuthCubit({
    required AuthRepository authRepository,
    required TokenStorage tokenStorage,
  })  : _authRepository = authRepository,
        _tokenStorage = tokenStorage,
        super(AuthInitial());

  // =====================================================================
  // Session Bootstrap
  // =====================================================================

  /// Restores session state on app launch from locally stored JWT.
  ///
  /// Does **not** sign in anonymously — guests remain [AuthGuest] until
  /// they explicitly choose [continueAsGuest] (Firebase Storage only).
  Future<void> checkAuthStatus() async {
    final token = await _tokenStorage.getAccessToken();

    if (token != null && token.isNotEmpty) {
      emit(AuthSuccess());
    } else {
      emit(AuthGuest());
    }
  }

  /// Explicit guest entry (e.g. "Browse as guest").
  ///
  /// Firebase anonymous auth supports Firebase Storage uploads/downloads;
  /// it is **not** the source of truth for API route guards — those rely
  /// on the absence of a JWT ([AuthGuest]).
  Future<void> continueAsGuest() async {
    emit(AuthLoading());
    try {
      await FirebaseAuth.instance.signInAnonymously();
      emit(AuthGuest());
    } catch (e) {
      debugPrint('Guest sign-in error: $e');
      emit(AuthFailure('Could not enter guest mode.'));
    }
  }

  // =====================================================================
  // Core Auth Operations
  // =====================================================================

  /// Authenticates via the backend API and transitions to [AuthSuccess].
  ///
  /// Tokens are persisted in [AuthRepository]; this cubit only reflects
  /// the resulting authenticated state.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final fcmToken = await _getFcmTokenSafely();
      await _authRepository.login(
        email: email,
        password: password,
        fcmToken: fcmToken,
      );
      emit(AuthSuccess());
    } catch (e) {
      debugPrint('Login error: $e');
      emit(AuthFailure(_extractMessage(e)));
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
      final fcmToken = await _getFcmTokenSafely();
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
      emit(AuthFailure(_extractMessage(e)));
    }
  }

  /// Logs out from the backend, clears local JWTs, and signs out of Firebase.
  ///
  /// Always ends in [AuthGuest] — [AuthRepository.logout] clears storage
  /// even when the network call fails.
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

  // =====================================================================
  // Async Email Validation (used by signup page debounce)
  // =====================================================================

  /// Checks whether [email] is already registered on the backend.
  ///
  /// Returns `false` on network errors so the user is never blocked
  /// by a transient failure during live validation.
  Future<bool> checkEmailExists(String email) async {
    try {
      return await _authRepository.checkEmailDuplication(email);
    } catch (e) {
      debugPrint('Email check error: $e');
      return false;
    }
  }

  // =====================================================================
  // Helpers
  // =====================================================================

  /// Retrieves the FCM device token, requesting notification permissions
  /// on iOS first. Returns `null` silently on any failure so auth flows
  /// are never blocked by push-notification issues.
  Future<String?> _getFcmTokenSafely() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) return null;
      }

      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('FCM token error: $e');
      return null;
    }
  }

  /// Unwraps the message from an [Exception] thrown by [ApiClient].
  String _extractMessage(Object error) {
    final raw = error.toString();
    const prefix = 'Exception: ';
    if (raw.startsWith(prefix)) {
      return raw.substring(prefix.length);
    }
    return raw;
  }
}
