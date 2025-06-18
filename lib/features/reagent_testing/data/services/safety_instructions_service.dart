import 'dart:convert';
import '../models/safety_instructions_model.dart';
import 'remote_config_service.dart';
import '../../../../core/utils/logger.dart';

class SafetyInstructionsService {
  final RemoteConfigService _remoteConfigService;
  Map<String, SafetyInstructionsModel>? _cachedSafetyInstructions;

  SafetyInstructionsService({RemoteConfigService? remoteConfigService})
    : _remoteConfigService = remoteConfigService ?? RemoteConfigService();

  /// Initialize the service (sets up Remote Config)
  Future<void> initialize() async {
    try {
      await _remoteConfigService.initialize();
      Logger.info('✅ SafetyInstructionsService initialized with Remote Config');
    } catch (e) {
      Logger.info(
        '⚠️ Remote Config initialization failed for safety instructions: $e',
      );
    }
  }

  /// Load all safety instructions (Remote Config first, then fallback)
  Future<Map<String, SafetyInstructionsModel>>
  loadAllSafetyInstructions() async {
    try {
      // Try Remote Config first
      if (_remoteConfigService.hasSafetyInstructions()) {
        Logger.info('📡 Loading safety instructions from Remote Config...');
        final remoteSafetyInstructions = await _remoteConfigService
            .getSafetyInstructions();
        if (remoteSafetyInstructions.isNotEmpty) {
          _cachedSafetyInstructions = remoteSafetyInstructions;
          Logger.info(
            '✅ Loaded ${remoteSafetyInstructions.length} safety instructions from Remote Config',
          );
          return remoteSafetyInstructions;
        }
      }

      // Fallback to local assets if Remote Config not available
      Logger.info('📁 Falling back to local safety instructions...');
      return await _loadSafetyInstructionsFromAssets();
    } catch (e) {
      Logger.info('❌ Error in loadAllSafetyInstructions: $e');
      // Final fallback to local assets
      return await _loadSafetyInstructionsFromAssets();
    }
  }

  /// Load safety instructions for a specific reagent
  Future<SafetyInstructionsModel?> loadSafetyInstructionsByReagent(
    String reagentName,
  ) async {
    try {
      // Try Remote Config first
      if (_remoteConfigService.hasSafetyInstructions()) {
        final remoteSafety = await _remoteConfigService
            .getSafetyInstructionsByReagent(reagentName);
        if (remoteSafety != null) {
          Logger.info(
            '✅ Loaded safety instructions for $reagentName from Remote Config',
          );
          return remoteSafety;
        }
      }

      // Fallback to cached data or local assets
      if (_cachedSafetyInstructions != null) {
        return _cachedSafetyInstructions![reagentName];
      }

      // Load all and return specific one
      final allSafetyInstructions = await loadAllSafetyInstructions();
      return allSafetyInstructions[reagentName];
    } catch (e) {
      Logger.info('❌ Error loading safety instructions for $reagentName: $e');
      return null;
    }
  }

  /// Get localized equipment list for a reagent
  Future<List<String>> getEquipmentForReagent(
    String reagentName, {
    bool isArabic = false,
  }) async {
    final safety = await loadSafetyInstructionsByReagent(reagentName);
    if (safety == null) return [];

    return safety.getEquipment(isArabic);
  }

  /// Get localized handling procedures for a reagent
  Future<List<String>> getHandlingProceduresForReagent(
    String reagentName, {
    bool isArabic = false,
  }) async {
    final safety = await loadSafetyInstructionsByReagent(reagentName);
    if (safety == null) return [];

    return safety.getHandlingProcedures(isArabic);
  }

  /// Get localized specific hazards for a reagent
  Future<List<String>> getSpecificHazardsForReagent(
    String reagentName, {
    bool isArabic = false,
  }) async {
    final safety = await loadSafetyInstructionsByReagent(reagentName);
    if (safety == null) return [];

    return safety.getSpecificHazards(isArabic);
  }

  /// Get localized storage instructions for a reagent
  Future<List<String>> getStorageForReagent(
    String reagentName, {
    bool isArabic = false,
  }) async {
    final safety = await loadSafetyInstructionsByReagent(reagentName);
    if (safety == null) return [];

    return safety.getStorage(isArabic);
  }

  /// Get localized test instructions for a reagent
  Future<List<String>> getInstructionsForReagent(
    String reagentName, {
    bool isArabic = false,
  }) async {
    final safety = await loadSafetyInstructionsByReagent(reagentName);
    if (safety == null) return [];

    return safety.getInstructions(isArabic);
  }

  /// Load safety instructions from local assets (fallback)
  Future<Map<String, SafetyInstructionsModel>>
  _loadSafetyInstructionsFromAssets() async {
    try {
      // For now, return empty since we're transitioning to Remote Config
      // In the future, we could add local safety instruction assets
      Logger.info(
        '⚠️ No local safety instructions available, using empty defaults',
      );
      return {};
    } catch (e) {
      Logger.info('❌ Error loading safety instructions from assets: $e');
      return {};
    }
  }

  /// Refresh data from Remote Config
  Future<bool> refreshFromRemoteConfig() async {
    try {
      final updated = await _remoteConfigService.fetchAndActivate();
      if (updated) {
        _cachedSafetyInstructions = null; // Clear cache to force reload
        Logger.info('✅ Safety instructions refreshed from Remote Config');
      }
      return updated;
    } catch (e) {
      Logger.info(
        '❌ Error refreshing safety instructions from Remote Config: $e',
      );
      return false;
    }
  }

  /// Check if using Remote Config data
  bool isUsingRemoteConfig() {
    return _remoteConfigService.hasSafetyInstructions();
  }

  /// Get current data source version
  String getDataVersion() {
    if (isUsingRemoteConfig()) {
      return 'Remote Config v${_remoteConfigService.getReagentVersion()}';
    } else {
      return 'Local Assets v1.0.0';
    }
  }

  /// Listen for real-time Remote Config updates
  Stream<void> onDataUpdated() async* {
    await for (final update in _remoteConfigService.onConfigUpdated()) {
      Logger.info('🔄 Safety instructions updated: ${update.updatedKeys}');
      if (update.updatedKeys.contains('safety_instructions')) {
        // Activate the new config and clear cache
        await _remoteConfigService.activate();
        _cachedSafetyInstructions = null;
        yield null; // Emit update signal
      }
    }
  }

  /// Clear cached data
  void clearCache() {
    _cachedSafetyInstructions = null;
  }
}
