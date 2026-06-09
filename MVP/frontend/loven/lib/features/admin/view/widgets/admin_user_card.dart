import 'package:flutter/material.dart';

class AdminUserCard extends StatelessWidget {
  const AdminUserCard({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.onToggleStatus,
  });

  final String name;
  final String email;
  final String role;
  final bool isActive;
  final VoidCallback onToggleStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isActive
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.errorContainer,
              child: Icon(
                Icons.person_outline,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(email),
                  const SizedBox(height: 6),
                  Text(
                    '${role.toUpperCase()} • ${isActive ? 'ACTIVE' : 'DISABLED'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onToggleStatus,
              child: Text(isActive ? 'Disable' : 'Reactivate'),
            ),
          ],
        ),
      ),
    );
  }
}