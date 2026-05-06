import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/build_info_card.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/driver_document_service.dart';

class DriverUi extends StatelessWidget {
  final Map<String, dynamic> data;
  final String driverId;
  Future<void> pickAndUploadFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null) return;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;

    final service = DocumentService();

    await service.uploadDocument(
      driverId: driverId,
      file: file,
      fileName: fileName,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Uploaded")));
  }

  const DriverUi({super.key, required this.data, required this.driverId});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            BuildInfoCard(
              title: "Hired On",
              value: data['hiredOn'] != null
                  ? DateFormat(
                      'yyyy-MM-dd',
                    ).format((data['hiredOn'] as Timestamp).toDate())
                  : 'N/A',
            ),
            BuildInfoCard(
              title: "Assigned Truck",
              value: data['assignedTruck'] ?? '',
            ),
            BuildInfoCard(
              title: "License Number",
              value: data['licenseNumber'] ?? '',
            ),
            BuildInfoCard(
              title: "Tickets",
              value: (data['tickets'] ?? 0).toString(),
            ),
            BuildInfoCard(
              title: "Incidents",
              value: (data['incidents'] ?? 0).toString(),
            ),

            const SizedBox(height: 20),
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

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('drivers')
                  .doc(driverId)
                  .collection('documents')
                  .orderBy('uploadedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Text("No documents");
                }

                return Column(
                  children: docs.map((doc) {
                    final d = doc.data() as Map<String, dynamic>;

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(d['fileName'] ?? ''),

                        onTap: () async {
                          final url = d['url'];

                          if (url != null) {
                            final uri = Uri.parse(url);

                            try {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error opening file: $e"),
                                ),
                              );
                            }
                          }
                        },

                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            await DocumentService().deleteDocument(
                              driverId: driverId,
                              docId: doc.id,
                              path: d['path'],
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
