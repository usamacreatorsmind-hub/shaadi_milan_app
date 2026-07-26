import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../../../app/router/app_router.dart';
import '../../../../../../../core/constants/app_labels.dart';
import '../../../../../../app/custom/image_picker/image_picker_controller.dart';
import '../../../../../agent/agent_app/presentation/notifier/analytics_provider.dart';
import '../../../../../agent/agent_app/presentation/notifier/user_nofier.dart';
import '../../../../../auth/presentation/providers/auth_providers.dart';
import '../../../../../translitration/models/bilingual_value.dart';
import '../../../domain/states/image_state.dart';
import '../../../../../../app/providers/global_providers.dart';
import '../../../widgets/pdf_viewer_bottomsheet.dart';
import '../../controllers/metrimony_profile_controller.dart';

@RoutePage()
class UserBiodataCheckScreen extends ConsumerStatefulWidget {
  const UserBiodataCheckScreen({super.key, required bool isAgreed});

  @override
  ConsumerState<UserBiodataCheckScreen> createState() => _UserBiodataCheckScreenState();
}

class _UserBiodataCheckScreenState extends ConsumerState<UserBiodataCheckScreen> {
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
        title: Text(AppLabels.verifyYourProfile(context), style: Theme.of(context).textTheme.headlineMedium),
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
            _infoRow(AppLabels.selectDateOfBirth(context), DateFormat('dd MMM yyyy').format(profile.identity.dob)),
            _infoRow(AppLabels.ageYrs(context), AppLabels.ageYears(context, profile.identity.age)),
            _infoRow(AppLabels.aadharNumber(context), profile.identity.aadhar),
            _infoRow(AppLabels.aboutMe(context), profile.identity.aboutMe),
          ]),

          _section(AppLabels.physicalProfile(context), Icons.accessibility_new, [
            _infoRow(AppLabels.height(context), profile.physical.height),
            _infoRow(AppLabels.weightKg(context), profile.physical.weight),
            _infoRow(AppLabels.selectComplexion(context), profile.physical.complexion),
            _infoRow(AppLabels.selectBodyType(context), profile.physical.bodyType),
            if (profile.physical.physicallyChallenged) _infoRow(AppLabels.physicallyChallenged(context), AppLabels.success(context)),
            if (profile.physical.physicallyChallenged && profile.physical.disabilityDetails != null)
              _infoRow(AppLabels.details(context), profile.physical.disabilityDetails),
          ]),

          _section(AppLabels.religionAndCaste(context), Icons.temple_hindu, [
            _infoRow(AppLabels.religion(context), profile.cultural.religion),
            _infoRow(AppLabels.caste(context), profile.cultural.caste),
            _infoRow(AppLabels.subCasteLabel(context), profile.cultural.subCaste),
            // _infoRow('Mother Tongue', profile.cultural.motherTongue),
            _chipWrap(AppLabels.languagesKnown(context), profile.cultural.languages.map((l) => isHindi ? l.hi : l.en).toList()),
          ]),

          _section(AppLabels.education(context), Icons.school, [
            _infoRow(AppLabels.collegeUniversity(context), profile.education.education?.college),
            _infoRow(AppLabels.degreeCourse(context), profile.education.education?.course),
            _infoRow(AppLabels.percentageCGPA(context), profile.education.education?.percentage),
            _infoRow(AppLabels.passingYear(context), profile.education.education?.passingYear),

            // add additional courses
            // Languages

            // Additional Courses (Firebase)
            _chipWrap(
              AppLabels.additionalQualifications(context),
              (profile.education.extraQualification?.qualifications ?? []).map((q) => isHindi ? q.hi : q.en).toList(),
            ),
          ]),

          _section(AppLabels.employmentDetails(context), Icons.work, [
            _infoRow(AppLabels.organization(context), profile.employment.company),
            _infoRow(AppLabels.role(context), profile.employment.designation),
            _infoRow(AppLabels.annualIncome(context), profile.employment.annualIncome),
            _infoRow(AppLabels.designation(context), profile.employment.designation),
            _infoRow(AppLabels.jobType(context), profile.employment.jobType),
          ]),

          _section(AppLabels.familyDetails(context), Icons.family_restroom, [
            _infoRow(AppLabels.fatherName(context), profile.family.fatherName),
            _infoRow(AppLabels.motherName(context), profile.family.motherName),
            _infoRow(AppLabels.numberOfBrothers(context), profile.family.numberOfBrothers),
            _infoRow(AppLabels.numberOfSisters(context), profile.family.numberOfSisters),
            _infoRow(AppLabels.familyType(context), profile.family.familyType),
            _infoRow(AppLabels.lifeStyleStatus(context), profile.family.familyStatus),
          ]),

          _section(AppLabels.location(context), Icons.location_on, [
            _infoRow(AppLabels.location(context), profile.address.addressLine1),
            _infoRow(AppLabels.post(context), profile.address.post),
            _infoRow(AppLabels.city(context), profile.address.city),
            _infoRow(AppLabels.state(context), profile.address.state),
            _infoRow(AppLabels.pinCodeLabel(context), profile.address.pincode),
          ]),

          _imageSection(profile.images, imageState),

          if (imageState.aadharPdfPath != null && imageState.aadharPdfPath!.isNotEmpty)
            _section(AppLabels.aadharDocument(context), Icons.document_scanner, [
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
                          const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
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
                      child: Image.file(File(imageState.aadharPdfPath!), height: 200, width: double.infinity, fit: BoxFit.cover),
                    ),
            ]),

          if (imageState.bioDataPath != null && imageState.bioDataPath!.isNotEmpty)
            _section(AppLabels.uploadBioData(context), Icons.description, [
              imageState.bioDataPath!.toLowerCase().endsWith('.pdf')
                  ? GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) =>
                              PdfViewerBottomsheet(source: imageState.bioDataPath!, title: AppLabels.uploadBioData(context), isLocal: true),
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
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
                      child: Image.file(File(imageState.bioDataPath!), height: 200, width: double.infinity, fit: BoxFit.cover),
                    ),
            ]),

          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isAgreed,
                  onChanged: (v) => setState(() => isAgreed = v ?? false),
                  title: Text(AppLabels.confirmDetailsCorrect(context), style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isAgreed ? _confirmSubmit : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(AppLabels.finalSubmit(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
    if (value == null) return const SizedBox();

    final isHindi = Localizations.localeOf(context).languageCode == 'hi';
    String displayValue = '';

    if (value is BilingualValue) {
      displayValue = isHindi ? value.hi : value.en;
    } else {
      displayValue = value.toString().trim();
    }

    if (displayValue.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ),
          Expanded(
            flex: 6,
            child: Text(displayValue, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values.map((e) => Chip(label: Text(e), backgroundColor: Theme.of(context).primaryColor.withOpacity(0.08))).toList(),
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
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.orange.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageSection(ProfileImages? images, ImagesState localImages) {
    // Check for local images (just picked)
    final hasLocalProfile = localImages.profileImage != null && localImages.profileImage!.isNotEmpty;
    final hasLocalPrimary = localImages.primaryImage != null && localImages.primaryImage!.isNotEmpty;
    final hasLocalAgent = localImages.imageWithAgentUrl != null && localImages.imageWithAgentUrl!.isNotEmpty;
    final hasLocalSecondary = localImages.secondaryImages.isNotEmpty;

    // Check for network images (already uploaded)
    final hasNetProfile = images?.profileImageUrl != null && images!.profileImageUrl.isNotEmpty;
    final hasNetPrimary = images?.primaryImageUrl != null && images!.primaryImageUrl.isNotEmpty;
    final hasNetAgent = images?.imageWithAgentUrl != null && images!.imageWithAgentUrl.isNotEmpty;
    final netSecondary = images?.secondaryImageUrls.where((url) => url.isNotEmpty).toList() ?? [];
    final hasNetSecondary = netSecondary.isNotEmpty;

    if (!hasLocalProfile && !hasLocalPrimary && !hasLocalAgent && !hasLocalSecondary &&
        !hasNetProfile && !hasNetPrimary && !hasNetAgent && !hasNetSecondary) {
      return const SizedBox();
    }

    return _section(AppLabels.photos(context), Icons.photo_library, [
      // 1. Profile Image
      if (hasLocalProfile || hasNetProfile) ...[
        _infoRow(AppLabels.profileImage(context), ""),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: hasLocalProfile
              ? Image.file(File(localImages.profileImage!), height: 200, width: double.infinity, fit: BoxFit.cover)
              : Image.network(images!.profileImageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
      ],

      // 2. Matrimony Image
      if (hasLocalPrimary || hasNetPrimary) ...[
        _infoRow(AppLabels.matrimonyImage(context), ""),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: hasLocalPrimary
              ? Image.file(File(localImages.primaryImage!), height: 200, width: double.infinity, fit: BoxFit.cover)
              : Image.network(images!.primaryImageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
      ],

      // 3. Image with Agent
      if (hasLocalAgent || hasNetAgent) ...[
        _infoRow(AppLabels.imageWithAgent(context), ""),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: hasLocalAgent
              ? Image.file(File(localImages.imageWithAgentUrl!), height: 200, width: double.infinity, fit: BoxFit.cover)
              : Image.network(images!.imageWithAgentUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
      ],

      // 4. Gallery Images
      if (hasLocalSecondary || hasNetSecondary) ...[
        _infoRow(AppLabels.galleryImages(context), ""),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hasLocalSecondary ? localImages.secondaryImages.length : netSecondary.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: hasLocalSecondary
                    ? Image.file(File(localImages.secondaryImages[i]), width: 100, fit: BoxFit.cover)
                    : Image.network(netSecondary[i], width: 100, fit: BoxFit.cover),
              );
            },
          ),
        ),
      ],
    ]);
  }

  // ================= SUBMIT =================

  Future<void> _confirmSubmit() async {
    final targetUid = ref.read(targetUserIdProvider);
    final authState = ref.read(authStateProvider);

    if (targetUid == null) return;

    String agentId = "";
    authState.whenData((user) {
      if (user != null) {
        agentId = user.fold((a) => a.uid, (u) => u.agentId);
      }
    });

    final imageState = ref.read(imagePickerProvider);
    
    // Check if any local file needs uploading
    final hasFilesToUpload = imageState.profileImage != null ||
        imageState.primaryImage != null ||
        imageState.imageWithAgentUrl != null ||
        imageState.secondaryImages.isNotEmpty ||
        imageState.aadharPdfPath != null ||
        imageState.bioDataPath != null;

    // Show Progress Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final progress = ref.watch(uploadProgressProvider);
          return AlertDialog(
            title: Text(hasFilesToUpload ? AppLabels.uploadingImages(context) : "Saving Profile..."),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasFilesToUpload) ...[
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 12),
                  Text("${(progress * 100).toInt()}%"),
                ] else
                  const CircularProgressIndicator(),
              ],
            ),
          );
        },
      ),
    );

    try {
      // 1. Upload Images if exist
      if (hasFilesToUpload) {
        await ref.read(imagePickerProvider.notifier).uploadImages(context, targetUid);
      }

      // 2. Final Submit to Firestore
      await ref.read(metrimonyControllerProvider.notifier).submitProfile(uid: targetUid, agentId: agentId);

      if (mounted) {
        Navigator.pop(context); // Close dialog
        
        final isAgent = ref.read(authStateProvider).value?.isLeft() ?? false;
        if (isAgent) {
          // Agent led registration finished
          ref.read(targetUserIdOverrideProvider.notifier).state = null; // Clear override
          
          // Refresh agent's dashboard data immediately
          ref.invalidate(agentUsersNotifierProvider);
          ref.invalidate(usersPaymentsNotifierProvider);
          ref.invalidate(analyticsProvider(agentId));
          
          // Trigger fetch so it's ready when we arrive at dashboard
          ref.read(agentUsersNotifierProvider.notifier).getUsersForAgent();
          ref.read(usersPaymentsNotifierProvider.notifier).getUsersPayment(agentId: agentId);
          
          context.router.replaceAll([AgentMainShellRoute(agentId: agentId)]);
        } else {
          context.router.replaceAll([UserMainShellRoute()]);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
