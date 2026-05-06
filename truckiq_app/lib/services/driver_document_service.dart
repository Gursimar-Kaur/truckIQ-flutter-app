import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentService {
  final _storage = FirebaseStorage.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> uploadDocument({
    required String driverId,
    required File file,
    required String fileName,
  }) async {
    //Create storage reference
    final ref = _storage
        .ref()
        .child('drivers/$driverId/documents/$fileName');

    // Upload file
    await ref.putFile(file);

    // Get download URL
    final url = await ref.getDownloadURL();

    // Save metadata in Firestore
    await _db
        .collection('drivers')
        .doc(driverId)
        .collection('documents')
        .add({
      'fileName': fileName,
      'url': url,
      'path': ref.fullPath, 
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteDocument({
    required String driverId,
    required String docId,
    required String path,
  }) async {
    // Delete from storage
    await _storage.ref(path).delete();

    // Delete from firestore
    await _db
        .collection('drivers')
        .doc(driverId)
        .collection('documents')
        .doc(docId)
        .delete();
  }
}