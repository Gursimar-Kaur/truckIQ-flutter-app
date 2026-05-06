import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  String id;
  String name;
  String licenseNumber;
  int tickets;
  int incidents;
  bool onShift;
  DateTime? hiredOn;
  String assignedTruck;

  Driver({
    required this.id,
    required this.name,
    required this.licenseNumber,
    required this.tickets,
    required this.incidents,
    required this.onShift,
    required this.hiredOn,
    required this.assignedTruck,
  });

  factory Driver.fromFirestore(Map<String, dynamic> data, String id) {
    return Driver(
      id: id,
      name: data['name'] ?? '',
      licenseNumber: data['licenseNumber'] ?? '',
      tickets: data['tickets'] ?? 0,
      incidents: data['incidents'] ?? 0,
      onShift: data['onShift'] ?? false,
      hiredOn: data['hiredOn'] != null
          ? (data['hiredOn'] as Timestamp).toDate()
          : null,
      assignedTruck: data['assignedTruck'] ?? '',
    );
  }
}
