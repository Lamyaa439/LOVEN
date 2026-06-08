import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:loven/app/dependencies.dart';
import 'package:loven/core/res/theme/app_theme.dart';
import 'package:loven/core/storage/app_preferences.dart';
import 'package:loven/core/router/splash_min_duration_notifier.dart';
import 'package:loven/core/theme/theme_bloc.dart';
import 'package:loven/features/account/data/repositories/account_repository.dart';
import 'package:loven/features/account/data/services/profile_image_storage_service.dart';
import 'package:loven/features/artist_profile/data/artist_repository.dart';
import 'package:loven/features/artwork/controller/cubit/artwork_cubit.dart';
import 'package:loven/features/auth/data/repositories/auth_repository.dart';
import 'package:loven/features/cart/controller/cubit/cart_cubit.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_cubit.dart';
import 'package:loven/features/feedback/controller/cubit/feedback_cubit.dart';
import 'package:loven/features/home/controller/bloc/home_bloc.dart';
import 'package:loven/features/home/controller/bloc/home_event.dart';
import 'package:loven/features/navigation/controller/cubit/navigation_bar_cubit.dart';
import 'package:loven/features/order/controller/cubit/order_cubit.dart';
import 'package:loven/features/order/data/repositories/order_repository.dart';
import 'package:loven/features/report/controller/cubit/report_cubit.dart';
import 'package:loven/features/verification_request/controller/cubit/verification_request_cubit.dart';

/// Root widget: global providers and [MaterialApp.router].
class LovenApp extends StatefulWidget {
  final AppPreferences appPreferences;

  const LovenApp({
    required this.appPreferences,
    super.key,
  });

  @override
  State<LovenApp> createState() => _LovenAppState();
}

class _LovenAppState extends State<LovenApp> {
  late final AppDependencies _deps;

  @override
  void initState() {
    super.initState();
    _deps = AppDependencies.create(widget.appPreferences);
  }

  @override
  void dispose() {
    _deps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppPreferences>.value(
          value: _deps.appPreferences,
        ),
        RepositoryProvider<ArtistRepository>.value(
          value: _deps.artistRepository,
        ),
        RepositoryProvider<AuthRepository>.value(
          value: _deps.authRepository,
        ),
        RepositoryProvider<AccountRepository>.value(
          value: _deps.accountRepository,
        ),
        RepositoryProvider<ProfileImageStorageService>.value(
          value: _deps.profileImageStorageService,
        ),
        RepositoryProvider<OrderRepository>.value(
          value: _deps.orderRepository,
        ),
      ],
      child: ChangeNotifierProvider<SplashMinDurationNotifier>.value(
        value: _deps.splashMinDurationNotifier,
        child: MultiBlocProvider(
          providers: [
          BlocProvider.value(value: _deps.authCubit),
          BlocProvider.value(value: _deps.accountCubit),
          BlocProvider.value(value: _deps.notificationsCubit),
          BlocProvider(create: (context) => NavigationBarCubit()),
          BlocProvider(
            create: (context) => HomeBloc(
              artworkRepository: _deps.artworkRepository,
            )..add(FetchHomeData()),
          ),
          BlocProvider(create: (context) => ThemeBloc()),
          BlocProvider(
            create: (_) => CartCubit(
              _deps.cartRepository,
              authCubit: _deps.authCubit,
            ),
          ),
          BlocProvider(
            create: (context) => ArtworkCubit(_deps.artworkRepository),
          ),
          BlocProvider(
            create: (context) => OrderCubit(_deps.orderRepository),
          ),
          BlocProvider(
            create: (context) => FeedbackCubit(_deps.feedbackRepository),
          ),
          BlocProvider(
            create: (context) => ReportCubit(_deps.reportRepository),
          ),
          BlocProvider(
            create: (_) => FavoritesCubit(
              _deps.favoritesRepository,
              authCubit: _deps.authCubit,
            ),
          ),
          BlocProvider(
            create: (_) => VerificationRequestCubit(
              _deps.verificationRequestRepository,
            ),
          ),
          ],
          child: BlocBuilder<ThemeBloc, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp.router(
                title: 'LOVEN',
                debugShowCheckedModeBanner: false,
                routerConfig: _deps.appRouter.router,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en', 'US'),
                  Locale('ar', 'SA'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
