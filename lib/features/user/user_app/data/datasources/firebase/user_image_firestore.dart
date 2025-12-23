import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 🔥 PRIMARY IMAGE UPLOAD
  Future<String> uploadPrimaryImage({
    required String uid,
    required String filePath,
  }) async {
    final file = File(filePath);

    final ref = _storage.ref().child('profile_images/$uid/primary.jpg');

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  // 🔥 SECONDARY IMAGES UPLOAD
  Future<List<String>> uploadSecondaryImages({
    required String uid,
    required List<String> filePaths,
  }) async {
    List<String> urls = [];

    for (int i = 0; i < filePaths.length; i++) {
      final file = File(filePaths[i]);

      final ref = _storage.ref().child('profile_images/$uid/gallery_$i.jpg');

      await ref.putFile(file);

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

    for (final Reference ref in result.items) {
      final url = await ref.getDownloadURL();
      if (ref.name == 'primary.jpg') {
        primaryImageUrl = url;
      } else if (ref.name.startsWith('gallery_')) {
        secondaryImageUrls.add(url);
      }
    }
    return {
      'primaryImageUrl': primaryImageUrl,
      'secondaryImageUrls': secondaryImageUrls,
    };
  }

  // 🔥 WATCH PROFILE IMAGES (NOT DIRECTLY SUPPORTED BY FIREBASE STORAGE)
  // This method will simulate watching by fetching periodically or on demand.
  // For real-time updates, you would typically store image URLs in Firestore
  // and watch the Firestore document.
}
