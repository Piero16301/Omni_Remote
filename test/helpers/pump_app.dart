import 'package:expressive_kit/expressive_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:omni_remote/l10n/l10n.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) {
    return pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...ExpressiveLocalizations.localizationsDelegates,
        ],
        supportedLocales: ExpressiveLanguages.supportedLocales,
        home: widget,
      ),
    );
  }
}
