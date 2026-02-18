import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_remote/connection/connection.dart';

class ConnectionPage extends StatelessWidget {
  const ConnectionPage({super.key});

  static const String pageName = 'connection';
  static const String pagePath = '/connection';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConnectionCubit()..loadSettings(),
      child: const ConnectionView(),
    );
  }
}
