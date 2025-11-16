import 'package:go_router/go_router.dart';
import 'package:omni_remote/home/home.dart';
import 'package:omni_remote/modify_group/modify_group.dart';
import 'package:user_api/user_api.dart';

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
      ),
      GoRoute(
        name: ModifyGroupPage.pageName,
        path: ModifyGroupPage.pagePath,
        builder: (context, state) {
          final group = state.extra as GroupModel?;
          return ModifyGroupPage(group: group);
        },
      ),
    ],
  );
}
