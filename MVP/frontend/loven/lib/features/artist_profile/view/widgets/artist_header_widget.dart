import 'package:flutter/material.dart';

import '../../../../core/res/theme/app_colors.dart';
import '../../model/artist_model.dart';

/// Profile header — presentation only; styling comes from [Theme] + [AppColors].
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
    final hasBio = artist.bio != null && artist.bio!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: AppColors.primaryPurple,
            backgroundImage:
                hasImage ? NetworkImage(artist.profileImageUrl!) : null,
            child: hasImage
                ? null
                : Text(
                    artist.displayName.isNotEmpty
                        ? artist.displayName[0].toUpperCase()
                        : '?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryBlue,
                      fontSize: 40,
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  artist.displayName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
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

          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: artist.isVerified
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colorScheme.onSurface.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  artist.isVerified
                  ? Icons.verified
                  : Icons.pending_outlined,
                  size: 16,
                  color: artist.isVerified
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.55),
                ),
                const SizedBox(width: 6),
                Text(
                  artist.isVerified
                  ? 'Verified Artist'
                  : 'Not verified yet',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: artist.isVerified
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          if (artist.city != null && artist.city!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              artist.city!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],

          const SizedBox(height: 12),
          Text(
            hasBio ? artist.bio! : 'No bio provided',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              fontSize: 14,
              color: hasBio
                  ? colorScheme.onSurface.withValues(alpha: 0.87)
                  : colorScheme.onSurface.withValues(alpha: 0.45),
              fontStyle: hasBio ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
