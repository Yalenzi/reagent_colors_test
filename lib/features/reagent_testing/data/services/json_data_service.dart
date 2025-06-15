import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/reagent_model.dart';
import '../models/drug_result_model.dart';

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

  // Load all reagents from JSON files
  Future<List<ReagentModel>> loadAllReagents() async {
    final List<ReagentModel> reagents = [];

    for (final filePath in _reagentFiles) {
      try {
        final reagent = await _loadReagentFromFile(filePath);
        if (reagent != null) {
          reagents.add(reagent);
        }
      } catch (e) {
        print('Error loading reagent from $filePath: $e');
        // Continue loading other reagents even if one fails
      }
    }

    // If no reagents loaded from files, return mock data
    if (reagents.isEmpty) {
      print('⚠️ No reagents loaded from assets');
    }

    return reagents;
  }

  // Load a specific reagent by name
  Future<ReagentModel?> loadReagentByName(String reagentName) async {
    final fileName =
        '${reagentName.toLowerCase().replaceAll("'", "")}_reagent.json';
    final filePath = 'assets/data/reagents/$fileName';

    try {
      return await _loadReagentFromFile(filePath);
    } catch (e) {
      print('Error loading reagent $reagentName: $e');
      return null;
    }
  }

  // Private method to load reagent from a specific file
  Future<ReagentModel?> _loadReagentFromFile(String filePath) async {
    try {
      print('🔄 Attempting to load asset: $filePath');
      final String jsonString = await rootBundle.loadString(filePath);
      print('✅ Asset loaded successfully: ${jsonString.substring(0, 100)}...');

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      print('✅ JSON parsed successfully for: ${jsonData['reagentName']}');

      final reagent = ReagentModel.fromJson(jsonData);
      print('✅ ReagentModel created successfully: ${reagent.reagentName}');

      return reagent;
    } catch (e, stackTrace) {
      print('❌ Error loading/parsing $filePath: $e');
      print('📍 Stack trace: $stackTrace');

      // Show user-friendly debug message
      print('Debug: Asset loading failed: Unable to load asset: "$filePath".');
      print('The asset does not exist or has empty data.');

      return null;
    }
  }

  // Search reagents by name or description
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

  // Filter reagents by safety level
  Future<List<ReagentModel>> getReagentsBySafetyLevel(
    String safetyLevel,
  ) async {
    final allReagents = await loadAllReagents();
    return allReagents
        .where((reagent) => reagent.safetyLevel == safetyLevel)
        .toList();
  }

  // Get available safety levels
  Future<List<String>> getAvailableSafetyLevels() async {
    final allReagents = await loadAllReagents();
    final safetyLevels = allReagents
        .map((reagent) => reagent.safetyLevel)
        .toSet()
        .toList();
    safetyLevels.sort();
    return safetyLevels;
  }

  // Get all unique drug names that can be tested
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

  // Get reagents that can test a specific drug
  Future<List<ReagentModel>> getReagentsForDrug(String drugName) async {
    final allReagents = await loadAllReagents();
    return allReagents.where((reagent) {
      return reagent.drugResults.any(
        (drugResult) => drugResult.drugName == drugName,
      );
    }).toList();
  }
}
