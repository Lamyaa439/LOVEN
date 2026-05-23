import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/theme/app_colors.dart';

class GuestSettingsWidget extends StatelessWidget {
  const GuestSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // 1. APP PREFERENCES
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

        const Divider(height: 40),

        // 2. PROMOTIONAL CTA
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Icon(Icons.auto_awesome,
                  size: 40, color: AppColors.primaryPurple),
              const SizedBox(height: 16),
              const Text(
                'Join the LOVEN Community',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Create an account to save favorites, follow artists, and manage your orders.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // UPDATED: Use go_router for clean navigation
                    context.push('/auth');
                  },
                  child: const Text('Sign Up / Login'),
                ),
              ),
            ],
          ),
        ),
      ],
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
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryPurple),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
