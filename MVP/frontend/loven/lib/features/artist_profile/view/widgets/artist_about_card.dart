import 'package:flutter/material.dart';

import '../../../../core/res/theme/app_colors.dart';
import '../../model/artist_model.dart';

class ArtistAboutCard extends StatelessWidget {
  const ArtistAboutCard({
    super.key,
    required this.artist,
  });

  final ArtistModel artist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasBio = artist.bio != null && artist.bio!.trim().isNotEmpty;
    final hasShipping = artist.shippingPolicy != null &&
        artist.shippingPolicy!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About the Artist',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasBio
                  ? artist.bio!
                  : 'This artist has not added a bio yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.55,
                color: Colors.black.withValues(alpha: hasBio ? 0.68 : 0.42),
                fontStyle: hasBio ? FontStyle.normal : FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _ArtistTag(label: 'Digital Art'),
                _ArtistTag(label: 'Original Artwork'),
                _ArtistTag(label: 'Marketplace Seller'),
              ],
            ),
            if (hasShipping) ...[
              const SizedBox(height: 18),
              Divider(
                color: Colors.black.withValues(alpha: 0.06),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 18,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      artist.shippingPolicy!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black.withValues(alpha: 0.58),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ArtistTag extends StatelessWidget {
  const _ArtistTag({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.16),
      side: BorderSide.none,
      labelStyle: const TextStyle(
        color: AppColors.primaryBlue,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    );
  }
}