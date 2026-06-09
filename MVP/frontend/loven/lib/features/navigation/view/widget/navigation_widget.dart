import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/features/navigation/controller/cubit/navigation_bar_cubit.dart';
import 'package:loven/features/cart/controller/cubit/cart_cubit.dart';
import 'package:loven/features/cart/controller/cubit/cart_state.dart';
import 'package:loven/core/res/theme/app_colors.dart';

class NavigationWidget extends StatelessWidget {
  const NavigationWidget({
    super.key,
    this.isArtist = false,
  });

  final bool isArtist;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBarCubit, NavigationBarState>(
      builder: (context, state) {
        return ColoredBox(
          color: Colors.transparent,
          child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: SizedBox(
            height: 82,
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        index: 0,
                        currentIndex: state.currentIndex,
                      ),
                      _NavItem(
                        icon: Icons.favorite_border_rounded,
                        activeIcon: Icons.favorite_rounded,
                        index: 1,
                        currentIndex: state.currentIndex,
                      ),
                      if (isArtist) const SizedBox(width: 64),
                      _CartNavItem(
                        index: 2,
                        currentIndex: state.currentIndex,
                      ),
                      _NavItem(
                        icon: Icons.person_outline_rounded,
                        activeIcon: Icons.person_rounded,
                        index: 3,
                        currentIndex: state.currentIndex,
                      ),
                    ],
                  ),
                ),
                if (isArtist)
                  Positioned(
                    top: -2,
                    child: GestureDetector(
                      onTap: () {
                        context.go('/artist/upload');
                      },
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.deepPurple,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.deepPurple.withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.index,
    required this.currentIndex,
  });

  final IconData icon;
  final IconData activeIcon;
  final int index;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final bool isActive = currentIndex == index;

    return IconButton(
      onPressed: () {
        context.read<NavigationBarCubit>().navigateTo(index);
      },
      icon: Icon(
        isActive ? activeIcon : icon,
        size: 25,
        color: isActive ? AppColors.primaryBlue : Colors.grey.shade500,
      ),
    );
  }
}

class _CartNavItem extends StatelessWidget {
  const _CartNavItem({
    required this.index,
    required this.currentIndex,
  });

  final int index;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final bool isActive = currentIndex == index;

    return IconButton(
      onPressed: () {
        context.read<NavigationBarCubit>().navigateTo(index);
      },
      icon: BlocBuilder<CartCubit, CartState>(
        builder: (context, cartState) {
          int itemCount = 0;

          if (cartState is CartLoaded) {
            itemCount = cartState.cart.items.fold<int>(
              0,
              (sum, item) => sum + item.quantity,
            );
          }

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                isActive
                    ? Icons.shopping_bag_rounded
                    : Icons.shopping_bag_outlined,
                size: 25,
                color: isActive ? AppColors.primaryBlue : Colors.grey.shade500,
              ),
              if (itemCount > 0)
                Positioned(
                  right: -8,
                  top: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.deepPurple,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      itemCount > 9 ? '9+' : '$itemCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}