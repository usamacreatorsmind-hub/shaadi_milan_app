import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../app/custom/image_picker/image_picker_controller.dart';
import '../../../../../../app/providers/global_providers.dart';
import '../../../../../../core/constants/app_labels.dart';
import '../../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../../data/repositories_impl/user_image_repo_impl.dart';
import '../../../domain/states/image_state.dart';
import '../../../widgets/pdf_viewer_bottomsheet.dart';
import '../my_profile_screen.dart';

@RoutePage()
class UserIdCardFormScreen extends ConsumerStatefulWidget {
  const UserIdCardFormScreen({super.key});

  @override
  ConsumerState<UserIdCardFormScreen> createState() => _UserIdCardFormScreenState();
}

class _UserIdCardFormScreenState extends ConsumerState<UserIdCardFormScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final imageState = ref.watch(imagePickerProvider);
    final controller = ref.read(imagePickerProvider.notifier);
    final targetUid = ref.watch(targetUserIdProvider);
    final profileAsync = targetUid != null ? ref.watch(matrimonyProfileProvider(targetUid)) : null;

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(AppLabels.idCards(context)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Upload ID Cards & Documents",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Upload clear copies of your Aadhaar Card and BioData for verification.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // 📄 AADHAAR CARD SECTION
              _buildDocumentCard(
                context: context,
                title: AppLabels.aadharCard(context),
                icon: Icons.badge_outlined,
                localPath: imageState.aadharPdfPath,
                existingUrl: profileAsync?.value?.images.aadharCardUrl,
                onPick: controller.pickAadharPdf,
              ),

              const SizedBox(height: 24),

              // 📄 BIODATA SECTION
              _buildDocumentCard(
                context: context,
                title: AppLabels.bioData(context),
                icon: Icons.description_outlined,
                localPath: imageState.bioDataPath,
                existingUrl: profileAsync?.value?.images.bioDataUrl,
                onPick: controller.pickBioDataImages,
              ),

              const SizedBox(height: 40),

              // 💾 SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveIdCards,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          "Save ID Cards",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String? localPath,
    required String? existingUrl,
    required VoidCallback onPick,
  }) {
    final theme = Theme.of(context);
    final hasLocal = localPath != null && localPath.isNotEmpty;
    final hasExisting = existingUrl != null && existingUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasLocal ? Colors.green : (hasExisting ? theme.primaryColor.withOpacity(0.3) : Colors.grey.shade300),
          width: hasLocal ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: theme.primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasLocal
                          ? "New document selected"
                          : (hasExisting ? "Uploaded" : "Not uploaded"),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: hasLocal ? Colors.green.shade700 : (hasExisting ? Colors.blue.shade700 : Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // PREVIEW AREA
          if (hasLocal) ...[
            _buildLocalPreview(localPath!),
            const SizedBox(height: 12),
          ] else if (hasExisting) ...[
            OutlinedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => PdfViewerBottomsheet(
                    source: existingUrl!,
                    title: title,
                    isLocal: false,
                  ),
                );
              },
              icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
              label: Text(AppLabels.viewDocument(context)),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.primaryColor,
                side: BorderSide(color: theme.primaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ACTION BUTTONS
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPick,
              icon: Icon(hasLocal || hasExisting ? Icons.refresh : Icons.upload_file_outlined, size: 18),
              label: Text(hasLocal || hasExisting ? "Change File" : "Select File (PDF / Image)"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalPreview(String path) {
    final isImage = path.toLowerCase().endsWith('.jpg') ||
        path.toLowerCase().endsWith('.jpeg') ||
        path.toLowerCase().endsWith('.png') ||
        path.toLowerCase().endsWith('.webp');

    if (isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(path),
          height: 140,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.green, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              path.split('/').last,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  Future<void> _saveIdCards() async {
    final uid = ref.read(targetUserIdProvider);
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User ID not found.")),
      );
      return;
    }

    final imageState = ref.read(imagePickerProvider);
    if (imageState.aadharPdfPath == null && imageState.bioDataPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an ID card or BioData file to upload.")),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final imageService = ref.read(imageUploadServiceProvider);

      final currentMatrimony = await ref.read(matrimonyRepositoryProvider).getMatrimonyProfile(uid);
      ProfileImages currentImages = currentMatrimony.images;

      String updatedAadharUrl = currentImages.aadharCardUrl;
      String updatedBioDataUrl = currentImages.bioDataUrl;

      // 1. Upload Aadhar if selected
      if (imageState.aadharPdfPath != null) {
        updatedAadharUrl = await imageService.uploadAadharCard(
          uid: uid,
          filePath: imageState.aadharPdfPath!,
        );
      }

      // 2. Upload BioData if selected
      if (imageState.bioDataPath != null) {
        updatedBioDataUrl = await imageService.uploadBioData(
          uid: uid,
          filePath: imageState.bioDataPath!,
        );
      }

      // 3. Construct updated ProfileImages
      final newProfileImages = currentImages.copyWith(
        aadharCardUrl: updatedAadharUrl,
        bioDataUrl: updatedBioDataUrl,
      );

      // 4. Update in Firestore matrimony profile
      await ref.read(matrimonyRepositoryProvider).updateImagesProfile(uid, newProfileImages);

      // 5. Reset local image picker state
      ref.read(imagePickerProvider.notifier).reset();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ID Cards saved successfully!")),
        );
        if (Navigator.canPop(context)) {
          context.router.maybePop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving ID Cards: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
