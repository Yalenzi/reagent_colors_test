import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/logger.dart';

class GeminiImageAnalysisService {
  static const String _modelName =
      'gemini-1.5-flash'; // Cheaper than 2.0-flash-exp
  late final GenerativeModel _model;

  GeminiImageAnalysisService({required String apiKey}) {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.1, // Low temperature for more consistent results
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 200, // Reduced from 1024 to minimize costs
      ),
    );
  }

  Future<String> analyzeImageForChemicals(File imageFile) async {
    try {
      Logger.info('🔬 Starting Gemini image analysis for chemical detection');

      // Read image file as bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Create the prompt for chemical analysis
      const String prompt = '''
Analyze chemicals in image. Return JSON:
{
  "detected_chemicals": ["chemicals"],
  "confidence_level": "high/medium/low",
  "analysis_notes": "brief description",
  "suggested_reagents": ["reagents"],
  "color_analysis": "colors seen"
}''';

      // Create content with image and text
      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      // Generate response
      final response = await _model.generateContent(content);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }

      Logger.info('✅ Gemini analysis completed successfully');
      return responseText;
    } catch (e) {
      Logger.error('❌ Gemini image analysis failed: $e');
      rethrow;
    }
  }

  Future<String> analyzeReagentTestImage({
    required File imageFile,
    required String reagentName,
    required List<Map<String, dynamic>> drugResults,
    required Map<String, dynamic> testContext,
  }) async {
    try {
      Logger.info(
        '🔬 Starting Gemini reagent test analysis for $reagentName...',
      );

      final imageBytes = await imageFile.readAsBytes();

      // Build the substance-color knowledge database for this reagent
      final substanceColorMap = StringBuffer();
      for (final drugResult in drugResults) {
        final substance = drugResult['drugName'] ?? 'Unknown';
        final color = drugResult['color'] ?? 'no change';
        substanceColorMap.writeln('- $substance: $color');
      }

      final prompt =
          '''
$reagentName test analysis.

Known reactions:
${substanceColorMap.toString()}

Return JSON only:
{
  "observed_color_description": "color seen",
  "primary_substance": "substance",
  "identified_substances": ["substances"],
  "test_result": "Positive/Negative/Inconclusive", 
  "confidence_level": "High/Medium/Low",
  "color_match_reasoning": "brief explanation",
  "analysis_notes": "key points"
}''';

      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      final response = await _model.generateContent(content);
      final analysisText = response.text ?? 'No analysis available';

      Logger.info(
        '✅ Reagent test analysis completed: ${analysisText.length} characters',
      );
      return analysisText;
    } catch (e, stackTrace) {
      Logger.error('❌ Gemini reagent test analysis failed: $e');
      Logger.error('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
