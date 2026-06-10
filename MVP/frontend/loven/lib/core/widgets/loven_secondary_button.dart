import 'package:flutter/material.dart';
import 'package:loven/core/res/dimensions/app_sizes.dart';

/// Quiet outlined action — uses [OutlinedButtonTheme] from [AppTheme].
class LovenSecondaryButton extends StatelessWidget {
  const LovenSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = icon != null
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: AppSizes.iconSm),
            label: Text(label),
          )
        : OutlinedButton(
            onPressed: onPressed,
            child: Text(label),
          );

    if (!expand) return button;

    return SizedBox(width: double.infinity, child: button);
  }
}
