import 'package:flutter/material.dart';

import '../../../../core/res/dimensions/app_spacing.dart';
import '../../../../core/res/responsive/responsive_extensions.dart';
import '../../../../core/res/theme/app_colors.dart';
import '../../model/artist_model.dart';

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
          ),
        ),
      ],
    );
  }
}

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
    );
  }
}