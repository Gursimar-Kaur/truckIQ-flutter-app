import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:truckiq_app/widgets/info_row.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TruckInfoCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const TruckInfoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoRow(label: "Model:", value: data['model'] ?? ''),
            InfoRow(label: "Mileage:", value: data['mileage'] ?? ''),
            InfoRow(
              label: "Purchased In:",
              value: data['purchasedIn'] != null
                  ? DateFormat(
                      'yyyy-MM-dd',
                    ).format((data['purchasedIn'] as Timestamp).toDate())
                  : 'N/A',
            ),
            InfoRow(
              label: "Last Service Date:",
              value: data['latestServiceDate'] != null
                  ? DateFormat(
                      'yyyy-MM-dd',
                    ).format((data['latestServiceDate'] as Timestamp).toDate())
                  : 'N/A',
            ),
            InfoRow(
              label: "Last Oil Change Date:",
              value: data['latestOilChange'] != null
                  ? DateFormat(
                      'yyyy-MM-dd',
                    ).format((data['latestOilChange'] as Timestamp).toDate())
                  : 'N/A',
            ),
          ],
        ),
      ),
    );
  }
}
