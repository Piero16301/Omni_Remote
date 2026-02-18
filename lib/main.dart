import 'package:flutter/material.dart';

import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupServiceLocator();

  await getIt<LocalStorageService>().initialize();

  await bootstrap(() => const AppPage());
}
