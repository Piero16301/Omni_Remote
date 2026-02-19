import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:omni_remote/app/app.dart';

void main() {
  group('AppDependencies', () {
    setUp(() {
      unawaited(getIt.reset());
    });

    test('setupServiceLocator registers LocalStorageService and MqttService',
        () {
      setupServiceLocator();
      expect(getIt.isRegistered<LocalStorageService>(), isTrue);
      expect(getIt.isRegistered<MqttService>(), isTrue);
    });
  });
}
