import 'package:flutter/material.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/auth/view/screens/login_page.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../mocks/preview_cubits.dart';
import '../mocks/preview_shell.dart';

@widgetbook.UseCase(name: 'Default', type: LoginPage)
Widget loginDefaultUseCase(BuildContext context) {
  return previewShell(
    authCubit: PreviewAuthCubit(AuthInitial()),
    child: const LoginPage(),
  );
}

@widgetbook.UseCase(name: 'Loading', type: LoginPage)
Widget loginLoadingUseCase(BuildContext context) {
  return previewShell(
    authCubit: PreviewAuthCubit(AuthLoading()),
    child: const LoginPage(),
  );
}

@widgetbook.UseCase(name: 'Error', type: LoginPage)
Widget loginErrorUseCase(BuildContext context) {
  return previewShell(
    authCubit: PreviewAuthCubit(
      AuthFailure('Invalid email or password. Please try again.'),
    ),
    child: const LoginPage(),
  );
}

@widgetbook.UseCase(name: 'From guest', type: LoginPage)
Widget loginFromGuestUseCase(BuildContext context) {
  return previewShell(
    authCubit: PreviewAuthCubit(AuthGuest()),
    child: const LoginPage(fromGuest: true),
  );
}
