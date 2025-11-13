import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/l10n/l10n.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.router;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) => MaterialApp.router(
        title: AppVariables.appName,
        routeInformationProvider: _router.routeInformationProvider,
        routerDelegate: _router.routerDelegate,
        routeInformationParser: _router.routeInformationParser,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(
          state.language.split('_').first,
          state.language.split('_').last,
        ),
        theme: AppThemes.lightTheme(baseColor: state.baseColor),
        darkTheme: AppThemes.darkTheme(baseColor: state.baseColor),
        themeAnimationCurve: Curves.easeInOut,
        themeAnimationDuration: const Duration(milliseconds: 400),
        themeMode: ThemeHelper.getThemeByName(state.theme),
      ),
    );
  }
}
