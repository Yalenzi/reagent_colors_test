import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reagent_colors_test/features/reagent_testing/domain/entities/reagent_entity.dart';
import 'package:reagent_colors_test/features/reagent_testing/data/models/gemini_analysis_models.dart';
import 'package:reagent_colors_test/features/reagent_testing/presentation/providers/reagent_testing_providers.dart';
import 'package:reagent_colors_test/core/utils/logger.dart';
import 'package:reagent_colors_test/l10n/app_localizations.dart';

class AIImageAnalysisSection extends ConsumerStatefulWidget {
  final ReagentEntity reagent;
  const AIImageAnalysisSection({super.key, required this.reagent});

  @override
  ConsumerState<AIImageAnalysisSection> createState() =>
      _AIImageAnalysisSectionState();
}

class _AIImageAnalysisSectionState
    extends ConsumerState<AIImageAnalysisSection> {
  final ImagePicker _picker = ImagePicker();
  File? _capturedImage;
  bool _isAnalyzing = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(testExecutionControllerProvider);

    final aiResult = state.maybeWhen(
      loaded: (execution, aiResult, notes) => aiResult,
      orElse: () => null,
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.aiAnalysis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.uploadImageDescription),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera),
                    label: Text(l10n.captureImage),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: Text(l10n.fromGallery),
                  ),
                ),
              ],
            ),
            if (_capturedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  children: [
                    Image.file(
                      _capturedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 12),
                    if (_isAnalyzing)
                      const CircularProgressIndicator()
                    else
                      Consumer(
                        builder: (context, ref, child) {
                          final geminiServiceAsync = ref.watch(
                            geminiAnalysisServiceProvider,
                          );

                          return geminiServiceAsync.when(
                            data: (service) => ElevatedButton(
                              onPressed: _analyzeImage,
                              child: Text(l10n.analyzeWithAI),
                            ),
                            loading: () => ElevatedButton(
                              onPressed: null,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Loading AI...'),
                                ],
                              ),
                            ),
                            error: (error, stack) => ElevatedButton(
                              onPressed: null,
                              child: const Text('AI Service Error'),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            if (aiResult != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: _buildAIResult(aiResult, l10n),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIResult(GeminiReagentTestResult result, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.aiAnalysisResult,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('${l10n.observedColor}: ${result.observedColorDescription}'),
        Text('${_getSubstanceLabel(l10n)}: ${result.primarySubstance}'),
        Text('${_getConfidenceLabel(l10n)}: ${result.confidenceLevel}'),
        Text('${l10n.analysisNotes}: ${result.analysisNotes}'),
      ],
    );
  }

  String _getSubstanceLabel(AppLocalizations l10n) {
    return l10n.localeName == 'ar' ? 'المادة' : 'Substance';
  }

  String _getConfidenceLabel(AppLocalizations l10n) {
    return l10n.localeName == 'ar' ? 'مستوى الثقة' : 'Confidence';
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (image != null) {
      setState(() {
        _capturedImage = File(image.path);
        _error = null;
      });
      ref
          .read(testExecutionControllerProvider.notifier)
          .updateAIAnalysisResult(null);
    }
  }

  Future<void> _analyzeImage() async {
    if (_capturedImage == null) return;
    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      // Get the AsyncValue from the FutureProvider
      final geminiServiceAsync = ref.read(geminiAnalysisServiceProvider);

      // Handle the async value
      await geminiServiceAsync.when(
        data: (geminiService) async {
          final drugResults = widget.reagent.drugResults
              .map(
                (result) => {
                  'drugName': result.drugName,
                  'color': result.color,
                },
              )
              .toList();

          final resultString = await geminiService.analyzeReagentTestImage(
            imageFile: _capturedImage!,
            reagentName: widget.reagent.reagentName,
            drugResults: drugResults,
            testContext: {'type': 'reagent_test'},
          );

          final resultJson = jsonDecode(resultString);
          final aiResult = GeminiReagentTestResult.fromJson(resultJson);

          ref
              .read(testExecutionControllerProvider.notifier)
              .updateAIAnalysisResult(aiResult);
        },
        loading: () {
          // Service is still loading, keep showing progress
          Logger.info('Gemini service is still initializing...');
        },
        error: (error, stack) {
          throw Exception('Gemini service initialization failed: $error');
        },
      );
    } catch (e) {
      Logger.error('AI Analysis failed: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _error = l10n.aiAnalysisError;
        });
      }
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }
}
