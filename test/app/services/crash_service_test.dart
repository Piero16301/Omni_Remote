import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';

class MockCrashRepository extends Mock implements CrashRepository {}

void main() {
  late CrashRepository repository;
  late CrashService service;

  setUp(() {
    repository = MockCrashRepository();
    service = CrashService(crashRepository: repository);
  });

  group('CrashService', () {
    test('recordError calls repository.recordError', () {
      final exception = Exception('test');
      final stack = StackTrace.current;
      const reason = 'test reason';

      service.recordError(exception, stack, reason: reason);

      verify(
        () => repository.recordError(
          exception,
          stack,
          reason: reason,
          information: [],
          fatal: false,
        ),
      ).called(1);
    });

    test('log calls repository.log', () {
      const message = 'test log';

      service.log(message);

      verify(() => repository.log(message)).called(1);
    });

    test('setCustomKey calls repository.setCustomKey', () {
      const key = 'test_key';
      const value = 'test_value';

      service.setCustomKey(key, value);

      verify(() => repository.setCustomKey(key, value)).called(1);
    });
  });
}
