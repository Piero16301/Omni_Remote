import 'package:go_router/go_router.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/connection/connection.dart';
import 'package:omni_remote/home/home.dart';
import 'package:omni_remote/modify_device/modify_device.dart';
import 'package:omni_remote/modify_group/modify_group.dart';
import 'package:omni_remote/settings/settings.dart';

class AppRouter {
  static final router = GoRouter(
    redirect: (context, state) {
      // Add any redirection logic here if needed
      return null;
    },
    routes: [
      GoRoute(
        name: HomePage.pageName,
        path: HomePage.pagePath,
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            name: ConnectionPage.pageName,
            path: ConnectionPage.pagePath,
            builder: (context, state) => const ConnectionPage(),
          ),
          GoRoute(
            name: SettingsPage.pageName,
            path: SettingsPage.pagePath,
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            name: ModifyGroupPage.pageName,
            path: ModifyGroupPage.pagePath,
            builder: (context, state) {
              final group = state.extra as GroupModel?;
              return ModifyGroupPage(group: group);
            },
          ),
          GoRoute(
            name: ModifyDevicePage.pageName,
            path: ModifyDevicePage.pagePath,
            builder: (context, state) {
              final device = state.extra as DeviceModel?;
              return ModifyDevicePage(device: device);
            },
          ),
        ],
      ),
    ],
  );
}
