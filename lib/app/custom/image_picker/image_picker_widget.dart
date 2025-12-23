import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/user/user_app/presentation/controllers/image_picker_controller.dart';

class ImagePickerWidget extends ConsumerWidget {
  const ImagePickerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageState = ref.watch(imagePickerProvider);
    final controller = ref.read(imagePickerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PRIMARY IMAGE
        GestureDetector(
          onTap: controller.pickPrimaryImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: imageState.primaryImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.camera_alt, size: 40),
                      SizedBox(height: 8),
                      Text('Select Primary Image'),
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

        // HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Gallery Images',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ActionChip(
              labelStyle: TextStyle(
                 
              ),
             
              elevation: 0,
              shadowColor: Colors.transparent,
              onPressed: controller.pickSecondaryImages,
              avatar: Icon(
                Icons.image_outlined,
                color: const Color.fromARGB(255, 105, 69, 15),
              ),
              label: const Text('Add More'),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // EMPTY PLACEHOLDER
        if (imageState.secondaryImages.isEmpty)
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (_, __) => Container(
                margin: const EdgeInsets.all(5),

                width: MediaQuery.of(context).size.width * 0.29,
                // height: MediaQuery.of(context).size.height * 0.28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt),
              ),
            ),
          ),

        // GALLERY IMAGES
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
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child: Icon(
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

        // Center(
        //   child: Container(
        //     width: double.infinity,
        //     padding: const EdgeInsets.all(9),
        //     child: ElevatedButton(
        //       onPressed: () {
        //         controller.uploadImages(
        //           ref,

        //           ref.read(authStateProvider).value!.uid,
        //         );
        //       },
        //       child: Icon(Icons.cloud_upload_outlined, size: 30),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
