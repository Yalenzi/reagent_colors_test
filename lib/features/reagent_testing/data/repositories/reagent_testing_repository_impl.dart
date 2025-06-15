import '../../domain/entities/reagent_entity.dart';
import '../../domain/repositories/reagent_testing_repository.dart';
import '../services/json_data_service.dart';

class ReagentTestingRepositoryImpl implements ReagentTestingRepository {
  final JsonDataService _jsonDataService;

  ReagentTestingRepositoryImpl(this._jsonDataService);

  @override
  Future<List<ReagentEntity>> getAllReagents() async {
    try {
      final reagentModels = await _jsonDataService.loadAllReagents();
      return reagentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to load reagents: $e');
    }
  }

  @override
  Future<ReagentEntity?> getReagentByName(String reagentName) async {
    try {
      final reagentModel = await _jsonDataService.loadReagentByName(
        reagentName,
      );
      return reagentModel?.toEntity();
    } catch (e) {
      throw Exception('Failed to load reagent $reagentName: $e');
    }
  }

  @override
  Future<List<ReagentEntity>> searchReagents(String query) async {
    try {
      final reagentModels = await _jsonDataService.searchReagents(query);
      return reagentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to search reagents: $e');
    }
  }

  @override
  Future<List<ReagentEntity>> getReagentsBySafetyLevel(
    String safetyLevel,
  ) async {
    try {
      final reagentModels = await _jsonDataService.getReagentsBySafetyLevel(
        safetyLevel,
      );
      return reagentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get reagents by safety level: $e');
    }
  }
}
