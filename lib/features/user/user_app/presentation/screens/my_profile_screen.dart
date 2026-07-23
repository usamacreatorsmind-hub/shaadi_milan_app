import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/app/custom/custom_widgets/shimmer.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';

import '../../../../../app/router/app_router.dart';
import '../../../../auth/domain/states/agent_state.dart';
import '../../../../translitration/models/bilingual_value.dart';
import '../../data/repositories_impl/agent_repository_impl.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import '../../domain/states/metrimony_profile_view_model.dart';
import '../../domain/states/state_city.dart';
import '../../widgets/pdf_viewer_bottomsheet.dart';

final matrimonyProfileProvider =
    StreamProvider.family<MetrimonyProfileViewModel, String>((ref, uid) {
      final matrimonyRepo = ref.watch(matrimonyRepositoryProvider);
      final userRepo = ref.watch(userRepositoryProvider);
      final agentRepo = ref.watch(agentRepositoryProvider);

      return matrimonyRepo.watchMatrimonyProfile(uid).asyncMap((
        matrimonyProfile,
      ) async {
        final user = await userRepo.fetchUser(matrimonyProfile.userId);

        final AgentEntity agent;

        if (user.agentId.isNotEmpty) {
          agent = await agentRepo.fetchAgent(user.agentId);
        } else {
          agent = AgentEntity.empty();
        }

        return MetrimonyProfileViewModel(
          metrimonyProfile: matrimonyProfile,
          userProfile: user,
          agentEntity: agent,
        );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => AutoRouter.of(context).maybePop(),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(AppLabels.error(context, e.toString()))),
        data: (profile) {
          BilingualValue resolvedState = profile.address.state;
          BilingualValue resolvedCity = profile.address.city;
          BilingualValue resolvedReligion = profile.cultural.religion;
          BilingualValue resolvedCaste = profile.cultural.caste;

          if (locationAsync.hasValue) {
            final states = locationAsync.value!;
            final stateObj = states
                .where((s) => s.name == profile.address.state.en)
                .firstOrNull;
            if (stateObj != null) {
              resolvedState = BilingualValue(
                en: stateObj.name,
                hi: stateObj.name,
              );
              final cityObj = stateObj.cities
                  .where(
                    (c) =>
                        c.id == profile.address.city.en ||
                        c.name == profile.address.city.en,
                  )
                  .firstOrNull;
              if (cityObj != null) {
                resolvedCity = BilingualValue(
                  en: cityObj.name,
                  hi: cityObj.name,
                );
              }
            }
          }

          final isHindi = Localizations.localeOf(context).languageCode == 'hi';

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                const SizedBox(height: 46),

                // 👤 TOP CARD
                _ProfileHeroCard(profile: profile),

                const SizedBox(height: 24),

                // build Image card that display all images of user
                _DetailSection(
                  title: AppLabels.photos(context),
                  children: [
                    profile.images.secondaryImageUrls.isNotEmpty
                        ? SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  profile.images.secondaryImageUrls.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => showPhotoDialogBox(
                                    photoUrl: profile
                                        .images
                                        .secondaryImageUrls[index],
                                    context: context,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        profile
                                            .images
                                            .secondaryImageUrls[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child; // image loaded
                                              }
                                              return ShimmerProfileCard(
                                                width: 100,
                                                height: 100,
                                              );
                                            },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey,
                                                ),
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
                  children: [
                    if (profile
                        .metrimonyProfile
                        .images
                        .aadharCardUrl
                        .isNotEmpty)
                      DetailRowWithAction(
                        label: AppLabels.aadharCard(context),
                        value: AppLabels.viewDocument(context),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => PdfViewerBottomsheet(
                              source:
                                  profile.metrimonyProfile.images.aadharCardUrl,
                              title: AppLabels.aadharCard(context),
                              isLocal: false,
                            ),
                          );
                        },
                      ),
                    if (profile
                        .metrimonyProfile
                        .images
                        .bioDataUrl
                        .isNotEmpty)
                      DetailRowWithAction(
                        label: AppLabels.bioData(context),
                        value: AppLabels.viewDocument(context),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => PdfViewerBottomsheet(
                              source:
                                  profile.metrimonyProfile.images.bioDataUrl,
                              title: AppLabels.bioData(context),
                              isLocal: false,
                            ),
                          );
                        },
                      ),
                    if (profile
                            .metrimonyProfile
                            .images
                            .aadharCardUrl
                            .isEmpty &&
                        profile
                            .metrimonyProfile
                            .images
                            .bioDataUrl
                            .isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          AppLabels.aadharCardNotUploaded(context),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),

                // 📝 ABOUT ME
                _DetailSection(
                  title: AppLabels.aboutMe(context),
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
                  children: [
                    _DetailRow(
                      AppLabels.aadharNumber(context),
                      profile.identity.aadhar,
                    ),
                    _DetailRow(
                      AppLabels.age(context),
                      AppLabels.ageYearsOld(context, profile.identity.age),
                    ),
                    _DetailRow(
                      AppLabels.gender(context),
                      profile.identity.gender,
                    ),
                    _DetailRow(
                      AppLabels.dateOfBirth(context),
                      profile.identity.dob.toString().split(" ").first,
                    ),
                  ],
                ),

                // 🎓 EDUCATION
                _DetailSection(
                  title: AppLabels.education(context),
                  children: [
                    _DetailRow(
                      AppLabels.course(context),
                      profile.education.education?.course,
                    ),
                    _DetailRow(
                      AppLabels.collegeUniversity(context),
                      profile.education.education?.college,
                    ),
                    _DetailRow(
                      AppLabels.passingYear(context),
                      profile.education.education?.passingYear.toString(),
                    ),
                    _DetailRow(
                      AppLabels.percentageCGPA(context),
                      profile.education.education?.percentage.toString(),
                    ),
                  ],
                ),

                // dettail sectionfor  additional qualification
                if (profile
                        .education
                        .extraQualification
                        ?.qualifications
                        .isNotEmpty ??
                    false)
                  _DetailSection(
                    title: AppLabels.additionalQualifications(context),
                    children: [
                      Wrap(
                        spacing: 10.0,
                        runSpacing: 4.0,
                        children: profile
                            .education
                            .extraQualification!
                            .qualifications
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
                  children: [
                    _DetailRow(
                      AppLabels.organization(context),
                      profile.employment.company,
                    ),
                    _DetailRow(
                      AppLabels.annualIncome(context),
                      profile.employment.annualIncome?.toString(),
                    ),
                    _DetailRow(
                      AppLabels.jobType(context),
                      profile.employment.jobType,
                    ),
                    _DetailRow(
                      AppLabels.designation(context),
                      profile.employment.designation,
                    ),
                  ],
                ),

                // 🏠 ADDRESS
                _DetailSection(
                  title: AppLabels.address(context),
                  children: [
                    _DetailRow(AppLabels.city(context), resolvedCity),
                    _DetailRow(AppLabels.state(context), resolvedState),
                  ],
                ),

                // 👪 FAMILY
                _DetailSection(
                  title: AppLabels.familyDetails(context),
                  children: [
                    _DetailRow(
                      AppLabels.fatherName(context),
                      profile.family.fatherName,
                    ),
                    _DetailRow(
                      AppLabels.motherName(context),
                      profile.family.motherName,
                    ),
                    _DetailRow(
                      AppLabels.familyType(context),
                      profile.family.familyType,
                    ),
                  ],
                ),

                //  physical details
                _DetailSection(
                  title: AppLabels.physicalDetails(context),
                  children: [
                    _DetailRow(
                      AppLabels.height(context),
                      _formatHeight(profile.physical.height.round()),
                    ),
                    _DetailRow(
                      AppLabels.weightKg(context),
                      "${profile.physical.weight.round()} kg",
                    ),
                    _DetailRow(
                      AppLabels.selectBodyType(context),
                      profile.physical.bodyType,
                    ),
                    _DetailRow(
                      AppLabels.selectComplexion(context),
                      profile.physical.complexion,
                    ),
                    _DetailRow(
                      AppLabels.physicallyChallenged(context),
                      profile.physical.physicallyChallenged
                          ? AppLabels.yesLabel(context)
                          : AppLabels.noLabel(context),
                    ),
                    if (profile.physical.physicallyChallenged)
                      _DetailRow(
                        AppLabels.disabilityDetails(context),
                        profile.physical.disabilityDetails,
                      ),
                  ],
                ),

                //  RELIGIOUS & ASTROLOGICAL
                _DetailSection(
                  title: AppLabels.religiousAndAstrological(context),
                  children: [
                    _DetailRow(AppLabels.religion(context), resolvedReligion),
                    _DetailRow(AppLabels.caste(context), resolvedCaste),
                    _DetailRow(
                      AppLabels.subCasteLabel(context),
                      profile.cultural.subCaste,
                    ),
                    _DetailRow(
                      AppLabels.addKnownLanguages(context),
                      profile.cultural.languages
                          .map((l) => isHindi ? l.hi : l.en)
                          .join(", "),
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

  void showPhotoDialogBox({
    required BuildContext context,
    required String photoUrl,
  }) {
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
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 50,
                      ),
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

  const DetailRowWithAction({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

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
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeroCard extends StatefulWidget {
  final MetrimonyProfileViewModel profile;
  const _ProfileHeroCard({required this.profile});

  @override
  State<_ProfileHeroCard> createState() => _ProfileHeroCardState();
}

class _ProfileHeroCardState extends State<_ProfileHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _elevationAnimation;

  bool get hasImage => widget.profile.userProfile.profileImageUrl.isNotEmpty;
  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_hoverController);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: GestureDetector(
        onTap: () => AutoRouter.of(
          context,
        ).push(MyProfileDetailRoute(user: widget.profile.user)),
        child: AnimatedBuilder(
          animation: _elevationAnimation,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(
                      0.15 + 0.1 * _elevationAnimation.value,
                    ),
                    blurRadius: 20 + 10 * _elevationAnimation.value,
                    offset: Offset(0, 10 + 5 * _elevationAnimation.value),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.canvasColor,

                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // ✨ Profile Header Section
                    Row(
                      children: [
                        // Profile Image with Badge
                        GestureDetector(
                          onTap: () => showPhotoDialogBox(
                            photoUrl:
                                widget.profile.userProfile.profileImageUrl,
                            context: context,
                          ),
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 55,
                                backgroundColor: theme.primaryColor.withOpacity(
                                  0.1,
                                ),
                                backgroundImage: hasImage
                                    ? NetworkImage(
                                        widget
                                            .profile
                                            .userProfile
                                            .profileImageUrl,
                                      )
                                    : null,
                                child: !hasImage
                                    ? Text(
                                        widget
                                                .profile
                                                .userProfile
                                                .fullName
                                                .en
                                                .isNotEmpty
                                            ? widget
                                                  .profile
                                                  .userProfile
                                                  .fullName
                                                  .en[0]
                                                  .toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
                                        ),
                                      )
                                    : null,
                              ),
                              // Online/Status Badge
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green.shade400,
                                    border: Border.all(
                                      color: theme.canvasColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name with Verified Badge
                              Row(
                                children: [
                                  Expanded(
                                    child: BilingualParser(
                                      value: widget.profile.user.fullName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: theme.primaryColor,
                                            fontSize: 24,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // Contact Info - Compact
                              _buildCompactContactInfo(
                                phone: widget.profile.user.phone.isEmpty
                                    ? AppLabels.notAvailableShort(context)
                                    : widget.profile.user.phone,
                                email: widget.profile.user.email.isEmpty
                                    ? AppLabels.notAvailableShort(context)
                                    : widget.profile.user.email,
                                theme: theme,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    // ✨ Stats & Attributes Chips
                    Wrap(
                      runSpacing: 10,
                      spacing: 10,
                      children: [
                        _buildAttributeChip(
                          label: widget.profile.identity.gender,
                          icon: Icons.person_outline,
                          theme: theme,
                        ),
                        _buildAttributeChip(
                          label: AppLabels.ageYearsOld(
                            context,
                            widget.profile.identity.age,
                          ),
                          icon: Icons.cake_outlined,
                          theme: theme,
                        ),
                        _buildAttributeChip(
                          label: widget.profile.employment.designation,
                          icon: Icons.work_outline,
                          theme: theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompactContactInfo({
    required String phone,
    required String email,
    required ThemeData theme,
  }) {
    final fontSize = 12.0;
    const maxChars = 20;

    String truncate(String text) {
      return text.length > maxChars
          ? '${text.substring(0, maxChars)}...'
          : text;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.phone_outlined,
              size: 14,
              color: theme.primaryColor.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                truncate(phone),
                style: TextStyle(fontSize: fontSize, color: Colors.grey[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.email_outlined,
              size: 14,
              color: theme.primaryColor.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                truncate(email),
                style: TextStyle(fontSize: fontSize, color: Colors.grey[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttributeChip({
    required dynamic label,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withValues(alpha: 0.08),
            theme.primaryColor.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.primaryColor),
          const SizedBox(width: 6),
          label is BilingualValue
              ? BilingualParser(
                  value: label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.primaryColor,
                  ),
                )
              : Text(
                  label.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.primaryColor,
                  ),
                ),
        ],
      ),
    );
  }

  void showPhotoDialogBox({
    required String photoUrl,
    required BuildContext context,
  }) {
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

  const _DetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
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
                  (value == null || value.toString().isEmpty)
                      ? AppLabels.notAvailableShort(context)
                      : value.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
        ],
      ),
    );
  }
}
