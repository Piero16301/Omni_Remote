import 'package:go_router/go_router.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/connection/connection.dart';
import 'package:omni_remote/home/home.dart';
import 'package:omni_remote/modify_device/modify_device.dart';
import 'package:omni_remote/modify_group/modify_group.dart';
import 'package:omni_remote/settings/settings.dart';

class AppRouter {
  static GoRouter getRouter() {
    return GoRouter(
      observers: [
        AppRouteObserver(analyticsService: getIt<AnalyticsService>()),
      ],
      routes: [
        GoRoute(
          name: AppRoute.home.name,
          path: AppRoute.home.path,
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              name: AppRoute.connection.name,
              path: AppRoute.connection.path,
              builder: (context, state) => const ConnectionPage(),
            ),
            GoRoute(
              name: AppRoute.settings.name,
              path: AppRoute.settings.path,
              builder: (context, state) => const SettingsPage(),
            ),
            GoRoute(
              name: AppRoute.modifyGroup.name,
              path: AppRoute.modifyGroup.path,
              builder: (context, state) {
                final group = state.extra as GroupModel?;
                return ModifyGroupPage(group: group);
              },
            ),
            GoRoute(
              name: AppRoute.modifyDevice.name,
              path: AppRoute.modifyDevice.path,
              builder: (context, state) {
                final device = state.extra as DeviceModel?;
                return ModifyDevicePage(device: device);
              },
            ),
          ],
        ),
      ],
      debugLogDiagnostics: true,
    );
  }
}

enum AppRoute {
  home('/', 'home'),
  connection('/connection', 'connection'),
  settings('/settings', 'settings'),
  modifyGroup('/modify-group', 'modify-group'),
  modifyDevice('/modify-device', 'modify-device');

  const AppRoute(this.path, this.name);
  final String path;
  final String name;
}
