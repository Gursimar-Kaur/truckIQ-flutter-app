import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/truck_doc_service.dart';


class TruckDocumentDisplay extends StatelessWidget {
  const TruckDocumentDisplay({
    super.key,
    required this.truckId,
  });

  final String truckId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trucks')
          .doc(truckId)
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
                        SnackBar(content: Text("Error opening file: $e")),
                      );
                    }
                  }
                },
    
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () async {
                    await DocumentService().deleteDocument(
                      truckId: truckId,
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
    );
  }
}