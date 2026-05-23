import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/features/navigation/controller/cubit/navigation_bar_cubit.dart';

class NavigationWidget extends StatelessWidget {
  const NavigationWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return BlocBuilder<NavigationBarCubit, NavigationBarState>(
      builder: (context, state) {
        return BottomNavigationBar(
          currentIndex: state.currentIndex,
          onTap: (index) {
            context.read<NavigationBarCubit>().navigateTo(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        );
      },
    );
  }
}
