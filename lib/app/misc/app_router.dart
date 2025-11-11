import 'package:go_router/go_router.dart';
import 'package:omni_remote/home/home.dart';

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
    ],
  );
}
