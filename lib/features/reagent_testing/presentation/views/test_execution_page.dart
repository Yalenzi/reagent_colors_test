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

  Widget _buildColorSelector(
    testExecution,
    TestExecutionController controller,
  ) {
    final colors = [
      {'name': 'Red', 'color': Colors.red},
      {'name': 'Orange', 'color': Colors.orange},
      {'name': 'Yellow', 'color': Colors.yellow},
      {'name': 'Green', 'color': Colors.green},
      {'name': 'Blue', 'color': Colors.blue},
      {'name': 'Purple', 'color': Colors.purple},
      {'name': 'Pink', 'color': Colors.pink},
      {'name': 'Brown', 'color': Colors.brown},
      {'name': 'Black', 'color': Colors.black},
      {'name': 'White', 'color': Colors.white},
      {'name': 'Grey', 'color': Colors.grey},
      {'name': 'Olive', 'color': CustomColors.olive},
      {'name': 'No color change', 'color': Colors.transparent},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((colorData) {
        final isSelected = testExecution.selectedColor == colorData['name'];
        return GestureDetector(
          onTap: () => controller.selectColor(colorData['name'] as String),
          child: Container(
            width: 50,
            height: 50,
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
            child: colorData['name'] == 'No color change'
                ? Icon(Icons.block, color: Colors.grey, size: 24)
                : null,
          ),
        );
      }).toList(),
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
        testExecution.selectedColor != null &&
        testExecution.selectedColor!.isNotEmpty;

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
              resultController.analyzeTestResult(
                reagent: widget.reagent,
                observedColor: testExecution.selectedColor!,
                notes: _notesController.text,
              );
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
}
