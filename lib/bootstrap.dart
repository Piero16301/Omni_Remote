import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:omni_remote/app/app.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    getIt<CrashService>().recordError(
      error,
      stackTrace,
      reason: 'Bloc ${bloc.runtimeType} Error',
    );
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
    getIt<CrashService>().recordError(
      details.exception,
      details.stack,
      reason: 'Flutter Error',
      fatal: true,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    log(error.toString(), stackTrace: stack);
    getIt<CrashService>().recordError(
      error,
      stack,
      reason: 'PlatformDispatcher Error',
      fatal: true,
    );
    return true;
  };

  Bloc.observer = const AppBlocObserver();

  runApp(await builder());
}
