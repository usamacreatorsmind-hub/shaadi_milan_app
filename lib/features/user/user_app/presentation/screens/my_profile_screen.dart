import 'package:shadi_milan/app/custom/custom_widgets/shimmer.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/custom/custom_widgets/chip_and_action_chip.dart'; 
import '../../../../../app/router/app_router.dart';
import '../../../../../core/enums/enum.dart';
import '../../../../auth/domain/states/agent_state.dart';
import '../../data/repositories_impl/agent_repository_impl.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import '../../domain/states/metrimony_profile_view_model.dart';
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
          // print agetn id
          print("This is agent id");
          print(user.agentId);

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
    final profileAsync = ref.watch(matrimonyProfileProvider(uid));
    print("inside my profile view");

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
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
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (profile) {
          print((" these all are details"));
          print(profile.toString());
          print(profile.user.toString());
          print("this is agent ");
          print(profile.agentEntity);

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
                  title: "Photos",
                  // actionChip: AppChip(
                  //   label: "Upload",
                  //   icon: Icons.upload,
                  //   onTap: () {
                  //     // AutoRouter.of(context).push(UserImageFormRoute());
                  //   },
                  // ),
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
                        : const Text("No additional photos available."),
                  ],
                ),

                const SizedBox(height: 14),

                // show aadhar widget with file name and a download url and a button to view the pdf
                _DetailSection(
                  title: "ID Cards",
                  // actionChip: AppChip(
                  //   label: "Download",
                  //   icon: Icons.download,
                  //   onTap: () {
                  //     // SHOW  snack bar
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(
                  //         content: Text("Download functionality coming soon!"),
                  //       ),
                  //     );
                  //   },
                  // ),
                  children: [
                    if (profile
                        .metrimonyProfile
                        .images
                        .aadharCardUrl
                        .isNotEmpty)
                      DetailRowWithAction(
                        label: "Aadhar Card",
                        value: "View PDF",
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => PdfViewerBottomsheet(
                              source:
                                  profile.metrimonyProfile.images.aadharCardUrl,
                              title: 'Aadhar PDF',
                              isLocal: false,
                            ),
                          );
                        },
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "Aadhar card not uploaded.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),

                // 📝 ABOUT ME
                _DetailSection(
                  title: "About Me",

                  // actionChip: AppChip(
                  //   label: "Edit",
                  //   icon: Icons.edit,
                  //   onTap: () => AutoRouter.of(context).push(
                  //     UserIdentityFormRoute(
                  //       mode: FormMode.edit,
                  //       existingIdentityProfile: profile.identity,
                  //     ),
                  //   ),
                  // ),
                  children: [
                    Text(
                      profile.identity.aboutMe ?? "No description available.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),

                // 📋 BASIC INFO
                _DetailSection(
                  title: "Basic Information",

                  // actionChip: AppChip(
                  //   label: "Edit",
                  //   icon: Icons.edit,

                  //   onTap: () => AutoRouter.of(context).push(
                  //     UserIdentityFormRoute(
                  //       mode: FormMode.edit,
                  //       existingIdentityProfile: profile.identity,
                  //     ),
                  //   ),
                  // ),
                  children: [
                    _DetailRow(
                      "Aadhar",
                      profile.identity.aadhar.toString() ?? 'N/A',

                      // SHOW  snack bar
                    ),

                    _DetailRow("Age", "${profile.identity.age ?? 'N/A'} years"),
                    _DetailRow("Gender", profile.identity.gender ?? 'N/A'),
                    _DetailRow(
                      "Date of Birth",
                      profile.identity.dob.toString().split(" ").first,
                    ),
                  ],
                ),

                // 🎓 EDUCATION
                _DetailSection(
                  title: "Education",

                  // actionChip: AppChip(
                  //   label: "Edit",
                  //   icon: Icons.edit,
                  //   onTap: () => AutoRouter.of(context).push(
                  //     UserEducationFormRoute(
                  //       mode: FormMode.edit,
                  //       existingEducationProfile: profile.education,
                  //     ),
                  //   ),
                  // ),
                  children: [
                    _DetailRow(
                      "Course",
                      profile.education.education?.course ?? "N/A",
                    ),
                    _DetailRow(
                      "College",
                      profile.education.education?.college ?? "N/A",
                    ),
                    _DetailRow(
                      "Passing Year",
                      profile.education.education?.passingYear.toString() ??
                          "N/A",
                    ),
                    _DetailRow(
                      "Percentage",
                      profile.education.education?.percentage.toString() ??
                          "N/A",
                    ),

                    // show extra qualification in chip  style
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
                    title: "Additional Qualifications",
                    // actionChip: AppChip(
                    //   label: "Edit",
                    //   icon: Icons.edit,
                    //   onTap: () => AutoRouter.of(context).push(
                    //     UserEducationFormRoute(
                    //       mode: FormMode.edit,
                    //       existingEducationProfile: profile.education,
                    //     ),
                    //   ),
                    // ),
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
                                label: Text(course),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),

                // employement
                _DetailSection(
                  title: "Employment",
                  // actionChip: AppChip(
                  //   label: "Edit",
                  //   icon: Icons.edit,
                  //   onTap: () => AutoRouter.of(context).push(
                  //     UserEmploymentFormRoute(
                  //       mode: FormMode.edit,
                  //       existingEmploymentProfile: profile.employment,
                  //     ),
                  //   ),
                  // ),
                  children: [
                    _DetailRow("Company", profile.employment.company ?? "N/A"),
                    _DetailRow(
                      "Income",
                      profile.employment.annualIncome.toString() ?? "N/A",
                    ),
                    _DetailRow("Job Type", profile.employment.jobType ?? "N/A"),
                    _DetailRow(
                      "Designation",
                      profile.employment.designation ?? "N/A",
                    ),
                  ],
                ),

                // 🏠 ADDRESS
                _DetailSection(
                  title: "Address",

                  // actionChip: AppChip(
                  //   label: "Edit",
                  //   onTap: () => AutoRouter.of(context).push(
                  //     UserAddressFormRoute(
                  //       mode: FormMode.edit,
                  //       existingAddressProfile: profile.address,
                  //     ),
                  //   ),
                  //   icon: Icons.edit,
                  // ),
                  children: [
                    _DetailRow("City", profile.address.city ?? "N/A"),
                    _DetailRow("State", profile.address.state ?? "N/A"),
                  ],
                ),

                // 👪 FAMILY
                _DetailSection(
                  title: "Family Details",

                  // actionChip: AppChip(
                  //   label: "Edit",
                  //   onTap: () => AutoRouter.of(context).push(
                  //     UserFamilyFormRoute(
                  //       mode: FormMode.edit,
                  //       existingFamilyProfile: profile.family,
                  //     ),
                  //   ),

                  //   icon: Icons.edit,
                  // ),
                  children: [
                    _DetailRow("Father", profile.family.fatherName ?? "N/A"),
                    _DetailRow("Mother", profile.family.motherName ?? "N/A"),
                    _DetailRow(
                      "Family Type",
                      profile.family.familyType ?? "N/A",
                    ),
                  ],
                ),

                //  physical details
                _DetailSection(
                  title: "Physical Details",
                  // actionChip: AppChip(
                  //   label: "Edit",
                  //   onTap: () => AutoRouter.of(context).push(
                  //     UserPhysicalFormRoute(
                  //       mode: FormMode.edit,
                  //       existingPhysicalProfile: profile.physical,
                  //     ),
                  //   ),
                  //   icon: Icons.edit,
                  // ),
                  children: [
                    _DetailRow("Height", "${profile.physical.height} cm"),
                    _DetailRow("Weight", "${profile.physical.weight} kg"),
                    _DetailRow("Body Type", profile.physical.bodyType ?? "N/A"),

                    _DetailRow(
                      "Complexion",
                      profile.physical.complexion ?? "N/A",
                    ),

                    _DetailRow(
                      "Disability",
                      profile.physical.physicallyChallenged ? "Yes" : "No ",
                    ),
                    if (profile.physical.physicallyChallenged)
                      _DetailRow(
                        "Details",
                        profile.physical.disabilityDetails ?? "N/A",
                      ),
                  ],
                ),

                // 🌟 RELIGIOUS & ASTROLOGICAL
                _DetailSection(
                  title: "Religious & Astrological",

                  // actionChip: AppChip(
                  //   label: "Edit",
                  //   icon: Icons.edit,
                  //   onTap: () => AutoRouter.of(context).push(
                  //     UserCultureFormRoute(
                  //       mode: FormMode.edit,
                  //       existingCulturalProfile: profile.cultural,
                  //     ),
                  //   ),
                  // ),
                  children: [
                    _DetailRow("Religion", profile.cultural.religion ?? "N/A"),
                    _DetailRow("Caste", profile.cultural.caste ?? "N/A"),
                    _DetailRow("Sub-caste", profile.cultural.subCaste ?? "N/A"),

                    _DetailRow(
                      "Languages",
                      profile.cultural.languages.join(", ") ?? "N/A",
                    ),
                  ],
                ),

                // // 🕵️ AGENT DETAILS
                // if (profile.agent != null) ...[
                //   const SizedBox(height: 24),
                //   _DetailSection(
                //     title: "Agent Details",
                //     actionChip: AppChip(
                //       label: "Contact",
                //       icon: Icons.call,
                //       onTap: () {},
                //     ),
                //     children: [
                //       _DetailRow("Name", profile.agent!.agentName),
                //       _DetailRow("Mobile", profile.agent!.agentMobile),
                //       _DetailRow("Email", profile.agent!.email),
                //       _DetailRow("Agent ID", profile.agent!.agentId),
                //     ],
                //   ),
                // ],

                // � PARTNER PREFERENCES
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
                                                .isNotEmpty
                                            ? widget
                                                  .profile
                                                  .userProfile
                                                  .fullName[0]
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
                                    child: Text(
                                      widget.profile.user.fullName ?? "N/A",
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
                                phone: widget.profile.user.phone ?? "N/A",
                                email: widget.profile.user.email ?? "N/A",
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
                          label: widget.profile.identity.gender ?? "N/A",
                          icon: Icons.person_outline,
                          theme: theme,
                        ),
                        _buildAttributeChip(
                          label: "${widget.profile.identity.age ?? 'N/A'} yrs",
                          icon: Icons.cake_outlined,
                          theme: theme,
                        ),
                        _buildAttributeChip(
                          label: widget.profile.employment.designation ?? "N/A",
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
    required String label,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withOpacity(0.08),
            theme.primaryColor.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
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

  Container _buildContactTile({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[100],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(child: Icon(icon, color: color)),
          Text(label),
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

  // final AppChip actionChip;

  const _DetailSection({
    required this.title,
    required this.children,
    // required this.actionChip,
  });

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

              //   adding chip or action chip
              const Spacer(),

              // actionChip,
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
  final String value;

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
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
