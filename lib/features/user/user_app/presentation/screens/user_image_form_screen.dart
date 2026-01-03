import '../../../../../app/custom/image_picker/image_picker_widget.dart';
import '../../../../../app/router/app_router.dart';
import '../../../../../app/custom/image_picker/image_picker_controller.dart';
import '../controllers/metrimony_profile_controller.dart';
import '../../../user_auth/presentation/providers/auth_providers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class UserImageFormScreen extends ConsumerWidget {
  const UserImageFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Profile Images')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ImagePickerWidget(),
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: () {
                // ✅ Validate that an image is selected
                final images = ref.read(imagePickerProvider);
                if (images.primaryImage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a primary profile image'),
                    ),
                  );
                  return;
                }

                if (images.aadharPdfPath == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select Aadhar PDF')),
                  );
                  return;
                }

                context.router.push(UserBiodataCheckRoute(isAgreed: false));
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.all(9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 30),
                    Text("Review & Submit"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
