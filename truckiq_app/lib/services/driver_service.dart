import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver.dart';

class DriverService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Driver>> getDrivers() {
    return _db.collection('drivers').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Driver.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> toggleOnShift(String driverId, bool newValue) async {
    await FirebaseFirestore.instance.collection('drivers').doc(driverId).update(
      {'onShift': newValue},
    );
  }

  Future<void> deleteDriver(String id) async {
    await FirebaseFirestore.instance.collection('drivers').doc(id).delete();
  }
}
