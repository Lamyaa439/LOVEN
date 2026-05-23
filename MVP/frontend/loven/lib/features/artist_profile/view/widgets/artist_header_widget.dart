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
    final hasShipping = artist.shippingPolicy != null &&
        artist.shippingPolicy!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor:
                      AppColors.primaryPurple.withValues(alpha: 0.35),
                  backgroundImage:
                      hasImage ? NetworkImage(artist.profileImageUrl!) : null,
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
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              artist.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (artist.isVerified) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.verified,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                      if (hasCity) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.55),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                artist.city!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        hasBio ? artist.bio! : 'No bio provided',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: hasBio
                              ? colorScheme.onSurface.withValues(alpha: 0.7)
                              : colorScheme.onSurface.withValues(alpha: 0.45),
                          fontStyle:
                              hasBio ? FontStyle.normal : FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Divider(
              color: colorScheme.onSurface.withValues(alpha: 0.08),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _ProfileStat(
                  icon: Icons.image_outlined,
                  value: '$artworkCount',
                  label: 'Artworks',
                ),
                const _VerticalDivider(),
                const _ProfileStat(
                  icon: Icons.favorite_border,
                  value: '0',
                  label: 'Favorites',
                ),
                const _VerticalDivider(),
                const _ProfileStat(
                  icon: Icons.shopping_bag_outlined,
                  value: '0',
                  label: 'Orders',
                ),
                const _VerticalDivider(),
                _ProfileStat(
                  icon: Icons.local_shipping_outlined,
                  value: hasShipping ? 'Yes' : '—',
                  label: 'Shipping',
                ),
              ],
            ),
          ],
        ),
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
            color: colorScheme.onSurface.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
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