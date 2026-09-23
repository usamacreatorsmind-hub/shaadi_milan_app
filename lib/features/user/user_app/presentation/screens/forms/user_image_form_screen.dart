import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../app/custom/image_picker/image_picker_controller.dart';
import '../../../../../../app/providers/global_providers.dart';
import '../../../../../../core/constants/app_labels.dart';
import '../../../data/datasources/firebase/user_firestore_ds.dart';
import '../../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../../data/repositories_impl/user_image_repo_impl.dart';
import '../../../domain/states/image_state.dart';
import '../my_profile_screen.dart';

@RoutePage()
class UserImageFormScreen extends ConsumerStatefulWidget {
  const UserImageFormScreen({super.key});

  @override
  ConsumerState<UserImageFormScreen> createState() => _UserImageFormScreenState();
}

class _UserImageFormScreenState extends ConsumerState<UserImageFormScreen> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final imageState = ref.watch(imagePickerProvider);
    final controller = ref.read(imagePickerProvider.notifier);
    final targetUid = ref.watch(targetUserIdProvider);
    final profileAsync = targetUid != null ? ref.watch(matrimonyProfileProvider(targetUid)) : null;

    final theme = Theme.of(context);
    final canPop = Navigator.canPop(context);

    final existingProfileImage = profileAsync?.value?.images.profileImageUrl;
    final existingSecondaryImages = profileAsync?.value?.images.secondaryImageUrls ?? [];

    ImageProvider? getProfileImageProvider() {
      if (imageState.profileImage != null) {
        return FileImage(File(imageState.profileImage!));
      } else if (existingProfileImage != null && existingProfileImage.isNotEmpty) {
        return NetworkImage(existingProfileImage);
      }
      return null;
    }

    final avatarImage = getProfileImageProvider();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: canPop
          ? AppBar(
              title: Text(AppLabels.uploadProfileImages(context)),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                onPressed: () => context.router.maybePop(),
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!canPop) ...[
                Text(
                  AppLabels.uploadProfileImages(context),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // 📸 PROFILE PHOTO SECTION
              _buildSectionHeader(context, "Profile Picture", Icons.person_pin_outlined),
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.primaryColor.withOpacity(0.2),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: avatarImage,
                      child: avatarImage == null
                          ? Icon(
                              Icons.person_outline_rounded,
                              size: 70,
                              color: Colors.grey.shade400,
                            )
                          : null,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.pickProfileImage(context),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: theme.primaryColor,
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Upload a clear face photo",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),

              const SizedBox(height: 40),

              // 🖼 GALLERY PHOTOS SECTION
              _buildSectionHeader(context, "Gallery Photos (Add 2-3 extra)", Icons.photo_library_outlined),
              const SizedBox(height: 16),

              if (imageState.secondaryImages.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: imageState.secondaryImages.length,
                    itemBuilder: (context, index) {
                      final path = imageState.secondaryImages[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(path),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => controller.removeSecondaryImage(path),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else if (existingSecondaryImages.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: existingSecondaryImages.length,
                    itemBuilder: (context, index) {
                      final url = existingSecondaryImages[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            url,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
                  ),
                  child: Center(
                    child: Text(
                      "No extra photos added",
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => controller.pickSecondaryImages(context),
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text("Add More Photos"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 💾 SAVE BUTTON (Always visible if standalone or if new photos picked)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _savePhotos,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          "Save Photos",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<void> _savePhotos() async {
    final uid = ref.read(targetUserIdProvider);
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User ID not found.")),
      );
      return;
    }

    final imageState = ref.read(imagePickerProvider);
    if (imageState.profileImage == null && imageState.secondaryImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No new photos selected to upload.")),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      final imageService = ref.read(imageUploadServiceProvider);

      final currentMatrimony = await ref.read(matrimonyRepositoryProvider).getMatrimonyProfile(uid);
      ProfileImages currentImages = currentMatrimony.images;

      String updatedProfileUrl = currentImages.profileImageUrl;
      List<String> updatedSecondaryUrls = List.from(currentImages.secondaryImageUrls);

      // 1. Upload Profile Image if picked
      if (imageState.profileImage != null) {
        updatedProfileUrl = await imageService.uploadProfileImage(
          uid: uid,
          filePath: imageState.profileImage!,
        );
        await ref.read(userFirestoreDSProvider).updateProfilePhoto(uid, updatedProfileUrl);
      }

      // 2. Upload Secondary Images if picked
      if (imageState.secondaryImages.isNotEmpty) {
        final uploadedGallery = await imageService.uploadSecondaryImages(
          uid: uid,
          filePaths: imageState.secondaryImages,
        );
        updatedSecondaryUrls = uploadedGallery;
      }

      // 3. Construct updated ProfileImages
      final newProfileImages = currentImages.copyWith(
        profileImageUrl: updatedProfileUrl,
        secondaryImageUrls: updatedSecondaryUrls,
      );

      // 4. Update in Firestore matrimony profile
      await ref.read(matrimonyRepositoryProvider).updateImagesProfile(uid, newProfileImages);

      // 5. Reset local image picker state
      ref.read(imagePickerProvider.notifier).reset();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Photos saved successfully!")),
        );
        if (Navigator.canPop(context)) {
          context.router.maybePop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving photos: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }
}
