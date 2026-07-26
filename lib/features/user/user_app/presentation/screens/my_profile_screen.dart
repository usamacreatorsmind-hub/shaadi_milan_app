import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/app/custom/custom_widgets/shimmer.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';

import '../../../../../app/router/app_router.dart';
import '../../../../../core/enums/enum.dart';
import '../../../../auth/domain/states/agent_state.dart';
import '../../../../translitration/models/bilingual_value.dart';
import '../../data/repositories_impl/agent_repository_impl.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import '../../domain/states/metrimony_profile_view_model.dart';
import '../../domain/states/state_city.dart';
import '../../widgets/pdf_viewer_bottomsheet.dart';

final matrimonyProfileProvider = StreamProvider.family<MetrimonyProfileViewModel, String>((ref, uid) {
  final matrimonyRepo = ref.watch(matrimonyRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  final agentRepo = ref.watch(agentRepositoryProvider);

  return matrimonyRepo.watchMatrimonyProfile(uid).asyncMap((matrimonyProfile) async {
    final user = await userRepo.fetchUser(matrimonyProfile.userId);

    final AgentEntity agent;

    if (user.agentId.isNotEmpty) {
      agent = await agentRepo.fetchAgent(user.agentId);
    } else {
      agent = AgentEntity.empty();
    }

    return MetrimonyProfileViewModel(metrimonyProfile: matrimonyProfile, userProfile: user, agentEntity: agent);
  });
});

@RoutePage()
class MyProfileScreen extends ConsumerWidget {
  final String uid;
  const MyProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationJsonProvider);
    final profileAsync = ref.watch(matrimonyProfileProvider(uid));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLabels.myProfile(context)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => AutoRouter.of(context).maybePop()),
      ),
      backgroundColor: Colors.grey[100],
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(AppLabels.error(context, e.toString()))),
        data: (profile) {
          BilingualValue resolvedState = profile.address.state;
          BilingualValue resolvedCity = profile.address.city;
          BilingualValue resolvedReligion = profile.cultural.religion;
          BilingualValue resolvedCaste = profile.cultural.caste;

          if (locationAsync.hasValue) {
            final states = locationAsync.value!;
            final stateObj = states.where((s) => s.name == profile.address.state.en).firstOrNull;
            if (stateObj != null) {
              resolvedState = BilingualValue(en: stateObj.name, hi: stateObj.name);
              final cityObj = stateObj.cities
                  .where((c) => c.id == profile.address.city.en || c.name == profile.address.city.en)
                  .firstOrNull;
              if (cityObj != null) {
                resolvedCity = BilingualValue(en: cityObj.name, hi: cityObj.name);
              }
            }
          }

          final isHindi = Localizations.localeOf(context).languageCode == 'hi';

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                _ProfileHeroCard(profile: profile),
                _DetailSection(
                  title: AppLabels.photos(context),
                  actionChip: _EditChip(onTap: () => context.router.push(const UserImageFormRoute())),
                  children: [
                    profile.images.secondaryImageUrls.isNotEmpty
                        ? SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: profile.images.secondaryImageUrls.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => showPhotoDialogBox(photoUrl: profile.images.secondaryImageUrls[index], context: context),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        profile.images.secondaryImageUrls[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child; // image loaded
                                          }
                                          return ShimmerProfileCard(width: 100, height: 100);
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                                            child: const Icon(Icons.broken_image, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Text(AppLabels.noPhotosAvailable(context)),
                  ],
                ),

                const SizedBox(height: 14),

                // show aadhar widget with file name and a download url and a button to view the pdf
                _DetailSection(
                  title: AppLabels.idCards(context),
                  actionChip: _EditChip(onTap: () => context.router.push(const UserImageFormRoute())),
                  children: [
                    if (profile.metrimonyProfile.images.aadharCardUrl.isNotEmpty)
                      DetailRowWithAction(
                        label: AppLabels.aadharCard(context),
                        value: AppLabels.viewDocument(context),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => PdfViewerBottomsheet(
                              source: profile.metrimonyProfile.images.aadharCardUrl,
                              title: AppLabels.aadharCard(context),
                              isLocal: false,
                            ),
                          );
                        },
                      ),
                    if (profile.metrimonyProfile.images.bioDataUrl.isNotEmpty)
                      DetailRowWithAction(
                        label: AppLabels.bioData(context),
                        value: AppLabels.viewDocument(context),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => PdfViewerBottomsheet(
                              source: profile.metrimonyProfile.images.bioDataUrl,
                              title: AppLabels.bioData(context),
                              isLocal: false,
                            ),
                          );
                        },
                      ),
                    if (profile.metrimonyProfile.images.aadharCardUrl.isEmpty && profile.metrimonyProfile.images.bioDataUrl.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(AppLabels.aadharCardNotUploaded(context), style: const TextStyle(color: Colors.grey)),
                      ),
                  ],
                ),

                // 📝 ABOUT ME
                _DetailSection(
                  title: AppLabels.aboutMe(context),
                  actionChip: _EditChip(
                    onTap: () => context.router.push(UserIdentityFormRoute(mode: FormMode.edit, existingIdentityProfile: profile.identity)),
                  ),
                  children: [
                    if (profile.identity.aboutMe.isNotEmpty)
                      BilingualParser(
                        value: profile.identity.aboutMe,
                        textAlign: TextAlign.justify,
                        style: TextStyle(color: Colors.grey[700]),
                      )
                    else
                      Text(
                        AppLabels.noDescriptionAvailable(context),
                        textAlign: TextAlign.justify,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                  ],
                ),

                // 📋 BASIC INFO
                _DetailSection(
                  title: AppLabels.basicInformation(context),
                  actionChip: _EditChip(
                    onTap: () => context.router.push(UserIdentityFormRoute(mode: FormMode.edit, existingIdentityProfile: profile.identity)),
                  ),
                  children: [
                    _DetailRow(AppLabels.aadharNumber(context), profile.identity.aadhar),
                    _DetailRow(AppLabels.age(context), AppLabels.ageYearsOld(context, profile.identity.age)),
                    _DetailRow(AppLabels.gender(context), profile.identity.gender),
                    _DetailRow(AppLabels.dateOfBirth(context), profile.identity.dob.toString().split(" ").first),
                  ],
                ),

                // 🎓 EDUCATION
                _DetailSection(
                  title: AppLabels.education(context),
                  actionChip: _EditChip(
                    onTap: () =>
                        context.router.push(UserEducationFormRoute(mode: FormMode.edit, existingEducationProfile: profile.education)),
                  ),
                  children: [
                    _DetailRow(AppLabels.course(context), profile.education.education?.course),
                    _DetailRow(AppLabels.collegeUniversity(context), profile.education.education?.college),
                    _DetailRow(AppLabels.passingYear(context), profile.education.education?.passingYear.toString()),
                    _DetailRow(AppLabels.percentageCGPA(context), profile.education.education?.percentage.toString()),
                  ],
                ),

                // dettail sectionfor  additional qualification
                if (profile.education.extraQualification?.qualifications.isNotEmpty ?? false)
                  _DetailSection(
                    title: AppLabels.additionalQualifications(context),
                    actionChip: _EditChip(
                      onTap: () =>
                          context.router.push(UserEducationFormRoute(mode: FormMode.edit, existingEducationProfile: profile.education)),
                    ),
                    children: [
                      Wrap(
                        spacing: 10.0,
                        runSpacing: 4.0,
                        children: profile.education.extraQualification!.qualifications
                            .map(
                              (course) => Chip(
                                backgroundColor: Theme.of(context).canvasColor,
                                label: BilingualParser(value: course),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),

                // employement
                _DetailSection(
                  title: AppLabels.employmentDetails(context),
                  actionChip: _EditChip(
                    onTap: () =>
                        context.router.push(UserEmploymentFormRoute(mode: FormMode.edit, existingEmploymentProfile: profile.employment)),
                  ),
                  children: [
                    _DetailRow(AppLabels.organization(context), profile.employment.company),
                    _DetailRow(AppLabels.annualIncome(context), profile.employment.annualIncome?.toString()),
                    _DetailRow(AppLabels.jobType(context), profile.employment.jobType),
                    _DetailRow(AppLabels.designation(context), profile.employment.designation),
                  ],
                ),

                // 🏠 ADDRESS
                _DetailSection(
                  title: AppLabels.address(context),
                  actionChip: _EditChip(
                    onTap: () => context.router.push(UserAddressFormRoute(mode: FormMode.edit, existingAddressProfile: profile.address)),
                  ),
                  children: [_DetailRow(AppLabels.city(context), resolvedCity), _DetailRow(AppLabels.state(context), resolvedState)],
                ),

                // 👪 FAMILY
                _DetailSection(
                  title: AppLabels.familyDetails(context),
                  actionChip: _EditChip(
                    onTap: () => context.router.push(UserFamilyFormRoute(mode: FormMode.edit, existingFamilyProfile: profile.family)),
                  ),
                  children: [
                    _DetailRow(AppLabels.fatherName(context), profile.family.fatherName),
                    _DetailRow(AppLabels.motherName(context), profile.family.motherName),
                    _DetailRow(AppLabels.familyType(context), profile.family.familyType),
                  ],
                ),

                //  physical details
                _DetailSection(
                  title: AppLabels.physicalDetails(context),
                  actionChip: _EditChip(
                    onTap: () => context.router.push(UserPhysicalFormRoute(mode: FormMode.edit, existingPhysicalProfile: profile.physical)),
                  ),
                  children: [
                    _DetailRow(AppLabels.height(context), _formatHeight(profile.physical.height.round())),
                    _DetailRow(AppLabels.weightKg(context), "${profile.physical.weight.round()} kg"),
                    _DetailRow(AppLabels.selectBodyType(context), profile.physical.bodyType),
                    _DetailRow(AppLabels.selectComplexion(context), profile.physical.complexion),
                    _DetailRow(
                      AppLabels.physicallyChallenged(context),
                      profile.physical.physicallyChallenged ? AppLabels.yesLabel(context) : AppLabels.noLabel(context),
                    ),
                    if (profile.physical.physicallyChallenged)
                      _DetailRow(AppLabels.disabilityDetails(context), profile.physical.disabilityDetails),
                  ],
                ),

                //  RELIGIOUS & ASTROLOGICAL
                _DetailSection(
                  title: AppLabels.religiousAndAstrological(context),
                  actionChip: _EditChip(
                    onTap: () => context.router.push(UserCultureFormRoute(mode: FormMode.edit, existingCulturalProfile: profile.cultural)),
                  ),
                  children: [
                    _DetailRow(AppLabels.religion(context), resolvedReligion),
                    _DetailRow(AppLabels.caste(context), resolvedCaste),
                    _DetailRow(AppLabels.subCasteLabel(context), profile.cultural.subCaste),
                    _DetailRow(
                      AppLabels.addKnownLanguages(context),
                      profile.cultural.languages.map((l) => isHindi ? l.hi : l.en).join(", "),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void showPhotoDialogBox({required BuildContext context, required String photoUrl}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => PhotoPreviewDialog(photoUrl: photoUrl),
    );
  }

  String _formatHeight(int cm) {
    final totalInches = (cm / 2.54).round();
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return '$cm cm ($feet\'$inches")';
  }
}

class PhotoPreviewDialog extends StatelessWidget {
  final String photoUrl;

  const PhotoPreviewDialog({super.key, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return ShimmerProfileCard(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.7,
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.7,
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                    );
                  },
                ),
              ),
            ),
          ),

          // ⬇️ Centered Close Button
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailRowWithAction extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const DetailRowWithAction({super.key, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          InkWell(
            onTap: onTap,
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  final MetrimonyProfileViewModel profile;
  const _ProfileHeroCard({required this.profile});

  bool get hasImage => profile.userProfile.profileImageUrl.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: primaryColor.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Decorative background element
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor.withOpacity(0.05)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image
                      GestureDetector(
                        onTap: () => showPhotoDialogBox(photoUrl: profile.userProfile.profileImageUrl, context: context),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: primaryColor.withOpacity(0.1),
                            backgroundImage: hasImage ? NetworkImage(profile.userProfile.profileImageUrl) : null,
                            child: !hasImage
                                ? Text(
                                    profile.userProfile.fullName.en.isNotEmpty ? profile.userProfile.fullName.en[0].toUpperCase() : '?',
                                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: primaryColor),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // User Basic Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: BilingualParser(
                                    value: profile.user.fullName,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      letterSpacing: -0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.verified, color: Colors.blue.shade400, size: 20),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoItem(
                              icon: Icons.phone_android_rounded,
                              text: profile.user.phone.isEmpty ? AppLabels.notAvailableShort(context) : profile.user.phone,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 6),
                            _buildInfoItem(
                              icon: Icons.alternate_email_rounded,
                              text: profile.user.email.isEmpty ? AppLabels.notAvailableShort(context) : profile.user.email,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  // Attributes Wrap
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPill(
                        label: profile.identity.gender,
                        icon: Icons.person_search_rounded,
                        backgroundColor: Colors.blue.shade50,
                        textColor: Colors.blue.shade700,
                      ),
                      _buildPill(
                        label: AppLabels.ageYearsOld(context, profile.identity.age),
                        icon: Icons.calendar_today_rounded,
                        backgroundColor: Colors.orange.shade50,
                        textColor: Colors.orange.shade700,
                      ),
                      _buildPill(
                        label: profile.employment.designation,
                        icon: Icons.work_history_rounded,
                        backgroundColor: Colors.purple.shade50,
                        textColor: Colors.purple.shade700,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text, required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPill({required dynamic label, required IconData icon, required Color backgroundColor, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(100)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          label is BilingualValue
              ? BilingualParser(
                  value: label,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                )
              : Text(
                  label.toString(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                ),
        ],
      ),
    );
  }

  void showPhotoDialogBox({required String photoUrl, required BuildContext context}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => PhotoPreviewDialog(photoUrl: photoUrl),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? actionChip;

  const _DetailSection({required this.title, required this.children, this.actionChip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (actionChip != null) actionChip!,
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _EditChip extends StatelessWidget {
  final VoidCallback onTap;
  const _EditChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, size: 14, color: theme.primaryColor),
            const SizedBox(width: 4),
            Text(
              "Edit",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final dynamic value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          value is BilingualValue
              ? BilingualParser(value: value as BilingualValue)
              : Text(
                  (value == null || value.toString().isEmpty) ? AppLabels.notAvailableShort(context) : value.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
        ],
      ),
    );
  }
}
