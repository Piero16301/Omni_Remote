import 'package:flutter/material.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/bootstrap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_api_remote/user_api_remote.dart';
import 'package:user_repository/user_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get SharedPreferences instance
  final preferences = await SharedPreferences.getInstance();

  // Initialize User API
  final userApi = UserApiRemote(preferences: preferences);

  // Initialize User Repository
  final userRepository = UserRepository(userApi: userApi);

  await bootstrap(
    () => AppPage(
      userRepository: userRepository,
    ),
  );
}
