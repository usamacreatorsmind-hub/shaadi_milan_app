import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 🔥 PRIMARY IMAGE UPLOAD
  Future<String> uploadPrimaryImage({
    required String uid,
    required String filePath,
    void Function(double)? onProgress,
  }) async {
    final file = File(filePath);

    final ref = _storage.ref().child('profile_images/$uid/primary.jpg');

    final task = ref.putFile(file);

    task.snapshotEvents.listen((event) {
      if (onProgress != null && event.totalBytes > 0) {
        onProgress(event.bytesTransferred / event.totalBytes);
      }
    });

    await task;

    return await ref.getDownloadURL();
  }

  // 🔥 SECONDARY IMAGES UPLOAD
  Future<List<String>> uploadSecondaryImages({
    required String uid,
    required List<String> filePaths,
    void Function(double)? onProgress,
  }) async {
    List<String> urls = [];

    for (int i = 0; i < filePaths.length; i++) {
      final file = File(filePaths[i]);

      final ref = _storage.ref().child('profile_images/$uid/gallery_$i.jpg');

      final task = ref.putFile(file);

      task.snapshotEvents.listen((event) {
        if (onProgress != null && event.totalBytes > 0) {
          final fileProgress = event.bytesTransferred / event.totalBytes;
          // Calculate total progress for the batch
          final totalProgress = (i + fileProgress) / filePaths.length;
          onProgress(totalProgress);
        }
      });

      await task;

      final url = await ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }

  // two methods for fetching images
  // 🔥 FETCH PROFILE IMAGES
  Future<Map<String, dynamic>> getProfileImages(String uid) async {
    final ListResult result = await _storage
        .ref('profile_images/$uid')
        .listAll();

    String primaryImageUrl = '';
    List<String> secondaryImageUrls = [];
    String aadharCardUrl = '';

    for (final Reference ref in result.items) {
      final url = await ref.getDownloadURL();
      if (ref.name == 'primary.jpg') {
        primaryImageUrl = url;
      } else if (ref.name.startsWith('gallery_')) {
        secondaryImageUrls.add(url);
      } else if (ref.name == 'aadhar_card.pdf') {
        aadharCardUrl = url;
      }
    }
    return {
      'primaryImageUrl': primaryImageUrl,
      'secondaryImageUrls': secondaryImageUrls,
      'aadharCardUrl': aadharCardUrl,
    };
  }

  // 🔥 AADHAR CARD UPLOAD
  Future<String> uploadAadharCard({
    required String uid,
    required String filePath,
    void Function(double)? onProgress,
  }) async {
    final file = File(filePath);

    final ref = _storage.ref().child('profile_images/$uid/aadhar_card.pdf');

    final task = ref.putFile(file);

    task.snapshotEvents.listen((event) {
      if (onProgress != null && event.totalBytes > 0) {
        onProgress(event.bytesTransferred / event.totalBytes);
      }
    });

    await task;

    return await ref.getDownloadURL();
  }

  // 🔥 FETCH AADHAR CARD IMAGE
  Future<String?> getAadharCardUrl(String uid) async {
    try {
      final ref = _storage.ref().child('profile_images/$uid/aadhar_card.pdf');
      return await ref.getDownloadURL();
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        return null; // Aadhar card not found
      }
      rethrow;
    }
  }

  // 🔥 WATCH PROFILE IMAGES (NOT DIRECTLY SUPPORTED BY FIREBASE STORAGE)
  // This method will simulate watching by fetching periodically or on demand.
  // For real-time updates, you would typically store image URLs in Firestore
  // and watch the Firestore document.
}
