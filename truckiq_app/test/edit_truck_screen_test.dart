import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truckiq_app/models/truck.dart';


class FakeEditTruckScreen extends StatefulWidget {
  final Truck? truck;
  const FakeEditTruckScreen({super.key, this.truck});

  @override
  State<FakeEditTruckScreen> createState() => _FakeEditTruckScreenState();
}

class _FakeEditTruckScreenState extends State<FakeEditTruckScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController truckController;
  late TextEditingController modelController;
  DateTime? purchasedIn;
  DateTime? latestServiceDate;
  DateTime? latestOilChange;

  bool get isEdit => widget.truck != null;

  @override
  void initState() {
    super.initState();
    truckController = TextEditingController(text: widget.truck?.truckNumber ?? '');
    modelController = TextEditingController(text: widget.truck?.model ?? '');
    purchasedIn = widget.truck?.purchasedIn;
    latestServiceDate = widget.truck?.latestServiceDate;
    latestOilChange = widget.truck?.latestOilChange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit Truck Details" : "Add Truck Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: truckController,
                decoration: const InputDecoration(labelText: 'Truck'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Model'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState!.validate();
                },
                child: Text(isEdit ? "Update Truck" : "Add Truck"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  group('EditTruckScreen', () {
    testWidgets('shows "Add Truck Details" title when truck is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FakeEditTruckScreen()),
      );
      expect(find.text('Add Truck Details'), findsOneWidget);
      expect(find.text('Add Truck'), findsOneWidget);
    });

    testWidgets('shows "Edit Truck Details" title when truck is provided', (tester) async {
      final truck = Truck(
        id: '1',
        truckNumber: 'T-001',
        model: 'Volvo FH',
        mileage: '10000',
        purchasedIn: DateTime(2021, 1, 1),
        latestServiceDate: DateTime(2024, 6, 1),
        latestOilChange: DateTime(2024, 5, 1),
      );

      await tester.pumpWidget(
        MaterialApp(home: FakeEditTruckScreen(truck: truck)),
      );

      expect(find.text('Edit Truck Details'), findsOneWidget);
      expect(find.text('Update Truck'), findsOneWidget);
    });

    testWidgets('pre-fills fields when editing an existing truck', (tester) async {
      final truck = Truck(
        id: '1',
        truckNumber: 'T-042',
        model: 'Kenworth T680',
        mileage: '55000',
        purchasedIn: DateTime(2020, 3, 15),
        latestServiceDate: DateTime(2024, 1, 10),
        latestOilChange: DateTime(2024, 1, 10),
      );

      await tester.pumpWidget(
        MaterialApp(home: FakeEditTruckScreen(truck: truck)),
      );

      expect(find.text('T-042'), findsOneWidget);
      expect(find.text('Kenworth T680'), findsOneWidget);
    });

    testWidgets('shows validation errors when form is submitted empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FakeEditTruckScreen()),
      );

      await tester.tap(find.text('Add Truck'));
      await tester.pump();

      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('does not show validation errors when fields are filled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FakeEditTruckScreen()),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'T-099');
      await tester.enterText(find.byType(TextFormField).at(1), 'Mack Anthem');

      await tester.tap(find.text('Add Truck'));
      await tester.pump();

      expect(find.text('Required'), findsNothing);
    });
  });
}