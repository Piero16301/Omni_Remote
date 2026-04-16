import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/bootstrap.dart';
import 'package:omni_remote/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the default options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const currentEnv = Environment.prod;

  // Setup service locator
  setupServiceLocator(currentEnv);

  // Initialize services and plugins in parallel
  final performance = getIt<PerformanceService>();
  final trace = performance.startTrace('app_initialization');
  await Future.wait([
    getIt<LocalStorageService>().initialize(),
  ]);
  performance.stopTrace(trace);

  // Bootstrap the app
  await bootstrap(() => const AppPage());
}
