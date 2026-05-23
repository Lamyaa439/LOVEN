import 'package:flutter/material.dart';
import 'package:loven/core/res/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // appBar: AppBar(
      //   title: const Text('Settings', style: TextStyle(color: Colors.white)),
      //   backgroundColor: AppColors.primaryPurple,
      //   iconTheme: const IconThemeData(color: Colors.white),
      // ),
      child: ListView(
        children: [
          // Account Management (Only for logged-in users)

          _buildSectionHeader(theme, 'Account Management'),
          _buildSettingsTile(
            icon: Icons.email_outlined,
            title: 'Change Email',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Password',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.delete_forever_outlined,
            title: 'Delete Account',
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {},
          ),

          const Divider(),

          // APP PREFERENCES
          _buildSectionHeader(theme, 'App Preferences'),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'Language (EN/AR)',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.notifications_none,
            title: 'Notifications',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: AppColors.primaryPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primaryPurple),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
