import 'package:flutter/material.dart';

import '../../../../core/res/theme/app_colors.dart';
import '../../model/artist_model.dart';

class ArtistHeaderWidget extends StatelessWidget {
  const ArtistHeaderWidget({
    super.key,
    required this.artist,
    required this.artworkCount,
  });

  final ArtistModel artist;
  final int artworkCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasImage =
        artist.profileImageUrl != null && artist.profileImageUrl!.isNotEmpty;
    final hasCity = artist.city != null && artist.city!.trim().isNotEmpty;
    final hasBio = artist.bio != null && artist.bio!.trim().isNotEmpty;
    final hasShipping =
        artist.shippingPolicy != null && artist.shippingPolicy!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 58,
            backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.30),
            backgroundImage: hasImage ? NetworkImage(artist.profileImageUrl!) : null,
            child: hasImage
                ? null
                : Text(
                    artist.displayName.isNotEmpty
                        ? artist.displayName[0].toUpperCase()
                        : '?',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),

          const SizedBox(height: 10),

          Text(
            'Artist',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  artist.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (artist.isVerified) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.verified_rounded,
                  size: 22,
                  color: colorScheme.primary,
                ),
              ],
            ],
          ),

          if (hasCity) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    artist.city!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 22),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'About',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              hasBio ? artist.bio! : 'No bio provided.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: hasBio
                    ? colorScheme.onSurface.withValues(alpha: 0.65)
                    : colorScheme.onSurface.withValues(alpha: 0.45),
                height: 1.45,
                fontStyle: hasBio ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 22),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                _ProfileStat(
                  icon: Icons.image_outlined,
                  value: '$artworkCount',
                  label: 'Artworks',
                ),
                const _VerticalDivider(),
                _ProfileStat(
                  icon: Icons.verified_outlined,
                  value: artist.isVerified ? 'Yes' : 'No',
                  label: 'Verified',
                ),
                const _VerticalDivider(),
                _ProfileStat(
                  icon: Icons.local_shipping_outlined,
                  value: hasShipping ? 'Yes' : '—',
                  label: 'Shipping',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      width: 1,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
    );
  }
}