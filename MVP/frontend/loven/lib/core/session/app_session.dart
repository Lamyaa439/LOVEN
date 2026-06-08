import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';

/// UI session helpers — single source of truth for protected interactions.
abstract final class AppSession {
  AppSession._();

  static bool hasSession(AuthState state) => authStateHasSession(state);

  static bool hasSessionFromContext(BuildContext context) {
    return authStateHasSession(context.read<AuthCubit>().state);
  }

  static bool watchSession(BuildContext context) {
    return authStateHasSession(context.watch<AuthCubit>().state);
  }
}
