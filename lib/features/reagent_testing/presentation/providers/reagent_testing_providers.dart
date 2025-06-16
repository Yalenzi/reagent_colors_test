import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/reagent_testing_repository_impl.dart';
import '../../data/repositories/test_result_history_repository.dart';
import '../../data/services/json_data_service.dart';
import '../../domain/repositories/reagent_testing_repository.dart';
import '../controllers/reagent_testing_controller.dart';
import '../controllers/test_execution_controller.dart';
import '../controllers/test_result_controller.dart';
import '../controllers/test_result_history_controller.dart';
import '../states/reagent_testing_state.dart';
import '../states/test_execution_state.dart';
import '../states/test_result_state.dart';
import '../states/test_result_history_state.dart';

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

// Test Execution Controller Provider
final testExecutionControllerProvider =
    StateNotifierProvider<TestExecutionController, TestExecutionState>((ref) {
      return TestExecutionController();
    });

// Test Result Controller Provider
final testResultControllerProvider =
    StateNotifierProvider<TestResultController, TestResultState>((ref) {
      final historyController = ref.watch(
        testResultHistoryControllerProvider.notifier,
      );
      return TestResultController(historyController: historyController);
    });

// Test Result History Repository Provider
final testResultHistoryRepositoryProvider =
    Provider<TestResultHistoryRepository>((ref) {
      return TestResultHistoryRepository();
    });

// Test Result History Controller Provider
final testResultHistoryControllerProvider =
    StateNotifierProvider<TestResultHistoryController, TestResultHistoryState>((
      ref,
    ) {
      final repository = ref.watch(testResultHistoryRepositoryProvider);
      return TestResultHistoryController(repository);
    });
