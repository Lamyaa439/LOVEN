import 'package:flutter/material.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';

/// Display name for checkout copy when available locally; otherwise email.
String checkoutUserDisplayLabel(AuthState state) {
  final user = authStateSessionUser(state);
  if (user == null) {
    return 'your account';
  }

  final name = user.name.trim();
  if (name.isNotEmpty) {
    return name;
  }

  return user.email;
}

/// Shared checkout presentation helpers — tokenized for LOVEN design system.
class CheckoutSectionTitle extends StatelessWidget {
  const CheckoutSectionTitle({
    super.key,
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.textMuted,
          size: AppSizes.iconMd,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(title, style: theme.textTheme.headlineSmall),
      ],
    );
  }
}

class CheckoutFieldSection extends StatelessWidget {
  const CheckoutFieldSection({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
  }
}

BoxDecoration checkoutCardDecoration(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    border: Border.all(color: AppColors.borderLight),
  );
}

InputDecoration checkoutInputDecoration({
  required String hint,
  required IconData icon,
}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, size: AppSizes.iconSm),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.inputBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.inputBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(
        color: AppColors.inputBorderFocused,
        width: 1.2,
      ),
    ),
  );
}

/// Legacy aliases — keep imports stable across checkout steps.
typedef SectionTitle = CheckoutSectionTitle;
typedef FieldSection = CheckoutFieldSection;

InputDecoration checkoutDecoration({
  required String hint,
  required IconData icon,
}) =>
    checkoutInputDecoration(hint: hint, icon: icon);
