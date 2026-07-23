import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../app/custom/image_picker/image_picker_controller.dart';
import '../../../../../../app/custom/image_picker/image_picker_widget.dart';
import '../../../../../../app/router/app_router.dart';
import '../../../../../../core/constants/app_labels.dart';

@RoutePage()
class UserImageFormScreen extends ConsumerWidget {
  const UserImageFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          // 🔽 SCROLLABLE CONTENT
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 120),
            children: [
              Text(
                AppLabels.uploadProfileImages(context),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              ExpandableImagePickerList(),
            ],
          ),

          // // 🔒 FIXED BOTTOM BUTTON
          // Positioned(left: 0, right: 0, bottom: 0, child: _FixedBottomButton()),
        ],
      ),
    );
  }
}

class _FixedBottomButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: () {
            final images = ref.read(imagePickerProvider);

            if (images.primaryImage == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLabels.pleaseSelectPrimaryImage(context)),
                ),
              );
              return;
            }

            if (images.aadharPdfPath == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLabels.pleaseSelectAadharPdf(context)),
                ),
              );
              return;
            }

            context.router.push(UserBiodataCheckRoute(isAgreed: false));
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            AppLabels.continueButton(context),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
