import '../../domain/entities/reagent_entity.dart';
import 'drug_result_model.dart';

class ReagentModel {
  final String reagentName;
  final String reagentNameAr;
  final String description;
  final String descriptionAr;
  final String safetyLevel;
  final String safetyLevelAr;
  final int testDuration;
  final List<String> chemicals;
  final List<DrugResultModel> drugResults;
  final String category;
  final List<String> references;
  // Optional: map observedColor -> list of references
  final Map<String, List<String>>? referencesByColor;

  const ReagentModel({
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

  static Map<String, List<String>>? _mapOfListFromJson(dynamic value) {
    if (value == null) return null;
    final map = <String, List<String>>{};
    (value as Map).forEach((key, v) {
      map[key as String] = List<String>.from(v as List);
    });
    return map;
  }

  // Convert from JSON to Model
  factory ReagentModel.fromJson(Map<String, dynamic> json) {
    return ReagentModel(
      reagentName: json['reagentName'] as String,
      reagentNameAr: json['reagentName_ar'] as String,
      description: json['description'] as String,
      descriptionAr: json['description_ar'] as String,
      safetyLevel: json['safetyLevel'] as String,
      safetyLevelAr: json['safetyLevel_ar'] as String,
      testDuration: json['testDuration'] as int,
      chemicals: List<String>.from(json['chemicals'] as List),
      drugResults: (json['drugResults'] as List)
          .map((result) => DrugResultModel.fromJson(result))
          .toList(),
      category: json['category'] as String? ?? 'General',
      references: json['references'] != null
          ? List<String>.from(json['references'] as List)
          : const [],
      referencesByColor: _mapOfListFromJson(json['referencesByColor']),
    );
  }

  // Convert Model to JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'reagentName': reagentName,
      'reagentName_ar': reagentNameAr,
      'description': description,
      'description_ar': descriptionAr,
      'safetyLevel': safetyLevel,
      'safetyLevel_ar': safetyLevelAr,
      'testDuration': testDuration,
      'chemicals': chemicals,
      'drugResults': drugResults.map((result) => result.toJson()).toList(),
      'category': category,
      'references': references,
    };
    if (referencesByColor != null) {
      data['referencesByColor'] = referencesByColor;
    }
    return data;
  }

  // Convert Model to Entity
  ReagentEntity toEntity() {
    return ReagentEntity(
      reagentName: reagentName,
      reagentNameAr: reagentNameAr,
      description: description,
      descriptionAr: descriptionAr,
      safetyLevel: safetyLevel,
      safetyLevelAr: safetyLevelAr,
      testDuration: testDuration,
      chemicals: chemicals,
      drugResults: drugResults.map((drugResult) => drugResult.toEntity()).toList(),
      category: category,
      references: references,
      referencesByColor: referencesByColor,
    );
  }

  // Convert from Entity to Model
  factory ReagentModel.fromEntity(ReagentEntity entity) {
    return ReagentModel(
      reagentName: entity.reagentName,
      reagentNameAr: entity.reagentNameAr,
      description: entity.description,
      descriptionAr: entity.descriptionAr,
      safetyLevel: entity.safetyLevel,
      safetyLevelAr: entity.safetyLevelAr,
      testDuration: entity.testDuration,
      chemicals: entity.chemicals,
      drugResults: entity.drugResults
          .map((drugResult) => DrugResultModel.fromEntity(drugResult))
          .toList(),
      category: entity.category,
      references: entity.references,
      referencesByColor: entity.referencesByColor,
    );
  }

  ReagentModel copyWith({
    String? reagentName,
    String? reagentNameAr,
    String? description,
    String? descriptionAr,
    String? safetyLevel,
    String? safetyLevelAr,
    int? testDuration,
    List<String>? chemicals,
    List<DrugResultModel>? drugResults,
    String? category,
    List<String>? references,
    Map<String, List<String>>? referencesByColor,
  }) {
    return ReagentModel(
      reagentName: reagentName ?? this.reagentName,
      reagentNameAr: reagentNameAr ?? this.reagentNameAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      safetyLevel: safetyLevel ?? this.safetyLevel,
      safetyLevelAr: safetyLevelAr ?? this.safetyLevelAr,
      testDuration: testDuration ?? this.testDuration,
      chemicals: chemicals ?? this.chemicals,
      drugResults: drugResults ?? this.drugResults,
      category: category ?? this.category,
      references: references ?? this.references,
      referencesByColor: referencesByColor ?? this.referencesByColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReagentModel &&
          runtimeType == other.runtimeType &&
          reagentName == other.reagentName &&
          reagentNameAr == other.reagentNameAr &&
          description == other.description &&
          descriptionAr == other.descriptionAr &&
          safetyLevel == other.safetyLevel &&
          safetyLevelAr == other.safetyLevelAr &&
          testDuration == other.testDuration &&
          chemicals == other.chemicals &&
          drugResults == other.drugResults &&
          category == other.category &&
          references == other.references &&
          _mapListEquals(referencesByColor, other.referencesByColor);

  bool _mapListEquals(Map<String, List<String>>? a, Map<String, List<String>>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      final l1 = a[key] ?? const <String>[];
      final l2 = b[key] ?? const <String>[];
      if (l1.length != l2.length) return false;
      for (var i = 0; i < l1.length; i++) {
        if (l1[i] != l2[i]) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode =>
      reagentName.hashCode ^
      reagentNameAr.hashCode ^
      description.hashCode ^
      descriptionAr.hashCode ^
      safetyLevel.hashCode ^
      safetyLevelAr.hashCode ^
      testDuration.hashCode ^
      chemicals.hashCode ^
      drugResults.hashCode ^
      category.hashCode ^
      references.hashCode ^
      (referencesByColor?.hashCode ?? 0);

  @override
  String toString() {
    return 'ReagentModel(reagentName: $reagentName, description: $description, safetyLevel: $safetyLevel, testDuration: $testDuration, chemicals: $chemicals, drugResults: ${drugResults.length} results, category: $category, references: $references, referencesByColor keys: ${referencesByColor?.keys.toList()})';
  }
}
