import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Services
  getIt.registerLazySingleton<FirestoreService>(() => FirestoreService());
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  // TODO: Add other services as we implement them
  // getIt.registerLazySingleton<SharedPreferencesService>(() => SharedPreferencesService());
}
