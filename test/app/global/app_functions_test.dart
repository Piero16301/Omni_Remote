import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omni_remote/app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('AppFunctions.showSnackBar displays correct snackbar',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AppFunctions.showSnackBar(
                    context,
                    message: 'Test message',
                    type: SnackBarType.success,
                  );
                },
                child: const Text('Show'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Test message'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, Colors.green);
  });
}
