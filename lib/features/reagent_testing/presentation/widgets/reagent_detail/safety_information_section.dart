import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/reagent_entity.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../data/services/safety_instructions_service.dart';
import '../../providers/reagent_testing_providers.dart';

class SafetyInformationSection extends ConsumerWidget {
  final ReagentEntity reagent;

  const SafetyInformationSection({super.key, required this.reagent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, l10n),
        const SizedBox(height: 16),
        _SafetyDetailsCard(reagent: reagent),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, AppLocalizations l10n) {
    return Row(
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
    );
  }
}

class _SafetyDetailsCard extends ConsumerWidget {
  final ReagentEntity reagent;

  const _SafetyDetailsCard({required this.reagent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
        child: FutureBuilder<SafetyData>(
          future: _loadSafetyData(safetyService, reagent.reagentName, isArabic),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingState();
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _ErrorState(l10n: l10n, theme: theme);
            }

            return _SafetyContent(safetyData: snapshot.data!, l10n: l10n);
          },
        ),
      ),
    );
  }

  Future<SafetyData> _loadSafetyData(
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

    return SafetyData(
      equipment: results[0],
      handlingProcedures: results[1],
      specificHazards: results[2],
      storage: results[3],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;

  const _ErrorState({required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
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
}

class _SafetyContent extends StatelessWidget {
  final SafetyData safetyData;
  final AppLocalizations l10n;

  const _SafetyContent({required this.safetyData, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SafetySection(
          title: l10n.equipment,
          items: safetyData.equipment,
          icon: Icons.security, // Safety equipment icon
        ),
        const SizedBox(height: 16),
        _SafetySection(
          title: l10n.handlingProcedures,
          items: safetyData.handlingProcedures,
          icon: Icons.pan_tool, // Handling procedures icon
        ),
        const SizedBox(height: 16),
        _SafetySection(
          title: l10n.specificHazards,
          items: safetyData.specificHazards,
          icon: Icons.warning, // Hazards icon
        ),
        const SizedBox(height: 16),
        _SafetySection(
          title: l10n.storage,
          items: safetyData.storage,
          icon: Icons.storage, // Storage icon
        ),
      ],
    );
  }
}

class _SafetySection extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;

  const _SafetySection({
    required this.title,
    required this.items,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 16, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => _SafetyItem(item: item)),
      ],
    );
  }
}

class _SafetyItem extends StatelessWidget {
  final String item;

  const _SafetyItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
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
          Expanded(child: Text(item, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class SafetyData {
  final List<String> equipment;
  final List<String> handlingProcedures;
  final List<String> specificHazards;
  final List<String> storage;

  const SafetyData({
    required this.equipment,
    required this.handlingProcedures,
    required this.specificHazards,
    required this.storage,
  });
}
