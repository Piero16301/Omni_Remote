import 'package:flutter/material.dart';
import 'package:omni_remote/settings/settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const String pageName = 'settings';
  static const String pagePath = '/settings';

  @override
  Widget build(BuildContext context) {
    return const SettingsView();
  }
}
