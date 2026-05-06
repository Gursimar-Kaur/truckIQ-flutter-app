import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceHistory {
  final String id;
  final String type;
  final int cost;
  final DateTime? maintenanceDate;

  MaintenanceHistory({
    required this.id,
    required this.type,
    required this.cost,
    required this.maintenanceDate,
  });

  factory MaintenanceHistory.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return MaintenanceHistory(
      id: id,
      type: data['type'],
      cost: data['cost'] ?? 0,
      maintenanceDate: data['maintenanceDate'] != null
          ? (data['maintenanceDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'cost': cost,
      'maintenanceDate': maintenanceDate != null
          ? Timestamp.fromDate(maintenanceDate!)
          : null,
    };
  }
}
