import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:truckiq_app/models/truck.dart';
import 'package:truckiq_app/models/maintenance_history.dart';

class TruckService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Truck>> getTrucks() {
    return _db.collection('trucks').snapshots().asyncMap((snapshot) async {
      final trucks = await Future.wait(
        snapshot.docs.map((doc) async {
          final historySnapshot = await _db
              .collection('trucks')
              .doc(doc.id)
              .collection('maintenanceHistory')
              .get();

          final history = historySnapshot.docs.map((h) {
            return MaintenanceHistory.fromFirestore(h.data(), h.id);
          }).toList();
          return Truck.fromFirestore(doc.data(), doc.id, history);
        }),
      );

      return trucks;
    });
  }

  Future<void> deleteTruck(String id) async {
    await FirebaseFirestore.instance.collection('trucks').doc(id).delete();
  }
}
