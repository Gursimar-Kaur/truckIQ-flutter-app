import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:truckiq_app/pages/add_maintenance_screen.dart';
import 'package:truckiq_app/widgets/highlight_banner.dart';
import 'package:truckiq_app/widgets/maintenance_card.dart';
import 'package:truckiq_app/widgets/truck_doc_display.dart';
import 'package:truckiq_app/widgets/truck_info_card.dart';
import 'dart:io';
import '../services/truck_doc_service.dart';
import 'package:truckiq_app/models/truck.dart';

class TruckDetailScreen extends StatelessWidget {
  final String truckId;

  const TruckDetailScreen({super.key, required this.truckId});

  Future<void> pickAndUploadFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;

    final service = DocumentService();
    await service.uploadDocument(
      truckId: truckId,
      file: file,
      fileName: fileName,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Uploaded")));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trucks')
          .doc(truckId)
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
            title: const Text("Truck Details"),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    'edit-truck',
                    arguments: Truck(
                      // pass the whole object
                      id: truckId,
                      truckNumber: data['truckNumber'],
                      mileage: data['mileage'],
                      model: data['model'],
                      purchasedIn: data['purchasedIn'] != null
                          ? (data['purchasedIn'] as Timestamp).toDate()
                          : null,

                      latestServiceDate: data['lastServiceDate'] != null
                          ? (data['lastServiceDate'] as Timestamp).toDate()
                          : null,

                      latestOilChange: data['latestOilChange'] != null
                          ? (data['latestOilChange'] as Timestamp).toDate()
                          : null,
                    ),
                  );
                },
              ),
            ],
          ),
          body: _buildBody(context, data),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, Map<String, dynamic> data) {
    String predictedNextService = 'N/A';
    if (data['latestServiceDate'] != null) {
      final DateTime lastService = (data['latestServiceDate'] as Timestamp)
          .toDate();
      final DateTime nextService = DateTime(
        lastService.year,
        lastService.month + 6,
        lastService.day,
      );
      predictedNextService = DateFormat('yyyy-MM-dd').format(nextService);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.local_shipping, size: 40),
                ),
                const SizedBox(height: 10),
                Text(
                  data['truckNumber'] ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          TruckInfoCard(data: data),

          const SizedBox(height: 12),

          // Predicted next service date
          HighlightBanner(
            label: "Predicted next service date:",
            value: predictedNextService,
            color: const Color.fromARGB(255, 25, 101, 27),
          ),

          const SizedBox(height: 8),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('trucks')
                .doc(truckId)
                .collection('maintenanceHistory')
                .snapshots(),
            builder: (context, snapshot) {
              String totalThisMonthStr = '\$0.00';

              if (snapshot.hasData) {
                final now = DateTime.now();
                double totalThisMonth = 0.0;

                for (final doc in snapshot.data!.docs) {
                  final docData = doc.data() as Map<String, dynamic>;

                  final rawDate = docData['maintenanceDate'];
                  final rawCost = docData['cost'];

                  if (rawDate != null && rawCost != null) {
                    final date = (rawDate as Timestamp).toDate();
                    if (date.year == now.year && date.month == now.month) {
                      totalThisMonth += (rawCost as num).toDouble();
                    }
                  }
                }

                totalThisMonthStr = '\$${totalThisMonth.toStringAsFixed(2)}';
              }

              return HighlightBanner(
                label: "Total maintenance this month:",
                value: totalThisMonthStr,
                color: const Color.fromARGB(255, 122, 23, 23),
              );
            },
          ),

          const SizedBox(height: 20),

          // Maintenance History header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Maintenance History:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddMaintenanceScreen(truckId: truckId),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Add maintenance"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Scrollable maintenance history section
          MaintenanceCard(truckId: truckId),

          const SizedBox(height: 8),

          // Documents section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Documents",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => pickAndUploadFile(context),
              ),
            ],
          ),

          TruckDocumentDisplay(truckId: truckId),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
