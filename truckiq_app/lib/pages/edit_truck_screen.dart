import 'package:flutter/material.dart';
import 'package:truckiq_app/widgets/build_text_field.dart';
import '../models/truck.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTruckScreen extends StatefulWidget {
  final Truck? truck; // null = add, not null = edit

  const EditTruckScreen({super.key, this.truck});

  @override
  State<EditTruckScreen> createState() => _EditTruckScreenState();
}

class _EditTruckScreenState extends State<EditTruckScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController truckController;
  late TextEditingController modelController;
  late TextEditingController mileageController;
  DateTime? latestServiceDate;
  DateTime? latestOilChange;
  DateTime? purchasedIn;

  bool get isEdit => widget.truck != null;

  @override
  void initState() {
    super.initState();

    truckController = TextEditingController(
      text: widget.truck?.truckNumber ?? '',
    );
    modelController = TextEditingController(text: widget.truck?.model ?? '');
    mileageController = TextEditingController(
      text: widget.truck?.mileage,
    );

    purchasedIn = widget.truck?.purchasedIn;
    latestServiceDate = widget.truck?.latestServiceDate;
    latestOilChange = widget.truck?.latestOilChange;
  }

  Future<void> saveTruck() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'truckNumber': truckController.text,
      'model': modelController.text,
      'purchasedIn': purchasedIn ?? DateTime.now(),
      'latestServiceDate': latestServiceDate ?? DateTime.now(),
      'latestOilChange': latestOilChange ?? DateTime.now(),
    };

    final db = FirebaseFirestore.instance;

    if (isEdit) {
      await db.collection('trucks').doc(widget.truck!.id).update(data);
    } else {
      await db.collection('trucks').add(data);
    }

    Navigator.pop(context, true);
  }

  Future<void> pickDate({
    required DateTime? currentDate,
    required Function(DateTime) onDateSelected,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        onDateSelected(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Truck Details" : "Add Truck Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              BuildTextField(label: "Truck", controller: truckController),
              BuildTextField(label: "Model", controller: modelController),
              BuildTextField(label: "Mileage", controller: mileageController),

              const SizedBox(height: 10),

              ListTile(
                title: Text(
                  purchasedIn == null
                      ? "Select Truck Purchase Date"
                      : "Purchased In: ${purchasedIn!.toLocal().toString().split(' ')[0]}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => pickDate(
                  currentDate: purchasedIn,
                  onDateSelected: (date) => purchasedIn = date,
                ),
              ),

              const SizedBox(height: 10),

              ListTile(
                title: Text(
                  latestServiceDate == null
                      ? "Select Last Service Date"
                      : "Last Service Date: ${latestServiceDate!.toLocal().toString().split(' ')[0]}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => pickDate(
                  currentDate: latestServiceDate,
                  onDateSelected: (date) => latestServiceDate = date,
                ),
              ),
              const SizedBox(height: 10),

              ListTile(
                title: Text(
                  latestOilChange == null
                      ? "Select Last Oil Change Date"
                      : "Last Oil Change: ${latestOilChange!.toLocal().toString().split(' ')[0]}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => pickDate(
                  currentDate: latestOilChange,
                  onDateSelected: (date) => latestOilChange = date,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: saveTruck,
                child: Text(isEdit ? "Update Truck" : "Add Truck"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
