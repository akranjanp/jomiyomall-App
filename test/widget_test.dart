import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jomiyo_mall/core/widgets/app_button.dart';

void main() {
  testWidgets('AppButton renders text and triggers callback', (WidgetTester tester) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            text: 'TEST BUTTON',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('TEST BUTTON'), findsOneWidget);
    await tester.tap(find.text('TEST BUTTON'));
    expect(pressed, isTrue);
  });
}
