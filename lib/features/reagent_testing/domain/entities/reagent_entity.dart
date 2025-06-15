import 'drug_result_entity.dart';

class ReagentEntity {
  final String reagentName;
  final String reagentNameAr;
  final String description;
  final String descriptionAr;
  final String safetyLevel;
  final String safetyLevelAr;
  final int testDuration;
  final List<String> chemicals;
  final List<DrugResultEntity> drugResults;
  final List<String> equipment;
  final List<String> specificHazards;
  final List<String> handlingProcedures;
  final List<String> storage;
  final List<String> instructions;
  final String category;

  const ReagentEntity({
    required this.reagentName,
    required this.reagentNameAr,
    required this.description,
    required this.descriptionAr,
    required this.safetyLevel,
    required this.safetyLevelAr,
    required this.testDuration,
    required this.chemicals,
    required this.drugResults,
    required this.equipment,
    required this.specificHazards,
    required this.handlingProcedures,
    required this.storage,
    required this.instructions,
    required this.category,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReagentEntity &&
        other.reagentName == reagentName &&
        other.reagentNameAr == reagentNameAr &&
        other.description == description &&
        other.descriptionAr == descriptionAr &&
        other.safetyLevel == safetyLevel &&
        other.safetyLevelAr == safetyLevelAr &&
        other.testDuration == testDuration &&
        _listEquals(other.chemicals, chemicals) &&
        _listEquals(other.drugResults, drugResults) &&
        _listEquals(other.equipment, equipment) &&
        _listEquals(other.specificHazards, specificHazards) &&
        _listEquals(other.handlingProcedures, handlingProcedures) &&
        _listEquals(other.storage, storage) &&
        _listEquals(other.instructions, instructions) &&
        other.category == category;
  }

  @override
  int get hashCode {
    return reagentName.hashCode ^
        reagentNameAr.hashCode ^
        description.hashCode ^
        descriptionAr.hashCode ^
        safetyLevel.hashCode ^
        safetyLevelAr.hashCode ^
        testDuration.hashCode ^
        chemicals.hashCode ^
        drugResults.hashCode ^
        equipment.hashCode ^
        specificHazards.hashCode ^
        handlingProcedures.hashCode ^
        storage.hashCode ^
        instructions.hashCode ^
        category.hashCode;
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'ReagentEntity(reagentName: $reagentName, description: $description, safetyLevel: $safetyLevel, testDuration: $testDuration, chemicals: $chemicals, drugResults: ${drugResults.length} results, equipment: ${equipment.length} items, instructions: ${instructions.length} steps, category: $category)';
  }
}
