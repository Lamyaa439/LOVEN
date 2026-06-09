import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/dimensions/app_spacing.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/features/account/controller/cubit/account_cubit.dart';
import 'package:loven/features/account/view/screens/account_screen.dart';
import 'package:loven/features/artist_profile/controller/artist_profile_cubit.dart';
import 'package:loven/features/artist_profile/data/artist_repository.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/cart/controller/cubit/cart_cubit.dart';
import 'package:loven/features/cart/view/screens/cart_screen.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_cubit.dart';
import 'package:loven/features/favorites/view/screens/favorites_screen.dart';
import 'package:loven/features/home/View/Screens/home_screen.dart';
import 'package:loven/features/notifications/controller/cubit/notifications_cubit.dart';

import 'package:loven/core/theme/theme_bloc.dart';
import '../../controller/cubit/navigation_bar_cubit.dart';
import 'package:loven/features/navigation/view/widget/navigation_widget.dart';
import 'package:loven/core/res/theme/app_colors.dart';

/// Bottom-nav tab indices aligned with [NavigationWidget].
///
/// Tab 4 (index [_accountTabIndex]) is the account hub ([AccountScreen]).
/// Artist storefront lives at [AppRoutes.myProfile], not in the shell.
const _favoritesTabIndex = 1;
const _cartTabIndex = 2;
const _accountTabIndex = 3;
const _firstProtectedTabIndex = _favoritesTabIndex;

class NavigationScreen extends StatefulWidget {
  final int initialIndex;
  final Widget? accountChild;

  const NavigationScreen({
    super.key,
    this.initialIndex = 0,
    this.accountChild,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  /// Protected tab bodies mount only after first visit while session is valid.
  final Set<int> _activatedProtectedTabs = <int>{};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final startIndex =
    widget.accountChild != null ? _accountTabIndex : widget.initialIndex;

context.read<NavigationBarCubit>().navigateTo(startIndex);
_activateProtectedTabIfNeeded(startIndex);

      if (authStateHasSession(context.read<AuthCubit>().state)) {
        context.read<NotificationsCubit>().loadNotifications(refresh: true);
      }
    });
  }

  void _activateProtectedTabIfNeeded(int tabIndex) {
    if (tabIndex == _accountTabIndex) {
      return;
    }

    if (tabIndex < _firstProtectedTabIndex) {
      return;
    }

    if (!authStateHasSession(context.read<AuthCubit>().state)) {
      return;
    }

    if (_activatedProtectedTabs.contains(tabIndex)) {
      return;
    }

    setState(() {
      _activatedProtectedTabs.add(tabIndex);
    });
  }

  void _clearActivatedProtectedTabs() {
    if (_activatedProtectedTabs.isEmpty) {
      return;
    }

    setState(_activatedProtectedTabs.clear);
  }

  Widget _buildProtectedTabSlot({
    required int tabIndex,
    required bool hasSession,
    required String guestMessage,
    required Widget child,
  }) {
    if (!hasSession) {
      return _GuestTabGate(message: guestMessage);
    }

    if (!_activatedProtectedTabs.contains(tabIndex)) {
      return const SizedBox.shrink();
    }

    return child;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) =>
              authStateHasSession(previous) && !authStateHasSession(current),
          listener: (context, state) {
            context.read<CartCubit>().resetForSignedOut();
            context.read<FavoritesCubit>().resetForSignedOut();
            context.read<AccountCubit>().resetForSignedOut();
            context.read<NotificationsCubit>().resetForSignedOut();
            _clearActivatedProtectedTabs();
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) =>
              !authStateHasSession(previous) && authStateHasSession(current),
          listener: (context, state) {
            _activateProtectedTabIfNeeded(
              context.read<NavigationBarCubit>().state.currentIndex,
            );
            context.read<NotificationsCubit>().loadNotifications(refresh: true);
          },
        ),
        BlocListener<NavigationBarCubit, NavigationBarState>(
          listener: (context, navState) {
            _activateProtectedTabIfNeeded(navState.currentIndex);
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Image.asset(
            'assets/images/loven-logo.png',
            height: 40,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                context.watch<ThemeBloc>().state == ThemeMode.light
                    ? Icons.nightlight_outlined
                    : Icons.light_mode_outlined,
              ),
              onPressed: () => context.read<ThemeBloc>().toggleTheme(),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBody: true,
        body: Stack(
  children: [
    BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final hasSession = authStateHasSession(authState);

        return BlocBuilder<NavigationBarCubit, NavigationBarState>(
          builder: (context, navState) {
            return IndexedStack(
              index: navState.currentIndex,
              children: [
                const HomeScreen(),
                _buildProtectedTabSlot(
                  tabIndex: _favoritesTabIndex,
                  hasSession: hasSession,
                  guestMessage: 'Sign in to view your favorites',
                  child: const FavoritesScreen(),
                ),
                _buildProtectedTabSlot(
                  tabIndex: _cartTabIndex,
                  hasSession: hasSession,
                  guestMessage: 'Sign in to view your cart',
                  child: const CartScreen(),
                ),
                widget.accountChild ??
                    BlocProvider(
                      key: const ValueKey('account-tab'),
                      create: (context) => ArtistProfileCubit(
                        repository: context.read<ArtistRepository>(),
                        authCubit: context.read<AuthCubit>(),
                      ),
                      child: const AccountScreen(),
                    ),
              ],
            );
          },
        );
      },
    ),

    Align(
      alignment: Alignment.bottomCenter,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final user = authStateSessionUser(authState);

          final isArtist =
              user?.systemRole.toLowerCase() == 'artist';

          return NavigationWidget(
            isArtist: isArtist,
          );
        },
      ),
    ),
  ],
),
      ),
    );
  }
}

class _GuestTabGate extends StatelessWidget {
  const _GuestTabGate({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.45),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.auth),
              child: const Text('Sign Up / Login'),
            ),
          ],
        ),
      ),
    );
  }
}
