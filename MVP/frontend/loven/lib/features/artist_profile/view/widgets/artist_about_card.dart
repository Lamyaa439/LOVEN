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
    final colorScheme = theme.colorScheme;

    final hasBio = artist.bio != null && artist.bio!.trim().isNotEmpty;
    final hasShipping = artist.shippingPolicy != null &&
        artist.shippingPolicy!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowTint,
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
                color: hasBio
    ? colorScheme.onSurfaceVariant
    : colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
                fontStyle: hasBio ? FontStyle.normal : FontStyle.italic,
              ),
            ),
            if (hasShipping) ...[
              const SizedBox(height: 18),
              Divider(
                color: colorScheme.outlineVariant,
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      artist.shippingPolicy!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
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