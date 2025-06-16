import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/reagent_entity.dart';
import '../controllers/test_execution_controller.dart';
import '../providers/reagent_testing_providers.dart';
import '../states/test_execution_state.dart';
import '../states/test_result_state.dart';
import 'test_result_page.dart';
import '../../../../core/config/get_it_config.dart';
import '../../../../core/config/api_keys.dart';
import '../../../../core/services/gemini_image_analysis_service.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/gemini_analysis_models.dart';

extension CustomColors on Colors {
  static const Color olive = Color(0xFF808000);
}

class TestExecutionPage extends ConsumerStatefulWidget {
  final ReagentEntity reagent;

  const TestExecutionPage({super.key, required this.reagent});

  @override
  ConsumerState<TestExecutionPage> createState() => _TestExecutionPageState();
}

class _TestExecutionPageState extends ConsumerState<TestExecutionPage> {
  final TextEditingController _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _capturedImage;
  bool _isAnalyzingImage = false;
  GeminiReagentTestResult? _aiAnalysisResult;
  String? _analysisError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(testExecutionControllerProvider.notifier)
          .initializeTest(widget.reagent);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(testExecutionControllerProvider);
    final controller = ref.read(testExecutionControllerProvider.notifier);

    // Listen to test result state for navigation
    ref.listen<TestResultState>(testResultControllerProvider, (previous, next) {
      if (next is TestResultLoaded) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TestResultPage(testResult: next.testResult),
          ),
        );
      } else if (next is TestResultError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing results: ${next.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Testing ${widget.reagent.reagentName}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildBody(state, controller),
    );
  }

  Widget _buildBody(
    TestExecutionState state,
    TestExecutionController controller,
  ) {
    if (state is TestExecutionInitial || state is TestExecutionLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is TestExecutionLoaded) {
      final testExecution = state.testExecution;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReadyToStartCard(context),
            const SizedBox(height: 24),
            _buildTestProcedure(context),
            const SizedBox(height: 24),
            _buildReactionTimer(context, testExecution, controller),
            const SizedBox(height: 24),
            _buildObservedColor(context, testExecution, controller),
            const SizedBox(height: 24),
            _buildTestNotes(context, testExecution, controller),
            const SizedBox(height: 24),
            _buildCompleteTestButton(context, testExecution, controller),
          ],
        ),
      );
    } else if (state is TestExecutionError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.message}'),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }
    return const Center(child: Text('Unknown state'));
  }

  Widget _buildReadyToStartCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.science_outlined,
                color: theme.colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ready to Start Test',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Follow the instructions below to begin',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestProcedure(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.list_alt_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Test Procedure',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.reagent.instructions.asMap().entries.map(
              (entry) =>
                  _buildProcedureStep(context, entry.key + 1, entry.value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcedureStep(
    BuildContext context,
    int number,
    String instruction,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.orange,
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionTimer(
    BuildContext context,
    testExecution,
    TestExecutionController controller,
  ) {
    final theme = Theme.of(context);
    final minutes = testExecution.remainingTime ~/ 60;
    final seconds = testExecution.remainingTime % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Reaction Timer',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                if (testExecution.isTimerRunning) {
                  controller.pauseTimer();
                } else {
                  controller.startTimer();
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          testExecution.isTimerRunning
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          testExecution.isTimerRunning
                              ? 'Pause Reaction Timer'
                              : 'Start Reaction Timer',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeString,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to ${testExecution.isTimerRunning ? 'pause' : 'start'} ${widget.reagent.testDuration} minute timer',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildImageCaptureButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildObservedColor(
    BuildContext context,
    testExecution,
    TestExecutionController controller,
  ) {
    final theme = Theme.of(context);

    final colors = [
      {
        'name': 'Clear/No Change',
        'color': Colors.grey.shade300,
        'textColor': Colors.black,
      },
      {'name': 'Red', 'color': Colors.red, 'textColor': Colors.white},
      {
        'name': 'Dark Red',
        'color': Colors.red.shade800,
        'textColor': Colors.white,
      },
      {'name': 'Orange', 'color': Colors.orange, 'textColor': Colors.white},
      {
        'name': 'Red-Orange',
        'color': Colors.deepOrange,
        'textColor': Colors.white,
      },
      {'name': 'Yellow', 'color': Colors.yellow, 'textColor': Colors.black},
      {
        'name': 'Light Yellow',
        'color': Colors.yellow.shade200,
        'textColor': Colors.black,
      },
      {'name': 'Green', 'color': Colors.green, 'textColor': Colors.white},
      {
        'name': 'Pale Green',
        'color': Colors.green.shade200,
        'textColor': Colors.black,
      },
      {'name': 'Blue', 'color': Colors.blue, 'textColor': Colors.white},
      {'name': 'Purple', 'color': Colors.purple, 'textColor': Colors.white},
      {
        'name': 'Violet',
        'color': Colors.purple.shade400,
        'textColor': Colors.white,
      },
      {
        'name': 'Magenta',
        'color': Colors.pink.shade400,
        'textColor': Colors.white,
      },
      {'name': 'Pink', 'color': Colors.pink, 'textColor': Colors.white},
      {'name': 'Brown', 'color': Colors.brown, 'textColor': Colors.white},
      {
        'name': 'Brownish',
        'color': Colors.brown.shade400,
        'textColor': Colors.white,
      },
      {'name': 'Black', 'color': Colors.black, 'textColor': Colors.white},
      {'name': 'Grey', 'color': Colors.grey, 'textColor': Colors.white},
      {
        'name': 'Light Blue',
        'color': Colors.lightBlue,
        'textColor': Colors.white,
      },
      {
        'name': 'Light Green',
        'color': Colors.lightGreen,
        'textColor': Colors.black,
      },
      {
        'name': 'Dark Blue',
        'color': Colors.blue.shade900,
        'textColor': Colors.white,
      },
      {
        'name': 'Dark Green',
        'color': Colors.green.shade800,
        'textColor': Colors.white,
      },
      {'name': 'Olive', 'color': CustomColors.olive, 'textColor': Colors.white},
      {
        'name': 'Greenish Brown',
        'color': Colors.brown.shade600,
        'textColor': Colors.white,
      },
      {
        'name': 'Maroon',
        'color': Colors.red.shade900,
        'textColor': Colors.white,
      },
      {
        'name': 'Navy',
        'color': Colors.indigo.shade900,
        'textColor': Colors.white,
      },
      {'name': 'Teal', 'color': Colors.teal, 'textColor': Colors.white},
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Observed Color',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select the color you observed after adding the reagent',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the color that best matches what you observed',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: colors.length,
              itemBuilder: (context, index) {
                final colorData = colors[index];
                final isSelected =
                    testExecution.selectedColor == colorData['name'];

                return GestureDetector(
                  onTap: () =>
                      controller.selectColor(colorData['name'] as String),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorData['color'] as Color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (colorData['name'] == 'Clear/No Change')
                          Center(
                            child: Text(
                              '?',
                              style: TextStyle(
                                color: colorData['textColor'] as Color,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 2,
                          left: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              colorData['name'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestNotes(
    BuildContext context,
    testExecution,
    TestExecutionController controller,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Test Notes',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              onChanged: (value) => controller.updateNotes(value),
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Add any observations, conditions, or notes about the test...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteTestButton(
    BuildContext context,
    testExecution,
    TestExecutionController controller,
  ) {
    final theme = Theme.of(context);
    final hasSelectedColor = testExecution.selectedColor != null;
    final hasAIResult = _aiAnalysisResult != null;
    final canComplete = hasSelectedColor || hasAIResult;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check_circle_outline),
        label: Text(
          hasAIResult
              ? 'Complete Test with AI Results'
              : 'Complete Test & View Results',
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: canComplete
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.12),
          foregroundColor: canComplete
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface.withValues(alpha: 0.38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: canComplete
            ? () => _completeTest(context, testExecution)
            : null,
      ),
    );
  }

  void _completeTest(BuildContext context, testExecution) {
    final resultController = ref.read(testResultControllerProvider.notifier);

    if (_aiAnalysisResult != null &&
        _aiAnalysisResult!.primarySubstance.isNotEmpty) {
      // Use AI analysis directly - create TestResultEntity with AI results
      resultController.analyzeTestResultWithAI(
        reagent: widget.reagent,
        aiResult: _aiAnalysisResult!,
        notes: testExecution.notes,
      );
    } else {
      // Use manual color selection with built-in analysis
      resultController.analyzeTestResult(
        reagent: widget.reagent,
        observedColor: testExecution.selectedColor!,
        notes: testExecution.notes,
      );
    }
  }

  Widget _buildImageCaptureButton(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Image Analysis',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Upload an image of your test result for AI analysis',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Image capture buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    onPressed: _isAnalyzingImage
                        ? null
                        : () => _captureImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('From Gallery'),
                    onPressed: _isAnalyzingImage
                        ? null
                        : () => _captureImage(ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                    ),
                  ),
                ),
              ],
            ),

            // Show captured image
            if (_capturedImage != null) ...[
              const SizedBox(height: 16),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_capturedImage!, fit: BoxFit.cover),
                ),
              ),
            ],

            // Show analysis progress
            if (_isAnalyzingImage) ...[
              const SizedBox(height: 16),
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Analyzing image with AI...'),
                  ],
                ),
              ),
            ],

            // Show AI analysis results
            if (_aiAnalysisResult != null) ...[
              const SizedBox(height: 16),
              _buildAIAnalysisResults(theme),
            ],

            // Show error
            if (_analysisError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analysis Error',
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _analysisError!,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAIAnalysisResults(ThemeData theme) {
    final result = _aiAnalysisResult!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_fix_high,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Analysis Complete',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Observed Color Description
          Row(
            children: [
              Text(
                'Observed Color: ',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            result.observedColorDescription,
            style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
          ),

          const SizedBox(height: 8),
          // Primary Substance Identified
          Row(
            children: [
              Text(
                'Identified Substance: ',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                result.primarySubstance.isEmpty
                    ? 'Unknown'
                    : result.primarySubstance,
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // All Identified Substances (if multiple)
          if (result.identifiedSubstances.length > 1) ...[
            const SizedBox(height: 4),
            Text(
              'All Possible: ${result.identifiedSubstances.join(', ')}',
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontSize: 12,
              ),
            ),
          ],

          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Test Result: ',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                result.testResult,
                style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Confidence: ',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                result.confidenceLevel,
                style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
              ),
            ],
          ),

          if (result.colorMatchReasoning.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Color Analysis: ${result.colorMatchReasoning}',
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontSize: 12,
              ),
            ),
          ],

          if (result.analysisNotes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Notes: ${result.analysisNotes}',
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontSize: 12,
              ),
            ),
          ],

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _applyAIResult(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Use AI Analysis'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _captureImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
          _aiAnalysisResult = null;
          _analysisError = null;
        });

        await _analyzeImage();
      }
    } catch (e) {
      Logger.error('Error capturing image: $e');
      setState(() {
        _analysisError = 'Failed to capture image: $e';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_capturedImage == null) return;

    // Check if Gemini service is available
    if (!ApiKeys.hasGeminiApiKey) {
      setState(() {
        _analysisError =
            'Gemini API key not configured. Please set GEMINI_API_KEY.';
      });
      return;
    }

    try {
      setState(() {
        _isAnalyzingImage = true;
        _analysisError = null;
      });

      final geminiService = getIt<GeminiImageAnalysisService>();

      // Get drug results from the reagent test for AI analysis
      final drugResults = widget.reagent.drugResults
          .map((result) => {'drugName': result.drugName, 'color': result.color})
          .toList();

      // Create test context
      final testContext = {
        'testDuration': widget.reagent.testDuration,
        'chemicals': widget.reagent.chemicals,
      };

      // Analyze with Gemini
      final response = await geminiService.analyzeReagentTestImage(
        imageFile: _capturedImage!,
        reagentName: widget.reagent.reagentName,
        drugResults: drugResults,
        testContext: testContext,
      );

      // Parse JSON response
      final jsonResponse = json.decode(
        response.replaceAll('```json', '').replaceAll('```', '').trim(),
      );
      final analysisResult = GeminiReagentTestResult.fromJson(jsonResponse);

      setState(() {
        _aiAnalysisResult = analysisResult;
        _isAnalyzingImage = false;
      });
    } catch (e) {
      Logger.error('AI analysis failed: $e');
      setState(() {
        _analysisError = 'AI analysis failed: $e';
        _isAnalyzingImage = false;
      });
    }
  }

  void _applyAIResult() {
    if (_aiAnalysisResult == null) return;

    final controller = ref.read(testExecutionControllerProvider.notifier);
    final result = _aiAnalysisResult!;

    // Map the AI-identified substance to a corresponding color
    // Look for the identified substance in the reagent's drug results
    String? matchingColor;
    if (result.primarySubstance.isNotEmpty) {
      for (final drugResult in widget.reagent.drugResults) {
        if (drugResult.drugName.toLowerCase() ==
            result.primarySubstance.toLowerCase()) {
          matchingColor = drugResult.color;
          break;
        }
      }
    }

    // If we found a matching color, select it
    if (matchingColor != null) {
      controller.selectColor(matchingColor);
    }

    // Add comprehensive AI analysis notes to the test notes
    final aiNotes = StringBuffer();
    aiNotes.writeln('=== AI Analysis Results ===');
    aiNotes.writeln('Observed Color: ${result.observedColorDescription}');
    if (result.primarySubstance.isNotEmpty) {
      aiNotes.writeln('Identified Substance: ${result.primarySubstance}');
    }
    if (result.identifiedSubstances.isNotEmpty) {
      aiNotes.writeln(
        'All Possible Substances: ${result.identifiedSubstances.join(', ')}',
      );
    }
    aiNotes.writeln('Test Result: ${result.testResult}');
    aiNotes.writeln('Confidence: ${result.confidenceLevel}');
    if (result.colorMatchReasoning.isNotEmpty) {
      aiNotes.writeln('Color Analysis: ${result.colorMatchReasoning}');
    }
    if (result.analysisNotes.isNotEmpty) {
      aiNotes.writeln('Additional Notes: ${result.analysisNotes}');
    }

    final currentNotes = _notesController.text;
    final updatedNotes = currentNotes.isEmpty
        ? aiNotes.toString()
        : '$currentNotes\n\n${aiNotes.toString()}';

    _notesController.text = updatedNotes;
    controller.updateNotes(updatedNotes);

    final substanceText = result.primarySubstance.isEmpty
        ? 'analysis'
        : result.primarySubstance;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied AI result: $substanceText'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
