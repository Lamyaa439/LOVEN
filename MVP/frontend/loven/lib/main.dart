import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'core/res/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/network/api_constants.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/controller/cubit/auth_cubit.dart';
import 'features/home/controller/bloc/home_bloc.dart';
import 'features/home/controller/bloc/home_event.dart';
import 'features/navigation/controller/cubit/navigation_bar_cubit.dart';

import 'features/cart/data/repositories/cart_repository.dart';
import 'features/cart/controller/cubit/cart_cubit.dart';

import 'features/artwork/data/repositories/artwork_repository.dart';
import 'features/artwork/controller/cubit/artwork_cubit.dart';

import 'features/order/data/repositories/order_repository.dart';
import 'features/order/controller/cubit/order_cubit.dart';

import 'features/feedback/data/repositories/feedback_repository.dart';
import 'features/feedback/controller/cubit/feedback_cubit.dart';

import 'features/report/data/repositories/report_repository.dart';
import 'features/report/controller/cubit/report_cubit.dart';

import 'features/favorites/controller/cubit/favorites_cubit.dart';
import 'features/favorites/data/repositories/favorites_repository.dart';

import 'features/verification_request/controller/cubit/verification_request_cubit.dart';
import 'features/verification_request/data/repositories/verification_request_repository.dart';

class ThemeBloc extends Cubit<ThemeMode> {
  ThemeBloc() : super(ThemeMode.light);

  void toggleTheme() {
    emit(
      state == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light,
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Initialize Firebase configuration before running the app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LovenApp());
}

class LovenApp extends StatefulWidget {
  const LovenApp({super.key});

  @override
  State<LovenApp> createState() => _LovenAppState();
}

class _LovenAppState extends State<LovenApp> {

  // Shared singletons created once and injected down the dependency chain.
  final TokenStorage _tokenStorage = TokenStorage();
  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final AuthCubit _authCubit;
  late final AppRouter _appRouter;
  
  @override
  void initState() {
    super.initState();
    
    _apiClient = ApiClient(tokenStorage: _tokenStorage);
    
    _authRepository = AuthRepository(
      apiClient: _apiClient,
      tokenStorage: _tokenStorage,
    );
    
    _authCubit = AuthCubit(
      authRepository: _authRepository,
      )..checkAuthStatus();
      
      _appRouter = AppRouter(_authCubit);
    }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),

        BlocProvider(
          create: (context) => NavigationBarCubit(),
        ),

        BlocProvider(
          create: (context) => HomeBloc()
            ..add(FetchHomeData()),
        ),

        BlocProvider(
          create: (context) => ThemeBloc(),
        ),

        BlocProvider(
          create: (context) => CartCubit(
            CartRepository(),
          ),
        ),

        BlocProvider(
          create: (context) => ArtworkCubit(
            ArtworkRepository(),
          ),
        ),

        BlocProvider(
          create: (context) => OrderCubit(
            OrderRepository(),
          ),
        ),

        BlocProvider(
          create: (context) => FeedbackCubit(
            FeedbackRepository(),
          ),
        ),

        BlocProvider(
          create: (context) => ReportCubit(
            ReportRepository(),
          ),
        ),

        BlocProvider(
          create: (_) => FavoritesCubit(
            FavoritesRepository(),
          ),
        ),

        BlocProvider(
          create: (_) => VerificationRequestCubit(
            VerificationRequestRepository(),
          ),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'LOVEN',
            debugShowCheckedModeBanner: false,
            routerConfig: _appRouter.router,
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
    );
  }
}