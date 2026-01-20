import 'dart:io';

import '../../../../auth/domain/states/user_state.dart';
import '../../widgets/pdf_viewer_bottomsheet.dart';

import '../../../../../app/custom/image_picker/image_picker_controller.dart';
import '../../../../../app/router/app_router.dart';
import '../../domain/states/image_state.dart';
import '../controllers/metrimony_profile_controller.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

@RoutePage()
class UserBiodataCheckScreen extends ConsumerStatefulWidget {
  const UserBiodataCheckScreen({super.key, required bool isAgreed});

  @override
  ConsumerState<UserBiodataCheckScreen> createState() =>
      _UserBiodataCheckScreenState();
}

class _UserBiodataCheckScreenState
    extends ConsumerState<UserBiodataCheckScreen> {
  bool isAgreed = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(metrimonyControllerProvider);
    final profile = state.metrimony;
    final authState = ref.watch(authStateProvider);
    final eitherUser = authState.value;
    final currentUser = eitherUser?.fold((l) => null, (r) => r);
    final imageState = ref.watch(imagePickerProvider);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Verify Your Profile',

          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _warningCard(),

          _section('User Details', Icons.person, [
            _infoRow('Full Name', currentUser?.fullName),
            _infoRow('Phone', currentUser?.phone),
          ]),

          _section('Identity', Icons.badge, [
            _infoRow('Gender', profile.identity.gender),
            _infoRow(
              'Date of Birth',
              DateFormat('dd MMM yyyy').format(profile.identity.dob),
            ),
            _infoRow('Age', '${profile.identity.age} Years'),
            _infoRow('Aadhar', profile.identity.aadhar),
            _infoRow('About me ', profile.identity.aboutMe),
          ]),

          _section('Physical', Icons.accessibility_new, [
            _infoRow('Height', profile.physical.height),
            _infoRow('Weight', profile.physical.weight),
            _infoRow('Complexion', profile.physical.complexion),
            _infoRow('Body Type', profile.physical.bodyType),
            if (profile.physical.physicallyChallenged)
              _infoRow('Disability', "Yes"),
            if (profile.physical.physicallyChallenged &&
                profile.physical.disabilityDetails != null)
              _infoRow('Details', profile.physical.disabilityDetails),
          ]),

          _section('Cultural', Icons.temple_hindu, [
            _infoRow('Religion', profile.cultural.religion),
            _infoRow('Caste', profile.cultural.caste),
            _infoRow('Sub Caste', profile.cultural.subCaste),
            // _infoRow('Mother Tongue', profile.cultural.motherTongue),
            _chipWrap('Languages Known', profile.cultural.languages),
          ]),

          _section('Education', Icons.school, [
            _infoRow('College', profile.education.education?.college),
            _infoRow('course', profile.education.education?.course),
            _infoRow('Percentage ', profile.education.education?.percentage),
            _infoRow('Passing Year', profile.education.education?.passingYear),

            // add additional courses
            // Languages

            // Additional Courses (Firebase)
            _chipWrap(
              'Additional Courses',
              profile.education.extraQualification?.qualifications ?? [],
            ),
          ]),

          _section('Employment', Icons.work, [
            _infoRow('Company', profile.employment.company),
            _infoRow('Role', profile.employment.designation),
            _infoRow('Annual Income', profile.employment.annualIncome),
            _infoRow('Designation', profile.employment.designation),
            _infoRow('Job Type', profile.employment.jobType),
          ]),

          _section('Family', Icons.family_restroom, [
            _infoRow('Father Name', profile.family.fatherName),
            _infoRow('Mother Name', profile.family.motherName),
            _infoRow('Brothers', profile.family.numberOfBrothers),
            _infoRow('Sisters', profile.family.numberOfSisters),
            _infoRow('Family Type', profile.family.familyType),
            _infoRow('Family Status', profile.family.familyStatus),
          ]),

          _section('Address', Icons.location_on, [
            _infoRow('Address', profile.address.addressLine1),
            _infoRow('Post', profile.address.post),
            _infoRow('City', profile.address.city),
            _infoRow('State', profile.address.state),
            _infoRow('Pincode', profile.address.pincode),
          ]),

          _imageSection(profile.images, imageState),

          if (imageState.aadharPdfPath != null &&
              imageState.aadharPdfPath!.isNotEmpty)
            _section('Aadhar Document', Icons.document_scanner, [
              imageState.aadharPdfPath!.toLowerCase().endsWith('.pdf')
                  ? GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => PdfViewerBottomsheet(
                            source: imageState.aadharPdfPath!,
                            title: 'Aadhar PDF',
                            isLocal: true,
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'View Aadhar PDF',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              decoration: TextDecoration.underline,
                              decorationColor: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(imageState.aadharPdfPath!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
            ]),

          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isAgreed,
                  onChanged: (v) => setState(() => isAgreed = v ?? false),
                  title: const Text(
                    'I confirm all details are correct',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isAgreed ? _confirmSubmit : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'FINAL SUBMIT',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================
  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipWrap(String label, List<String>? values) {
    if (values == null || values.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values
                .map(
                  (e) => Chip(
                    label: Text(e),
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.08),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _warningCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Please verify carefully. Once submitted, profile cannot be edited.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageSection(ProfileImages? images, ImagesState localImages) {
    final hasLocalPrimary = localImages.primaryImage != null;
    final hasLocalSecondary = localImages.secondaryImages.isNotEmpty;

    if (images == null && !hasLocalPrimary) return const SizedBox();

    return _section('Profile Images', Icons.photo, [
      if (hasLocalPrimary)
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(localImages.primaryImage!),
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        )
      else if (images?.primaryImageUrl != null)
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            images!.primaryImageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

      if (hasLocalSecondary ||
          (images?.secondaryImageUrls.isNotEmpty ?? false)) ...[
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hasLocalSecondary
                ? localImages.secondaryImages.length
                : (images?.secondaryImageUrls.length ?? 0),
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              if (hasLocalSecondary) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(localImages.secondaryImages[i]),
                    width: 90,
                    fit: BoxFit.cover,
                  ),
                );
              }
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  images!.secondaryImageUrls[i],
                  width: 90,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
      ],
    ]);
  }

  // ================= SUBMIT =================

  Future<void> _confirmSubmit() async {
    final authState = ref.read(authStateProvider);
    final eitherUser = authState.value;

    if (eitherUser == null) return;

    final user = eitherUser.fold((l) => null, (r) => r);

    if (user == null) return;

    // 1. Upload Images if local images exist
    final imageState = ref.read(imagePickerProvider);
    if (imageState.primaryImage != null) {
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
        await ref.read(imagePickerProvider.notifier).uploadImages(user.uid);
        if (context.mounted) Navigator.pop(context); // Close dialog
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Close dialog
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
        }
        return;
      }
    }

    await ref
        .read(metrimonyControllerProvider.notifier)
        .submitProfile(uid: user.uid, agentId: user.agentId);
if (context.mounted) {
      context.router.replaceAll([const UserMainShellRoute()]);
    }
  }
}
