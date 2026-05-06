import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<int> getDriverCount() {
    return _db
        .collection('drivers')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getTruckCount() {
    return _db
        .collection('trucks')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
