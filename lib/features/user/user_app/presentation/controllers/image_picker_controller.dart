import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/user_image_repo_impl.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/image_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/controllers/metrimony_profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerController extends StateNotifier<ImagesState> {
  ImagePickerController() : super(ImagesState.initial());

  final ImagePicker _picker = ImagePicker();
  static const int maxSecondaryImages = 3;

  // 📸 Pick primary image
  Future<void> pickPrimaryImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    state = state.copyWith(primaryImage: image.path);
  }

  // 🖼 Pick multiple gallery images
  Future<void> pickSecondaryImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 50, limit: 3);
    if (images.isEmpty) return;

    final paths = images.map((e) => e.path).toList();

    final updated = {...state.secondaryImages, ...paths}.toList();

    state = state.copyWith(
      secondaryImages: updated.take(maxSecondaryImages).toList(),
    );
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

  Future<void> uploadImages(WidgetRef ref, String uid) async {
    final String? primaryImageUrl = await ref
        .read(userImageRepositoryProvider)
        .uploadPrimaryImage(uid: uid, filePath: state.primaryImage!);

    final List<String> secondaryImageUrls = await ref
        .read(userImageRepositoryProvider)
        .uploadSecondaryImages(uid: uid, filePaths: state.secondaryImages);

    ref
        .read(metrimonyControllerProvider.notifier)
        .saveImages(
          ProfileImages(
            primaryImageUrl: primaryImageUrl!,
            secondaryImageUrls: secondaryImageUrls,
          ),
        );
  }
}

final imagePickerProvider =
    StateNotifierProvider<ImagePickerController, ImagesState>(
      (ref) => ImagePickerController(),
    );
