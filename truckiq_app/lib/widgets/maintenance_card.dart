import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MaintenanceCard extends StatelessWidget {
  const MaintenanceCard({
    super.key,
    required this.truckId,
  });

  final String truckId;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('trucks')
              .doc(truckId)
              .collection('maintenanceHistory')
              .orderBy('maintenanceDate', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final records = snapshot.data!.docs;
    
            if (records.isEmpty) {
              return const Center(child: Text("No maintenance records."));
            }
    
            return ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: records.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final m = records[index].data() as Map<String, dynamic>;
                final Timestamp? dateTs = m['maintenanceDate'];
                final String dateStr = dateTs != null
                    ? DateFormat('dd-MM-yyyy').format(dateTs.toDate())
                    : 'N/A';
                final double cost = (m['cost'] ?? 0).toDouble();
    
                return ListTile(
                  dense: true,
                  title: Text(
                    m['type'] ?? 'Maintenance',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Date: $dateStr",
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            "Cost: \$${cost.toStringAsFixed(0)}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Delete Record"),
                              content: const Text(
                                "Are you sure you want to delete this maintenance record?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(ctx).pop(false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(ctx).pop(true),
                                  child: const Text("Delete"),
                                ),
                              ],
                            ),
                          );
    
                          if (confirm == true) {
                            await FirebaseFirestore.instance
                                .collection('trucks')
                                .doc(truckId)
                                .collection('maintenanceHistory')
                                .doc(records[index].id)
                                .delete();
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

