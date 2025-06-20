import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/reagent_entity.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../controllers/reagent_detail_controller.dart';

import '../../views/test_execution_page.dart';

class StartTestButton extends ConsumerWidget {
  final ReagentEntity reagent;

  const StartTestButton({super.key, required this.reagent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isAcknowledged = ref.watch(reagentDetailControllerProvider);

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
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isAcknowledged ? () => _navigateToTest(context) : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isAcknowledged ? Icons.play_arrow : Icons.warning_outlined,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isAcknowledged
                      ? l10n.startTest
                      : l10n.safetyAcknowledgmentRequired,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToTest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestExecutionPage(reagent: reagent),
      ),
    );
  }
}
