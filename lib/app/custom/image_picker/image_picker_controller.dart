import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../features/user/user_app/data/repositories_impl/user_image_repo_impl.dart';
import '../../../features/user/user_app/domain/states/image_state.dart';
import '../../../features/user/user_app/presentation/controllers/metrimony_profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

final uploadProgressProvider = StateProvider<double>((ref) => 0.0);

class ImagePickerController extends StateNotifier<ImagesState> {
  ImagePickerController(this.ref) : super(ImagesState.initial());

  final Ref ref;
  final ImagePicker _picker = ImagePicker();

  static const int maxSecondaryImages = 3;

  bool _isPicking = false;

  Future<String?> _cropImage(String path, {bool isPrimary = false}) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      maxWidth: isPrimary ? 500 : 800,
      maxHeight: isPrimary ? 500 : 800,
      compressQuality: isPrimary ? 70 : 80,
      compressFormat: ImageCompressFormat.jpg,

      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.pink,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );
    return croppedFile?.path;
  }

  // 📄 Pick Aadhar PDF
  Future<void> pickAadharPdf() async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) return;

      state = state.copyWith(aadharPdfPath: result.files.single.path);
    } finally {
      _isPicking = false;
    }
  }

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

      final croppedPath = await _cropImage(image.path, isPrimary: true);
      if (croppedPath != null) {
        state = state.copyWith(primaryImage: croppedPath);
      }
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

      final List<String> croppedPaths = [];
      for (final img in images) {
        final cropped = await _cropImage(img.path);
        if (cropped != null) {
          croppedPaths.add(cropped);
        }
      }
      final updated = {...state.secondaryImages, ...croppedPaths}.toList();

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
    if (state.aadharPdfPath == null) {
      throw Exception('Aadhar PDF is required');
    }

    try {
      ref.read(uploadProgressProvider.notifier).state = 0.0;

      // Use service directly to access progress callbacks
      final service = ref.read(imageUploadServiceProvider);

      final hasSecondary = state.secondaryImages.isNotEmpty;
      final steps = hasSecondary ? 3 : 2;
      final stepWeight = 1.0 / steps;

      void updateStepProgress(int stepIndex, double p) {
        final base = stepIndex * stepWeight;
        final current = p * stepWeight;
        ref.read(uploadProgressProvider.notifier).state = base + current;
      }

      // 1. Primary
      final primaryImageUrl = await service.uploadPrimaryImage(
        uid: uid,
        filePath: state.primaryImage!,
        onProgress: (p) => updateStepProgress(0, p),
      );

      // 2. Secondary (Optional)
      List<String> secondaryImageUrls = [];
      int nextStep = 1;

      if (hasSecondary) {
        secondaryImageUrls = await service.uploadSecondaryImages(
          uid: uid,
          filePaths: state.secondaryImages,
          onProgress: (p) => updateStepProgress(1, p),
        );
        nextStep = 2;
      }

      // 3. Aadhar
      final aadharCardUrl = await service.uploadAadharCard(
        uid: uid,
        filePath: state.aadharPdfPath!,
        onProgress: (p) => updateStepProgress(nextStep, p),
      );

      ref
          .read(metrimonyControllerProvider.notifier)
          .saveImages(
            ProfileImages(
              primaryImageUrl: primaryImageUrl,
              aadharCardUrl: aadharCardUrl,
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
