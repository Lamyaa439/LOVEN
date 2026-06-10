import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
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

/// Bottom-nav tab indices aligned with [NavigationWidget].
///
/// Tab 4 (index [_accountTabIndex]) is the account hub ([AccountScreen]).
/// Artist storefront lives at [AppRoutes.myProfile], not in the shell.
const _homeTabIndex = 0;
const _cartTabIndex = 2;
const _accountTabIndex = 3;

/// Shell top-chrome contract (Phase 0):
/// - Home tab: no shell [AppBar] — [HomeScreen] owns editorial header + actions.
/// - Cart tab: no shell [AppBar] — [CartScreen] owns its own [AppBar].
/// - Account tab with [accountChild]: no shell [AppBar] — pushed child owns chrome.
/// - Favorites + default Account: shell logo [AppBar] + theme toggle only.

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

      if (authStateHasSession(context.read<AuthCubit>().state)) {
        context.read<NotificationsCubit>().loadNotifications(refresh: true);
      }
    });
  }

  Widget _buildProtectedTabSlot({
    required bool hasSession,
    required String guestMessage,
    required Widget child,
  }) {
    if (!hasSession) {
      return _GuestTabGate(message: guestMessage);
    }

    return child;
  }

  /// Whether the shell renders the shared logo [AppBar] for [tabIndex].
  bool _shouldShowShellAppBar(int tabIndex) {
    if (tabIndex == _homeTabIndex) {
      return false;
    }
    if (tabIndex == _cartTabIndex) {
      return false;
    }
    if (tabIndex == _accountTabIndex && widget.accountChild != null) {
      return false;
    }
    return true;
  }

  PreferredSizeWidget _buildShellAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Image.asset(
        'assets/images/loven-logo.png',
        height: AppSizes.shellLogoHeight,
      ),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: 'Toggle theme',
          icon: Icon(
            context.watch<ThemeBloc>().state == ThemeMode.light
                ? Icons.nightlight_outlined
                : Icons.light_mode_outlined,
          ),
          onPressed: () => context.read<ThemeBloc>().toggleTheme(),
        ),
      ],
    );
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
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) =>
              !authStateHasSession(previous) && authStateHasSession(current),
          listener: (context, state) {
            context.read<NotificationsCubit>().loadNotifications(refresh: true);
          },
        ),
      ],
      child: BlocBuilder<NavigationBarCubit, NavigationBarState>(
        builder: (context, navState) {
          final showShellAppBar = _shouldShowShellAppBar(navState.currentIndex);

          return Scaffold(
            appBar: showShellAppBar ? _buildShellAppBar(context) : null,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            extendBody: true,
            body: Stack(
              children: [
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    final hasSession = authStateHasSession(authState);

                    return IndexedStack(
                      index: navState.currentIndex,
                      children: [
                        const HomeScreen(),
                        _buildProtectedTabSlot(
                          hasSession: hasSession,
                          guestMessage: 'Sign in to view your favorites',
                          child: const FavoritesScreen(),
                        ),
                        _buildProtectedTabSlot(
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
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, authState) {
                      final user = authStateSessionUser(authState);
                      final isArtist =
                          user?.systemRole.toLowerCase() == 'artist';

                      return NavigationWidget(isArtist: isArtist);
                    },
                  ),
                ),
              ],
            ),
          );
        },
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
