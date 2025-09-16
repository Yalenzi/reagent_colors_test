import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../models/reagent_model.dart';
import '../models/safety_instructions_model.dart';
import '../../../../core/utils/logger.dart';

class RemoteConfigService {
  static const String _reagentDataKey = 'reagent_data';
  static const String _safetyInstructionsKey = 'safety_instructions';
  static const String _availableReagentsKey = 'available_reagents';
  static const String _reagentVersionKey = 'reagent_version';
  static const String _geminiApiKeyKey = 'gemini_api_key';
  static const String _referenceListKey = 'reference_list';

  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  /// Initialize Remote Config with default values
  Future<void> initialize() async {
    try {
      // Set configuration settings
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      // Set default values (fallback to local assets)
      await _remoteConfig.setDefaults({
        _reagentDataKey: '{}',
        _safetyInstructionsKey: '{}',
        _availableReagentsKey: '[]',
        _reagentVersionKey: '1.0.0',
        _geminiApiKeyKey: '', // No default for security
        _referenceListKey: '{}',
      });

      // Fetch and activate
      await fetchAndActivate();

      Logger.info('✅ Remote Config initialized successfully');
    } catch (e) {
      Logger.info('❌ Error initializing Remote Config: $e');
      rethrow;
    }
  }

  /// Fetch latest config and activate
  Future<bool> fetchAndActivate() async {
    try {
      final bool updated = await _remoteConfig.fetchAndActivate();
      if (updated) {
        Logger.info('🔄 Remote Config updated with new values');
      }
      return updated;
    } catch (e) {
      Logger.info('❌ Error fetching Remote Config: $e');
      return false;
    }
  }

  /// Get all reagents from Remote Config
  Future<List<ReagentModel>> getReagents() async {
    try {
      final String reagentDataJson = _remoteConfig.getString(_reagentDataKey);
      final String availableReagentsJson = _remoteConfig.getString(
        _availableReagentsKey,
      );

      if (reagentDataJson.isEmpty || reagentDataJson == '{}') {
        Logger.info('⚠️ No reagent data in Remote Config, using fallback');
        return [];
      }

      final Map<String, dynamic> reagentData = json.decode(reagentDataJson);
      final List<String> availableReagents = List<String>.from(
        json.decode(availableReagentsJson),
      );

      final List<ReagentModel> reagents = [];

      for (final reagentName in availableReagents) {
        if (reagentData.containsKey(reagentName)) {
          try {
            final reagentJson =
                reagentData[reagentName] as Map<String, dynamic>;
            final reagent = ReagentModel.fromJson(reagentJson);
            reagents.add(reagent);
            Logger.info(
              '✅ Loaded reagent from Remote Config: ${reagent.reagentName}',
            );
          } catch (e) {
            Logger.info('❌ Error parsing reagent $reagentName: $e');
          }
        }
      }

      Logger.info('📊 Loaded ${reagents.length} reagents from Remote Config');
      return reagents;
    } catch (e) {
      Logger.info('❌ Error getting reagents from Remote Config: $e');
      return [];
    }
  }

  /// Get specific reagent by name
  Future<ReagentModel?> getReagentByName(String reagentName) async {
    try {
      final reagents = await getReagents();
      return reagents.firstWhere(
        (reagent) =>
            reagent.reagentName.toLowerCase() == reagentName.toLowerCase(),
        orElse: () => throw StateError('Reagent not found'),
      );
    } catch (e) {
      Logger.info('❌ Reagent $reagentName not found in Remote Config: $e');
      return null;
    }
  }

  /// Check if reagent data is available in Remote Config
  bool hasReagentData() {
    final String reagentDataJson = _remoteConfig.getString(_reagentDataKey);
    return reagentDataJson.isNotEmpty && reagentDataJson != '{}';
  }

  /// Get current reagent version
  String getReagentVersion() {
    return _remoteConfig.getString(_reagentVersionKey);
  }

  /// Get available reagent names
  List<String> getAvailableReagentNames() {
    try {
      final String availableReagentsJson = _remoteConfig.getString(
        _availableReagentsKey,
      );
      if (availableReagentsJson.isEmpty || availableReagentsJson == '[]') {
        return [];
      }
      return List<String>.from(json.decode(availableReagentsJson));
    } catch (e) {
      Logger.info('❌ Error getting available reagent names: $e');
      return [];
    }
  }

  /// Get all safety instructions from Remote Config
  Future<Map<String, SafetyInstructionsModel>> getSafetyInstructions() async {
    try {
      final String safetyDataJson = _remoteConfig.getString(
        _safetyInstructionsKey,
      );

      if (safetyDataJson.isEmpty || safetyDataJson == '{}') {
        Logger.info(
          '⚠️ No safety instructions in Remote Config, using fallback',
        );
        return {};
      }

      final Map<String, dynamic> safetyData = json.decode(safetyDataJson);
      final Map<String, SafetyInstructionsModel> safetyInstructions = {};

      for (final entry in safetyData.entries) {
        final reagentName = entry.key;
        final safetyJson = entry.value as Map<String, dynamic>;

        try {
          final safety = SafetyInstructionsModel.fromJson(
            reagentName,
            safetyJson,
          );
          safetyInstructions[reagentName] = safety;
          Logger.info('✅ Loaded safety instructions for: $reagentName');
        } catch (e) {
          Logger.info(
            '❌ Error parsing safety instructions for $reagentName: $e',
          );
        }
      }

      Logger.info(
        '📋 Loaded safety instructions for ${safetyInstructions.length} reagents',
      );
      return safetyInstructions;
    } catch (e) {
      Logger.info('❌ Error getting safety instructions from Remote Config: $e');
      return {};
    }
  }

  /// Get safety instructions for a specific reagent
  Future<SafetyInstructionsModel?> getSafetyInstructionsByReagent(
    String reagentName,
  ) async {
    try {
      final allSafetyInstructions = await getSafetyInstructions();
      return allSafetyInstructions[reagentName];
    } catch (e) {
      Logger.info('❌ Safety instructions for $reagentName not found: $e');
      return null;
    }
  }

  /// Check if safety instructions data is available in Remote Config
  bool hasSafetyInstructions() {
    final String safetyDataJson = _remoteConfig.getString(
      _safetyInstructionsKey,
    );
    return safetyDataJson.isNotEmpty && safetyDataJson != '{}';
  }

  /// Listen for real-time config updates
  Stream<RemoteConfigUpdate> onConfigUpdated() {
    return _remoteConfig.onConfigUpdated;
  }

  /// Activate fetched config
  Future<bool> activate() async {
    try {
      return await _remoteConfig.activate();
    } catch (e) {
      Logger.info('❌ Error activating Remote Config: $e');
      return false;
    }
  }

  /// Get Gemini API key from Remote Config
  String getGeminiApiKey() {
    final apiKey = _remoteConfig.getString(_geminiApiKeyKey);
    if (apiKey.isNotEmpty) {
      Logger.info('🔑 Gemini API key loaded from Remote Config');
    } else {
      Logger.info('⚠️ No Gemini API key found in Remote Config');
    }
    return apiKey;
  }

  /// Check if Gemini API key is available in Remote Config
  bool hasGeminiApiKey() {
    final apiKey = _remoteConfig.getString(_geminiApiKeyKey);
    return apiKey.isNotEmpty;
  }

  /// Get Gemini API key with fallback to environment variable
  String getGeminiApiKeyWithFallback() {
    // First try Remote Config
    final remoteApiKey = getGeminiApiKey();
    if (remoteApiKey.isNotEmpty) {
      return remoteApiKey;
    }

    // Fallback to environment variable
    const envApiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (envApiKey.isNotEmpty) {
      Logger.info('🔑 Using Gemini API key from environment variable');
      return envApiKey;
    }

    Logger.error('❌ No Gemini API key found in Remote Config or environment');
    return '';
  }

  /// Get references for a specific reagent
  Future<List<String>> getReferencesForReagent(String reagentName) async {
    try {
      final String referenceListJson = _remoteConfig.getString(
        _referenceListKey,
      );
      if (referenceListJson.isEmpty || referenceListJson == '{}') {
        Logger.info('⚠️ No references found in Remote Config for $reagentName');
        return [];
      }

      final Map<String, dynamic> referenceList = json.decode(referenceListJson);
      if (!referenceList.containsKey(reagentName)) {
        Logger.info('⚠️ No references found for reagent: $reagentName');
        return [];
      }

      final List<dynamic> references =
          referenceList[reagentName]['reference'] ?? [];
      return references.cast<String>();
    } catch (e) {
      Logger.info('❌ Error getting references for $reagentName: $e');
      return [];
    }
  }

  /// Check if references are available in Remote Config
  bool hasReferences() {
    final String referenceListJson = _remoteConfig.getString(_referenceListKey);
    return referenceListJson.isNotEmpty && referenceListJson != '{}';
  }
}
