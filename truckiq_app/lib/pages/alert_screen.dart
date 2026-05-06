import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<Map<String, dynamic>?> _getHighestCostTruck(
      List<QueryDocumentSnapshot> trucks,
      DateTime now,
    ) async {
      double highestCost = 0.0;
      String? highestTruckId;
      String? highestTruckNumber;

      for (final truck in trucks) {
        final truckId = truck.id;
        final truckData = truck.data() as Map<String, dynamic>;

        final maintenanceSnap = await FirebaseFirestore.instance
            .collection('trucks')
            .doc(truckId)
            .collection('maintenanceHistory')
            .get();

        double truckTotal = 0.0;

        for (final doc in maintenanceSnap.docs) {
          final data = doc.data();
          final rawDate = data['maintenanceDate'];
          final rawCost = data['cost'];

          if (rawDate != null && rawCost != null) {
            final date = (rawDate as Timestamp).toDate();
            if (date.year == now.year && date.month == now.month) {
              truckTotal += (rawCost as num).toDouble();
            }
          }
        }

        if (truckTotal > highestCost) {
          highestCost = truckTotal;
          highestTruckId = truckId;
          highestTruckNumber = truckData['truckNumber'];
        }
      }

      if (highestTruckId == null) return null;

      return {
        'truckId': highestTruckId,
        'truckNumber': highestTruckNumber,
        'cost': highestCost,
      };
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('trucks').snapshots(),
      builder: (context, trucksSnapshot) {
        if (!trucksSnapshot.hasData) return const SizedBox.shrink();

        final trucks = trucksSnapshot.data!.docs;
        final now = DateTime.now();
        final List<Color> alertColors = [
          Colors.green.shade100,
          Colors.yellow.shade100,
          Colors.blue.shade100,
          Colors.orange.shade100,
          Colors.purple.shade100,
        ];
        return FutureBuilder<Map<String, dynamic>?>(
          future: _getHighestCostTruck(trucks, now),
          builder: (context, futureSnapshot) {
            if (!futureSnapshot.hasData || futureSnapshot.data == null) {
              return const SizedBox.shrink();
            }

            final highest = futureSnapshot.data!;
            final truckName = highest['truckNumber'];
            final cost = highest['cost'] as double;

            return Scaffold(
              appBar: AppBar(title: const Text('Alerts')),
              body: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: alertColors[Random().nextInt(alertColors.length)],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('💰', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Truck $truckName cost \$${cost.toStringAsFixed(2)} this month - highest in fleet.',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            // handle dismiss
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
