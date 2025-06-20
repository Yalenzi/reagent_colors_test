import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/reagent_entity.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../controllers/reagent_detail_controller.dart';

class SafetyAcknowledgmentSection extends ConsumerWidget {
  final ReagentEntity reagent;

  const SafetyAcknowledgmentSection({super.key, required this.reagent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isAcknowledged = ref.watch(reagentDetailControllerProvider);
    final controller = ref.read(reagentDetailControllerProvider.notifier);

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
            _buildSectionHeader(theme, l10n),
            const SizedBox(height: 16),
            _buildAcknowledgmentCheckbox(
              theme,
              l10n,
              isAcknowledged,
              controller,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.verified_user, // Acknowledgment/verification icon
            color: theme.colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          l10n.safetyAcknowledgment,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAcknowledgmentCheckbox(
    ThemeData theme,
    AppLocalizations l10n,
    bool isAcknowledged,
    ReagentDetailController controller,
  ) {
    return Row(
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
    );
  }
}
