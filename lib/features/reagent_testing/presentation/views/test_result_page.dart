import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:reagentkit/features/reagent_testing/domain/entities/test_result_entity.dart';
import 'package:reagentkit/features/reagent_testing/presentation/providers/reagent_testing_providers.dart';
import 'package:reagentkit/features/reagent_testing/presentation/states/test_result_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/localization_helper.dart';

class TestResultPage extends ConsumerWidget {
  const TestResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(testResultControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.testResults),
        leading: IconButton(
          icon: Icon(LocalizationHelper.getBackChevronIcon(context)),
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
          tooltip: 'Back to Home',
        ),
        actions: [
          IconButton(
            icon: Icon(HeroIcons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
            tooltip: 'Share Results',
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, TestResultState state) {
    if (state is TestResultLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is TestResultLoaded) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  48, // Extra padding
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                TestResultContent(testResult: state.testResult),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  icon: Icon(HeroIcons.home),
                  label: const Text('Back to Home'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      );
    } else if (state is TestResultError) {
      return Center(child: Text('Error: ${state.message}'));
    } else {
      return const Center(child: Text('No result yet.'));
    }
  }
}

class TestResultContent extends StatelessWidget {
  final TestResultEntity testResult;

  const TestResultContent({super.key, required this.testResult});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Test Results',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildResultRow(context, 'Reagent:', testResult.reagentName),
            const SizedBox(height: 8),
            _buildResultRow(
              context,
              'Observed Color:',
              testResult.observedColor,
            ),
            const SizedBox(height: 8),
            _buildResultRow(
              context,
              'Possible Substances:',
              testResult.possibleSubstances.join(', '),
            ),
            const SizedBox(height: 8),
            _buildResultRow(
              context,
              'Confidence:',
              '${testResult.confidencePercentage}%',
            ),
            if (testResult.notes != null && testResult.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildResultRow(context, 'Notes:', testResult.notes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
