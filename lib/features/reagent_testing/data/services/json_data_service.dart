import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/reagent_model.dart';
import 'remote_config_service.dart';
import '../../../../core/utils/logger.dart';

class JsonDataService {
  static const List<String> _reagentFiles = [
    'assets/data/reagents/marquis_reagent.json',
    'assets/data/reagents/ehrlich_reagent.json',
    'assets/data/reagents/mecke_reagent.json',
    'assets/data/reagents/mandelin_reagent.json',
    'assets/data/reagents/liebermann_reagent.json',
    'assets/data/reagents/froehde_reagent.json',
    'assets/data/reagents/simons_reagent.json',
    'assets/data/reagents/scott_reagent.json',
    'assets/data/reagents/morris_reagent.json',
    'assets/data/reagents/hofmann_reagent.json',
    'assets/data/reagents/folin_reagent.json',
    'assets/data/reagents/gallic_reagent.json',
    'assets/data/reagents/zimmermann_reagent.json',
    'assets/data/reagents/robadope_reagent.json',
  ];

  final RemoteConfigService _remoteConfigService;

  JsonDataService({RemoteConfigService? remoteConfigService})
    : _remoteConfigService = remoteConfigService ?? RemoteConfigService();

  /// Initialize the service (sets up Remote Config)
  Future<void> initialize() async {
    try {
      await _remoteConfigService.initialize();
      Logger.info('✅ JsonDataService initialized with Remote Config');
    } catch (e) {
      Logger.info(
        '⚠️ Remote Config initialization failed, will use local assets: $e',
      );
    }
  }

  /// Load all reagents (Remote Config first, then local assets fallback)
  Future<List<ReagentModel>> loadAllReagents() async {
    try {
      // Try Remote Config first
      if (_remoteConfigService.hasReagentData()) {
        Logger.info('📡 Loading reagents from Remote Config...');
        final remoteReagents = await _remoteConfigService.getReagents();
        if (remoteReagents.isNotEmpty) {
          Logger.info(
            '✅ Loaded ${remoteReagents.length} reagents from Remote Config',
          );
          return remoteReagents;
        }
      }

      // Fallback to local assets
      Logger.info('📁 Falling back to local asset files...');
      return await _loadReagentsFromAssets();
    } catch (e) {
      Logger.info('❌ Error in loadAllReagents: $e');
      // Final fallback to local assets
      return await _loadReagentsFromAssets();
    }
  }

  /// Load reagents from local asset files
  Future<List<ReagentModel>> _loadReagentsFromAssets() async {
    final List<ReagentModel> reagents = [];

    for (final filePath in _reagentFiles) {
      try {
        final reagent = await _loadReagentFromFile(filePath);
        if (reagent != null) {
          reagents.add(reagent);
        }
      } catch (e) {
        Logger.info('Error loading reagent from $filePath: $e');
        // Continue loading other reagents even if one fails
      }
    }

    // If no reagents loaded from files, return empty list
    if (reagents.isEmpty) {
      Logger.info('⚠️ No reagents loaded from assets');
    } else {
      Logger.info('✅ Loaded ${reagents.length} reagents from local assets');
    }

    return reagents;
  }

  /// Load a specific reagent by name (Remote Config first, then local assets)
  Future<ReagentModel?> loadReagentByName(String reagentName) async {
    try {
      // Try Remote Config first
      if (_remoteConfigService.hasReagentData()) {
        final remoteReagent = await _remoteConfigService.getReagentByName(
          reagentName,
        );
        if (remoteReagent != null) {
          Logger.info('✅ Loaded $reagentName from Remote Config');
          return remoteReagent;
        }
      }

      // Fallback to local assets
      Logger.info('📁 Loading $reagentName from local assets...');
      return await _loadReagentFromAssetsByName(reagentName);
    } catch (e) {
      Logger.info('❌ Error loading reagent $reagentName: $e');
      return await _loadReagentFromAssetsByName(reagentName);
    }
  }

  /// Load reagent from local assets by name
  Future<ReagentModel?> _loadReagentFromAssetsByName(String reagentName) async {
    final fileName =
        '${reagentName.toLowerCase().replaceAll("'", "")}_reagent.json';
    final filePath = 'assets/data/reagents/$fileName';

    try {
      return await _loadReagentFromFile(filePath);
    } catch (e) {
      Logger.info('Error loading reagent $reagentName from assets: $e');
      return null;
    }
  }

  /// Private method to load reagent from a specific file
  Future<ReagentModel?> _loadReagentFromFile(String filePath) async {
    try {
      Logger.info('🔄 Attempting to load asset: $filePath');
      final String jsonString = await rootBundle.loadString(filePath);
      Logger.info(
        '✅ Asset loaded successfully: ${jsonString.substring(0, 100)}...',
      );

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      Logger.info('✅ JSON parsed successfully for: ${jsonData['reagentName']}');

      final reagent = ReagentModel.fromJson(jsonData);
      Logger.info(
        '✅ ReagentModel created successfully: ${reagent.reagentName}',
      );

      return reagent;
    } catch (e, stackTrace) {
      Logger.info('❌ Error loading/parsing $filePath: $e');
      Logger.info('📍 Stack trace: $stackTrace');

      // Show user-friendly debug message
      Logger.info(
        'Debug: Asset loading failed: Unable to load asset: "$filePath".',
      );
      Logger.info('The asset does not exist or has empty data.');

      return null;
    }
  }

  /// Refresh data from Remote Config
  Future<bool> refreshFromRemoteConfig() async {
    try {
      final updated = await _remoteConfigService.fetchAndActivate();
      if (updated) {
        Logger.info('✅ Remote Config data refreshed successfully');
      }
      return updated;
    } catch (e) {
      Logger.info('❌ Error refreshing Remote Config: $e');
      return false;
    }
  }

  /// Check if using Remote Config data
  bool isUsingRemoteConfig() {
    return _remoteConfigService.hasReagentData();
  }

  /// Get current data source version
  String getDataVersion() {
    if (isUsingRemoteConfig()) {
      return 'Remote Config v${_remoteConfigService.getReagentVersion()}';
    } else {
      return 'Local Assets v1.0.0';
    }
  }

  /// Search reagents by name or description
  Future<List<ReagentModel>> searchReagents(String query) async {
    final allReagents = await loadAllReagents();
    final lowercaseQuery = query.toLowerCase();

    return allReagents.where((reagent) {
      return reagent.reagentName.toLowerCase().contains(lowercaseQuery) ||
          reagent.description.toLowerCase().contains(lowercaseQuery) ||
          reagent.chemicals.any(
            (chemical) => chemical.toLowerCase().contains(lowercaseQuery),
          );
    }).toList();
  }

  /// Filter reagents by safety level
  Future<List<ReagentModel>> getReagentsBySafetyLevel(
    String safetyLevel,
  ) async {
    final allReagents = await loadAllReagents();
    return allReagents
        .where((reagent) => reagent.safetyLevel == safetyLevel)
        .toList();
  }

  /// Get available safety levels
  Future<List<String>> getAvailableSafetyLevels() async {
    final allReagents = await loadAllReagents();
    final safetyLevels = allReagents
        .map((reagent) => reagent.safetyLevel)
        .toSet()
        .toList();
    safetyLevels.sort();
    return safetyLevels;
  }

  /// Get all unique drug names that can be tested
  Future<List<String>> getAllTestableDrugs() async {
    final allReagents = await loadAllReagents();
    final Set<String> drugNames = {};

    for (final reagent in allReagents) {
      for (final drugResult in reagent.drugResults) {
        drugNames.add(drugResult.drugName);
      }
    }

    final sortedDrugs = drugNames.toList();
    sortedDrugs.sort();
    return sortedDrugs;
  }

  /// Get reagents that can test a specific drug
  Future<List<ReagentModel>> getReagentsForDrug(String drugName) async {
    final allReagents = await loadAllReagents();
    return allReagents.where((reagent) {
      return reagent.drugResults.any(
        (drugResult) => drugResult.drugName == drugName,
      );
    }).toList();
  }

  /// Listen for real-time Remote Config updates
  Stream<void> onDataUpdated() async* {
    await for (final update in _remoteConfigService.onConfigUpdated()) {
      Logger.info('🔄 Remote Config updated: ${update.updatedKeys}');
      if (update.updatedKeys.contains('reagent_data') ||
          update.updatedKeys.contains('available_reagents')) {
        // Activate the new config
        await _remoteConfigService.activate();
        yield null; // Emit update signal
      }
    }
  }
}
