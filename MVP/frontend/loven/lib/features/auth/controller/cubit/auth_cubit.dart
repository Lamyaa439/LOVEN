import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:loven/core/storage/token_storage.dart';
import 'package:loven/features/auth/data/models/user_model.dart';
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

  Future<void> checkAuthStatus() async {
    final token = await _tokenStorage.getAccessToken();

    if (token != null && token.isNotEmpty) {
      final role = await _tokenStorage.getUserRole();

      print('LOADED ROLE: $role');

      emit(
        AuthSuccess(
          user: UserModel(
            id: '',
            name: '',
            email: '',
            phoneNumber: null,
            profileImageUrl: null,
            systemRole: role ?? '',
          ),
        ),
      );
    } else {
      emit(AuthGuest());
    }
  }

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

      final savedRole = await _tokenStorage.getUserRole();
      final role = systemRole ?? savedRole ?? '';

      emit(
        AuthSuccess(
          user: UserModel(
            id: '',
            name: '',
            email: email,
            phoneNumber: null,
            profileImageUrl: null,
            systemRole: role,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Login error: $e');
      emit(AuthFailure(_extractMessage(e)));
    }
  }

  Future<void> signInWithGoogle() async {
  emit(AuthLoading());

  try {
    await _authRepository.signInWithGoogle();

    final user = await _authRepository.getCurrentUser();

    await _tokenStorage.saveUserRole(
      user.systemRole,
    );

    emit(AuthSuccess(user: user));
  } catch (e) {
    emit(AuthFailure(_extractMessage(e)));
  }
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

      print('SAVING ROLE: $systemRole');

      await _tokenStorage.saveUserRole(systemRole);

      emit(
        AuthSuccess(
          user: UserModel(
            id: '',
            name: name,
            email: email,
            phoneNumber: null,
            profileImageUrl: null,
            systemRole: systemRole,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Signup error: $e');
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

      final role = await _tokenStorage.getUserRole();


      emit(
        AuthSuccess(
          user: UserModel(
            id: '',
            name: '',
            email: '',
            phoneNumber: null,
            profileImageUrl: null,
            systemRole: role ?? '',
          ),
        ),
      );
    } catch (e) {
      emit(AuthFailure(_extractMessage(e)));
    }
  }

  Future<void> loadCurrentUser() async {
    emit(AuthLoading());

    try {
      final user = await _authRepository.getCurrentUser();

      await _tokenStorage.saveUserRole(user.systemRole);

      emit(AuthSuccess(user: user));
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
      debugPrint('Email check error: $e');
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
      debugPrint('FCM token error: $e');
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