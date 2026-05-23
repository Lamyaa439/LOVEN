import 'package:flutter/material.dart';
import 'package:loven/core/res/theme/app_colors.dart';
import '../../splash/splash_screen.dart'; // Adjust path if needed to point to your login/splash

class GuestSettingsScreen extends StatelessWidget {
  const GuestSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
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

          // 2. PROMOTIONAL CTA (Encouraging guests to sign up)
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
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SplashScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text('Sign Up / Login'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Re-using your helper methods for visual consistency
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
