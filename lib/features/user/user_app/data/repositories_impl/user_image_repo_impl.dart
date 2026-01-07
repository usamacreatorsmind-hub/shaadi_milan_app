import 'dart:io';

import '../datasources/firebase/user_image_firestore.dart';
import '../../domain/repositories/user_image_repository.dart';
import '../../domain/states/image_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserImageRepositoryImpl implements UserImageRepository {
  final ImageUploadService _imageUploadService;

  UserImageRepositoryImpl(this._imageUploadService);

  @override
  Future<String> uploadPrimaryImage({
    required String uid,
    required String filePath,
  }) {
    return _imageUploadService.uploadPrimaryImage(uid: uid, filePath: filePath);
  }

  @override
  Future<List<String>> uploadSecondaryImages({
    required String uid,
    required List<String> filePaths,
  }) {
    return _imageUploadService.uploadSecondaryImages(
      uid: uid,
      filePaths: filePaths,
    );
  }

  @override
  Future<ProfileImages> getProfileImages(String uid) async {
    final imagesMap = await _imageUploadService.getProfileImages(uid);
    return ProfileImages(
      primaryImageUrl: imagesMap['primaryImageUrl'] as String,
      aadharCardUrl: imagesMap['aadharCardUrl'] as String,

      secondaryImageUrls: imagesMap['secondaryImageUrls'] as List<String>,
    );
  }

  @override
  Stream<ProfileImages> watchProfileImages(String uid) {
    // This is a simplified implementation. For true real-time updates,
    // image URLs would typically be stored in Firestore and watched there.
    // Here, we're just returning a stream that emits the current state once.
    return Stream.fromFuture(getProfileImages(uid));
  }
}

final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  return ImageUploadService();
});

final userImageRepositoryProvider = Provider<UserImageRepository>((ref) {
  return UserImageRepositoryImpl(ref.watch(imageUploadServiceProvider));
});
