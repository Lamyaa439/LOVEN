import 'package:flutter_test/flutter_test.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/router/redirect_policy.dart';
import 'package:loven/core/router/splash_min_duration_notifier.dart';
import 'package:loven/core/storage/app_preferences.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/auth/data/models/auth_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final customer = AuthUser(
    id: '1',
    name: 'Customer',
    email: 'user@example.com',
    systemRole: 'customer',
  );

  final admin = AuthUser(
    id: '2',
    name: 'Admin',
    email: 'admin@example.com',
    systemRole: 'admin',
  );

  late SplashMinDurationNotifier splashReady;
  late SplashMinDurationNotifier splashWaiting;

  setUp(() {
    splashReady = SplashMinDurationNotifier()..markReady();
    splashWaiting = SplashMinDurationNotifier();
  });

  Future<AppPreferences> appPreferences({bool onboardingCompleted = false}) async {
    SharedPreferences.setMockInitialValues(
      onboardingCompleted ? {'onboarding_completed': true} : {},
    );
    final prefs = AppPreferences();
    await prefs.init();
    return prefs;
  }

  String? redirect({
    required AuthState authState,
    required AppPreferences appPreferences,
    required String path,
    SplashMinDurationNotifier? splash,
  }) {
    return resolveRedirect(
      authState: authState,
      appPreferences: appPreferences,
      splashMinDuration: splash ?? splashReady,
      matchedLocation: path,
    );
  }

  group('resolveRedirect — splash', () {
    test('maps splashLegacy to splash', () async {
      final prefs = await appPreferences();
      expect(
        redirect(
          authState: const AuthGuest(),
          appPreferences: prefs,
          path: AppRoutes.splashLegacy,
        ),
        AppRoutes.splash,
      );
    });

    test('stays on splash while bootstrapping', () async {
      final prefs = await appPreferences();
      expect(
        redirect(
          authState: const AuthLoading(),
          appPreferences: prefs,
          path: AppRoutes.splash,
        ),
        isNull,
      );
    });

    test('stays on splash until minimum duration elapses', () async {
      final prefs = await appPreferences();
      expect(
        redirect(
          authState: const AuthGuest(),
          appPreferences: prefs,
          path: AppRoutes.splash,
          splash: splashWaiting,
        ),
        isNull,
      );
    });

    test('after splash ready, guest without onboarding goes to onboarding',
        () async {
      final prefs = await appPreferences(onboardingCompleted: false);
      expect(
        redirect(
          authState: const AuthGuest(),
          appPreferences: prefs,
          path: AppRoutes.splash,
        ),
        AppRoutes.onboarding,
      );
    });

    test('after splash ready, guest with onboarding goes to home', () async {
      final prefs = await appPreferences(onboardingCompleted: true);
      expect(
        redirect(
          authState: const AuthGuest(),
          appPreferences: prefs,
          path: AppRoutes.splash,
        ),
        AppRoutes.home,
      );
    });

    test('after splash ready, customer session goes to home', () async {
      final prefs = await appPreferences(onboardingCompleted: true);
      expect(
        redirect(
          authState: AuthSuccess(user: customer),
          appPreferences: prefs,
          path: AppRoutes.splash,
        ),
        AppRoutes.home,
      );
    });

    test('after splash ready, admin session goes to admin', () async {
      final prefs = await appPreferences(onboardingCompleted: true);
      expect(
        redirect(
          authState: AuthSuccess(user: admin),
          appPreferences: prefs,
          path: AppRoutes.splash,
        ),
        AppRoutes.admin,
      );
    });
  });

  group('resolveRedirect — bootstrapping', () {
    test('session-required route waits on splash during AuthInitial', () async {
      final prefs = await appPreferences();
      expect(
        redirect(
          authState: const AuthInitial(),
          appPreferences: prefs,
          path: AppRoutes.cart,
        ),
        AppRoutes.splash,
      );
    });

    test('public route stays during AuthLoading', () async {
      final prefs = await appPreferences();
      expect(
        redirect(
          authState: const AuthLoading(),
          appPreferences: prefs,
          path: AppRoutes.artists,
        ),
        isNull,
      );
    });
  });

  group('resolveRedirect — guest', () {
    test('protected route redirects to auth', () async {
      final prefs = await appPreferences(onboardingCompleted: true);
      expect(
        redirect(
          authState: const AuthGuest(),
          appPreferences: prefs,
          path: AppRoutes.notifications,
        ),
        AppRoutes.auth,
      );
    });

    test('guest account hub stays on profile', () async {
      final prefs = await appPreferences(onboardingCompleted: true);
      expect(
        redirect(
          authState: const AuthGuest(),
          appPreferences: prefs,
          path: AppRoutes.profile,
        ),
        isNull,
      );
    });

    test('completed onboarding skips onboarding screen', () async {
      final prefs = await appPreferences(onboardingCompleted: true);
      expect(
        redirect(
          authState: const AuthGuest(),
          appPreferences: prefs,
          path: AppRoutes.onboarding,
        ),
        AppRoutes.home,
      );
    });

    test('password recovery stays public for guest', () async {
      final prefs = await appPreferences();
      expect(
        redirect(
          authState: const AuthGuest(),
          appPreferences: prefs,
          path: AppRoutes.forgotPassword,
        ),
        isNull,
      );
    });
  });

  group('resolveRedirect — authenticated', () {
    test('auth entry redirects customer to home', () async {
      final prefs = await appPreferences(onboardingCompleted: true);
      expect(
        redirect(
          authState: AuthSuccess(user: customer),
          appPreferences: prefs,
          path: AppRoutes.login,
        ),
        AppRoutes.home,
      );
    });

    test('signup sub-route redirects admin to admin dashboard', () async {
      final prefs = await appPreferences(onboardingCompleted: true);
      expect(
        redirect(
          authState: AuthSuccess(user: admin),
          appPreferences: prefs,
          path: AppRoutes.signupVerifyEmail,
        ),
        AppRoutes.admin,
      );
    });

    test('signed-in user leaves onboarding to home', () async {
      final prefs = await appPreferences(onboardingCompleted: false);
      expect(
        redirect(
          authState: AuthSuccess(user: customer),
          appPreferences: prefs,
          path: AppRoutes.onboarding,
        ),
        AppRoutes.home,
      );
    });

    test('operation failure with session keeps auth-entry redirect', () async {
      final prefs = await appPreferences(onboardingCompleted: true);
      expect(
        redirect(
          authState: AuthOperationFailure(
            message: 'error',
            sessionUser: admin,
          ),
          appPreferences: prefs,
          path: AppRoutes.auth,
        ),
        AppRoutes.admin,
      );
    });
  });

  group('resolveRedirect — non-guest failures', () {
    test('AuthFailure on protected route does not force auth redirect', () async {
      final prefs = await appPreferences(onboardingCompleted: true);
      expect(
        redirect(
          authState: const AuthFailure('Invalid credentials'),
          appPreferences: prefs,
          path: AppRoutes.cart,
        ),
        isNull,
      );
    });
  });
}
