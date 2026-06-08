import 'package:loven/core/network/api_client.dart';
import 'package:loven/core/router/app_router.dart';
import 'package:loven/core/router/splash_min_duration_notifier.dart';
import 'package:loven/core/storage/app_preferences.dart';
import 'package:loven/core/storage/token_storage.dart';
import 'package:loven/features/account/controller/cubit/account_cubit.dart';
import 'package:loven/features/account/data/repositories/account_repository.dart';
import 'package:loven/features/account/data/services/profile_image_storage_service.dart';
import 'package:loven/features/artist_profile/data/artist_repository.dart';
import 'package:loven/features/artwork/data/repositories/artwork_repository.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/data/repositories/auth_repository.dart';
import 'package:loven/features/auth/data/services/firebase_auth_service.dart';
import 'package:loven/features/cart/data/repositories/cart_repository.dart';
import 'package:loven/features/favorites/data/repositories/favorites_repository.dart';
import 'package:loven/features/feedback/data/repositories/feedback_repository.dart';
import 'package:loven/features/notifications/controller/cubit/notifications_cubit.dart';
import 'package:loven/features/notifications/data/repositories/notifications_repository.dart';
import 'package:loven/features/order/data/repositories/order_repository.dart';
import 'package:loven/features/report/data/repositories/report_repository.dart';
import 'package:loven/features/verification_request/data/repositories/verification_request_repository.dart';

/// App-wide singletons constructed once at startup.
///
/// **Ownership:** repositories, [ApiClient], [FirebaseAuthService], [AuthCubit],
/// [AppRouter], and session wiring. Does not build widgets — [LovenApp] consumes
/// this graph.
class AppDependencies {
  AppDependencies._({
    required this.appPreferences,
    required this.tokenStorage,
    required this.apiClient,
    required this.authRepository,
    required this.accountRepository,
    required this.firebaseAuthService,
    required this.profileImageStorageService,
    required this.authCubit,
    required this.accountCubit,
    required this.artworkRepository,
    required this.orderRepository,
    required this.artistRepository,
    required this.favoritesRepository,
    required this.verificationRequestRepository,
    required this.cartRepository,
    required this.feedbackRepository,
    required this.reportRepository,
    required this.notificationsRepository,
    required this.notificationsCubit,
    required this.splashMinDurationNotifier,
    required this.appRouter,
  });

  final AppPreferences appPreferences;
  final TokenStorage tokenStorage;
  final ApiClient apiClient;
  final AuthRepository authRepository;
  final AccountRepository accountRepository;
  final FirebaseAuthService firebaseAuthService;
  final ProfileImageStorageService profileImageStorageService;
  final AuthCubit authCubit;
  final AccountCubit accountCubit;
  final ArtworkRepository artworkRepository;
  final OrderRepository orderRepository;
  final ArtistRepository artistRepository;
  final FavoritesRepository favoritesRepository;
  final VerificationRequestRepository verificationRequestRepository;
  final CartRepository cartRepository;
  final FeedbackRepository feedbackRepository;
  final ReportRepository reportRepository;
  final NotificationsRepository notificationsRepository;
  final NotificationsCubit notificationsCubit;
  final SplashMinDurationNotifier splashMinDurationNotifier;
  final AppRouter appRouter;

  /// Builds the dependency graph and starts session restore (single call site).
  factory AppDependencies.create(AppPreferences appPreferences) {
    final tokenStorage = TokenStorage();
    final apiClient = ApiClient(tokenStorage: tokenStorage);

    final authRepository = AuthRepository(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );

    final accountRepository = AccountRepository(apiClient: apiClient);
    final firebaseAuthService = FirebaseAuthService();
    final profileImageStorageService = ProfileImageStorageService();

    final artworkRepository = ArtworkRepository(apiClient: apiClient);
    final orderRepository = OrderRepository(apiClient: apiClient);
    final artistRepository = ArtistRepository(apiClient: apiClient);
    final favoritesRepository = FavoritesRepository(apiClient: apiClient);
    final verificationRequestRepository = VerificationRequestRepository(
      apiClient: apiClient,
    );
    final cartRepository = CartRepository(apiClient: apiClient);
    final feedbackRepository = FeedbackRepository(apiClient: apiClient);
    final reportRepository = ReportRepository(apiClient: apiClient);
    final notificationsRepository = NotificationsRepository(
      apiClient: apiClient,
    );

    final authCubit = AuthCubit(
      authRepository: authRepository,
      accountRepository: accountRepository,
      firebaseAuthService: firebaseAuthService,
    );

    final accountCubit = AccountCubit(
      accountRepository: accountRepository,
      authCubit: authCubit,
    );

    final notificationsCubit = NotificationsCubit(
      notificationsRepository,
      authCubit: authCubit,
    );

    final splashMinDurationNotifier = SplashMinDurationNotifier();

    apiClient.attachSessionExpiredHandler(() {
      if (authCubit.isClosed) {
        return;
      }
      authCubit.handleSessionExpired();
    });

    authCubit.restoreSession();

    final appRouter = AppRouter(
      authCubit,
      appPreferences: appPreferences,
      splashMinDurationNotifier: splashMinDurationNotifier,
      artistRepository: artistRepository,
      verificationRequestRepository: verificationRequestRepository,
    );

    return AppDependencies._(
      appPreferences: appPreferences,
      tokenStorage: tokenStorage,
      apiClient: apiClient,
      authRepository: authRepository,
      accountRepository: accountRepository,
      firebaseAuthService: firebaseAuthService,
      profileImageStorageService: profileImageStorageService,
      authCubit: authCubit,
      accountCubit: accountCubit,
      artworkRepository: artworkRepository,
      orderRepository: orderRepository,
      artistRepository: artistRepository,
      favoritesRepository: favoritesRepository,
      verificationRequestRepository: verificationRequestRepository,
      cartRepository: cartRepository,
      feedbackRepository: feedbackRepository,
      reportRepository: reportRepository,
      notificationsRepository: notificationsRepository,
      notificationsCubit: notificationsCubit,
      splashMinDurationNotifier: splashMinDurationNotifier,
      appRouter: appRouter,
    );
  }

  void dispose() {
    apiClient.detachSessionExpiredHandler();
    notificationsCubit.close();
    accountCubit.close();
    authCubit.close();
    splashMinDurationNotifier.dispose();
  }
}
