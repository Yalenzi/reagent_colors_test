import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/reagent_testing_repository_impl.dart';
import '../../data/services/json_data_service.dart';
import '../../domain/repositories/reagent_testing_repository.dart';
import '../controllers/reagent_testing_controller.dart';
import '../states/reagent_testing_state.dart';

// JSON Data Service Provider
final jsonDataServiceProvider = Provider<JsonDataService>((ref) {
  return JsonDataService();
});

// Repository Provider
final reagentTestingRepositoryProvider = Provider<ReagentTestingRepository>((
  ref,
) {
  final jsonDataService = ref.watch(jsonDataServiceProvider);
  return ReagentTestingRepositoryImpl(jsonDataService);
});

// Controller Provider
final reagentTestingControllerProvider =
    StateNotifierProvider<ReagentTestingController, ReagentTestingState>((ref) {
      final repository = ref.watch(reagentTestingRepositoryProvider);
      return ReagentTestingController(repository);
    });
