import 'package:flutter/material.dart';

import '../../../../core/res/theme/app_colors.dart';
import '../../model/artist_model.dart';
import '../../../../core/res/responsive/responsive_extensions.dart';
import '../../../../core/res/dimensions/app_spacing.dart';

class ArtistProfileHeroWidget extends StatelessWidget {
  const ArtistProfileHeroWidget({
    super.key,
    required this.artist,
    required this.artworkCount,
    required this.isOwner,
    required this.onUpload,
    required this.onEdit,
  });

  final ArtistModel artist;
  final int artworkCount;
  final bool isOwner;
  final VoidCallback onUpload;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage =
        artist.profileImageUrl != null && artist.profileImageUrl!.isNotEmpty;
    final hasCoverImage =
      artist.coverImageUrl != null && artist.coverImageUrl!.isNotEmpty;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
  height: context.responsive(mobile: 160, tablet: 200, desktop: 220),
  width: double.infinity,
  decoration: BoxDecoration(
    gradient: hasCoverImage
        ? null
        : const LinearGradient(
            colors: [
              AppColors.primaryPurple,
              AppColors.deepPurple,
              AppColors.primaryBlue,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
              color: Colors.black.withValues(alpha: 0.18),
            ),
          ),
        )
      else ...[
        Positioned(
          top: -20,
          right: -20,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: context.responsive(mobile: -40, tablet: -46),
          left: -30,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const Center(
          child: Icon(
            Icons.auto_awesome,
            size: 120,
            color: Colors.white54,
          ),
        ),
      ],
    ],
  ),
),
            Positioned(
              bottom: context.responsive(mobile: -40, tablet: -46),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
  radius: context.responsive(mobile: 40, tablet: 48),
                  backgroundColor: AppColors.primaryPurple,
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
              ),
            ),
          ],
        ),
        SizedBox(
  height: context.responsive(
    mobile: 52,
    tablet: 60,
  ),
),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              artist.displayName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            if (artist.isVerified) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.verified_rounded,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ],
          ],
        ),
        if (artist.city != null && artist.city!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            artist.city!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
Text(
  'Digital Artist • Contemporary Art',
  style: theme.textTheme.bodySmall?.copyWith(
    color: Colors.black54,
    fontWeight: FontWeight.w600,
  ),
),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (isOwner)
          Padding(
            padding: EdgeInsets.symmetric(
  horizontal: context.responsive(
    mobile: 16,
    tablet: 24,
  ),
),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
  onPressed: onUpload,
  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
  label: const Text('Upload'),
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryBlue,
    foregroundColor: Colors.white,
    elevation: 0,
    minimumSize: Size.fromHeight(
  context.responsive(
    mobile: 42,
    tablet: 44,
  ),
),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
  onPressed: onEdit,
  icon: const Icon(Icons.edit_outlined, size: 18),
  label: const Text('Edit'),
  style: OutlinedButton.styleFrom(
    foregroundColor: AppColors.primaryBlue,
    minimumSize: Size.fromHeight(
  context.responsive(
    mobile: 42,
    tablet: 44,
  ),
),
    side: BorderSide(
      color: AppColors.primaryBlue.withValues(alpha: 0.25),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(
  horizontal: context.responsive(
    mobile: 12,
    tablet: 18,
  ),
),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: context.responsive(
  mobile: 1.25,
  tablet: 1.5,
),
            children: [
              _StatCard(
                icon: Icons.palette_outlined,
                value: '$artworkCount',
                label: 'Artworks',
              ),
              _StatCard(
                icon: Icons.verified_outlined,
                value: artist.isVerified ? 'Verified' : 'Pending',
                label: 'Status',
              ),
              _StatCard(
                icon: Icons.local_shipping_outlined,
                value: artist.shippingPolicy?.isNotEmpty == true
                    ? 'Available'
                    : '—',
                label: 'Shipping',
              ),
              const _StatCard(
                icon: Icons.shopping_bag_outlined,
                value: 'Seller',
                label: 'Account',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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

    return Container(
      padding: EdgeInsets.all(
  context.responsive(
    mobile: 10,
    tablet: 14,
  ),
),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
  context.responsive(
    mobile: 16,
    tablet: 22,
  ),
),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(icon, color: AppColors.deepPurple, size: 18),
    const SizedBox(height: 8),
    Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w900,
        fontSize: 18,
      ),
    ),
    const SizedBox(height: 2),
    Text(
      label.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(
        color: Colors.black45,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
    ),
  ],
),
    );
  }
}