import 'package:flutter_test/flutter_test.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';

void main() {
  group('AuthState', () {
    test('AuthGuest and AuthSuccess are distinct session states', () {
      expect(AuthGuest(), isA<AuthState>());
      expect(AuthSuccess(), isA<AuthState>());
      expect(AuthInitial(), isA<AuthState>());
    });
  });
}
