import 'package:arvika_marriage_bureau/core/themes/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../features/user/user_app/data/repositories_impl/user_image_repo_impl.dart';
import '../../../features/user/user_app/domain/states/image_state.dart';
import '../../../features/user/user_app/presentation/controllers/metrimony_profile_controller.dart';

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
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: AppTheme.lightTheme.primaryColor,

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
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) return;

      state = state.copyWith(aadharPdfPath: result.files.single.path);
    } finally {
      _isPicking = false;
    }
  }

  // pick images from gallary
  Future<void> pickAadharImages() async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result == null || result.files.single.path == null) return;

      state = state.copyWith(aadharPdfPath: result.files.single.path);
    } finally {
      _isPicking = false;
    }
  }

  // 📸 Pick primary image
  Future<void> pickPrimaryImage(BuildContext context) async {
    if (_isPicking) return;
    final source = await showImageSourceSelection(context);
    if (source == null) return;
    _isPicking = true;

    try {
      final XFile? image = await _picker.pickImage(source: source);

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
  Future<void> pickSecondaryImages(BuildContext context) async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      final images = await _picker.pickMultiImage(limit: maxSecondaryImages);

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
    if (state.profileImage == null || state.profileImage!.isEmpty) {
      throw Exception('Profile image is required');
    }
    if (state.primaryImage == null || state.primaryImage!.isEmpty) {
      throw Exception('Primary image is required');
    }
    if (state.imageWithAgentUrl == null || state.imageWithAgentUrl!.isEmpty) {
      throw Exception('Image with agent is required');
    }
    if (state.secondaryImages.isEmpty) {
      throw Exception('At least one gallery image is required');
    }
    if (state.aadharPdfPath == null || state.aadharPdfPath!.isEmpty) {
      throw Exception('Aadhar document is required');
    }

    try {
      ref.read(uploadProgressProvider.notifier).state = 0.0;

      // Use service directly to access progress callbacks
      final service = ref.read(imageUploadServiceProvider);

      const steps =
          5; // primary, secondary, aadhar, imageWithAgent, profileImage
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

      // 2. Secondary
      final secondaryImageUrls = await service.uploadSecondaryImages(
        uid: uid,
        filePaths: state.secondaryImages,
        onProgress: (p) => updateStepProgress(1, p),
      );

      // 3. Aadhar
      final aadharCardUrl = await service.uploadAadharCard(
        uid: uid,
        filePath: state.aadharPdfPath!,
        onProgress: (p) => updateStepProgress(2, p),
      );

      final imagewithagenturl = await service.uploadImageWithAgent(
        uid: uid,
        filePath: state.imageWithAgentUrl!,
        onProgress: (p) => updateStepProgress(3, p),
      );

      final profileImageUrl = await service.uploadProfileImage(
        uid: uid,
        filePath: state.profileImage!,
        onProgress: (p) => updateStepProgress(4, p),
      );

      ref
          .read(metrimonyControllerProvider.notifier)
          .saveImages(
            ProfileImages(
              profileImageUrl: profileImageUrl,
              primaryImageUrl: primaryImageUrl,
              imageWithAgentUrl: imagewithagenturl,
              aadharCardUrl: aadharCardUrl,
              secondaryImageUrls: secondaryImageUrls,
            ),
          );
    } catch (e) {
      rethrow; // UI will handle snackbar
    }
  }

  void pickImageWithAgent() async {
    // Implementation for picking image with agent
    if (_isPicking) return;
    _isPicking = true;

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image == null) return;

      final croppedPath = await _cropImage(image.path, isPrimary: false);
      if (croppedPath != null) {
        state = state.copyWith(imageWithAgentUrl: croppedPath);
      }
    } finally {
      _isPicking = false;
    }
  }

  Future<void> pickProfileImage(BuildContext context) async {
    if (_isPicking) return;

    final source = await showImageSourceSelection(context);

    if (source == null) return; // user cancelled

    _isPicking = true;

    try {
      final XFile? image = await _picker.pickImage(source: source);

      if (image == null) return;

      final croppedPath = await _cropImage(image.path, isPrimary: true);

      if (croppedPath != null) {
        state = state.copyWith(profileImage: croppedPath);
      }
    } finally {
      _isPicking = false;
    }
  }

  // build a image source selection bottom sheet
  Future<ImageSource?> showImageSourceSelection(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

final imagePickerProvider =
    StateNotifierProvider<ImagePickerController, ImagesState>(
      (ref) => ImagePickerController(ref),
    );
