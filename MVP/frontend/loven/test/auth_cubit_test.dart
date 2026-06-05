import 'package:flutter_test/flutter_test.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/auth/data/models/auth_user.dart';

void main() {
  group('AuthState', () {
    final user = UserModel(
      id: '1',
      name: 'Test',
      email: 'test@example.com',
      systemRole: 'customer',
    );

    test('AuthGuest and AuthSuccess are distinct session states', () {
      expect(const AuthGuest(), isA<AuthState>());
      expect(AuthSuccess(user: user), isA<AuthState>());
      expect(const AuthInitial(), isA<AuthState>());
    });

    test('authStateHasSession distinguishes guest from operation failure', () {
      expect(authStateHasSession(const AuthGuest()), isFalse);
      expect(authStateHasSession(const AuthFailure('login failed')), isFalse);
      expect(authStateHasSession(AuthSuccess(user: user)), isTrue);
      expect(
        authStateHasSession(
          AuthOperationFailure(
            message: 'network',
            sessionUser: user,
          ),
        ),
        isTrue,
      );
      expect(
        authStateHasSession(
          const AuthOperationFailure(message: 'network'),
        ),
        isFalse,
      );
    });
  });
}
