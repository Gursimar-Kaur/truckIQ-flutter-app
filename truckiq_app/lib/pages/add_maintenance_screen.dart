import 'package:flutter/material.dart';
import 'package:truckiq_app/widgets/build_text_field.dart';
import '../models/maintenance_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMaintenanceScreen extends StatefulWidget {
  final MaintenanceHistory? maintenanceHistory;
  final String truckId;

  const AddMaintenanceScreen({
    super.key,
    this.maintenanceHistory,
    required this.truckId,
  });

  @override
  State<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends State<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController typeController;
  late TextEditingController costController;
  DateTime? maintenanceDate;

  @override
  void initState() {
    super.initState();

    typeController = TextEditingController(
      text: widget.maintenanceHistory?.type ?? '',
    );
    costController = TextEditingController(
      text: widget.maintenanceHistory?.cost.toString() ?? '0',
    );
    maintenanceDate = widget.maintenanceHistory?.maintenanceDate;
  }

  Future<void> saveMaintenance() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'type': typeController.text,
      'cost': int.tryParse(costController.text),
      'maintenanceDate': maintenanceDate ?? DateTime.now(),
    };

    final db = FirebaseFirestore.instance;

    await db
        .collection('trucks')
        .doc(widget.truckId)
        .collection('maintenanceHistory')
        .add(data);

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
      appBar: AppBar(title: Text("Add Maintenance")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              BuildTextField(label: "Type", controller:  typeController),
              BuildTextField(label: "Cost", controller:  costController, isNumber: true),

              const SizedBox(height: 10),

              ListTile(
                title: Text(
                  maintenanceDate == null
                      ? "Select Maintenance Date"
                      : "Purchased In: ${maintenanceDate!.toLocal().toString().split(' ')[0]}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => pickDate(
                  currentDate: maintenanceDate,
                  onDateSelected: (date) => maintenanceDate = date,
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: saveMaintenance,
                child: Text("Add Maintenance"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
