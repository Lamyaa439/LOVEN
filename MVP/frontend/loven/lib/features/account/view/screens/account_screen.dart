import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/storage/app_preferences.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/artist_profile/controller/artist_profile_cubit.dart';
import 'package:loven/features/artist_profile/controller/artist_profile_state.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/auth/data/models/auth_user.dart';
import 'package:loven/features/navigation/controller/cubit/navigation_bar_cubit.dart';
import 'package:loven/features/account/controller/cubit/account_cubit.dart';
import 'package:loven/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.logout),
          content: Text(l10n.logoutConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.logout),
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

  bool get _isArtist => user.systemRole == AuthUser.roleArtist;

  Future<void> _changeRole(BuildContext context) async {
    final nextRole = _isArtist ? AuthUser.roleCustomer : AuthUser.roleArtist;

    await context.read<AccountCubit>().updateRole(systemRole: nextRole);

    if (nextRole == AuthUser.roleArtist) {
      context.read<ArtistProfileCubit>().fetchMyProfileData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
            _AccountSectionHeader(title: l10n.account),
            if (!_isArtist)
              _AccountTile(
                icon: Icons.person_outline,
                title: l10n.accountDetails,
                subtitle: l10n.accountDetailsSubtitle,
                onTap: () => context.push(AppRoutes.profileEdit),
              ),
            _AccountTile(
              icon: _isArtist ? Icons.person_outline : Icons.brush_outlined,
              title: _isArtist ? l10n.switchToCustomer : l10n.becomeArtist,
              subtitle:
                  _isArtist ? l10n.useLovenAsCustomer : l10n.createAndShowcase,
              onTap: () => _changeRole(context),
            ),
            _AccountTile(
              icon: Icons.location_on_outlined,
              title: l10n.savedAddresses,
              subtitle: l10n.manageDelivery,
              onTap: () => context.push(AppRoutes.location),
            ),
            _AccountTile(
              icon: Icons.lock_outline,
              title: l10n.changePassword,
              subtitle: l10n.updatePassword,
              onTap: () => context.push(AppRoutes.changePassword),
            ),
            if (_isArtist) ...[
              const SizedBox(height: AppSpacing.xl),
              _AccountSectionHeader(title: l10n.artist),
              _AccountTile(
                icon: Icons.storefront_outlined,
                title: l10n.myArtistProfile,
                subtitle: l10n.manageStorefront,
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
                        title: l10n.incomingOrders,
                        subtitle: l10n.reviewOrders,
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
                          title: l10n.requestVerification,
                          subtitle: l10n.applyVerifiedBadge,
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
            _AccountSectionHeader(title: l10n.activity),
            _AccountTile(
                icon: Icons.favorite_border,
                title: l10n.yourFavorites,
                subtitle: l10n.savedArtworks,
                onTap: onOpenFavorites),
            _AccountTile(
                icon: Icons.shopping_bag_outlined,
                title: l10n.orderHistory,
                subtitle: l10n.viewPreviousOrders,
                onTap: () => context.go(AppRoutes.ordersHistory)),
            const SizedBox(height: AppSpacing.xl),
            _AccountSectionHeader(title: l10n.support),
            _AccountTile(
                icon: Icons.feedback_outlined,
                title: l10n.sendFeedback,
                subtitle: l10n.shareThoughts,
                onTap: () => context.go(AppRoutes.feedback)),
            _AccountSectionHeader(title: l10n.language),
            _AccountTile(
              icon: Icons.language_outlined,
              title: l10n.language,
              subtitle: l10n.currentLanguage,
              onTap: () {
                // 1. Get the current language code
                final appPrefs = context.read<AppPreferences>();
                final currentCode = appPrefs.languageCode;

                // 2. Toggle the code
                final newCode = currentCode == 'ar' ? 'en' : 'ar';
                appPrefs.setLanguageCode(newCode);
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            _AccountTile(
                icon: Icons.logout,
                title: l10n.logout,
                subtitle: l10n.signOut,
                isDanger: true,
                onTap: onLogout),
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final String localizedRole =
        role == AuthUser.roleArtist ? l10n.artist : l10n.customer;

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
                    localizedRole.toUpperCase(),
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
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.avatarSm,
              height: AppSizes.avatarSm,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: iconColor, size: AppSizes.iconSm),
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
    final l10n = AppLocalizations.of(context)!;

    return GalleryEmptyState(
      icon: Icons.person_outline,
      title: l10n.signIn,
      subtitle: l10n.signInSubtitle,
      actionLabel: l10n.signUp,
      onAction: () => context.push(AppRoutes.auth),
      usePrimaryAction: true,
    );
  }
}
