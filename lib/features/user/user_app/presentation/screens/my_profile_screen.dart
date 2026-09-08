import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shadi_milan/app/custom/custom_widgets/shimmer.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';
import '../../../../../app/router/app_router.dart';
import '../../../../../core/enums/enum.dart';
import '../../../../auth/domain/states/agent_state.dart';
import '../../../../translitration/models/bilingual_value.dart';
import '../../../user_razorpay/domain/states/payment.dart';
import '../../../user_razorpay/presentation/notifier/payment_notifier.dart';
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
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _ProfileHeroCard(profile: profile),
                const SizedBox(height: 8),
                _DetailSection(
                  title: AppLabels.photos(context),
                  actionChip: _EditChip(onTap: () => context.router.push(const UserImageFormRoute())),
                  children: [
                    profile.images.secondaryImageUrls.isNotEmpty
                        ? SizedBox(
                            height: 110,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: profile.images.secondaryImageUrls.length,
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => showPhotoDialogBox(photoUrl: profile.images.secondaryImageUrls[index], context: context),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        profile.images.secondaryImageUrls[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return ShimmerProfileCard(width: 100, height: 100);
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey.shade100,
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
                        : Container(
                            width: double.infinity,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(AppLabels.noPhotosAvailable(context), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                              ],
                            ),
                          ),
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.badge_outlined, color: Colors.grey.shade400, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              AppLabels.aadharCardNotUploaded(context),
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
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
                    _DetailRow(AppLabels.annualIncome(context), profile.employment.annualIncome),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
              child: Text(
                value,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).primaryColor),
              ),
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
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.12), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(top: -40, right: -40, child: CircleAvatar(radius: 80, backgroundColor: primaryColor.withOpacity(0.05))),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Image
                      GestureDetector(
                        onTap: () => showPhotoDialogBox(photoUrl: profile.userProfile.profileImageUrl, context: context),
                        child: Hero(
                          tag: 'profile_image',
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [primaryColor.withOpacity(0.5), primaryColor.withOpacity(0.1)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 43,
                                backgroundColor: primaryColor.withOpacity(0.1),
                                backgroundImage: hasImage ? NetworkImage(profile.userProfile.profileImageUrl) : null,
                                child: !hasImage
                                    ? Text(
                                        profile.userProfile.fullName.en.isNotEmpty ? profile.userProfile.fullName.en[0].toUpperCase() : '?',
                                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // User Basic Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: BilingualParser(
                                    value: profile.user.fullName,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                      letterSpacing: -0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.verified, color: Colors.blue.shade500, size: 18),
                              ],
                            ),
                            const SizedBox(height: 6),
                            _buildInfoItem(
                              icon: Icons.phone_iphone_rounded,
                              text: profile.user.phone.isEmpty ? AppLabels.notAvailableShort(context) : profile.user.phone,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(height: 4),
                            _buildInfoItem(
                              icon: Icons.email_outlined,
                              text: profile.user.email.isEmpty ? AppLabels.notAvailableShort(context) : profile.user.email,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(height: 10),
                            // Matrimony ID
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: profile.metrimonyProfile.metrimonyId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text("ID Copied"),
                                    behavior: SnackBarBehavior.floating,
                                    width: 150,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        profile.metrimonyProfile.metrimonyId.isEmpty ? "NO-ID" : profile.metrimonyProfile.metrimonyId,
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade800),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(Icons.copy_all_rounded, size: 14, color: primaryColor),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Subscription Card
                  Consumer(
                    builder: (context, ref, _) {
                      final paymentState = ref.watch(paymentNotifierProvider(profile.userProfile.uid));
                      final isPremium = paymentState.status == PayStatus.success;

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isPremium
                                ? [const Color(0xFF1E88E5), const Color(0xFF1565C0)]
                                : [Colors.grey.shade100, Colors.grey.shade200],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isPremium ? Colors.white.withOpacity(0.2) : Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPremium ? Icons.auto_awesome_rounded : Icons.person_outline_rounded,
                                color: isPremium ? Colors.white : Colors.grey.shade600,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isPremium ? "Platinum Plus" : "Free Member",
                                    style: TextStyle(
                                      color: isPremium ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    isPremium
                                        ? "Valid till ${DateFormat('d MMM, yyyy').format(paymentState.payment!.createdAt.add(const Duration(days: 365)))}"
                                        : "Upgrade for benefits",
                                    style: TextStyle(color: isPremium ? Colors.white70 : Colors.grey.shade600, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                  const SizedBox(height: 16),
                  // Attributes
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildPill(
                        label: profile.identity.gender,
                        icon: Icons.face_rounded,
                        backgroundColor: const Color(0xFFFFF4F4),
                        textColor: const Color(0xFFD32F2F),
                      ),
                      _buildPill(
                        label: AppLabels.ageYearsOld(context, profile.identity.age),
                        icon: Icons.cake_rounded,
                        backgroundColor: const Color(0xFFF4F9FF),
                        textColor: const Color(0xFF1976D2),
                      ),
                      _buildPill(
                        label: profile.employment.designation,
                        icon: Icons.business_center_rounded,
                        backgroundColor: const Color(0xFFF4FFF6),
                        textColor: const Color(0xFF388E3C),
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
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.1), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          label is BilingualValue
              ? BilingualParser(
                  value: label,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
                )
              : Text(
                  label.toString(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
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
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: -0.5),
              ),
              if (actionChip != null) actionChip!,
            ],
          ),
          const SizedBox(height: 16),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_note_rounded, size: 18, color: theme.primaryColor),
              const SizedBox(width: 4),
              Text(
                "Edit",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: theme.primaryColor),
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: value is BilingualValue
                ? BilingualParser(
                    value: value as BilingualValue,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black87),
                  )
                : Text(
                    (value == null || value.toString().isEmpty) ? AppLabels.notAvailableShort(context) : value.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black87),
                    textAlign: TextAlign.end,
                  ),
          ),
        ],
      ),
    );
  }
}
