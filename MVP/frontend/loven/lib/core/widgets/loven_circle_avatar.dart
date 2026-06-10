import 'package:flutter/material.dart';
import 'package:loven/core/res/design_system.dart';

/// Circular avatar with network loading and graceful fallback.
class LovenCircleAvatar extends StatelessWidget {
  const LovenCircleAvatar({
    super.key,
    required this.imageUrl,
    required this.radius,
    this.fallbackLabel,
    this.fallbackIcon = Icons.person_rounded,
  });

  final String? imageUrl;
  final double radius;
  final String? fallbackLabel;
  final IconData fallbackIcon;

  bool get _hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diameter = radius * 2;

    if (!_hasImage) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surfaceSoft,
        child: _buildFallback(theme),
      );
    }

    return ClipOval(
      child: Image.network(
        imageUrl!.trim(),
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.surfaceSoft,
            child: _buildFallback(theme),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.surfaceSoft,
            child: SizedBox(
              width: AppSizes.iconMd,
              height: AppSizes.iconMd,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFallback(ThemeData theme) {
    final label = fallbackLabel?.trim();
    if (label != null && label.isNotEmpty) {
      return Text(
        label[0].toUpperCase(),
        style: theme.textTheme.titleLarge?.copyWith(
          color: AppColors.brandPrimary,
        ),
      );
    }

    return Icon(
      fallbackIcon,
      color: theme.colorScheme.primary,
      size: AppSizes.iconMd,
    );
  }
}
