import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../auth/login_screen.dart';

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Section
            Container(
              padding: const EdgeInsets.all(24),
              color: AppColors.cardBackground,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryNavy,
                    child: Text(
                      Helpers.getInitials(user?.displayName ?? ''),
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? 'User',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (user?.emailVerified == true) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Email Verified',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            
            // Notification Settings
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Notification Preferences',
                style: AppTextStyles.h4,
              ),
            ),
            Consumer<SettingsProvider>(
              builder: (context, settingsProvider, _) {
                return SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive notifications for swap offers'),
                  value: settingsProvider.notificationsEnabled,
                  onChanged: (value) {
                    settingsProvider.toggleNotifications(
                      authProvider.currentUserId!,
                      value,
                    );
                  },
                  activeTrackColor: AppColors.primaryNavy.withAlpha(100),
                  activeThumbColor: AppColors.primaryNavy,
                );
              },
            ),
            Consumer<SettingsProvider>(
              builder: (context, settingsProvider, _) {
                return SwitchListTile(
                  title: const Text('Email Updates'),
                  subtitle: const Text('Receive updates via email'),
                  value: settingsProvider.emailUpdates,
                  onChanged: (value) {
                    settingsProvider.toggleEmailUpdates(value);
                  },
                  activeTrackColor: AppColors.primaryNavy.withAlpha(100),
                  activeThumbColor: AppColors.primaryNavy,
                );
              },
            ),
            
            const Divider(height: 32),
            
            // About Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'About',
                style: AppTextStyles.h4,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('App Version'),
              subtitle: const Text('1.0.0'),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Terms of Service'),
              onTap: () {
                // TODO: Implement terms of service
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              onTap: () {
                // TODO: Implement privacy policy
              },
            ),
            
            const Divider(height: 32),
            
            // Sign Out Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirm == true && context.mounted) {
                    await authProvider.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.textWhite,
                ),
                child: const Text('Sign Out'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
