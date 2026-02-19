import 'package:flutter_test/flutter_test.dart';
import 'package:omni_remote/app/app.dart';

void main() {
  group('AppRouter', () {
    test('Router instance returns proper GoRouter instance', () {
      final router = AppRouter.router;
      expect(router, isNotNull);
      // Ensures the route configurations are generated.
      expect(router.configuration.routes.isNotEmpty, isTrue);
    });
  });
}
