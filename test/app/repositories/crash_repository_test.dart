import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  late FirebaseCrashlytics crashlytics;
  late CrashlyticsCrashRepository repository;

  setUp(() {
    crashlytics = MockFirebaseCrashlytics();
    repository = CrashlyticsCrashRepository(crashlytics: crashlytics);
  });

  group('CrashlyticsCrashRepository', () {
    test('log calls crashlytics.log', () async {
      const message = 'test log';

      when(() => crashlytics.log(any<String>())).thenAnswer((_) async {});

      repository.log(message);

      verify(() => crashlytics.log(message)).called(1);
    });

    test('recordError calls crashlytics.recordError', () async {
      final exception = Exception('test');
      final stack = StackTrace.current;
      const reason = 'test reason';

      when(
        () => crashlytics.recordError(
          any<dynamic>(),
          any<StackTrace?>(),
          reason: any<dynamic>(named: 'reason'),
          information: any<Iterable<Object>>(named: 'information'),
          fatal: any<bool>(named: 'fatal'),
        ),
      ).thenAnswer((_) async {});

      repository.recordError(exception, stack, reason: reason);

      verify(
        () => crashlytics.recordError(
          exception,
          stack,
          reason: reason,
          information: [],
        ),
      ).called(1);
    });

    test('setCustomKey calls crashlytics.setCustomKey', () async {
      const key = 'test_key';
      const value = 'test_value';

      when(() => crashlytics.setCustomKey(any<String>(), any<Object>()))
          .thenAnswer((_) async {});

      repository.setCustomKey(key, value);

      verify(() => crashlytics.setCustomKey(key, value)).called(1);
    });
  });
}
