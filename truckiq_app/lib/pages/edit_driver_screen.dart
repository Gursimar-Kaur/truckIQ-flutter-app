import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver.dart';
import '../widgets/build_text_field.dart';

class EditDriverScreen extends StatefulWidget {
  final Driver? driver; // null = add, not null = edit

  const EditDriverScreen({super.key, this.driver});

  @override
  State<EditDriverScreen> createState() => _EditDriverScreenState();
}

class _EditDriverScreenState extends State<EditDriverScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController licenseController;
  late TextEditingController truckController;
  late TextEditingController ticketsController;
  late TextEditingController incidentsController;

  DateTime? hiredOn;

  bool get isEdit => widget.driver != null;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.driver?.name ?? '');
    licenseController = TextEditingController(
      text: widget.driver?.licenseNumber ?? '',
    );
    truckController = TextEditingController(
      text: widget.driver?.assignedTruck ?? '',
    );
    ticketsController = TextEditingController(
      text: widget.driver?.tickets.toString() ?? '0',
    );
    incidentsController = TextEditingController(
      text: widget.driver?.incidents.toString() ?? '0',
    );

    hiredOn = widget.driver?.hiredOn;
  }

  Future<void> saveDriver() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': nameController.text,
      'licenseNumber': licenseController.text,
      'assignedTruck': truckController.text,
      'tickets': int.tryParse(ticketsController.text) ?? 0,
      'incidents': int.tryParse(incidentsController.text) ?? 0,
      'hiredOn': hiredOn ?? DateTime.now(),
    };

    final db = FirebaseFirestore.instance;

    if (isEdit) {
      await db.collection('drivers').doc(widget.driver!.id).update(data);
    } else {
      await db.collection('drivers').add(data);
    }

    Navigator.pop(context, true);
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: hiredOn ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => hiredOn = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit Driver" : "Add Driver")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              BuildTextField(label: "Name", controller: nameController),
              BuildTextField(label: "License Number", controller: licenseController),
              BuildTextField(label: "Assigned Truck", controller: truckController),
              BuildTextField(label: "Tickets", controller: ticketsController, isNumber: true),
              BuildTextField(label:"Incidents", controller: incidentsController, isNumber: true),

              const SizedBox(height: 10),

              ListTile(
                title: Text(
                  hiredOn == null
                      ? "Select Hire Date"
                      : "Hired On: ${hiredOn!.toLocal().toString().split(' ')[0]}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: pickDate,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: saveDriver,
                child: Text(isEdit ? "Update Driver" : "Add Driver"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
