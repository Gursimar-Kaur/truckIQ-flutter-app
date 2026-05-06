// import framework
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// import code to test
import 'package:truckiq_app/widgets/dashboard_card.dart';

void main() {
  group('DashboardCard Widget tests', () {
    late Widget app;

    setUp(() {
      app = const MaterialApp(
        home: Scaffold(
          body: DashboardCard(title: 'Trucks', value: '10'),
        ),
      );
    });

    testWidgets('DashboardCard should display title and value on load', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(app);

      // Act
      final title = find.text('Trucks');
      final value = find.text('10');
      final card = find.byType(DashboardCard);

      // Assert
      expect(title, findsOneWidget);
      expect(value, findsOneWidget);
      expect(card, findsOneWidget);
    });
  });
}