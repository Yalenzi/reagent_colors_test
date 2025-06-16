import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../models/reagent_model.dart';

class RemoteConfigService {
  static const String _reagentDataKey = 'reagent_data';
  static const String _availableReagentsKey = 'available_reagents';
  static const String _reagentVersionKey = 'reagent_version';

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
        _availableReagentsKey: '[]',
        _reagentVersionKey: '1.0.0',
      });

      // Fetch and activate
      await fetchAndActivate();

      print('✅ Remote Config initialized successfully');
    } catch (e) {
      print('❌ Error initializing Remote Config: $e');
      rethrow;
    }
  }

  /// Fetch latest config and activate
  Future<bool> fetchAndActivate() async {
    try {
      final bool updated = await _remoteConfig.fetchAndActivate();
      if (updated) {
        print('🔄 Remote Config updated with new values');
      }
      return updated;
    } catch (e) {
      print('❌ Error fetching Remote Config: $e');
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
        print('⚠️ No reagent data in Remote Config, using fallback');
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
            print(
              '✅ Loaded reagent from Remote Config: ${reagent.reagentName}',
            );
          } catch (e) {
            print('❌ Error parsing reagent $reagentName: $e');
          }
        }
      }

      print('📊 Loaded ${reagents.length} reagents from Remote Config');
      return reagents;
    } catch (e) {
      print('❌ Error getting reagents from Remote Config: $e');
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
      print('❌ Reagent $reagentName not found in Remote Config: $e');
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
      print('❌ Error getting available reagent names: $e');
      return [];
    }
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
      print('❌ Error activating Remote Config: $e');
      return false;
    }
  }
}
