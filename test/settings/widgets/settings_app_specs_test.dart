import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:omni_remote/settings/settings.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  group('SettingsAppSpecs', () {
    setUp(() {
      PackageInfo.setMockInitialValues(
        appName: 'Omni Remote',
        packageName: 'com.omni.remote',
        version: '1.2.3',
        buildNumber: '4',
        buildSignature: 'buildSignature',
      );
    });

    testWidgets('renders App specs correctly after loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SettingsAppSpecs(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
      expect(
        find.text('Version'),
        findsOneWidget,
      );
      expect(find.text('1.2.3 (4)'), findsOneWidget);
    });
  });
}
