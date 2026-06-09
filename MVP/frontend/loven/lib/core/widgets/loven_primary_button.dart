import 'package:flutter/material.dart';
import 'package:loven/core/res/dimensions/app_sizes.dart';

/// Full-width primary CTA — uses [ElevatedButtonTheme] from [AppTheme].
class LovenPrimaryButton extends StatelessWidget {
  const LovenPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            width: AppSizes.iconMd,
            height: AppSizes.iconMd,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: AppSizes.iconSm),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              )
            : Text(label);

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: child,
    );

    if (!expand) return button;

    return SizedBox(
      width: double.infinity,
      child: button,
    );
  }
}
