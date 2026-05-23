import 'package:flutter_test/flutter_test.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';

void main() {
  // This group organizes your tests
  group('AuthCubit Guest Experience', () {
    test('Initial state should be AuthInitial', () {
      final cubit = AuthCubit();
      expect(cubit.state, isA<AuthInitial>());
    });

    test('continueAsGuest should transition state to AuthGuest', () async {
      final cubit = AuthCubit();

      // We are calling the method you implemented
      await cubit.continueAsGuest();

      // Assert that we reached the Guest state
      expect(cubit.state, isA<AuthGuest>());
    });
  });
}
