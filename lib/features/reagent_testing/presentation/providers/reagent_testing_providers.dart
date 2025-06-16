import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/reagent_testing_repository_impl.dart';
import '../../data/repositories/test_result_history_repository.dart';
import '../../data/services/json_data_service.dart';
import '../../data/services/remote_config_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/reagent_testing_repository.dart';
import '../controllers/reagent_testing_controller.dart';
import '../controllers/test_execution_controller.dart';
import '../controllers/test_result_controller.dart';
import '../controllers/test_result_history_controller.dart';
import '../states/reagent_testing_state.dart';
import '../states/test_execution_state.dart';
import '../states/test_result_state.dart';
import '../states/test_result_history_state.dart';

// Remote Config Service Provider
final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});

// JSON Data Service Provider (now with Remote Config)
final jsonDataServiceProvider = Provider<JsonDataService>((ref) {
  final remoteConfigService = ref.watch(remoteConfigServiceProvider);
  return JsonDataService(remoteConfigService: remoteConfigService);
});

// Repository Provider
final reagentTestingRepositoryProvider = Provider<ReagentTestingRepository>((
  ref,
) {
  final jsonDataService = ref.watch(jsonDataServiceProvider);
  return ReagentTestingRepositoryImpl(jsonDataService);
});

// Controller Provider with initialization
final reagentTestingControllerProvider =
    StateNotifierProvider<ReagentTestingController, ReagentTestingState>((ref) {
      final repository = ref.watch(reagentTestingRepositoryProvider);
      final jsonDataService = ref.watch(jsonDataServiceProvider);

      final controller = ReagentTestingController(repository);

      // Initialize Remote Config when controller is created
      _initializeRemoteConfig(ref, jsonDataService, controller);

      return controller;
    });

// Helper function to initialize Remote Config
Future<void> _initializeRemoteConfig(
  Ref ref,
  JsonDataService jsonDataService,
  ReagentTestingController controller,
) async {
  try {
    // Initialize Remote Config
    await jsonDataService.initialize();

    // Load initial data
    controller.loadAllReagents();

    // Listen for real-time updates
    jsonDataService.onDataUpdated().listen((_) {
      Logger.info('🔄 Reagent data updated from Remote Config, reloading...');
      controller.loadAllReagents();
    });

    Logger.info('✅ Remote Config initialization complete');
  } catch (e) {
    Logger.info('⚠️ Remote Config initialization failed, using local data: $e');
    // Still load local data as fallback
    controller.loadAllReagents();
  }
}

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

// Data source info provider (for debugging/info display)
final dataSourceInfoProvider = Provider<String>((ref) {
  final jsonDataService = ref.watch(jsonDataServiceProvider);
  return jsonDataService.getDataVersion();
});

// Remote Config refresh provider
final remoteConfigRefreshProvider = FutureProvider<bool>((ref) async {
  final jsonDataService = ref.watch(jsonDataServiceProvider);
  return await jsonDataService.refreshFromRemoteConfig();
});
