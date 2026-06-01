import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/features/artist_profile/data/artist_repository.dart';
import 'package:loven/features/artist_profile/view/screens/artist_profile_screen.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/auth/view/screens/profile_screen.dart';
import 'package:loven/features/cart/view/screens/cart_screen.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_cubit.dart';
import 'package:loven/features/favorites/view/screens/favorites_screen.dart';
import 'package:loven/features/home/View/Screens/home_screen.dart';

import '../../../../main.dart';
import '../../controller/cubit/navigation_bar_cubit.dart';
import '../widget/navigation_widget.dart';

class NavigationScreen extends StatefulWidget {
  final int initialIndex;
  final bool isGuest;

  const NavigationScreen({
    super.key,
    this.initialIndex = 0,
    this.isGuest = false,
  });

 @override
 State<NavigationScreen> createState() => _NavigationScreenState();
  void dispose() {
    _navigationCubit.close();
    super.dispose();
}

 

class _NavigationScreenState extends State<NavigationScreen> {}
  @override
  void? initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(_) {
      context.read<NavigationBarCubit>().navigateTo(widget.initialIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isGuest && mounted) {
        context.read<FavoritesCubit>().loadFavorites();
      }
    });
  
@override
    return Scaffold(
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
      body: BlocBuilder<NavigationBarCubit, NavigationBarState>(
        builder: (context, state) {
          return IndexedStack(
            index: state.currentIndex,
            children: [
              HomeScreen(
                isGuest: widget.isGuest,
              ),
              widget.isGuest
                  ? _buildGuestGate(
                      context,
                      "Sign in to view your favorites",
                    )
                  : const FavoritesScreen(),
              widget.isGuest
                  ? _buildGuestGate(
                      context,
                      "Sign in to view your cart",
                    )
                  : const CartScreen(),
              widget.isGuest
                  ? _buildGuestGate(
                      context,
                      "Sign in to view your profile",
                    )
                  : ArtistProfileScreen(
                      repository: context.read<ArtistRepository>(),
                    ),
            ],
          );
        },
      ),
      bottomNavigationBar: const NavigationWidget(),
    );
  }

  Widget _buildGuestGate(
    BuildContext context,
    String message,
  ) {
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
              onPressed: () => context.push('/auth'),
              child: const Text(
                'Sign Up / Login',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
}