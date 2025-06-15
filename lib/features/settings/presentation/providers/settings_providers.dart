import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/services/shared_preferences_service.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/entities/settings_entity.dart';
import '../controllers/settings_controller.dart';
import '../states/settings_state.dart';

// Service Providers
final sharedPreferencesServiceProvider = Provider<SharedPreferencesService>((
  ref,
) {
  return SharedPreferencesService();
});

// Repository Providers
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.read(sharedPreferencesServiceProvider));
});

// Controller Providers
final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
      return SettingsController(ref.read(settingsRepositoryProvider));
    });

// Convenience providers for specific settings values
final currentThemeModeProvider = Provider<String>((ref) {
  final settingsState = ref.watch(settingsControllerProvider);
  if (settingsState is SettingsLoaded) {
    switch (settingsState.settings.themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
  return 'system'; // Default
});

final currentLanguageProvider = Provider<String>((ref) {
  final settingsState = ref.watch(settingsControllerProvider);
  if (settingsState is SettingsLoaded) {
    return settingsState.settings.language;
  }
  return 'en'; // Default
});

final pushNotificationsEnabledProvider = Provider<bool>((ref) {
  final settingsState = ref.watch(settingsControllerProvider);
  if (settingsState is SettingsLoaded) {
    return settingsState.settings.pushNotificationsEnabled;
  }
  return true; // Default
});

final vibrationEnabledProvider = Provider<bool>((ref) {
  final settingsState = ref.watch(settingsControllerProvider);
  if (settingsState is SettingsLoaded) {
    return settingsState.settings.vibrationEnabled;
  }
  return true; // Default
});
