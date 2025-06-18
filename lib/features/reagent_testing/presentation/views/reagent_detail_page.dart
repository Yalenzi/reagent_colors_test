import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reagent_colors_test/features/reagent_testing/presentation/controllers/reagent_detail_controller.dart';
import '../../domain/entities/reagent_entity.dart';
import 'test_execution_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/localization_helper.dart';
import '../providers/reagent_testing_providers.dart';
import '../../data/services/safety_instructions_service.dart';

class ReagentDetailPage extends ConsumerWidget {
  final ReagentEntity reagent;

  const ReagentDetailPage({super.key, required this.reagent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isAcknowledged = ref.watch(reagentDetailControllerProvider);
    final controller = ref.read(reagentDetailControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationHelper.getLocalizedReagentName(context, reagent),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(context, l10n),
                  const SizedBox(height: 24),
                  _buildSafetyInformation(context, l10n, ref),
                  const SizedBox(height: 24),
                  _buildChemicalComponents(context, l10n),
                  const SizedBox(height: 24),
                  _buildTestInstructions(context, l10n, ref),
                  const SizedBox(height: 24),
                  _buildSafetyAcknowledgment(
                    context,
                    l10n,
                    isAcknowledged,
                    controller,
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, l10n, isAcknowledged, controller),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, AppLocalizations l10n) {
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.science_outlined,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocalizationHelper.getLocalizedReagentName(
                          context,
                          reagent,
                        ),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        LocalizationHelper.getLocalizedDescription(
                          context,
                          reagent,
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.duration(reagent.testDuration.toString()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${l10n.category}: ${_translateCategory(reagent.category, l10n)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _translateCategory(String categoryValue, AppLocalizations l10n) {
    switch (categoryValue.toLowerCase()) {
      case 'primary tests':
        return l10n.primaryTests;
      case 'secondary tests':
        return l10n.secondaryTests;
      case 'specialized tests':
        return l10n.specializedTests;
      default:
        return categoryValue; // Return original if no translation found
    }
  }

  Widget _buildSafetyInformation(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_outlined,
                color: theme.colorScheme.onError,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.safetyInformation,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDetailedSafetyCard(context, l10n, ref),
      ],
    );
  }

  Widget _buildDetailedSafetyCard(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
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
        child: FutureBuilder<Map<String, List<String>>>(
          future: _loadAllSafetyData(
            safetyService,
            reagent.reagentName,
            isArabic,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Column(
                children: [
                  Icon(Icons.warning_outlined, color: theme.colorScheme.error),
                  const SizedBox(height: 8),
                  Text(
                    l10n.errorLoadingSettings,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
              );
            }

            final safetyData = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSafetySection(
                  context,
                  l10n.equipment,
                  safetyData['equipment'] ?? [],
                  Icons.construction_outlined,
                ),
                const SizedBox(height: 16),
                _buildSafetySection(
                  context,
                  l10n.handlingProcedures,
                  safetyData['handlingProcedures'] ?? [],
                  Icons.pan_tool_outlined,
                ),
                const SizedBox(height: 16),
                _buildSafetySection(
                  context,
                  l10n.specificHazards,
                  safetyData['specificHazards'] ?? [],
                  Icons.dangerous_outlined,
                ),
                const SizedBox(height: 16),
                _buildSafetySection(
                  context,
                  l10n.storage,
                  safetyData['storage'] ?? [],
                  Icons.inventory_2_outlined,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<Map<String, List<String>>> _loadAllSafetyData(
    SafetyInstructionsService safetyService,
    String reagentName,
    bool isArabic,
  ) async {
    final results = await Future.wait<List<String>>([
      safetyService.getEquipmentForReagent(reagentName, isArabic: isArabic),
      safetyService.getHandlingProceduresForReagent(
        reagentName,
        isArabic: isArabic,
      ),
      safetyService.getSpecificHazardsForReagent(
        reagentName,
        isArabic: isArabic,
      ),
      safetyService.getStorageForReagent(reagentName, isArabic: isArabic),
    ]);

    return {
      'equipment': results[0],
      'handlingProcedures': results[1],
      'specificHazards': results[2],
      'storage': results[3],
    };
  }

  Widget _buildSafetySection(
    BuildContext context,
    String title,
    List<String> items,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(item, style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildChemicalComponents(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.science_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              l10n.chemicalComponents,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: reagent.chemicals
                  .map(
                    (chemical) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              chemical,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestInstructions(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    final safetyService = ref.read(safetyInstructionsServiceProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list_alt_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              l10n.testInstructions,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<List<String>>(
              future: safetyService.getInstructionsForReagent(
                reagent.reagentName,
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
                  children: instructions
                      .asMap()
                      .entries
                      .map(
                        (entry) => Padding(
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
                                    '${entry.key + 1}',
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
                                  entry.value,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyAcknowledgment(
    BuildContext context,
    AppLocalizations l10n,
    bool isAcknowledged,
    ReagentDetailController controller,
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
                  Icons.verified_user_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.safetyAcknowledgment,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: isAcknowledged,
                  onChanged: (value) =>
                      controller.setSafetyAcknowledgment(value ?? false),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.safetyAcknowledgmentText,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    AppLocalizations l10n,
    bool isAcknowledged,
    ReagentDetailController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isAcknowledged
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TestExecutionPage(reagent: reagent),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            isAcknowledged ? l10n.startTest : l10n.safetyAcknowledgmentRequired,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
