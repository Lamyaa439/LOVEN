import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/res/design_system.dart';
import 'package:loven/features/artist_profile/controller/artist_profile_cubit.dart';
import 'package:loven/features/cart/controller/cubit/cart_cubit.dart';
import 'package:loven/features/cart/controller/cubit/cart_state.dart';
import 'package:loven/features/navigation/controller/cubit/navigation_bar_cubit.dart';

class NavigationWidget extends StatelessWidget {
  const NavigationWidget({
    super.key,
    this.isArtist = false,
  });

  final bool isArtist;

  void _navigateToTab(BuildContext context, int index) {
    context.read<NavigationBarCubit>().navigateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBarCubit, NavigationBarState>(
      builder: (context, state) {
        return ColoredBox(
          color: Colors.transparent,
          child: SafeArea(
            minimum: const EdgeInsets.fromLTRB(
              AppSizes.floatingNavHorizontalGutter,
              AppSpacing.none,
              AppSizes.floatingNavHorizontalGutter,
              AppSizes.floatingNavBottomInset,
            ),
            child: SizedBox(
              height: AppSizes.floatingNavStackHeight,
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  _FloatingNavBar(
                    isArtist: isArtist,
                    currentIndex: state.currentIndex,
                    onNavigate: (index) => _navigateToTab(context, index),
                  ),
                  if (isArtist)
                    Positioned(
                      top: AppSizes.floatingNavStackHeight -
                          AppSizes.floatingNavBarHeight -
                          AppSizes.floatingNavFabSize / 2,
                      child: _ArtistFab(
                        onTap: () async {
                          final created =
                              await context.push('/artworks/create');

                          if (created == true && context.mounted) {
                            context
                                .read<ArtistProfileCubit>()
                                .fetchMyProfileData();
                          }
                        },
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

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.isArtist,
    required this.currentIndex,
    required this.onNavigate,
  });

  final bool isArtist;
  final int currentIndex;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final glassFill =
        isDark ? AppColors.navGlassFillDark : AppColors.navGlassFillLight;
    final glassBorder =
        isDark ? AppColors.navGlassBorderDark : AppColors.navGlassBorderLight;

    final notchGap = AppSpacing.md;
    final notchRadius = AppSizes.floatingNavFabSize / 2 + notchGap;

    final bar = isArtist
        ? ClipPath(
            clipper: _NavBarNotchClipper(
              cornerRadius: AppRadius.pill,
              notchRadius: notchRadius,
            ),
            child: _NavGlassSurface(
              fillColor: glassFill,
              borderColor: glassBorder,
              child: _NavIconRow(
                isArtist: isArtist,
                currentIndex: currentIndex,
                onNavigate: onNavigate,
              ),
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: _NavGlassSurface(
              fillColor: glassFill,
              borderColor: glassBorder,
              child: _NavIconRow(
                isArtist: isArtist,
                currentIndex: currentIndex,
                onNavigate: onNavigate,
              ),
            ),
          );

    return Container(
      height: AppSizes.floatingNavBarHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.floatingNavBar,
      ),
      child: bar,
    );
  }
}

class _NavGlassSurface extends StatelessWidget {
  const _NavGlassSurface({
    required this.fillColor,
    required this.borderColor,
    required this.child,
  });

  final Color fillColor;
  final Color borderColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(color: borderColor),
        ),
        child: child,
      ),
    );
  }
}

class _NavIconRow extends StatelessWidget {
  const _NavIconRow({
    required this.isArtist,
    required this.currentIndex,
    required this.onNavigate,
  });

  final bool isArtist;
  final int currentIndex;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _NavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          index: 0,
          currentIndex: currentIndex,
          onTap: () => onNavigate(0),
        ),
        _NavItem(
          icon: Icons.favorite_border_rounded,
          activeIcon: Icons.favorite_rounded,
          index: 1,
          currentIndex: currentIndex,
          onTap: () => onNavigate(1),
        ),
        if (isArtist)
          const SizedBox(width: AppSizes.floatingNavArtistSlotWidth),
        _CartNavItem(
          index: 2,
          currentIndex: currentIndex,
          onTap: () => onNavigate(2),
        ),
        _NavItem(
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          index: 3,
          currentIndex: currentIndex,
          onTap: () => onNavigate(3),
        ),
      ],
    );
  }
}

class _ArtistFab extends StatelessWidget {
  const _ArtistFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: AppSizes.floatingNavFabSize,
        height: AppSizes.floatingNavFabSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.brandSecondary,
          boxShadow: AppShadows.floatingNavFab,
        ),
        child: Icon(
          Icons.add_rounded,
          color: AppColors.textOnBrand,
          size: AppSizes.floatingNavFabIconSize,
        ),
      ),
    );
  }
}

/// Pill nav bar with a smooth U-shaped top-center notch — empty space for the FAB.
class _NavBarNotchClipper extends CustomClipper<Path> {
  _NavBarNotchClipper({
    required this.cornerRadius,
    required this.notchRadius,
  });

  final double cornerRadius;
  final double notchRadius;

  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    final radius = cornerRadius.clamp(0.0, height / 2).toDouble();
    final centerX = width / 2;

    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.lineTo(centerX - notchRadius, 0);
    path.arcToPoint(
      Offset(centerX + notchRadius, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );
    path.lineTo(width - radius, 0);
    path.quadraticBezierTo(width, 0, width, radius);
    path.lineTo(width, height - radius);
    path.quadraticBezierTo(width, height, width - radius, height);
    path.lineTo(radius, height);
    path.quadraticBezierTo(0, height, 0, height - radius);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant _NavBarNotchClipper oldClipper) {
    return oldClipper.cornerRadius != cornerRadius ||
        oldClipper.notchRadius != notchRadius;
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = currentIndex == index;

    return IconButton(
      onPressed: onTap,
      icon: Icon(
        isActive ? activeIcon : icon,
        size: AppSizes.floatingNavIconSize,
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _CartNavItem extends StatelessWidget {
  const _CartNavItem({
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = currentIndex == index;

    return IconButton(
      onPressed: onTap,
      icon: BlocBuilder<CartCubit, CartState>(
        builder: (context, cartState) {
          var itemCount = 0;

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
                size: AppSizes.floatingNavIconSize,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              if (itemCount > 0)
                Positioned(
                  right: -AppSpacing.sm,
                  top: -AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxs + 1,
                      vertical: AppSpacing.xxs / 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.badgeBackground,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: AppSizes.cartBadgeMinSize,
                      minHeight: AppSizes.cartBadgeMinSize,
                    ),
                    child: Text(
                      itemCount > 9 ? '9+' : '$itemCount',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.badgeForeground,
                        fontSize: AppSizes.cartBadgeFontSize,
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
