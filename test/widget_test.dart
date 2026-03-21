import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennywise/theme/app_theme.dart';

void main() {
  testWidgets('theme smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: Center(child: Text('PennyWise'))),
      ),
    );

    expect(find.text('PennyWise'), findsOneWidget);
  });
}
