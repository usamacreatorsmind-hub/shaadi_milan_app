import '../../../../../app/custom/image_picker/image_picker_widget.dart';
import '../../../../../app/router/app_router.dart';
import '../controllers/image_picker_controller.dart';
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
        child: Column(
          children: [
            ImagePickerWidget(),
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: () async {
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

                final user = ref.read(authStateProvider).value;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User not found')),
                  );
                  return;
                }

                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Consumer(
                    builder: (context, ref, _) {
                      final progress = ref.watch(uploadProgressProvider);
                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Uploading Images..."),
                            const SizedBox(height: 20),
                            LinearProgressIndicator(value: progress),
                            const SizedBox(height: 10),
                            Text("${(progress * 100).toInt()}%"),
                          ],
                        ),
                      );
                    },
                  ),
                );

                try {
                  await ref
                      .read(imagePickerProvider.notifier)
                      .uploadImages(user.uid);

                  if (context.mounted) {
                    // Navigator.pop(context); // Pop loading
                    // context.router.push(const UserIdentityFormRoute());
                    // show snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Images uploaded successfully!'),
                      ),
                    );
                    // ref
                    //     .read(metrimonyControllerProvider.notifier)
                    //     .nextStep(); // Move to the next step
                    Navigator.pop(context); // Pop loading
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context); // Pop loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Upload failed: $e")),
                    );
                  }
                  debugPrint("Upload failed: $e");
                }
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

                    Text("Upload Images"),
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
