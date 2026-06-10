import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/artist_profile/controller/artist_profile_cubit.dart';
import 'package:loven/features/artist_profile/controller/artist_profile_state.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/auth/data/models/auth_user.dart';
import 'package:loven/features/navigation/controller/cubit/navigation_bar_cubit.dart';
import 'package:loven/features/account/controller/cubit/account_cubit.dart';

/// Single account hub for guests and signed-in users (`/profile`).
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final user = authStateSessionUser(context.read<AuthCubit>().state);
      if (user?.systemRole == 'artist') {
        context.read<ArtistProfileCubit>().fetchMyProfileData();
      }
    });
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && mounted) {
      await context.read<AuthCubit>().logout();
    }
  }

  void _openFavoritesTab() {
    context.go(AppRoutes.home);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NavigationBarCubit>().navigateTo(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthGuest) {
          return const _GuestAccountView();
        }

        final user = authStateSessionUser(state);
        if (user != null) {
          return _SignedInAccountHub(
            user: user,
            onLogout: _confirmLogout,
            onOpenFavorites: _openFavoritesTab,
          );
        }

        return const GalleryLoadingState();
      },
    );
  }
}

class _SignedInAccountHub extends StatelessWidget {
  const _SignedInAccountHub({
    required this.user,
    required this.onLogout,
    required this.onOpenFavorites,
  });

  final AuthUser user;
  final VoidCallback onLogout;
  final VoidCallback onOpenFavorites;

  bool get _isArtist => user.systemRole == 'artist';

  Future<void> _changeRole(BuildContext context) async {
    final nextRole = _isArtist ? 'customer' : 'artist';

    await context.read<AccountCubit>().updateRole(systemRole: nextRole);

    if (nextRole == 'artist') {
      context.read<ArtistProfileCubit>().fetchMyProfileData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.lg,
          AppSpacing.screenPadding,
          AppSpacing.bottomNavClearance,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AccountHeader(
              name: user.name,
              email: user.email,
              imageUrl: user.profileImageUrl,
              role: user.systemRole,
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            const _AccountSectionHeader(title: 'Account'),
            _AccountTile(
              icon: Icons.person_outline,
              title: 'Account details',
              subtitle: 'Name, email, and account photo',
              onTap: () => context.push(AppRoutes.profileEdit),
            ),
            _AccountTile(
              icon: _isArtist ? Icons.person_outline : Icons.brush_outlined,
              title: _isArtist ? 'Switch to customer' : 'Become an artist',
              subtitle: _isArtist
                  ? 'Use LOVEN as a customer account'
                  : 'Create and showcase your artwork',
              onTap: () => _changeRole(context),
            ),
            _AccountTile(
              icon: Icons.location_on_outlined,
              title: 'Saved addresses',
              subtitle: 'Manage your delivery locations',
              onTap: () => context.push(AppRoutes.location),
            ),
            _AccountTile(
              icon: Icons.lock_outline,
              title: 'Change password',
              subtitle: 'Update your account password',
              onTap: () => context.push(AppRoutes.changePassword),
            ),
            if (_isArtist) ...[
              const SizedBox(height: AppSpacing.xl),
              const _AccountSectionHeader(title: 'Artist'),
              _AccountTile(
                icon: Icons.storefront_outlined,
                title: 'My artist profile',
                subtitle: 'Manage your storefront and portfolio',
                onTap: () => context.go(AppRoutes.myProfile),
              ),
              BlocBuilder<ArtistProfileCubit, ArtistProfileState>(
                builder: (context, artistState) {
                  final artist = artistState.artist;
                  if (artist == null) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      _AccountTile(
                        icon: Icons.inventory_2_outlined,
                        title: 'Incoming orders',
                        subtitle: 'Review and fulfill buyer orders',
                        onTap: () {
                          context.push(
                            AppRoutes.ordersIncoming,
                            extra: artist.id,
                          );
                        },
                      ),
                      if (!artist.isVerified)
                        _AccountTile(
                          icon: Icons.verified_outlined,
                          title: 'Request verification',
                          subtitle: 'Apply for a verified artist badge',
                          onTap: () {
                            context.go(AppRoutes.verificationRequest);
                          },
                        ),
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            const _AccountSectionHeader(title: 'Activity'),
            _AccountTile(
              icon: Icons.favorite_border,
              title: 'Your favorites',
              subtitle: 'Artworks you have saved',
              onTap: onOpenFavorites,
            ),
            _AccountTile(
              icon: Icons.shopping_bag_outlined,
              title: 'Order history',
              subtitle: 'View your previous orders',
              onTap: () => context.go(AppRoutes.ordersHistory),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _AccountSectionHeader(title: 'Support'),
            _AccountTile(
              icon: Icons.feedback_outlined,
              title: 'Send feedback',
              subtitle: 'Share your thoughts with us',
              onTap: () => context.go(AppRoutes.feedback),
            ),
            const SizedBox(height: AppSpacing.xl),
            _AccountTile(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              isDanger: true,
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountSectionHeader extends StatelessWidget {
  const _AccountSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.role,
  });

  final String name;
  final String email;
  final String? imageUrl;
  final String role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LovenSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          LovenCircleAvatar(
            imageUrl: imageUrl,
            radius: AppSizes.avatarLg / 2,
            fallbackLabel: name,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = isDanger ? AppColors.error : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: LovenSurfaceCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.avatarMd,
              height: AppSizes.avatarMd,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: iconColor, size: AppSizes.iconMd),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isDanger ? AppColors.error : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: AppSizes.iconMd,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestAccountView extends StatelessWidget {
  const _GuestAccountView();

  @override
  Widget build(BuildContext context) {
    return GalleryEmptyState(
      icon: Icons.person_outline,
      title: 'Sign in to view your profile',
      subtitle:
          'Create an account or log in to manage your orders, addresses, and more.',
      actionLabel: 'Sign up / Log in',
      onAction: () => context.push(AppRoutes.auth),
      usePrimaryAction: true,
    );
  }
}
