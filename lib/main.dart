import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
