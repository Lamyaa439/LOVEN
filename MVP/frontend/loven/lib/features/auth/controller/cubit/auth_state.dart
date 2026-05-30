import 'package:loven/features/auth/data/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel? user;

  AuthSuccess({this.user});
}

class AuthGuest extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}