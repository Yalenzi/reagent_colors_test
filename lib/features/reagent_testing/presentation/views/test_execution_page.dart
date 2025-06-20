import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reagent_colors_test/features/reagent_testing/domain/entities/reagent_entity.dart';
import 'package:reagent_colors_test/features/reagent_testing/presentation/providers/reagent_testing_providers.dart';
import 'package:reagent_colors_test/features/reagent_testing/presentation/widgets/test_execution/test_execution_content.dart';
import 'package:reagent_colors_test/l10n/app_localizations.dart';

class TestExecutionPage extends ConsumerStatefulWidget {
  final ReagentEntity reagent;

  const TestExecutionPage({super.key, required this.reagent});

  @override
  ConsumerState<TestExecutionPage> createState() => _TestExecutionPageState();
}

class _TestExecutionPageState extends ConsumerState<TestExecutionPage> {
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
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          final shouldPop = await _showExitConfirmation(context);
          if (shouldPop == true && mounted && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.reagent.reagentName),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            tooltip: 'Back',
            onPressed: () async {
              final shouldPop = await _showExitConfirmation(context);
              if (shouldPop == true && mounted && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: TestExecutionContent(reagent: widget.reagent),
      ),
    );
  }

  Future<bool?> _showExitConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmExit),
        content: Text(l10n.testProgressWillBeLost),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.exit),
          ),
        ],
      ),
    );
  }
}
