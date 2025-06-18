import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/test_result_entity.dart';
import '../../../../l10n/app_localizations.dart';

class TestResultPage extends ConsumerWidget {
  final TestResultEntity testResult;

  const TestResultPage({super.key, required this.testResult});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.testResults),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildResultsCard(context, theme, l10n),
                    const SizedBox(height: 24),
                    if (testResult.notes != null &&
                        testResult.notes!.isNotEmpty)
                      _buildNotesCard(context, theme, l10n),
                  ],
                ),
              ),
            ),
            _buildBottomButton(context, theme, l10n),
          ],
        ),
      ),
    );
  }

  String _translateSubstanceName(
    String substanceName,
    AppLocalizations l10n,
    BuildContext context,
  ) {
    // Handle the unknown substance case
    if (substanceName == 'Unknown substance or impure sample') {
      return l10n.unknownSubstance;
    }

    // Check if current locale is Arabic
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (!isArabic) {
      return substanceName; // Return original for English
    }

    // Map common drug names to Arabic
    final drugNameTranslations = {
      'Amphetamine': 'الأمفيتامين',
      '2C-B': '2C-B',
      'Cocaine': 'الكوكايين',
      'DMT': 'DMT',
      'Ketamine': 'الكيتامين',
      'LSD': 'LSD',
      'MDA': 'MDA',
      'MDMA': 'MDMA',
      'Mephedrone': 'الميفيدرون',
      'Methamphetamine': 'الميثامفيتامين',
      'Psilocybin': 'السيلوسيبين',
      'No Change': 'لا يوجد تغيير',
      'AI Analysis Result': 'نتيجة تحليل الذكاء الاصطناعي',
    };

    return drugNameTranslations[substanceName] ?? substanceName;
  }

  String _getLocalizedSubstances(AppLocalizations l10n, BuildContext context) {
    final translatedSubstances = testResult.possibleSubstances
        .map((substance) => _translateSubstanceName(substance, l10n, context))
        .toList();

    return translatedSubstances.join('، '); // Use Arabic comma for Arabic text
  }

  String _translateColor(
    String colorName,
    AppLocalizations l10n,
    BuildContext context,
  ) {
    // Check if current locale is Arabic
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (!isArabic) {
      return colorName; // Return original for English
    }

    // Map common color names to Arabic
    final colorTranslations = {
      'red': 'أحمر',
      'orange': 'برتقالي',
      'yellow': 'أصفر',
      'green': 'أخضر',
      'blue': 'أزرق',
      'purple': 'بنفسجي',
      'violet': 'بنفسجي',
      'pink': 'وردي',
      'brown': 'بني',
      'black': 'أسود',
      'white': 'أبيض',
      'grey': 'رمادي',
      'gray': 'رمادي',
      'clear': 'شفاف',
      'no color change': 'لا يوجد تغير في اللون',
      'no change': 'لا يوجد تغيير',
      'light': 'فاتح',
      'dark': 'داكن',
      'bright': 'ساطع',
      'pale': 'باهت',
      'deep': 'عميق',
    };

    // Handle complex color descriptions
    String translatedColor = colorName.toLowerCase();

    // Replace each color word with its Arabic equivalent
    colorTranslations.forEach((english, arabic) {
      translatedColor = translatedColor.replaceAll(english, arabic);
    });

    // Capitalize first letter if it was capitalized in original
    if (colorName.isNotEmpty && colorName[0] == colorName[0].toUpperCase()) {
      translatedColor =
          translatedColor[0].toUpperCase() + translatedColor.substring(1);
    }

    return translatedColor;
  }

  Widget _buildResultsCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.testResults,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildResultRow(
              context,
              '${l10n.reagent}:',
              testResult.reagentName,
              theme,
            ),
            const SizedBox(height: 16),
            _buildResultRow(
              context,
              '${l10n.observedColorLabel}:',
              _translateColor(testResult.observedColor, l10n, context),
              theme,
            ),
            const SizedBox(height: 16),
            _buildResultRow(
              context,
              '${l10n.possibleSubstances}:',
              _getLocalizedSubstances(l10n, context),
              theme,
            ),
            const SizedBox(height: 16),
            _buildResultRow(
              context,
              '${l10n.confidence}:',
              '${testResult.confidencePercentage}%',
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(
    BuildContext context,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
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
            Row(
              children: [
                Icon(
                  Icons.note_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.testNotes,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(testResult.notes!, style: theme.textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to home (pop all test-related pages)
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.8),
            foregroundColor: theme.colorScheme.onSurfaceVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            l10n.backToHome,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
