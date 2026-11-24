import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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
import '../../../data/repositories_impl/user_repo_impl.dart';
import '../user_details_screen.dart';
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
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 8),
              Center(
                child: Text(
                  AppLabels.verifyYourProfile(context),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 20),
              _warningCard(),

              // ... rest of ListView remains same ...
              _section(AppLabels.details(context), Icons.person_outline, [
                _infoRow(AppLabels.fullName(context), currentUser?.fullName),
                _infoRow(AppLabels.phone(context), currentUser?.phone),
                _infoRow(AppLabels.email(context), currentUser?.email),
              ]),

              _section(AppLabels.saveIdentity(context), Icons.badge_outlined, [
                _infoRow("First Name", profile.identity.firstName),
                _infoRow("Last Name", profile.identity.lastName),
                _infoRow("Birthplace", profile.identity.birthplace),
                _infoRow("Marital Status", profile.identity.maritalStatus),
                _infoRow(AppLabels.gender(context), profile.identity.gender),
                _infoRow(AppLabels.selectDateOfBirth(context), DateFormat('dd MMM yyyy').format(profile.identity.dob)),
                _infoRow(AppLabels.ageYrs(context), AppLabels.ageYears(context, profile.identity.age)),
              ]),

              _section(AppLabels.physicalProfile(context), Icons.accessibility_new_rounded, [
                _infoRow(AppLabels.height(context), profile.physical.height),
                _infoRow(AppLabels.weightKg(context), profile.physical.weight),
                _infoRow(AppLabels.selectComplexion(context), profile.physical.complexion),
                _infoRow(AppLabels.selectBodyType(context), profile.physical.bodyType),
                if (profile.physical.physicallyChallenged) _infoRow(AppLabels.physicallyChallenged(context), AppLabels.success(context)),
                if (profile.physical.physicallyChallenged && profile.physical.disabilityDetails != null)
                  _infoRow(AppLabels.details(context), profile.physical.disabilityDetails),
              ]),

              _section(AppLabels.religionAndCaste(context), Icons.temple_hindu_outlined, [
                _infoRow(AppLabels.religion(context), profile.cultural.religion),
                _infoRow(AppLabels.caste(context), profile.cultural.caste),
                _chipWrap(AppLabels.languagesKnown(context), profile.cultural.languages.map((l) => isHindi ? l.hi : l.en).toList()),
              ]),

              _section(AppLabels.education(context), Icons.school_outlined, [
                _infoRow(AppLabels.collegeUniversity(context), profile.education.education?.college),
                _infoRow(AppLabels.degreeCourse(context), profile.education.education?.course),
                _chipWrap(
                  AppLabels.additionalQualifications(context),
                  (profile.education.extraQualification?.qualifications ?? []).map((q) => isHindi ? q.hi : q.en).toList(),
                ),
              ]),

              _section(AppLabels.employmentDetails(context), Icons.work_outline_rounded, [
                _infoRow(AppLabels.jobType(context), profile.employment.jobType),
                if (profile.employment.jobType.en != 'Not Working') ...[
                  _infoRow(AppLabels.organization(context), profile.employment.company),
                  _infoRow(AppLabels.designation(context), profile.employment.designation),
                  _infoRow(AppLabels.annualIncome(context), profile.employment.annualIncome),
                  _infoRow(AppLabels.workLocation(context), profile.employment.workLocation),
                ],
              ]),

              _section(AppLabels.familyDetails(context), Icons.family_restroom_outlined, [
                _infoRow(AppLabels.fatherName(context), profile.family.fatherName),
                if (profile.family.fatherOccupation != null && !profile.family.fatherOccupation!.isEmpty)
                  _infoRow("Father's Occupation", profile.family.fatherOccupation!),
                _infoRow(AppLabels.motherName(context), profile.family.motherName),
                if (profile.family.motherOccupation != null && !profile.family.motherOccupation!.isEmpty)
                  _infoRow("Mother's Occupation", profile.family.motherOccupation!),
                _infoRow(AppLabels.numberOfBrothers(context), profile.family.numberOfBrothers),
                _infoRow(AppLabels.numberOfSisters(context), profile.family.numberOfSisters),
                _infoRow(AppLabels.familyType(context), profile.family.familyType),
                _infoRow(AppLabels.lifeStyleStatus(context), profile.family.familyStatus),
              ]),

              _section(AppLabels.location(context), Icons.location_on_outlined, [
                _infoRow(AppLabels.location(context), profile.address.addressLine1),
                _infoRow(AppLabels.city(context), profile.address.city),
                _infoRow(AppLabels.state(context), profile.address.state),
                _infoRow(AppLabels.pinCodeLabel(context), profile.address.pincode),
              ]),

              _imageSection(profile.images, imageState),
              const SizedBox(height: 20),
            ],
          ),
        ),
        // 🔒 FIXED BOTTOM BAR
        // 🔒 COMPACT BOTTOM BAR
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            border: Border(top: BorderSide(color: Colors.grey.shade100)),
          ),
          child: SafeArea(
            top: false,
            bottom: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🏁 Agreement Section
                GestureDetector(
                  onTap: () => setState(() => isAgreed = !isAgreed),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: isAgreed ? Theme.of(context).primaryColor : Colors.transparent,
                            border: Border.all(color: isAgreed ? Theme.of(context).primaryColor : Colors.grey.shade400, width: 1.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: isAgreed ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            AppLabels.confirmDetailsCorrect(context),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 🚀 Button Row
                Row(
                  children: [
                    // ⬅ BACK BUTTON
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(metrimonyControllerProvider.notifier).previousStep();
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(color: Colors.grey.shade300),
                          foregroundColor: Colors.black87,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(AppLabels.back(context), style: const TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ➡ SUBMIT BUTTON
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isAgreed ? _confirmSubmit : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: Text(
                          AppLabels.finalSubmit(context).toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= UI HELPERS =================
  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(children: children),
          ),
        ],
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

    if (displayValue.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Text(
              displayValue,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
              textAlign: TextAlign.right,
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
    // Check for network images (already uploaded)
    final hasNetProfile = images?.profileImageUrl != null && images!.profileImageUrl.isNotEmpty;

    if (!hasLocalProfile && !hasNetProfile) return const SizedBox();

    return _section(AppLabels.photos(context), Icons.photo_library_outlined, [
      Center(
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2), width: 4),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: ClipOval(
            child: hasLocalProfile
                ? Image.file(File(localImages.profileImage!), fit: BoxFit.cover)
                : CachedNetworkImage(
                    imageUrl: images!.profileImageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 320,
                    memCacheHeight: 320,
                    maxWidthDiskCache: 600,
                    maxHeightDiskCache: 600,
                    placeholder: (_, __) => Container(color: Colors.grey.shade200),
                    errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Center(
        child: Text(
          AppLabels.profileImage(context),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
        ),
      ),
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
    final hasFilesToUpload =
        imageState.profileImage != null ||
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
          // Refresh auth & current user providers so isProfileCreated=true
          // takes effect immediately (unlocking details & Chat/Call gates).
          ref.invalidate(authStateProvider);
          ref.invalidate(currentUserProvider);
          ref.invalidate(currentUserMatrimonyProfileProvider);
          context.router.replaceAll([UserMainShellRoute()]);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission failed: $e'), backgroundColor: Colors.red));
      }
    }
  }
}
