import 'maintenance_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Truck {
  final String id;
  final String truckNumber;
  final String model;
  final String mileage;
  final DateTime? purchasedIn;
  final DateTime? latestServiceDate;
  final DateTime? latestOilChange;

  Truck({
    required this.id,
    required this.truckNumber,
    required this.model,
    required this.mileage,
    required this.purchasedIn,
    required this.latestServiceDate,
    required this.latestOilChange,
  });

  factory Truck.fromFirestore(
    Map<String, dynamic> data,
    String id,
    List<MaintenanceHistory> maintenanceHistory,
  ) {
    return Truck(
      id: id,
      truckNumber: data['truckNumber'] ?? '',
      model: data['model'] ?? '',
      mileage: data['mileage'] ?? 'N/A',
      purchasedIn: data['purchasedIn'] != null
          ? (data['purchasedIn'] as Timestamp).toDate()
          : null,
      latestServiceDate: data['latestServiceDate'] != null
          ? (data['latestServiceDate'] as Timestamp).toDate()
          : null,
      latestOilChange: data['latestOilChange'] != null
          ? (data['latestOilChange'] as Timestamp).toDate()
          : null,
    );
  }
}
