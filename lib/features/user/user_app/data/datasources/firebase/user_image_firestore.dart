import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Custom exception for upload-related errors
class UploadException implements Exception {
  final String message;
  final String? code;
  UploadException(this.message, {this.code});
  @override
  String toString() => message;
}

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Validate file exists and is accessible
  bool _validateFile(String filePath) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw UploadException('File does not exist: $filePath');
      }
      return true;
    } catch (e) {
      throw UploadException('File validation failed: $e');
    }
  }

  /// Get file extension from path
  String _getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  /// Validate image file format
  bool _isValidImageFormat(String ext) {
    const validFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    return validFormats.contains(ext);
  }

  /// Validate document file format (includes images for aadhar)
  bool _isValidDocumentFormat(String ext) {
    const validFormats = ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'];
    return validFormats.contains(ext);
  }

  /// Check file size (max 50MB by default)
  bool _validateFileSize(String filePath, {int maxMB = 50}) {
    try {
      final file = File(filePath);
      final sizeInMB = file.lengthSync() / (1024 * 1024);
      if (sizeInMB > maxMB) {
        throw UploadException(
          'File too large: ${sizeInMB.toStringAsFixed(2)}MB exceeds ${maxMB}MB limit',
          code: 'size-exceeded',
        );
      }
      return true;
    } catch (e) {
      if (e is UploadException) rethrow;
      throw UploadException('File size check failed: $e');
    }
  }

  // 🔥 PRIMARY IMAGE UPLOAD
  Future<String> uploadPrimaryImage({
    required String uid,
    required String filePath,
    void Function(double)? onProgress,
  }) async {
    try {
      _validateFile(filePath);

      final ext = _getFileExtension(filePath);
      if (!_isValidImageFormat(ext)) {
        throw UploadException(
          'Invalid image format: .$ext. Allowed: jpg, jpeg, png, gif, webp',
          code: 'invalid-format',
        );
      }

      _validateFileSize(filePath);

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
    } on FirebaseException catch (e) {
      throw UploadException(
        'Firebase upload failed: ${e.message}',
        code: e.code,
      );
    } on UploadException {
      rethrow;
    } catch (e) {
      throw UploadException('Unexpected error during upload: $e');
    }
  }

  // 🔥 SECONDARY IMAGES UPLOAD
  Future<List<String>> uploadSecondaryImages({
    required String uid,
    required List<String> filePaths,
    void Function(double)? onProgress,
  }) async {
    if (filePaths.isEmpty) {
      throw UploadException('No files provided for upload');
    }

    List<String> urls = [];

    try {
      for (int i = 0; i < filePaths.length; i++) {
        final filePath = filePaths[i];

        try {
          _validateFile(filePath);

          final ext = _getFileExtension(filePath);
          if (!_isValidImageFormat(ext)) {
            throw UploadException(
              'File $i: Invalid format .$ext. Allowed: jpg, jpeg, png, gif, webp',
              code: 'invalid-format',
            );
          }

          _validateFileSize(filePath);

          final file = File(filePath);
          final ref = _storage.ref().child(
            'profile_images/$uid/gallery_$i.jpg',
          );

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
        } catch (e) {
          throw UploadException('Error uploading file $i: $e');
        }
      }

      return urls;
    } on FirebaseException catch (e) {
      throw UploadException(
        'Firebase batch upload failed: ${e.message}',
        code: e.code,
      );
    } on UploadException {
      rethrow;
    } catch (e) {
      throw UploadException('Unexpected error during batch upload: $e');
    }
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
    String bioDataUrl = '';
    String imageWithAgentUrl = '';
    String profileImageUrl = '';

    for (final Reference ref in result.items) {
      final url = await ref.getDownloadURL();
      if (ref.name == 'primary.jpg') {
        primaryImageUrl = url;
      } else if (ref.name.startsWith('gallery_')) {
        secondaryImageUrls.add(url);
      } else if (ref.name.startsWith('aadhar_card.')) {
        aadharCardUrl = url;
      } else if (ref.name.startsWith('biodata.')) {
        bioDataUrl = url;
      } else if (ref.name == 'image_with_agent.jpg') {
        imageWithAgentUrl = url;
      } else if (ref.name == 'profile_image.jpg') {
        profileImageUrl = url;
      }
    }
    return {
      'primaryImageUrl': primaryImageUrl,
      'secondaryImageUrls': secondaryImageUrls,
      'aadharCardUrl': aadharCardUrl,
      'bioDataUrl': bioDataUrl,
      'imageWithAgentUrl': imageWithAgentUrl,
      'profileImageUrl': profileImageUrl,
    };
  }

  // 🔥 AADHAR CARD UPLOAD
  Future<String> uploadAadharCard({
    required String uid,
    required String filePath,
    void Function(double)? onProgress,
  }) async {
    try {
      _validateFile(filePath);

      final ext = _getFileExtension(filePath);
      if (!_isValidDocumentFormat(ext)) {
        throw UploadException(
          'Invalid file format: .$ext. Allowed: pdf, doc, docx, jpg, jpeg, png',
          code: 'invalid-format',
        );
      }

      _validateFileSize(filePath, maxMB: 50);

      final file = File(filePath);
      // Use the actual file extension
      final ref = _storage.ref().child('profile_images/$uid/aadhar_card.$ext');

      final task = ref.putFile(file);

      task.snapshotEvents.listen((event) {
        if (onProgress != null && event.totalBytes > 0) {
          onProgress(event.bytesTransferred / event.totalBytes);
        }
      });

      await task;

      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw UploadException(
        'Firebase document upload failed: ${e.message}',
        code: e.code,
      );
    } on UploadException {
      rethrow;
    } catch (e) {
      throw UploadException('Unexpected error uploading document: $e');
    }
  }

  // 🔥 FETCH AADHAR CARD IMAGE
  Future<String?> getAadharCardUrl(String uid) async {
    try {
      final ref = _storage.ref().child('profile_images/$uid/aadhar_card.pdf');
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return null; // Aadhar card not found
      }
      throw UploadException(
        'Failed to fetch Aadhar card URL: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw UploadException('Unexpected error fetching Aadhar card: $e');
    }
  }

  // 🔥 BIODATA UPLOAD
  Future<String> uploadBioData({
    required String uid,
    required String filePath,
    void Function(double)? onProgress,
  }) async {
    try {
      _validateFile(filePath);

      final ext = _getFileExtension(filePath);
      if (!_isValidDocumentFormat(ext)) {
        throw UploadException(
          'Invalid file format: .$ext. Allowed: pdf, doc, docx, jpg, jpeg, png',
          code: 'invalid-format',
        );
      }

      _validateFileSize(filePath, maxMB: 50);

      final file = File(filePath);
      final ref = _storage.ref().child('profile_images/$uid/biodata.$ext');

      final task = ref.putFile(file);

      task.snapshotEvents.listen((event) {
        if (onProgress != null && event.totalBytes > 0) {
          onProgress(event.bytesTransferred / event.totalBytes);
        }
      });

      await task;

      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw UploadException(
        'Firebase biodata upload failed: ${e.message}',
        code: e.code,
      );
    } on UploadException {
      rethrow;
    } catch (e) {
      throw UploadException('Unexpected error uploading biodata: $e');
    }
  }

  Future<String> uploadImageWithAgent({
    required String uid,
    required String filePath,
    required void Function(double) onProgress,
  }) async {
    try {
      _validateFile(filePath);

      final ext = _getFileExtension(filePath);
      if (!_isValidImageFormat(ext)) {
        throw UploadException(
          'Invalid image format: .$ext. Allowed: jpg, jpeg, png, gif, webp',
          code: 'invalid-format',
        );
      }

      _validateFileSize(filePath);

      final file = File(filePath);

      final ref = _storage.ref().child(
        'profile_images/$uid/image_with_agent.jpg',
      );

      final task = ref.putFile(file);

      task.snapshotEvents.listen((event) {
        if (event.totalBytes > 0) {
          onProgress(event.bytesTransferred / event.totalBytes);
        }
      });

      await task;

      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw UploadException(
        'Firebase image upload failed: ${e.message}',
        code: e.code,
      );
    } on UploadException {
      rethrow;
    } catch (e) {
      throw UploadException('Unexpected error uploading image with agent: $e');
    }
  }

  // download image with agent
  Future<String?> getImageWithAgentUrl(String uid) async {
    try {
      final ref = _storage.ref().child(
        'profile_images/$uid/image_with_agent.jpg',
      );
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return null; // Image with agent not found
      }
      throw UploadException(
        'Failed to fetch image with agent: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw UploadException('Unexpected error fetching image with agent: $e');
    }
  }

  // 🔥 PROFILE IMAGE UPLOAD
  Future<String> uploadProfileImage({
    required String uid,
    required String filePath,
    void Function(double)? onProgress,
  }) async {
    try {
      _validateFile(filePath);

      final ext = _getFileExtension(filePath);
      if (!_isValidImageFormat(ext)) {
        throw UploadException(
          'Invalid image format: .$ext. Allowed: jpg, jpeg, png, gif, webp',
          code: 'invalid-format',
        );
      }

      _validateFileSize(filePath);

      final file = File(filePath);
      final ref = _storage.ref().child('profile_images/$uid/profile_image.jpg');

      final task = ref.putFile(file);

      task.snapshotEvents.listen((event) {
        if (onProgress != null && event.totalBytes > 0) {
          onProgress(event.bytesTransferred / event.totalBytes);
        }
      });

      await task;

      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw UploadException(
        'Firebase upload failed: ${e.message}',
        code: e.code,
      );
    } on UploadException {
      rethrow;
    } catch (e) {
      throw UploadException('Unexpected error during upload: $e');
    }
  }

  // 🔥 WATCH PROFILE IMAGES (NOT DIRECTLY SUPPORTED BY FIREBASE STORAGE)
  // This method will simulate watching by fetching periodically or on demand.
  // For real-time updates, you would typically store image URLs in Firestore
  // and watch the Firestore document.
}
