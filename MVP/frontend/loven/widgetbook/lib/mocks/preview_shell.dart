import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/core/res/theme/app_theme.dart';
import 'package:loven/features/artist_profile/data/artist_repository.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/cart/controller/cubit/cart_cubit.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_cubit.dart';
import 'package:loven/features/order/controller/cubit/order_cubit.dart';
import 'package:loven/features/artwork/controller/cubit/artwork_cubit.dart';

/// Wraps a screen with LOVEN theme and optional bloc/repository providers.
///
/// Widgetbook addons handle device frame and light/dark switching; this shell
/// supplies app-specific theme and dependency injection only.
Widget previewShell({
  required Widget child,
  ArtistRepository? artistRepository,
  AuthCubit? authCubit,
  CartCubit? cartCubit,
  FavoritesCubit? favoritesCubit,
  OrderCubit? orderCubit,
  ArtworkCubit? artworkCubit,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    home: MultiRepositoryProvider(
      providers: [
        if (artistRepository != null)
          RepositoryProvider<ArtistRepository>.value(
            value: artistRepository,
          ),
      ],
      child: MultiBlocProvider(
        providers: [
          if (authCubit != null)
            BlocProvider<AuthCubit>.value(value: authCubit),
          if (cartCubit != null)
            BlocProvider<CartCubit>.value(value: cartCubit),
          if (favoritesCubit != null)
            BlocProvider<FavoritesCubit>.value(value: favoritesCubit),
          if (orderCubit != null)
            BlocProvider<OrderCubit>.value(value: orderCubit),
          if (artworkCubit != null)
            BlocProvider<ArtworkCubit>.value(value: artworkCubit),
        ],
        child: Scaffold(
          body: SafeArea(child: child),
        ),
      ),
    ),
  );
}
