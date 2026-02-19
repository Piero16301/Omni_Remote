import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omni_remote/l10n/l10n.dart';

void main() {
  testWidgets('AppLocalizationsX returns l10n instance', (tester) async {
    BuildContext? testContext;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            testContext = context;
            return const Placeholder();
          },
        ),
      ),
    );

    expect(testContext, isNotNull);
    final l10n = testContext!.l10n;
    expect(l10n, isA<AppLocalizations>());
  });
}
