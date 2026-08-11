import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../app/custom/image_picker/image_picker_controller.dart';
import '../../../../../../core/constants/app_labels.dart';

@RoutePage()
class UserImageFormScreen extends ConsumerWidget {
  const UserImageFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageState = ref.watch(imagePickerProvider);
    final controller = ref.read(imagePickerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLabels.uploadProfileImages(context),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 40),

              // 📸 CIRCULAR AVATAR
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
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
                      radius: 80,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: imageState.profileImage != null
                          ? FileImage(File(imageState.profileImage!))
                          : null,
                      child: imageState.profileImage == null
                          ? Icon(
                              Icons.person_outline_rounded,
                              size: 80,
                              color: Colors.grey.shade400,
                            )
                          : null,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.pickProfileImage(context),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Text(
                "Please upload a clear profile picture",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),

              const SizedBox(height: 24),

              // 🔘 SELECT IMAGE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.pickProfileImage(context),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(
                    imageState.profileImage == null
                        ? "Select Photo"
                        : "Change Photo",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
