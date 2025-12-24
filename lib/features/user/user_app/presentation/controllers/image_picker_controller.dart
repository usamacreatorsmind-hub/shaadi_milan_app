import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/user_image_repo_impl.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/image_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/controllers/metrimony_profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerController extends StateNotifier<ImagesState> {
  ImagePickerController(this.ref) : super(ImagesState.initial());

  final Ref ref;
  final ImagePicker _picker = ImagePicker();

  static const int maxSecondaryImages = 3;

  bool _isPicking = false;

  // 📸 Pick primary image
  Future<void> pickPrimaryImage() async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      state = state.copyWith(primaryImage: image.path);
    } finally {
      _isPicking = false;
    }
  }

  // 🖼 Pick multiple gallery images
  Future<void> pickSecondaryImages() async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      final images = await _picker.pickMultiImage(
        imageQuality: 50,
        limit: maxSecondaryImages,
      );

      if (images.isEmpty) return;

      final paths = images.map((e) => e.path).toList();
      final updated = {...state.secondaryImages, ...paths}.toList();

      state = state.copyWith(
        secondaryImages: updated.take(maxSecondaryImages).toList(),
      );
    } finally {
      _isPicking = false;
    }
  }

  // ❌ Remove one gallery image
  void removeSecondaryImage(String path) {
    state = state.copyWith(
      secondaryImages: state.secondaryImages.where((e) => e != path).toList(),
    );
  }

  // ❌ Clear primary
  void clearPrimaryImage() {
    state = state.copyWith(primaryImage: null);
  }

  // ❌ Clear gallery
  void clearSecondaryImages() {
    state = state.copyWith(secondaryImages: []);
  }

  void reset() {
    state = ImagesState.initial();
  }

  // ☁️ Upload images
  Future<void> uploadImages(String uid) async {
    if (state.primaryImage == null) {
      throw Exception('Primary image is required');
    }

    try {
      final primaryImageUrl = await ref
          .read(userImageRepositoryProvider)
          .uploadPrimaryImage(uid: uid, filePath: state.primaryImage!);

      final secondaryImageUrls = await ref
          .read(userImageRepositoryProvider)
          .uploadSecondaryImages(uid: uid, filePaths: state.secondaryImages);

      ref
          .read(metrimonyControllerProvider.notifier)
          .saveImages(
            ProfileImages(
              primaryImageUrl: primaryImageUrl,
              secondaryImageUrls: secondaryImageUrls,
            ),
          );
    } catch (e) {
      rethrow; // UI will handle snackbar
    }
  }
}

final imagePickerProvider =
    StateNotifierProvider<ImagePickerController, ImagesState>(
      (ref) => ImagePickerController(ref),
    );
