import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/theme/app_colors.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/features/artist_profile/controller/artist_profile_cubit.dart';
import 'package:loven/features/artist_profile/controller/artist_profile_state.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/auth/data/models/auth_user.dart';
import 'package:loven/features/navigation/controller/cubit/navigation_bar_cubit.dart';
import 'package:loven/features/account/controller/cubit/account_cubit.dart';

/// Single account hub for guests and signed-in users (`/profile`).
///
/// Consolidates account, settings, and role-gated artist tools in one surface.
/// Session identity from [AuthCubit]; profile edits via [AccountCubit] on the edit route.
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
      if (!mounted) {
        return;
      }

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
      if (!mounted) {
        return;
      }
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

        return const Center(child: CircularProgressIndicator());
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

    await context.read<AccountCubit>().updateRole(
      systemRole: nextRole,
    );

    if (nextRole == 'artist') {
      context.read<ArtistProfileCubit>().fetchMyProfileData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AccountHeader(
              name: user.name,
              email: user.email,
              imageUrl: user.profileImageUrl,
              role: user.systemRole,
            ),
            const SizedBox(height: 28),
            _AccountSectionHeader(theme: theme, title: 'Account'),
            _AccountTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              subtitle: 'Update your personal information',
              onTap: () => context.push(AppRoutes.profileEdit),
            ),
            _AccountTile(
  icon: _isArtist
      ? Icons.person_outline
      : Icons.brush_outlined,
  title: _isArtist
      ? 'Switch to Customer'
      : 'Become an Artist',
  subtitle: _isArtist
      ? 'Use LOVEN as a customer account'
      : 'Create and showcase your artwork',
  onTap: () => _changeRole(context),
),
            _AccountTile(
              icon: Icons.location_on_outlined,
              title: 'Saved Addresses',
              subtitle: 'Manage your delivery locations',
              onTap: () => context.push(AppRoutes.location),
            ),
            _AccountTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your account password',
              onTap: () => context.push(AppRoutes.changePassword),
            ),
            if (_isArtist) ...[
              const SizedBox(height: 20),
              _AccountSectionHeader(theme: theme, title: 'Artist'),
              _AccountTile(
                icon: Icons.storefront_outlined,
                title: 'My Artist Profile',
                subtitle: 'Manage your storefront and portfolio',
                onTap: () => context.push(AppRoutes.myProfile),
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
                        title: 'Incoming Orders',
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
                          title: 'Request Verification',
                          subtitle: 'Apply for a verified artist badge',
                          onTap: () {
                            context.push(AppRoutes.verificationRequest);
                          },
                        ),
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: 20),
            _AccountSectionHeader(theme: theme, title: 'Activity'),
            _AccountTile(
              icon: Icons.favorite_border,
              title: 'Your Favorites',
              subtitle: 'Artworks you have saved',
              onTap: onOpenFavorites,
            ),
            _AccountTile(
              icon: Icons.shopping_bag_outlined,
              title: 'Order History',
              subtitle: 'View your previous orders',
              onTap: () => context.push(AppRoutes.ordersHistory),
            ),
            const SizedBox(height: 20),
            _AccountSectionHeader(theme: theme, title: 'Support'),
            _AccountTile(
              icon: Icons.feedback_outlined,
              title: 'Send Feedback',
              subtitle: 'Share your thoughts with us',
              onTap: () => context.push(AppRoutes.feedback),
            ),
            const SizedBox(height: 24),
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
  const _AccountSectionHeader({
    required this.theme,
    required this.title,
  });

  final ThemeData theme;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: AppColors.primaryPurple,
          fontWeight: FontWeight.w800,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.95),
            colorScheme.primary.withValues(alpha: 0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                ? NetworkImage(imageUrl!)
                : null,
            child: imageUrl == null || imageUrl!.isEmpty
                ? const Icon(
                    Icons.person,
                    size: 38,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
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
    final color = isDanger ? Colors.red : Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDanger ? Colors.red : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).hintColor,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _GuestAccountView extends StatelessWidget {
  const _GuestAccountView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            const Text(
              'Sign in to view your profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create an account or log in to manage your orders, address, and profile.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
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
