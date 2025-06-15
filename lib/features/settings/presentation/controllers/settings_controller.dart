import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../states/settings_state.dart';

class SettingsController extends StateNotifier<SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsController(this._settingsRepository)
    : super(const SettingsInitial()) {
    loadSettings();
  }

  // Load settings from repository
  Future<void> loadSettings() async {
    state = const SettingsLoading();
    try {
      final settings = await _settingsRepository.getSettings();
      state = SettingsLoaded(settings);
    } catch (e) {
      state = SettingsError('Failed to load settings: $e');
    }
  }

  // Update theme mode
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    state = const SettingsLoading();
    try {
      await _settingsRepository.updateThemeMode(themeMode);
      final updatedSettings = currentState.settings.copyWith(
        themeMode: themeMode,
      );
      state = SettingsSuccess('Theme updated successfully', updatedSettings);
      // After showing success, return to loaded state
      await Future.delayed(const Duration(milliseconds: 500));
      state = SettingsLoaded(updatedSettings);
    } catch (e) {
      state = SettingsError('Failed to update theme: $e');
      // Return to previous state after error
      await Future.delayed(const Duration(seconds: 2));
      state = currentState;
    }
  }

  // Update language
  Future<void> updateLanguage(String language) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    state = const SettingsLoading();
    try {
      await _settingsRepository.updateLanguage(language);
      final updatedSettings = currentState.settings.copyWith(
        language: language,
      );
      state = SettingsSuccess('Language updated successfully', updatedSettings);
      // After showing success, return to loaded state
      await Future.delayed(const Duration(milliseconds: 500));
      state = SettingsLoaded(updatedSettings);
    } catch (e) {
      state = SettingsError('Failed to update language: $e');
      // Return to previous state after error
      await Future.delayed(const Duration(seconds: 2));
      state = currentState;
    }
  }

  // Update push notifications
  Future<void> updatePushNotifications(bool enabled) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    state = const SettingsLoading();
    try {
      await _settingsRepository.updatePushNotifications(enabled);
      final updatedSettings = currentState.settings.copyWith(
        pushNotificationsEnabled: enabled,
      );
      state = SettingsSuccess(
        enabled ? 'Push notifications enabled' : 'Push notifications disabled',
        updatedSettings,
      );
      // After showing success, return to loaded state
      await Future.delayed(const Duration(milliseconds: 500));
      state = SettingsLoaded(updatedSettings);
    } catch (e) {
      state = SettingsError('Failed to update push notifications: $e');
      // Return to previous state after error
      await Future.delayed(const Duration(seconds: 2));
      state = currentState;
    }
  }

  // Update vibration
  Future<void> updateVibration(bool enabled) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    state = const SettingsLoading();
    try {
      await _settingsRepository.updateVibration(enabled);
      final updatedSettings = currentState.settings.copyWith(
        vibrationEnabled: enabled,
      );
      state = SettingsSuccess(
        enabled ? 'Vibration enabled' : 'Vibration disabled',
        updatedSettings,
      );
      // After showing success, return to loaded state
      await Future.delayed(const Duration(milliseconds: 500));
      state = SettingsLoaded(updatedSettings);
    } catch (e) {
      state = SettingsError('Failed to update vibration: $e');
      // Return to previous state after error
      await Future.delayed(const Duration(seconds: 2));
      state = currentState;
    }
  }

  // Reset to default settings
  Future<void> resetToDefaults() async {
    state = const SettingsLoading();
    try {
      await _settingsRepository.resetToDefaults();
      final defaultSettings = await _settingsRepository.getSettings();
      state = SettingsSuccess('Settings reset to defaults', defaultSettings);
      // After showing success, return to loaded state
      await Future.delayed(const Duration(milliseconds: 500));
      state = SettingsLoaded(defaultSettings);
    } catch (e) {
      state = SettingsError('Failed to reset settings: $e');
    }
  }

  // Refresh settings
  Future<void> refreshSettings() async {
    await loadSettings();
  }
}
