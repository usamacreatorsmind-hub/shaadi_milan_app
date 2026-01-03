import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'image_picker_controller.dart';
import '../custom_widgets/chip_and_action_chip.dart';

final _imagePickingProvider = StateProvider<bool>((ref) => false);

class ImagePickerWidget extends ConsumerWidget {
  const ImagePickerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageState = ref.watch(imagePickerProvider);

    final controller = ref.read(imagePickerProvider.notifier);
    final isPicking = ref.watch(_imagePickingProvider);

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Future<void> safePick(Future<void> Function() action) async {
      if (isPicking) return;
      ref.read(_imagePickingProvider.notifier).state = true;
      try {
        await action();
      } finally {
        ref.read(_imagePickingProvider.notifier).state = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= PRIMARY IMAGE =================
        GestureDetector(
          onTap: () => safePick(controller.pickPrimaryImage),
          child: Container(
            height: 400,
            margin: const EdgeInsets.only(bottom: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outline),
            ),
            child: imageState.primaryImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 40, color: colors.primary),
                      const SizedBox(height: 8),
                      Text(
                        'Select Primary Image',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(imageState.primaryImage!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 16),

        // ================= HEADER =================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gallery Images',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            AppChip(
              label: 'Add Image',
              onTap: () => safePick(controller.pickSecondaryImages),
              backgroundColor: colors.secondaryContainer,
              textColor: colors.onSecondaryContainer,
              icon: Icons.add,
            ),
          ],
        ),

        const SizedBox(height: 8),

        // add for aadhar image also
        const SizedBox(height: 16),

        // ================= EMPTY PLACEHOLDER =================
        if (imageState.secondaryImages.isEmpty)
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (_, __) => Container(
                margin: const EdgeInsets.all(6),
                width: MediaQuery.of(context).size.width * 0.29,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.camera_alt, color: colors.onSurfaceVariant),
              ),
            ),
          ),

        // ================= GALLERY IMAGES =================
        if (imageState.secondaryImages.isNotEmpty)
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imageState.secondaryImages.length,
              itemBuilder: (context, index) {
                final path = imageState.secondaryImages[index];
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: MediaQuery.of(context).size.width * 0.29,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: GestureDetector(
                        onTap: () => controller.removeSecondaryImage(path),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: colors.scrim.withOpacity(0.6),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

        // ================= AADHAR IMAGE =================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aadhar Card (PDF)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            AppChip(
              label: 'Upload PDF',
              onTap: () => safePick(controller.pickAadharPdf),
              backgroundColor: colors.secondaryContainer,
              textColor: colors.onSecondaryContainer,
              icon: Icons.picture_as_pdf,
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => safePick(controller.pickAadharPdf),
          child: Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outline),
            ),
            child: imageState.aadharPdfPath == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 30,
                        color: colors.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select Aadhar PDF',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          imageState.aadharPdfPath!.split('/').last,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
