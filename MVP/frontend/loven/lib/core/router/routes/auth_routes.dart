import 'package:go_router/go_router.dart';
import 'package:loven/core/router/app_router_deps.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/router/router_helpers.dart';
import 'package:loven/features/auth/view/screens/change_password_screen.dart';
import 'package:loven/features/auth/view/screens/edit_profile_screen.dart';
import 'package:loven/features/auth/view/screens/forgot_password_page.dart';
import 'package:loven/features/auth/view/screens/login_page.dart';
import 'package:loven/features/auth/view/screens/new_password_page.dart';
import 'package:loven/features/auth/view/screens/password_changed_page.dart';
import 'package:loven/features/auth/view/screens/signup_page.dart';
import 'package:loven/features/auth/view/screens/signup_success_page.dart';
import 'package:loven/features/auth/view/screens/signup_verification_email_page.dart';
import 'package:loven/features/auth/view/screens/verification_code_page.dart';

/// Credential, recovery, password change, profile edit, and sign-up flow routes.
List<RouteBase> buildAuthRoutesPrimary(AppRouterDeps deps) {
  return [
    GoRoute(
      path: AppRoutes.auth,
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(fromGuest: true),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.forgotPasswordCode,
      builder: (context, state) {
        return routeWithRequiredStringExtra(
          state: state,
          title: 'Verification Code',
          missingMessage: 'Email is required to verify your code.',
          builder: (email) => VerificationCodePage(email: email),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.forgotPasswordNewPassword,
      builder: (context, state) => const NewPasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.forgotPasswordSuccess,
      builder: (context, state) => const PasswordChangedPage(),
    ),
    GoRoute(
      path: AppRoutes.changePassword,
      builder: (context, state) => const ChangePasswordScreen(),
    ),
  ];
}

List<RouteBase> buildAuthRoutesProfile(AppRouterDeps deps) {
  return [
    GoRoute(
      path: AppRoutes.profileEdit,
      builder: (context, state) => const EditProfileScreen(),
    ),
  ];
}

List<RouteBase> buildAuthRoutesSignup(AppRouterDeps deps) {
  return [
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) {
        final fromGuest = state.uri.queryParameters['fromGuest'] == 'true';
        return SignupPage(fromGuest: fromGuest);
      },
    ),
    GoRoute(
      path: AppRoutes.signupVerifyEmail,
      builder: (context, state) {
        return routeWithRequiredStringExtra(
          state: state,
          title: 'Verify Email',
          missingMessage: 'Email is required to continue signup verification.',
          builder: (email) => SignupVerificationEmailPage(email: email),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.signupSuccess,
      builder: (context, state) => const SignupSuccessPage(),
    ),
  ];
}
