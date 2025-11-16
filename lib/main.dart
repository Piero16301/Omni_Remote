import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/bootstrap.dart';
import 'package:user_api/user_api.dart';
import 'package:user_api_remote/user_api_remote.dart';
import 'package:user_repository/user_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive
    ..registerAdapter(GroupModelAdapter())
    ..registerAdapter(DeviceModelAdapter());

  // Initialize User API
  await UserApiRemote.init();
  final userApi = UserApiRemote();

  // Initialize User Repository
  final userRepository = UserRepository(userApi: userApi);

  await bootstrap(
    () => AppPage(
      userRepository: userRepository,
    ),
  );
}
