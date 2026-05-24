import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:loven/features/auth/data/repositories/auth_repository.dart';
import 'auth_state.dart';
import 'package:loven/core/storage/token_storage.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final AuthRepository _authRepository = AuthRepository();

  Future<String?> _getFcmTokenSafely() async {
    try {
      // Ask iOS user for notification permission.
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();

        print("APNS TOKEN: $apnsToken");

        if (apnsToken == null) {
          print("APNS token is not ready yet. Skipping FCM token for now.");
          return null;
        }
      }

      final fcmToken = await FirebaseMessaging.instance.getToken();

      print("FCM TOKEN: $fcmToken");

      return fcmToken;
    } catch (e) {
      print("FCM TOKEN ERROR: $e");
      return null;
    }
  }

  Future<void> checkAuthStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      if (user.isAnonymous) {
        emit(AuthGuest());
      } else {
        emit(AuthSuccess());
      }
      } else {
        emit(AuthInitial());
      }
    }
    
    Future<void> continueAsGuest() async {
      emit(AuthLoading());
      
      try {
        await FirebaseAuth.instance.signInAnonymously();
        
        emit(AuthGuest());
        } catch (e) {
          print("Guest error: $e");
          emit(AuthFailure("Could not enter guest mode."));
        }
      }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      final fcmToken = await _getFcmTokenSafely();

      print("LOGIN FCM TOKEN: $fcmToken");

      await _authRepository.login(
        email: email,
        password: password,
        fcmToken: fcmToken,
      );

      emit(AuthSuccess());
    } catch (e) {
      print("LOGIN ERROR: $e");
      emit(AuthFailure(_mapErrorMessage(e)));
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

      print("SIGNUP FCM TOKEN: $fcmToken");

      await _authRepository.register(
        name: name,
        email: email,
        password: password,
        systemRole: systemRole,
        fcmToken: fcmToken,
      );

      emit(AuthSuccess());
    } catch (e) {
      print("SIGNUP ERROR: $e");
      emit(AuthFailure(_mapErrorMessage(e)));
    }
  }
  
  Future<void> logout() async {
    emit(AuthLoading());
    
    try {
      await _authRepository.logout();
      await TokenStorage().clearAllTokens();
      await FirebaseAuth.instance.signOut();
      
      emit(AuthGuest());
      } catch (e) {
        await TokenStorage().clearAllTokens();
        await FirebaseAuth.instance.signOut();
        emit(AuthGuest());
      }
    }

  String _mapErrorMessage(Object error) {
    final errorText = error.toString();

    if (errorText.contains('User already exists')) {
      return 'An account with this email already exists';
    }

    if (errorText.contains('Invalid credentials') ||
        errorText.contains('401')) {
      return 'Invalid email or password';
    }

    if (errorText.contains('Failed to fetch')) {
      return 'Unable to connect to server';
    }

    if (errorText.contains('400')) {
      return 'Please check your input';
    }

    return errorText;
  }
}
