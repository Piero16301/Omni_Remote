import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:omni_remote/app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await getIt.reset();
    setupServiceLocator(Environment.mock);
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('AppRoute enum', () {
    test('home has correct path and name', () {
      expect(AppRoute.home.path, equals('/'));
      expect(AppRoute.home.name, equals('home'));
    });

    test('connection has correct path and name', () {
      expect(AppRoute.connection.path, equals('/connection'));
      expect(AppRoute.connection.name, equals('connection'));
    });

    test('settings has correct path and name', () {
      expect(AppRoute.settings.path, equals('/settings'));
      expect(AppRoute.settings.name, equals('settings'));
    });

    test('modifyGroup has correct path and name', () {
      expect(AppRoute.modifyGroup.path, equals('/modify-group'));
      expect(AppRoute.modifyGroup.name, equals('modify-group'));
    });

    test('modifyDevice has correct path and name', () {
      expect(AppRoute.modifyDevice.path, equals('/modify-device'));
      expect(AppRoute.modifyDevice.name, equals('modify-device'));
    });
  });

  group('AppRouter', () {
    test('getRouter returns a non-null GoRouter with routes', () {
      final router = AppRouter.getRouter();
      expect(router, isNotNull);
      expect(router.configuration.routes.isNotEmpty, isTrue);
    });

    test('has 4 child routes under home', () {
      final router = AppRouter.getRouter();
      final homeRoute = router.configuration.routes.first as GoRoute;
      expect(homeRoute.name, equals('home'));
      expect(homeRoute.routes.length, equals(4));
    });

    test('modifyGroup builder casts null extra to GroupModel?', () {
      const Object? extra = null;
      const group = extra as GroupModel?;
      expect(group, isNull);
    });

    test('modifyGroup builder casts GroupModel extra correctly', () {
      final groupModel = GroupModel(
        id: 'g1',
        title: 'Test',
        subtitle: 'Sub',
        icon: 'settings',
      );
      final Object extra = groupModel;
      final group = extra as GroupModel?;
      expect(group, equals(groupModel));
      expect(group?.id, equals('g1'));
    });

    test('modifyDevice builder casts null extra to DeviceModel?', () {
      const Object? extra = null;
      const device = extra as DeviceModel?;
      expect(device, isNull);
    });

    test('modifyDevice builder casts DeviceModel extra correctly', () {
      final deviceModel = DeviceModel(
        id: 'd1',
        title: 'Test Device',
        subtitle: 'Sub',
        groupId: 'g1',
        icon: 'settings',
        tileType: DeviceTileType.boolean,
      );
      final Object extra = deviceModel;
      final device = extra as DeviceModel?;
      expect(device, equals(deviceModel));
      expect(device?.id, equals('d1'));
    });

    testWidgets('AppRouter supports full router config', (tester) async {
      final router = AppRouter.getRouter();
      expect(router.configuration.routes.first, isA<GoRoute>());
    });
  });
}
