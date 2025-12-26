import '../../data/repositories_impl/user_image_repo_impl.dart';
import '../../domain/states/image_state.dart';
import 'metrimony_profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';

final uploadProgressProvider = StateProvider<double>((ref) => 0.0);

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
      ref.read(uploadProgressProvider.notifier).state = 0.0;

      // Use service directly to access progress callbacks
      final service = ref.read(imageUploadServiceProvider);

      void updateProgress(double p, {bool isSecondary = false}) {
        // Weighted progress: 50% primary, 50% secondary (if exists)
        double total = p;
        if (state.secondaryImages.isNotEmpty) {
          total = isSecondary ? 0.5 + (p * 0.5) : p * 0.5;
        }
        ref.read(uploadProgressProvider.notifier).state = total;
      }

      final primaryImageUrl = await service.uploadPrimaryImage(
        uid: uid,
        filePath: state.primaryImage!,
        onProgress: (p) => updateProgress(p),
      );

      final secondaryImageUrls = await service.uploadSecondaryImages(
        uid: uid,
        filePaths: state.secondaryImages,
        onProgress: (p) => updateProgress(p, isSecondary: true),
      );

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
