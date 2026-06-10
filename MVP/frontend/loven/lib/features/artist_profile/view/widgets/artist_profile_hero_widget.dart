import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';

/// Editorial artist identity header — cover, avatar, name, and real stats only.
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
