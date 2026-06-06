import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/theme/app_colors.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/features/artist_profile/controller/artist_profile_cubit.dart';
import 'package:loven/features/artist_profile/data/artist_repository.dart';
import 'package:loven/features/artist_profile/view/screens/artist_profile_screen.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/cart/controller/cubit/cart_cubit.dart';
import 'package:loven/features/cart/view/screens/cart_screen.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_cubit.dart';
import 'package:loven/features/favorites/view/screens/favorites_screen.dart';
import 'package:loven/features/home/View/Screens/home_screen.dart';

import 'package:loven/core/theme/theme_bloc.dart';
import '../../controller/cubit/navigation_bar_cubit.dart';
import '../widget/navigation_widget.dart';

/// Bottom-nav tab indices aligned with [NavigationWidget].
const _favoritesTabIndex = 1;
const _cartTabIndex = 2;
const _profileTabIndex = 3;
const _firstProtectedTabIndex = _favoritesTabIndex;

class NavigationScreen extends StatefulWidget {
  final int initialIndex;

  const NavigationScreen({
    super.key,
    this.initialIndex = 0,
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

      context.read<NavigationBarCubit>().navigateTo(widget.initialIndex);
      _activateProtectedTabIfNeeded(widget.initialIndex);
    });
  }

  void _activateProtectedTabIfNeeded(int tabIndex) {
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
        body: BlocBuilder<AuthCubit, AuthState>(
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
                    _buildProtectedTabSlot(
                      tabIndex: _profileTabIndex,
                      hasSession: hasSession,
                      guestMessage: 'Sign in to view your profile',
                      child: BlocProvider(
                        create: (context) => ArtistProfileCubit(
                          repository: context.read<ArtistRepository>(),
                          authCubit: context.read<AuthCubit>(),
                        ),
                        child: const ArtistProfileScreen(),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        bottomNavigationBar: const NavigationWidget(),
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
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => context.push(AppRoutes.auth),
              child: const Text('Sign Up / Login'),
            ),
          ],
        ),
      ),
    );
  }
}
