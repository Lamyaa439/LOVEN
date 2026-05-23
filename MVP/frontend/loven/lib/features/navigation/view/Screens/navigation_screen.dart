import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/features/artist_profile/view/screens/artist_profile_screen.dart';
import 'package:loven/features/auth/view/screens/profile_screen.dart';
import 'package:loven/features/home/View/Screens/home_screen.dart';
import '../../../../main.dart';
import 'package:loven/core/res/theme/app_colors.dart';
import '../../controller/cubit/navigation_bar_cubit.dart';
import '../widget/navigation_widget.dart';
import 'package:loven/features/cart/view/screens/cart_screen.dart';

class NavigationScreen extends StatelessWidget {
  final bool isGuest;

  const NavigationScreen({
    super.key,
    this.isGuest = false,
  });

  bool? get isDarkTheme => null;

  @override
  Widget build(BuildContext context) {
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
            const HomeScreen(),
            isGuest
                ? _buildGuestGate(context, "Sign in to view your cart")
                : const CartScreen(),
            // isGuest
            //     ? _buildGuestGate(context, "Sign in to view profiles")
            //     : const ArtistProfileScreen(),
            const ProfileScreen()
          ],
        );
      }),
      bottomNavigationBar: const NavigationWidget(),
    );
  }

  Widget _buildGuestGate(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: () => context.push('/auth'),
              child: const Text('Sign Up / Login'),
            ),
          ],
        ),
      ),
    );
  }
}
