import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/navigation/controller/cubit/navigation_bar_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _buildSectionHeader(theme, 'Account'),
          
          _buildSettingsTile(
            context: context,
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              context.push('/artist-profile/edit');
            },
          ),
          
          _buildSettingsTile(
            context: context,
            icon: Icons.location_on_outlined,
            title: 'Saved Addresses',
            onTap: () {},
          ),
          
          _buildSettingsTile(
            context: context,
            icon: Icons.phone_outlined,
            title: 'Phone Number',
            onTap: () {},
          ),
          
          _buildSettingsTile(
            context: context,
            icon: Icons.email_outlined,
            title: 'Change Email',
            onTap: () {},
          ),
          
          _buildSettingsTile(
            context: context,
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {},
          ),
          
          const SizedBox(height: 20),
          
          _buildSectionHeader(theme, 'Activity'),
          
          _buildSettingsTile(
            context: context,
            icon: Icons.favorite_border,
            title: 'Your Favorites',
            onTap: () {
              context.pop();
              context
              .read<NavigationBarCubit>()
              .navigateTo(1);
            },
          ),
          
          _buildSettingsTile(
            context: context,
            icon: Icons.shopping_bag_outlined,
            title: 'Order History',
            onTap: () {},
          ),
          
          const SizedBox(height: 20),
          
          _buildSettingsTile(
            context: context,
            icon: Icons.delete_forever_outlined,
            title: 'Delete Account',
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {},
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.logout,
            title: 'Logout',
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () async {
              final shouldLogout =
              await showDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text(
                      'Are you sure you want to logout?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                            false,
                          );
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                            true,
                          );
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
              if (shouldLogout == true) {
                await context
                .read<AuthCubit>()
                .logout();
                
                if (context.mounted) {
                  context.go('/auth');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: AppColors.primaryPurple,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
    Color? textColor,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.12),
          child: Icon(
            icon,
            color: iconColor ?? AppColors.primaryPurple,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        subtitle: subtitle == null ? null : Text(subtitle),
        trailing: const Icon(Icons.chevron_right, size: 22),
        onTap: onTap,
      ),
    );
  }
}