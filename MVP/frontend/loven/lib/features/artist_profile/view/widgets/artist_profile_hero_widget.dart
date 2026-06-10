import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';

<<<<<<< HEAD
import '../../../../core/res/dimensions/app_spacing.dart';
import '../../../../core/res/responsive/responsive_extensions.dart';
import '../../../../core/res/theme/app_colors.dart';
import '../../model/artist_model.dart';

=======
/// Editorial artist identity header — cover, avatar, name, and real stats only.
>>>>>>> 9f02d84a284267ff8822af9136379e2bd9b99522
class ArtistProfileHeroWidget extends StatelessWidget {
  const ArtistProfileHeroWidget({
    super.key,
    required this.artist,
    required this.artworkCount,
    required this.isOwner,
    required this.onEdit,
  });

  final ArtistModel artist;
  final int artworkCount;
  final bool isOwner;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
<<<<<<< HEAD
    final colorScheme = theme.colorScheme;

    final hasProfileImage =
        artist.profileImageUrl != null && artist.profileImageUrl!.isNotEmpty;
    final hasCoverImage =
        artist.coverImageUrl != null && artist.coverImageUrl!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.responsive(mobile: 16, tablet: 24),
        AppSpacing.md,
        context.responsive(mobile: 16, tablet: 24),
        AppSpacing.lg,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(
            context.responsive(mobile: 28, tablet: 32),
          ),
          border: Border.all(
            color: colorScheme.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowTint,
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(
                      context.responsive(mobile: 28, tablet: 32),
                    ),
                  ),
                  child: Container(
                    height: context.responsive(
                      mobile: 150,
                      tablet: 190,
                      desktop: 210,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: hasCoverImage
                          ? null
                          : AppColors.brandWash,
                      image: hasCoverImage
                          ? DecorationImage(
                              image: NetworkImage(artist.coverImageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: Stack(
                      children: [
                        if (hasCoverImage)
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppColors.heroBottomGradient,
                              ),
                            ),
                          )
                        else
                          Center(
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              size: 72,
                              color: AppColors.brandSecondary.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -42,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: context.responsive(mobile: 42, tablet: 48),
                      backgroundColor: AppColors.brandAccent.withValues(
                        alpha: 0.55,
                      ),
                      backgroundImage: hasProfileImage
                          ? NetworkImage(artist.profileImageUrl!)
                          : null,
                      child: hasProfileImage
                          ? null
                          : Text(
                              artist.displayName.isNotEmpty
                                  ? artist.displayName[0].toUpperCase()
                                  : '?',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(
              height: context.responsive(mobile: 56, tablet: 62),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: Column(
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    children: [
                      Text(
                        artist.displayName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (artist.isVerified)
                        Icon(
                          Icons.verified_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    _subtitleForArtist(artist),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  if (isOwner) ...[
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit Profile'),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),

                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          value: '$artworkCount',
                          label: 'Artworks',
                        ),
                      ),
                      _StatDivider(color: colorScheme.outlineVariant),
                      Expanded(
                        child: _StatTile(
                          value: artist.isVerified ? 'Verified' : 'Pending',
                          label: 'Status',
                        ),
                      ),
                      _StatDivider(color: colorScheme.outlineVariant),
                      Expanded(
                        child: _StatTile(
                          value: artist.shippingPolicy?.isNotEmpty == true
                              ? 'Available'
                              : '—',
                          label: 'Shipping',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitleForArtist(ArtistModel artist) {
    final city = artist.city;

    if (city != null && city.isNotEmpty) {
      return '$city • Digital Artist';
    }

    return 'Digital Artist';
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
=======
    final sessionUser = isOwner
        ? authStateSessionUser(context.watch<AuthCubit>().state)
        : null;
    final resolvedImageUrl = _resolveProfileImageUrl(sessionUser?.profileImageUrl);
    final hasCover =
        artist.coverImageUrl != null && artist.coverImageUrl!.isNotEmpty;
    final hasCity = artist.city != null && artist.city!.trim().isNotEmpty;
    final hasShipping =
        artist.shippingPolicy != null && artist.shippingPolicy!.trim().isNotEmpty;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            _CoverBanner(
              coverImageUrl: hasCover ? artist.coverImageUrl : null,
            ),
            Positioned(
              bottom: -(AppSizes.avatarXl / 2),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xxs),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: LovenCircleAvatar(
                  imageUrl: resolvedImageUrl,
                  radius: AppSizes.avatarXl / 2,
                  fallbackLabel: artist.displayName,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: (AppSizes.avatarXl / 2) + AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      artist.displayName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                  if (artist.isVerified) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.verified_rounded,
                      color: AppColors.brandPrimary,
                      size: AppSizes.iconMd,
                    ),
                  ],
                ],
              ),
              if (hasCity) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  artist.city!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              _ArtistStatsRow(
                artworkCount: artworkCount,
                isVerified: artist.isVerified,
                hasShipping: hasShipping,
              ),
              if (isOwner) ...[
                const SizedBox(height: AppSpacing.lg),
                LovenSecondaryButton(
                  label: 'Edit artist profile',
                  icon: Icons.edit_outlined,
                  expand: false,
                  onPressed: onEdit,
                ),
              ],
            ],
>>>>>>> 9f02d84a284267ff8822af9136379e2bd9b99522
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
      ],
    );
  }

  String? _resolveProfileImageUrl(String? accountImageUrl) {
    final artistImage = artist.profileImageUrl?.trim();
    if (artistImage != null && artistImage.isNotEmpty) {
      return artistImage;
    }

    final accountImage = accountImageUrl?.trim();
    if (isOwner && accountImage != null && accountImage.isNotEmpty) {
      return accountImage;
    }

    return null;
  }
}

class _CoverBanner extends StatelessWidget {
  const _CoverBanner({this.coverImageUrl});

  final String? coverImageUrl;

  @override
  Widget build(BuildContext context) {
    final hasCover = coverImageUrl != null && coverImageUrl!.isNotEmpty;

    return SizedBox(
      height: AppSizes.discoverFeaturedHeight,
      width: double.infinity,
      child: hasCover
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  coverImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _CoverFallback(),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.heroBottomGradient,
                  ),
                ),
              ],
            )
          : const _CoverFallback(),
    );
  }
}

<<<<<<< HEAD
class _StatDivider extends StatelessWidget {
  const _StatDivider({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: color,
=======
class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceSoft,
            AppColors.brandAccent.withValues(alpha: 0.35),
            AppColors.brandPrimary.withValues(alpha: 0.18),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.brush_outlined,
          size: AppSizes.iconLg * 2,
          color: AppColors.favoriteEmpty,
        ),
      ),
    );
  }
}

class _ArtistStatsRow extends StatelessWidget {
  const _ArtistStatsRow({
    required this.artworkCount,
    required this.isVerified,
    required this.hasShipping,
  });

  final int artworkCount;
  final bool isVerified;
  final bool hasShipping;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final stats = <Widget>[
      _StatChip(
        label: artworkCount == 1 ? '1 work' : '$artworkCount works',
      ),
      if (isVerified)
        _StatChip(
          label: 'Verified',
          icon: Icons.verified_outlined,
        ),
      if (hasShipping)
        _StatChip(
          label: 'Ships',
          icon: Icons.local_shipping_outlined,
        ),
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: stats
          .map(
            (chip) => DefaultTextStyle(
              style: theme.textTheme.labelMedium!.copyWith(
                color: AppColors.textSecondary,
              ),
              child: chip,
            ),
          )
          .toList(),
>>>>>>> 9f02d84a284267ff8822af9136379e2bd9b99522
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    this.icon,
  });

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSizes.iconSm, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(label),
        ],
      ),
    );
  }
}
