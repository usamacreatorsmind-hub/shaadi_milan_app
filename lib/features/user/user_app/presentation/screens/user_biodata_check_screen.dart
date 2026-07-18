import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/constants/app_labels.dart';
import '../../../../../app/custom/image_picker/image_picker_controller.dart';
import '../../../../../app/router/app_router.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/states/image_state.dart';
import '../../widgets/pdf_viewer_bottomsheet.dart';
import '../controllers/metrimony_profile_controller.dart';

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
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';

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
          AppLabels.verifyYourProfile(context),

          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _warningCard(),

          _section(AppLabels.details(context), Icons.person, [
            _infoRow(AppLabels.fullName(context), currentUser?.fullName),
            _infoRow(AppLabels.phone(context), currentUser?.phone),
            _infoRow(AppLabels.email(context), currentUser?.email),
          ]),

          _section(AppLabels.saveIdentity(context), Icons.badge, [
            _infoRow(AppLabels.gender(context), profile.identity.gender),
            _infoRow(
              AppLabels.selectDateOfBirth(context),
              DateFormat('dd MMM yyyy').format(profile.identity.dob),
            ),
            _infoRow(
              AppLabels.ageYrs(context),
              AppLabels.ageYears(context, profile.identity.age),
            ),
            _infoRow(AppLabels.aadharNumber(context), profile.identity.aadhar),
            _infoRow(
              AppLabels.aboutMe(context),
              isHindi
                  ? profile.identity.aboutMe.hi
                  : profile.identity.aboutMe.en,
            ),
          ]),

          _section(
            AppLabels.physicalProfile(context),
            Icons.accessibility_new,
            [
              _infoRow(AppLabels.height(context), profile.physical.height),
              _infoRow(AppLabels.weightKg(context), profile.physical.weight),
              _infoRow(
                AppLabels.selectComplexion(context),
                profile.physical.complexion,
              ),
              _infoRow(
                AppLabels.selectBodyType(context),
                profile.physical.bodyType,
              ),
              if (profile.physical.physicallyChallenged)
                _infoRow(
                  AppLabels.physicallyChallenged(context),
                  AppLabels.success(context),
                ),
              if (profile.physical.physicallyChallenged &&
                  profile.physical.disabilityDetails != null)
                _infoRow(
                  AppLabels.details(context),
                  profile.physical.disabilityDetails,
                ),
            ],
          ),

          _section(AppLabels.religionAndCaste(context), Icons.temple_hindu, [
            _infoRow(AppLabels.religion(context), profile.cultural.religion),
            _infoRow(AppLabels.caste(context), profile.cultural.caste),
            _infoRow(
              AppLabels.subCasteLabel(context),
              isHindi
                  ? profile.cultural.subCaste.hi
                  : profile.cultural.subCaste.en,
            ),
            // _infoRow('Mother Tongue', profile.cultural.motherTongue),
            _chipWrap(
              AppLabels.languagesKnown(context),
              profile.cultural.languages
                  .map((l) => isHindi ? l.hi : l.en)
                  .toList(),
            ),
          ]),

          _section(AppLabels.education(context), Icons.school, [
            _infoRow(
              AppLabels.collegeUniversity(context),
              isHindi
                  ? profile.education.education?.college.hi
                  : profile.education.education?.college.en,
            ),
            _infoRow(
              AppLabels.degreeCourse(context),
              isHindi
                  ? profile.education.education?.course.hi
                  : profile.education.education?.course.en,
            ),
            _infoRow(
              AppLabels.percentageCGPA(context),
              profile.education.education?.percentage,
            ),
            _infoRow(
              AppLabels.passingYear(context),
              profile.education.education?.passingYear,
            ),

            // add additional courses
            // Languages

            // Additional Courses (Firebase)
            _chipWrap(
              AppLabels.additionalQualifications(context),
              (profile.education.extraQualification?.qualifications ?? [])
                  .map((q) => isHindi ? q.hi : q.en)
                  .toList(),
            ),
          ]),

          _section(AppLabels.employmentDetails(context), Icons.work, [
            _infoRow(
              AppLabels.organization(context),
              isHindi
                  ? profile.employment.company?.hi
                  : profile.employment.company?.en,
            ),
            _infoRow(
              AppLabels.role(context),
              isHindi
                  ? profile.employment.designation?.hi
                  : profile.employment.designation?.en,
            ),
            _infoRow(
              AppLabels.annualIncome(context),
              profile.employment.annualIncome,
            ),
            _infoRow(
              AppLabels.designation(context),
              isHindi
                  ? profile.employment.designation?.hi
                  : profile.employment.designation?.en,
            ),
            _infoRow(AppLabels.jobType(context), profile.employment.jobType),
          ]),

          _section(AppLabels.familyDetails(context), Icons.family_restroom, [
            _infoRow(AppLabels.fatherName(context), profile.family.fatherName),
            _infoRow(AppLabels.motherName(context), profile.family.motherName),
            _infoRow(
              AppLabels.numberOfBrothers(context),
              profile.family.numberOfBrothers,
            ),
            _infoRow(
              AppLabels.numberOfSisters(context),
              profile.family.numberOfSisters,
            ),
            _infoRow(AppLabels.familyType(context), profile.family.familyType),
            _infoRow(
              AppLabels.lifeStyleStatus(context),
              profile.family.familyStatus,
            ),
          ]),

          _section(AppLabels.location(context), Icons.location_on, [
            _infoRow(
              AppLabels.location(context),
              isHindi
                  ? profile.address.addressLine1.hi
                  : profile.address.addressLine1.en,
            ),
            _infoRow(
              AppLabels.post(context),
              isHindi ? profile.address.post.hi : profile.address.post.en,
            ),
            _infoRow(AppLabels.city(context), profile.address.city),
            _infoRow(AppLabels.state(context), profile.address.state),
            _infoRow(AppLabels.pinCodeLabel(context), profile.address.pincode),
          ]),

          _imageSection(profile.images, imageState),

          if (imageState.aadharPdfPath != null &&
              imageState.aadharPdfPath!.isNotEmpty)
            _section(
              AppLabels.aadharDocument(context),
              Icons.document_scanner,
              [
                imageState.aadharPdfPath!.toLowerCase().endsWith('.pdf')
                    ? GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => PdfViewerBottomsheet(
                              source: imageState.aadharPdfPath!,
                              title: AppLabels.aadharDocument(context),
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
                              AppLabels.document(context),
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
              ],
            ),

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
                  title: Text(
                    AppLabels.confirmDetailsCorrect(context),
                    style: const TextStyle(fontWeight: FontWeight.w600),
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
                  child: Text(
                    AppLabels.finalSubmit(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
              AppLabels.verifyCarefullyWarning(context),
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

    return _section(AppLabels.profileImage(context), Icons.photo, [
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
                  Text(AppLabels.uploadingImages(context)),
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
            .uploadImages(context, user.uid);
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
      context.router.replaceAll([UserMainShellRoute()]);
    }
  }
}
