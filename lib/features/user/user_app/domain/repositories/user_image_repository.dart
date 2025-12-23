import '../states/image_state.dart';

abstract class UserImageRepository {
  Future<String> uploadPrimaryImage({
    required String uid,
    required String filePath,
  });

  Future<List<String>> uploadSecondaryImages({
    required String uid,
    required List<String> filePaths,
  });

  Future<ProfileImages> getProfileImages(String uid);
  Stream<ProfileImages> watchProfileImages(String uid);
}
