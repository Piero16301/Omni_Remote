import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_remote/app/app.dart';
import 'package:user_repository/user_repository.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    required UserRepository userRepository,
    super.key,
  }) : _userRepository = userRepository;

  final UserRepository _userRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>.value(value: _userRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AppCubit>(
            create: (_) {
              final cubit = AppCubit(_userRepository);
              unawaited(cubit.initialLoad());
              return cubit;
            },
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}
