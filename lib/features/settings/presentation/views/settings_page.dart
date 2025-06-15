import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../states/settings_state.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../providers/settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsControllerProvider);
    final currentTheme = ref.watch(currentThemeModeProvider);
    final currentLanguage = ref.watch(currentLanguageProvider);
    final pushNotificationsEnabled = ref.watch(
      pushNotificationsEnabledProvider,
    );
    final vibrationEnabled = ref.watch(vibrationEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: _buildBody(
        context,
        settingsState,
        currentTheme,
        currentLanguage,
        pushNotificationsEnabled,
        vibrationEnabled,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SettingsState settingsState,
    String currentTheme,
    String currentLanguage,
    bool pushNotificationsEnabled,
    bool vibrationEnabled,
  ) {
    if (settingsState is SettingsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (settingsState is SettingsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              settingsState.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Retry loading settings
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Appearance Section
          SettingsSection(
            title: 'Appearance',
            icon: Icons.palette,
            children: [
              SettingsDropdownTile<String>(
                title: 'Theme',
                subtitle: 'Choose your preferred theme',
                leadingIcon: Icons.brightness_6,
                value: currentTheme,
                items: const [
                  DropdownMenuItem(value: 'light', child: Text('Light')),
                  DropdownMenuItem(value: 'dark', child: Text('Dark')),
                  DropdownMenuItem(value: 'system', child: Text('System')),
                ],
                onChanged: (value) {
                  // Will implement functionality later
                  if (value != null) {
                    _showComingSoonDialog(context, 'Theme switching');
                  }
                },
                isFirst: true,
                isLast: true,
              ),
            ],
          ),

          // Language Section
          SettingsSection(
            title: 'Language',
            icon: Icons.language,
            children: [
              SettingsDropdownTile<String>(
                title: 'App Language',
                subtitle: 'Select your preferred language',
                leadingIcon: Icons.translate,
                value: currentLanguage,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                ],
                onChanged: (value) {
                  // Will implement functionality later
                  if (value != null) {
                    _showComingSoonDialog(context, 'Language switching');
                  }
                },
                isFirst: true,
                isLast: true,
              ),
            ],
          ),

          // Notifications Section
          SettingsSection(
            title: 'Notifications',
            icon: Icons.notifications,
            children: [
              SettingsSwitchTile(
                title: 'Push Notifications',
                subtitle: 'Receive notifications about test results',
                leadingIcon: Icons.notifications_active,
                value: pushNotificationsEnabled,
                onChanged: (value) {
                  // Will implement functionality later
                  _showComingSoonDialog(context, 'Push notifications');
                },
                isFirst: true,
              ),
              SettingsSwitchTile(
                title: 'Vibration',
                subtitle: 'Vibrate on notifications and interactions',
                leadingIcon: Icons.vibration,
                value: vibrationEnabled,
                onChanged: (value) {
                  // Will implement functionality later
                  _showComingSoonDialog(context, 'Vibration settings');
                },
                isLast: true,
              ),
            ],
          ),

          // About Section
          SettingsSection(
            title: 'About',
            icon: Icons.info,
            children: [
              SettingsTile(
                title: 'Developers',
                subtitle: 'Meet the team behind this app',
                leadingIcon: Icons.code,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showDevelopersDialog(context),
                isFirst: true,
              ),
              SettingsTile(
                title: 'Version',
                subtitle: '1.0.0',
                leadingIcon: Icons.info_outline,
                isLast: true,
              ),
            ],
          ),

          // Additional spacing at bottom
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚧 Coming Soon'),
        content: Text('$feature functionality will be implemented soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDevelopersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.code, color: Colors.blue),
            SizedBox(width: 8),
            Text('Developers'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reagent Testing App',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '👨‍💻 المطورين',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(' يوسف مسير العنزي'),
            Text(' محمد نفاع الرويلي'),

            SizedBox(height: 16),
            Text(
              '🧪 About the App:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'This app helps users safely test substances using chemical reagents.',
            ),
            SizedBox(height: 16),
            Text('📧 Contact: ', style: TextStyle(color: Colors.blue)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
