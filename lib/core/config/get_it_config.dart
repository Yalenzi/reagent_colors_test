import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/gemini_image_analysis_service.dart';
import 'api_keys.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Services
  getIt.registerLazySingleton<FirestoreService>(() => FirestoreService());
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  // AI Services - Gemini API
  if (ApiKeys.hasGeminiApiKey) {
    getIt.registerLazySingleton<GeminiImageAnalysisService>(
      () => GeminiImageAnalysisService(apiKey: ApiKeys.geminiApiKey),
    );
  }

  // TODO: Add other services as we implement them
  // getIt.registerLazySingleton<SharedPreferencesService>(() => SharedPreferencesService());
}
