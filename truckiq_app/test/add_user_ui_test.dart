import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truckiq_app/pages/edit_driver_screen.dart';

void main() {

  testWidgets('Shows Required error when fields are empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EditDriverScreen()));

    final formFinder = find.byType(Form);
    final FormState formState = tester.state(formFinder);
    formState.validate();

    await tester.pump();

    expect(find.text("Required"), findsWidgets);
  });

  testWidgets('Shows error when tickets or incidents are negative', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EditDriverScreen()));

    await tester.enterText(find.byType(TextFormField).at(0), 'John');
    await tester.enterText(find.byType(TextFormField).at(1), 'ABC123');
    await tester.enterText(find.byType(TextFormField).at(2), 'Truck 1');
    await tester.enterText(find.byType(TextFormField).at(3), '-1');
    await tester.enterText(find.byType(TextFormField).at(4), '-5');

    final formState = tester.state<FormState>(find.byType(Form));
    formState.validate();
    await tester.pump();

    expect(find.text("Cannot be negative"), findsWidgets);
  });
}
