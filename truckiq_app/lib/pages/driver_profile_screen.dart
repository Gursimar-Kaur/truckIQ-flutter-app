import 'package:flutter/material.dart';
import '../models/driver.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:truckiq_app/widgets/driver_ui.dart';

class DriverProfileScreen extends StatelessWidget {
  final String driverId;

  const DriverProfileScreen({super.key, required this.driverId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Driver Profile"),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    'edit-driver',
                    arguments: Driver(
                      id: driverId,
                      name: data['name'],
                      licenseNumber: data['licenseNumber'],
                      tickets: data['tickets'],
                      incidents: data['incidents'],
                      onShift: data['onShift'] ?? false,
                      assignedTruck: data['assignedTruck'] ?? '',
                      hiredOn: data['hiredOn']?.toDate(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: DriverUi(data: data, driverId: driverId),
        );
      },
    );
  }
}
