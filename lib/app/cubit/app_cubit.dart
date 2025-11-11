import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:omni_remote/app/app.dart';
import 'package:user_repository/user_repository.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit(this.userRepository) : super(const AppState());

  final UserRepository userRepository;

  Future<void> initialLoad() async {
    // Setting the language to the device language if it's not set
    final language = userRepository.getLanguage();
    if (language == null) {
      final deviceLanguage = Platform.localeName;
      await userRepository.saveLanguage(language: deviceLanguage);
    }
    emit(state.copyWith(language: userRepository.getLanguage()));

    // Setting the theme to the device theme if it's not set
    final darkTheme = userRepository.getDarkTheme();
    if (darkTheme == null) {
      final deviceBrightness = PlatformDispatcher.instance.platformBrightness;
      await userRepository.saveDarkTheme(
        darkTheme: deviceBrightness == Brightness.dark,
      );
    }
    emit(state.copyWith(darkTheme: userRepository.getDarkTheme()));

    // Setting the base color to INDIGO if it's not set
    final baseColor = userRepository.getBaseColor();
    if (baseColor == null) {
      await userRepository.saveBaseColor(
        baseColor: AppVariables.defaultBaseColor,
      );
    }
    emit(state.copyWith(baseColor: userRepository.getBaseColor()));
  }

  Future<void> changeLanguage({required String language}) async {
    await userRepository.saveLanguage(language: language);
    emit(state.copyWith(language: language));
  }

  Future<void> changeTheme({required bool darkTheme}) async {
    await userRepository.saveDarkTheme(darkTheme: darkTheme);
    emit(state.copyWith(darkTheme: darkTheme));
  }

  Future<void> changeBaseColor({required String baseColor}) async {
    await userRepository.saveBaseColor(baseColor: baseColor);
    emit(state.copyWith(baseColor: baseColor));
  }
}
