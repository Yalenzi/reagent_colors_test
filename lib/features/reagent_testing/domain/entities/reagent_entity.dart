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
  final String category;
  final List<String> references;
  // Optional: map observedColor -> list of references specific to that color
  final Map<String, List<String>>? referencesByColor;

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
    required this.category,
    this.references = const [],
    this.referencesByColor,
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
        _listEquals(other.references, references) &&
        _mapListEquals(other.referencesByColor, referencesByColor) &&
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
        references.hashCode ^
        (referencesByColor?.hashCode ?? 0) ^
        category.hashCode;
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _mapListEquals(Map<String, List<String>>? a, Map<String, List<String>>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (!_listEquals(a[key]!, b[key]!)) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'ReagentEntity(reagentName: $reagentName, description: $description, safetyLevel: $safetyLevel, testDuration: $testDuration, chemicals: $chemicals, drugResults: ${drugResults.length} results, category: $category, references: $references, referencesByColor keys: ${referencesByColor?.keys.toList()})';
  }
}
