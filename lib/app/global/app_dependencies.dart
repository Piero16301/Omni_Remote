import 'package:get_it/get_it.dart';
import 'package:omni_remote/app/app.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<LocalStorageService>(LocalStorageService.new);
}
