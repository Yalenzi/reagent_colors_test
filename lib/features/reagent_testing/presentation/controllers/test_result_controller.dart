import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reagent_entity.dart';
import '../../domain/entities/test_result_entity.dart';
import '../states/test_result_state.dart';
import 'test_result_history_controller.dart';
import '../../data/models/gemini_analysis_models.dart';

class TestResultController extends StateNotifier<TestResultState> {
  final TestResultHistoryController? _historyController;

  TestResultController({TestResultHistoryController? historyController})
    : _historyController = historyController,
      super(const TestResultInitial());

  void analyzeTestResult({
    required ReagentEntity reagent,
    required String observedColor,
    String? notes,
  }) {
    state = const TestResultLoading();

    try {
      // Analyze the observed color against the reagent's drug results
      final analysisResult = _analyzeColorMatch(reagent, observedColor);

      final testResult = TestResultEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        reagentName: reagent.reagentName,
        observedColor: observedColor,
        possibleSubstances: analysisResult['substances'] as List<String>,
        confidencePercentage: analysisResult['confidence'] as int,
        notes: notes,
        testCompletedAt: DateTime.now(),
      );

      state = TestResultLoaded(testResult: testResult);

      // Save to history if history controller is available
      _historyController?.saveTestResult(testResult);
    } catch (e) {
      state = TestResultError(message: 'Failed to analyze test result: $e');
    }
  }

  void analyzeTestResultWithAI({
    required ReagentEntity reagent,
    required GeminiReagentTestResult aiResult,
    String? notes,
  }) {
    state = const TestResultLoading();

    try {
      // Convert AI confidence level to percentage
      int confidencePercentage;
      switch (aiResult.confidenceLevel.toLowerCase()) {
        case 'high':
        case 'very high':
          confidencePercentage = 90;
          break;
        case 'medium':
        case 'moderate':
          confidencePercentage = 70;
          break;
        case 'low':
          confidencePercentage = 50;
          break;
        default:
          confidencePercentage = 60;
      }

      // Use AI-identified substances, or fall back to "AI Analysis" if empty
      final possibleSubstances = aiResult.identifiedSubstances.isNotEmpty
          ? aiResult.identifiedSubstances
          : [
              aiResult.primarySubstance.isNotEmpty
                  ? aiResult.primarySubstance
                  : 'AI Analysis Result',
            ];

      final testResult = TestResultEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        reagentName: reagent.reagentName,
        observedColor: aiResult.observedColorDescription,
        possibleSubstances: possibleSubstances,
        confidencePercentage: confidencePercentage,
        notes: notes,
        testCompletedAt: DateTime.now(),
      );

      state = TestResultLoaded(testResult: testResult);

      // Save to history if history controller is available
      _historyController?.saveTestResult(testResult);
    } catch (e) {
      state = TestResultError(message: 'Failed to analyze AI test result: $e');
    }
  }

  Map<String, dynamic> _analyzeColorMatch(
    ReagentEntity reagent,
    String observedColor,
  ) {
    final List<String> possibleSubstances = [];
    int confidence = 0;

    // Normalize the observed color for comparison
    final normalizedObservedColor = _normalizeColor(observedColor);

    // Check each drug result for color matches
    for (final drugResult in reagent.drugResults) {
      final expectedColors = _extractColorsFromDescription(drugResult.color);

      for (final expectedColor in expectedColors) {
        final normalizedExpectedColor = _normalizeColor(expectedColor);

        if (_colorsMatch(normalizedObservedColor, normalizedExpectedColor)) {
          possibleSubstances.add(drugResult.drugName);
          break; // Don't add the same substance multiple times
        }
      }
    }

    // Calculate confidence based on matches and specificity
    if (possibleSubstances.isEmpty) {
      // Check for "no change" or "no color change" scenarios
      if (_isNoChangeColor(normalizedObservedColor)) {
        for (final drugResult in reagent.drugResults) {
          if (_isNoChangeDescription(drugResult.color)) {
            possibleSubstances.add(drugResult.drugName);
          }
        }
        confidence = possibleSubstances.isNotEmpty ? 75 : 20;
      } else {
        confidence = 20; // Low confidence for unknown results
        possibleSubstances.add('Unknown substance or impure sample');
      }
    } else {
      // Higher confidence for specific matches, lower for multiple matches
      confidence = possibleSubstances.length == 1 ? 85 : 65;
    }

    return {'substances': possibleSubstances, 'confidence': confidence};
  }

  String _normalizeColor(String color) {
    return color
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('/', '')
        .replaceAll('>', '')
        .replaceAll('clear', 'nochange')
        .replaceAll('nochange', 'nochange');
  }

  List<String> _extractColorsFromDescription(String colorDescription) {
    // Extract individual colors from descriptions like "orange > brown" or "purple/brown"
    final colors = colorDescription
        .toLowerCase()
        .split(RegExp(r'[>\-/,]'))
        .map((color) => color.trim())
        .where((color) => color.isNotEmpty)
        .toList();

    return colors;
  }

  bool _colorsMatch(String observed, String expected) {
    // Direct match
    if (observed == expected) return true;

    // Handle color variations and synonyms
    final colorSynonyms = {
      'red': ['red', 'redorange'],
      'orange': ['orange', 'redorange'],
      'brown': ['brown', 'brownish'],
      'purple': ['purple', 'violet'],
      'black': ['black', 'darkbrown'],
      'yellow': ['yellow', 'lightyellow', 'yellowish'],
      'green': ['green', 'lightgreen', 'palegreen'],
      'blue': ['blue', 'lightblue', 'darkblue'],
      'pink': ['pink', 'magenta'],
      'grey': ['grey', 'gray'],
    };

    for (final entry in colorSynonyms.entries) {
      if (entry.value.contains(observed) && entry.value.contains(expected)) {
        return true;
      }
    }

    return false;
  }

  bool _isNoChangeColor(String color) {
    final noChangeColors = ['nochange', 'clear', 'clearnochange'];
    return noChangeColors.contains(color);
  }

  bool _isNoChangeDescription(String description) {
    final lowerDescription = description.toLowerCase();
    return lowerDescription.contains('no color change') ||
        lowerDescription.contains('no change') ||
        lowerDescription.contains('no instant reaction');
  }

  void reset() {
    state = const TestResultInitial();
  }
}
