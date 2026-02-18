import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_remote/app/app.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppCubit>(
          create: (_) => AppCubit()
            ..initialize()
            // Initialize app and mqtt client
            // ignore: discarded_futures
            ..initializeMqttClient(),
        ),
      ],
      child: const AppView(),
    );
  }
}
