import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reagent_colors_test/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitleWithIcon),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: _buildBody(
        context,
        l10n,
        ref,
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
    AppLocalizations l10n,
    WidgetRef ref,
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
              l10n.errorLoadingSettings,
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
              child: Text(l10n.retry),
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
            title: l10n.appearance,
            icon: Icons.palette,
            children: [
              SettingsDropdownTile<String>(
                title: l10n.theme,
                subtitle: l10n.themeSubtitle,
                leadingIcon: Icons.brightness_6,
                value: currentTheme,
                items: [
                  DropdownMenuItem(
                    value: 'light',
                    child: Text(l10n.lightTheme),
                  ),
                  DropdownMenuItem(value: 'dark', child: Text(l10n.darkTheme)),
                  DropdownMenuItem(
                    value: 'system',
                    child: Text(l10n.systemTheme),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    final themeMode = switch (value) {
                      'light' => ThemeMode.light,
                      'dark' => ThemeMode.dark,
                      'system' => ThemeMode.system,
                      _ => ThemeMode.system,
                    };
                    ref
                        .read(settingsControllerProvider.notifier)
                        .updateTheme(themeMode);
                  }
                },
                isFirst: true,
                isLast: true,
              ),
            ],
          ),

          // Language Section
          SettingsSection(
            title: l10n.language,
            icon: Icons.language,
            children: [
              SettingsDropdownTile<String>(
                title: l10n.appLanguage,
                subtitle: l10n.appLanguageSubtitle,
                leadingIcon: Icons.translate,
                value: currentLanguage,
                items: [
                  DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                  DropdownMenuItem(value: 'ar', child: Text(l10n.arabic)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .changeLanguage(value);
                  }
                },
                isFirst: true,
                isLast: true,
              ),
            ],
          ),

          // Notifications Section
          SettingsSection(
            title: l10n.notifications,
            icon: Icons.notifications,
            children: [
              SettingsSwitchTile(
                title: l10n.pushNotifications,
                subtitle: l10n.pushNotificationsSubtitle,
                leadingIcon: Icons.notifications_active,
                value: pushNotificationsEnabled,
                onChanged: (value) {
                  // Will implement functionality later
                  _showComingSoonDialog(context, l10n, l10n.pushNotifications);
                },
                isFirst: true,
              ),
              SettingsSwitchTile(
                title: l10n.vibration,
                subtitle: l10n.vibrationSubtitle,
                leadingIcon: Icons.vibration,
                value: vibrationEnabled,
                onChanged: (value) {
                  // Will implement functionality later
                  _showComingSoonDialog(context, l10n, l10n.vibration);
                },
                isLast: true,
              ),
            ],
          ),

          // About Section
          SettingsSection(
            title: l10n.about,
            icon: Icons.info,
            children: [
              SettingsTile(
                title: l10n.developers,
                subtitle: l10n.developersSubtitle,
                leadingIcon: Icons.code,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showDevelopersDialog(context, l10n),
                isFirst: true,
              ),
              SettingsTile(
                title: l10n.version,
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

  void _showComingSoonDialog(
    BuildContext context,
    AppLocalizations l10n,
    String feature,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.comingSoonTitle),
        content: Text(l10n.comingSoonContent(feature)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showDevelopersDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.code, color: Colors.blue),
            const SizedBox(width: 8),
            Text(l10n.developersDialogTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reagentTestingApp,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.theDevelopers,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(l10n.developerOneName),
            Text(l10n.developerTwoName),
            const SizedBox(height: 16),
            Text(
              l10n.aboutTheApp,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(l10n.aboutTheAppContent),
            const SizedBox(height: 16),
            Text(l10n.contact, style: const TextStyle(color: Colors.blue)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
