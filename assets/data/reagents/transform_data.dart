import 'dart:convert';
import 'dart:io';

// Script to transform drug-centric data to reagent-centric data
Future<void> main() async {
  final Map<String, List<Map<String, dynamic>>> reagentDatabase = {};

  final drugFiles = [
    'Amphetamine_reagent_data.json',
    '2C-B_reagent_data.json',
    'Cocaine_reagent_data.json',
    'DMT_reagent_data.json',
    'Ketamine_reagent_data.json',
    'LSD_reagent_data.json',
    'MDA_reagent_data.json',
    'MDMA_reagent_data.json',
    'Mephedrone_reagent_data.json',
    'Methamphetamine_reagent_data.json',
    'Psilocybin_reagent_data.json',
  ];

  for (final fileName in drugFiles) {
    final file = File(fileName);
    if (await file.exists()) {
      final content = await file.readAsString();
      final drugData = jsonDecode(content) as Map<String, dynamic>;
      final drugName = drugData['drugName'] as String;
      final reagents = drugData['reagentsymbol-full'] as List<dynamic>;

      for (final reagentData in reagents) {
        final reagent = reagentData as Map<String, dynamic>;
        final reagentName = reagent['reagent'] as String;
        final result = reagent['result'] as Map<String, dynamic>;

        reagentDatabase.putIfAbsent(reagentName, () => []);
        reagentDatabase[reagentName]!.add({
          'drugName': drugName,
          'color': result['color'],
          'color_ar': result['color_ar'],
        });
      }
    }
  }

  // Generate reagent-centric JSON files
  for (final reagentName in reagentDatabase.keys) {
    final reagentData = {
      'reagentName': reagentName,
      'description': _getReagentDescription(reagentName),
      'safetyLevel': _getSafetyLevel(reagentName),
      'testDuration': _getTestDuration(reagentName),
      'chemicals': _getChemicals(reagentName),
      'drugResults': reagentDatabase[reagentName],
    };

    final output = const JsonEncoder.withIndent('  ').convert(reagentData);
    await File(
      '${reagentName.toLowerCase().replaceAll("'", "")}_reagent.json',
    ).writeAsString(output);
  }

  // Reagent-centric data generated successfully!
}

String _getReagentDescription(String reagentName) {
  switch (reagentName) {
    case 'Marquis':
      return 'Primary reagent for detecting MDMA, amphetamines, and opiates';
    case 'Ehrlich':
      return 'Detects psychedelics like LSD, DMT, and psilocybin';
    case 'Mecke':
      return 'Secondary confirmation test for MDMA and amphetamines';
    case 'Mandelin':
      return 'Identifies ketamine and PCP compounds';
    case 'Liebermann':
      return 'Tests for amphetamines and cocaine';
    case 'Froehde':
      return 'Detects opiates and morphine derivatives';
    case 'Simon\'s':
      return 'Specific test for secondary amines (MDMA)';
    case 'Scott':
      return 'Cocaine-specific reagent test';
    case 'Morris':
      return 'Secondary test for various stimulants';
    default:
      return 'Chemical reagent for substance identification';
  }
}

String _getSafetyLevel(String reagentName) {
  switch (reagentName) {
    case 'Marquis':
    case 'Ehrlich':
    case 'Mecke':
      return 'HIGH';
    case 'Mandelin':
    case 'Liebermann':
    case 'Froehde':
      return 'EXTREME';
    default:
      return 'HIGH';
  }
}

int _getTestDuration(String reagentName) {
  switch (reagentName) {
    case 'Marquis':
    case 'Mecke':
    case 'Simon\'s':
      return 30;
    case 'Ehrlich':
      return 60;
    case 'Mandelin':
    case 'Liebermann':
      return 45;
    default:
      return 40;
  }
}

List<String> _getChemicals(String reagentName) {
  switch (reagentName) {
    case 'Marquis':
      return ['Formaldehyde', 'Concentrated Sulfuric Acid'];
    case 'Ehrlich':
      return ['4-Dimethylaminobenzaldehyde', 'Hydrochloric Acid', 'Ethanol'];
    case 'Mecke':
      return ['Selenous Acid', 'Concentrated Sulfuric Acid'];
    case 'Mandelin':
      return ['Ammonium Metavanadate', 'Concentrated Sulfuric Acid'];
    case 'Liebermann':
      return ['Potassium Nitrite', 'Concentrated Sulfuric Acid'];
    case 'Scott':
      return ['Cobalt Thiocyanate', 'Hydrochloric Acid', 'Chloroform'];
    default:
      return ['Chemical Reagent'];
  }
}
