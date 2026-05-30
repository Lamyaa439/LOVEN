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
        artist.profileImageUrl != null &&
        artist.profileImageUrl!.isNotEmpty;

    final hasCity =
        artist.city != null &&
        artist.city!.trim().isNotEmpty;

    final hasBio =
        artist.bio != null &&
        artist.bio!.trim().isNotEmpty;

    final hasShipping =
        artist.shippingPolicy != null &&
        artist.shippingPolicy!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: 90,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryPurple.withValues(alpha: 0.85),
                      AppColors.primaryBlue.withValues(alpha: 0.82),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -24,
                      top: -18,
                      child: Icon(
                        Icons.palette_outlined,
                        size: 120,
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    Positioned(
                      left: -18,
                      bottom: -26,
                      child: Icon(
                        Icons.brush_outlined,
                        size: 110,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 72,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.scaffoldBackgroundColor,
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor:
                        AppColors.primaryPurple.withValues(alpha: 0.22),
                    backgroundImage: hasImage
                        ? NetworkImage(artist.profileImageUrl!)
                        : null,
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
                ),
              ),
            ],
          ),

          const SizedBox(height: 72),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  artist.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800,)
                  .copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (artist.isVerified) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.verified_rounded,
                  size: 18,
                  color: AppColors.primaryBlue,
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),

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
                Text(
                  artist.city!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.62),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 22),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.07),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasBio
                      ? artist.bio!
                      : 'This artist has not added a bio yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: hasBio
                        ? colorScheme.onSurface.withValues(alpha: 0.68)
                        : colorScheme.onSurface.withValues(alpha: 0.45),
                    height: 1.5,
                    fontStyle: hasBio ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primaryPurple.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                _SoftStat(
                  icon: Icons.image_outlined,
                  value: '$artworkCount',
                  label: 'Artworks',
                ),
                const _VerticalDivider(),
                _SoftStat(
                  icon: Icons.verified_outlined,
                  value: artist.isVerified ? 'Verified' : 'Pending',
                  label: 'Status',
                ),
                const _VerticalDivider(),
                _SoftStat(
                  icon: Icons.local_shipping_outlined,
                  value: hasShipping ? 'Available' : '—',
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

class _SoftStat extends StatelessWidget {
  const _SoftStat({
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

    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.52),
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
      color: Theme.of(context)
          .colorScheme
          .onSurface
          .withValues(alpha: 0.08),
    );
  }
}