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
import '../../../../core/config/api_keys.dart';
import '../../../../core/services/gemini_image_analysis_service.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/gemini_analysis_models.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/localization_helper.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
        title: Text(
          l10n.testing(
            LocalizationHelper.getLocalizedReagentName(context, widget.reagent),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildBody(state, controller, l10n),
    );
  }

  Widget _buildBody(
    TestExecutionState state,
    TestExecutionController controller,
    AppLocalizations l10n,
  ) {
    if (state is TestExecutionInitial || state is TestExecutionLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.loading),
          ],
        ),
      );
    } else if (state is TestExecutionLoaded) {
      final testExecution = state.testExecution;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReadyToStartCard(context, l10n),
            const SizedBox(height: 24),
            _buildTestProcedure(context, l10n),
            const SizedBox(height: 24),
            _buildReactionTimer(context, l10n, testExecution, controller),
            const SizedBox(height: 24),
            _buildAIImageAnalysis(context, l10n),
            const SizedBox(height: 24),
            _buildObservedColor(context, l10n, testExecution, controller),
            const SizedBox(height: 24),
            _buildTestNotes(context, l10n, testExecution, controller),
            const SizedBox(height: 24),
            _buildCompleteTestButton(context, l10n, testExecution, controller),
          ],
        ),
      );
    } else if (state is TestExecutionError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.error(state.message)),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.goBack),
            ),
          ],
        ),
      );
    }
    return Center(child: Text(l10n.unknownState));
  }

  Widget _buildReadyToStartCard(BuildContext context, AppLocalizations l10n) {
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
                    l10n.readyToStart,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.readyToStartDescription,
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

  Widget _buildTestProcedure(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final safetyService = ref.read(safetyInstructionsServiceProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

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
                Icon(Icons.list_alt_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.testProcedure,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<String>>(
              future: safetyService.getInstructionsForReagent(
                widget.reagent.reagentName,
                isArabic: isArabic,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Column(
                    children: [
                      Icon(
                        Icons.warning_outlined,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.errorLoadingSettings,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                  );
                }

                final instructions = snapshot.data!;
                return Column(
                  children: instructions.asMap().entries.map((entry) {
                    int index = entry.key;
                    String instruction = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              instruction,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionTimer(
    BuildContext context,
    AppLocalizations l10n,
    testExecution,
    TestExecutionController controller,
  ) {
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
            Text(
              l10n.reactionTimer,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    _formatDuration(
                      Duration(
                        seconds:
                            testExecution.timerDuration -
                            testExecution.remainingTime,
                      ),
                    ),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: testExecution.isTimerRunning
                            ? () => controller.pauseTimer()
                            : () => controller.startTimer(),
                        child: Text(
                          testExecution.isTimerRunning
                              ? l10n.stopTimer
                              : l10n.startTimer,
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => controller.resetTimer(),
                        child: Text(l10n.resetTimer),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservedColor(
    BuildContext context,
    AppLocalizations l10n,
    testExecution,
    TestExecutionController controller,
  ) {
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
            Text(
              l10n.observedColor,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.observedColorDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.tapColorInstruction,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _buildColorSelector(testExecution, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildAIImageAnalysis(BuildContext context, AppLocalizations l10n) {
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
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.aiAnalysis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.uploadImageDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _takePicture(ImageSource.camera),
                    icon: const Icon(Icons.camera),
                    label: Text(l10n.takePhoto),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _takePicture(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: Text(l10n.fromGallery),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSecondary,
                    ),
                  ),
                ),
              ],
            ),
            if (_capturedImage != null) ...[
              const SizedBox(height: 16),
              Container(
                height: 200,
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isAnalyzingImage ? null : _analyzeImage,
                      child: _isAnalyzingImage
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(l10n.analyzing),
                              ],
                            )
                          : Text(l10n.analyzeWithAI),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => setState(() {
                      _capturedImage = null;
                      _aiAnalysisResult = null;
                      _analysisError = null;
                    }),
                    child: Text(l10n.retakePhoto),
                  ),
                ],
              ),
            ],
            if (_aiAnalysisResult != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aiAnalysisResult,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.observedColor}: ${_aiAnalysisResult!.observedColorDescription}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    if (_aiAnalysisResult!.primarySubstance.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.aiSuggestion}: ${_aiAnalysisResult!.primarySubstance}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.confidenceLevel}: ${_aiAnalysisResult!.confidenceLevel}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final controller = ref.read(
                            testExecutionControllerProvider.notifier,
                          );
                          controller.selectColor(
                            _aiAnalysisResult!.observedColorDescription,
                          );

                          // Auto-populate notes with AI analysis
                          final aiNotes = _buildAIAnalysisNotes(
                            _aiAnalysisResult!,
                          );
                          _notesController.text = aiNotes;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.aiResultsApplied),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(l10n.useAiResults),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_analysisError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${l10n.aiAnalysisError}: $_analysisError',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector(
    testExecution,
    TestExecutionController controller,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final colors = [
      {
        'name': 'Clear/No change',
        'color': Colors.transparent,
        'localizedName': l10n.clearNoChange,
      },
      {'name': 'Red', 'color': Colors.red, 'localizedName': l10n.red},
      {
        'name': 'Dark Red',
        'color': const Color(0xFF8B0000),
        'localizedName': l10n.darkRed,
      },
      {'name': 'Orange', 'color': Colors.orange, 'localizedName': l10n.orange},
      {
        'name': 'Red-Orange',
        'color': const Color(0xFFFF4500),
        'localizedName': l10n.redOrange,
      },
      {'name': 'Yellow', 'color': Colors.yellow, 'localizedName': l10n.yellow},
      {
        'name': 'Light Yellow',
        'color': const Color(0xFFFFFFE0),
        'localizedName': l10n.lightYellow,
      },
      {'name': 'Green', 'color': Colors.green, 'localizedName': l10n.green},
      {
        'name': 'Pale Green',
        'color': const Color(0xFF98FB98),
        'localizedName': l10n.paleGreen,
      },
      {'name': 'Blue', 'color': Colors.blue, 'localizedName': l10n.blue},
      {'name': 'Purple', 'color': Colors.purple, 'localizedName': l10n.purple},
      {
        'name': 'Violet',
        'color': const Color(0xFF8A2BE2),
        'localizedName': l10n.violet,
      },
      {
        'name': 'Magenta',
        'color': Colors.pink.shade300,
        'localizedName': l10n.magenta,
      },
      {'name': 'Pink', 'color': Colors.pink, 'localizedName': l10n.pink},
      {'name': 'Brown', 'color': Colors.brown, 'localizedName': l10n.brown},
      {
        'name': 'Brownish',
        'color': const Color(0xFFA0522D),
        'localizedName': l10n.brownish,
      },
      {'name': 'Black', 'color': Colors.black, 'localizedName': l10n.black},
      {'name': 'Grey', 'color': Colors.grey, 'localizedName': l10n.grey},
      {
        'name': 'Light Blue',
        'color': Colors.lightBlue,
        'localizedName': l10n.lightBlue,
      },
      {
        'name': 'Light Green',
        'color': Colors.lightGreen,
        'localizedName': l10n.lightGreen,
      },
      {
        'name': 'Dark Blue',
        'color': const Color(0xFF00008B),
        'localizedName': l10n.darkBlue,
      },
      {
        'name': 'Dark Green',
        'color': const Color(0xFF006400),
        'localizedName': l10n.darkGreen,
      },
      {
        'name': 'Olive',
        'color': CustomColors.olive,
        'localizedName': l10n.olive,
      },
      {
        'name': 'Greenish Brown',
        'color': const Color(0xFF8FBC8F),
        'localizedName': l10n.greenishBrown,
      },
      {
        'name': 'Maroon',
        'color': const Color(0xFF800000),
        'localizedName': l10n.maroon,
      },
      {
        'name': 'Navy',
        'color': const Color(0xFF000080),
        'localizedName': l10n.navy,
      },
      {
        'name': 'Teal',
        'color': const Color(0xFF008080),
        'localizedName': l10n.teal,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final colorData = colors[index];
        final isSelected = testExecution.selectedColor == colorData['name'];
        return GestureDetector(
          onTap: () => controller.selectColor(colorData['name'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: colorData['color'] as Color,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (colorData['name'] == 'Clear/No change')
                  Icon(Icons.block, color: Colors.grey, size: 20)
                else
                  const SizedBox(height: 20),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    colorData['localizedName'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _getTextColor(colorData['color'] as Color),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTestNotes(
    BuildContext context,
    AppLocalizations l10n,
    testExecution,
    TestExecutionController controller,
  ) {
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
            Text(
              l10n.testNotes,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: l10n.testNotesPlaceholder,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              maxLines: 4,
              onChanged: (value) => controller.updateNotes(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteTestButton(
    BuildContext context,
    AppLocalizations l10n,
    testExecution,
    TestExecutionController controller,
  ) {
    final canComplete =
        (testExecution.selectedColor != null &&
            testExecution.selectedColor!.isNotEmpty) ||
        _aiAnalysisResult != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canComplete
            ? () => _completeTest(testExecution, controller, l10n)
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          l10n.completeTest,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _completeTest(
    testExecution,
    TestExecutionController controller,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.completeTest),
        content: Text(l10n.completeTestDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              final resultController = ref.read(
                testResultControllerProvider.notifier,
              );

              // Check if we should use AI analysis or manual color selection
              if (_aiAnalysisResult != null &&
                  (testExecution.selectedColor == null ||
                      testExecution.selectedColor!.isEmpty ||
                      testExecution.selectedColor ==
                          _aiAnalysisResult!.observedColorDescription)) {
                // Use AI analysis results directly to preserve AI's substance identification
                Logger.info(
                  '🤖 Using AI analysis results for test completion: ${_aiAnalysisResult!.primarySubstance}',
                );

                resultController.analyzeTestResultWithAI(
                  reagent: widget.reagent,
                  aiResult: _aiAnalysisResult!,
                  notes: _notesController.text,
                );
              } else {
                // Use manual color selection with traditional color matching
                final observedColor = testExecution.selectedColor ?? 'Unknown';
                Logger.info(
                  '🎨 Using manual color selection for test completion: $observedColor',
                );
                resultController.analyzeTestResult(
                  reagent: widget.reagent,
                  observedColor: observedColor,
                  notes: _notesController.text,
                );
              }
            },
            child: Text(l10n.completeTest),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _takePicture(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
          _aiAnalysisResult = null;
          _analysisError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_capturedImage == null) return;

    setState(() {
      _isAnalyzingImage = true;
      _analysisError = null;
    });

    try {
      final geminiService = GeminiImageAnalysisService(
        apiKey: ApiKeys.geminiApiKey,
      );

      final drugResults = widget.reagent.drugResults
          .map((result) => {'drugName': result.drugName, 'color': result.color})
          .toList();

      final analysisJson = await geminiService.analyzeReagentTestImage(
        imageFile: _capturedImage!,
        reagentName: widget.reagent.reagentName,
        drugResults: drugResults,
        testContext: {'type': 'reagent_test'},
      );

      // Parse the JSON response
      try {
        final jsonData = jsonDecode(analysisJson);
        final analysisResult = GeminiReagentTestResult.fromJson(jsonData);

        setState(() {
          _aiAnalysisResult = analysisResult;
          _isAnalyzingImage = false;
        });

        // Auto-select the AI-analyzed color for easy completion
        if (analysisResult.observedColorDescription.isNotEmpty) {
          final controller = ref.read(testExecutionControllerProvider.notifier);
          controller.selectColor(analysisResult.observedColorDescription);
        }

        // Auto-populate notes with AI analysis
        final aiNotes = _buildAIAnalysisNotes(analysisResult);
        if (mounted) {
          _notesController.text = aiNotes;
        }
      } catch (parseError) {
        throw Exception('Failed to parse AI analysis: $parseError');
      }
    } catch (e) {
      setState(() {
        _analysisError = e.toString();
        _isAnalyzingImage = false;
      });
      Logger.error('AI analysis failed: $e');
    }
  }

  String _buildAIAnalysisNotes(GeminiReagentTestResult aiResult) {
    final l10n = AppLocalizations.of(context)!;
    final notes = StringBuffer();
    notes.writeln('--- ${l10n.aiAnalysis} ---');

    if (aiResult.colorMatchReasoning.isNotEmpty) {
      notes.writeln('${l10n.analysisNotes}: ${aiResult.colorMatchReasoning}');
    }

    if (aiResult.analysisNotes.isNotEmpty) {
      notes.writeln('Technical Notes: ${aiResult.analysisNotes}');
    }

    if (aiResult.recommendations.isNotEmpty) {
      notes.writeln('Recommendations: ${aiResult.recommendations}');
    }

    if (aiResult.testResult.isNotEmpty) {
      notes.writeln('${l10n.testResult}: ${aiResult.testResult}');
    }

    if (aiResult.concentrationEstimate.isNotEmpty) {
      notes.writeln('Concentration: ${aiResult.concentrationEstimate}');
    }

    return notes.toString().trim();
  }

  Color _getTextColor(Color backgroundColor) {
    // Calculate luminance to determine if text should be white or black
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
