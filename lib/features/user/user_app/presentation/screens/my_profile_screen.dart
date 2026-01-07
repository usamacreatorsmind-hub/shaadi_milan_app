import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/agent_repository_impl.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/user_repo_impl.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/agent_state.dart';
import 'package:arvika_marriage_bureau/core/enums/enum.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_profile_view_model.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/widgets/pdf_viewer_bottomsheet.dart';
import 'package:auto_route/auto_route.dart';

import '../../../../../app/app.dart';
import '../../../../../app/custom/custom_widgets/chip_and_action_chip.dart';
import '../../../../../app/custom/shimmer.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/states/metrimony_state.dart';
import '../../domain/states/user_state.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final matrimonyProfileProvider =
    StreamProvider.family<MetrimonyProfileViewModel, String>((ref, uid) {
      final matrimonyRepo = ref.watch(matrimonyRepositoryProvider);
      final userRepo = ref.watch(userRepositoryProvider);
      final agentRepo = ref.watch(agentRepositoryProvider);

      return matrimonyRepo.watchMatrimonyProfile(uid).asyncMap((
        matrimonyProfile,
      ) async {
        final user = await userRepo.fetchUser(matrimonyProfile.userId);

        final AgentProfile agent;

        if (matrimonyProfile.agentId.isNotEmpty) {
          // print agetn id
          print("This is agent id");
          print(matrimonyProfile.agentId);

          agent = await agentRepo.fetchAgent(matrimonyProfile.agentId);
        } else {
          agent = AgentProfile(
            agentId: '',
            agentName: '',
            agentMobile: '',
            email: '',
            registrationDate: DateTime.now(),
            role: '',
            photoUrl: '',
            address: '',
            agentAadharUrl: '',
            uid: '',
          );
        }

        return MetrimonyProfileViewModel(
          metrimonyProfile: matrimonyProfile,
          userProfile: user,
          agentProfile: agent,
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
      backgroundColor: Colors.grey[100],

      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (profile) {
          print((" these all are details"));
          print(profile.toString());
          print(profile.user.toString());
          print("this is agent ");
          print(profile.agentProfile);

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
                  actionChip: AppChip(
                    label: "Upload",
                    icon: Icons.upload,
                    onTap: () {},
                  ),
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
                  actionChip: AppChip(
                    label: "Download",
                    icon: Icons.download,
                    onTap: () {
                      // SHOW  snack bar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Download functionality coming soon!"),
                        ),
                      );
                    },
                  ),
                  children: [
                    if (profile.metrimonyProfile.images.aadharCardUrl != null &&
                        profile
                            .metrimonyProfile
                            .images
                            .aadharCardUrl!
                            .isNotEmpty)
                      _DetailRowWithAction(
                        label: "Aadhar Card",
                        value: "View PDF",
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => PdfViewerBottomsheet(
                              pdfUrl: profile
                                  .metrimonyProfile
                                  .images
                                  .aadharCardUrl!,
                              title: "Aadhar Card",
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
                  actionChip: AppChip(
                    label: "Edit",
                    icon: Icons.edit,
                    onTap: () {},
                  ),
                  children: [
                    Text(
                      "No description available.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),

                // 📋 BASIC INFO
                _DetailSection(
                  title: "Basic Information",

                  actionChip: AppChip(
                    label: "Edit",
                    icon: Icons.edit,

                    onTap: () => AutoRouter.of(context).push(
                      UserIdentityFormRoute(
                        mode: FormMode.edit,
                        existingIdentityProfile: profile.identity,
                      ),
                    ),
                  ),

                  children: [
                    _DetailRow(
                      "Aadhar",
                      profile.identity?.aadhar.toString() ?? 'N/A',

                      // SHOW  snack bar
                    ),

                    _DetailRow(
                      "Age",
                      "${profile.identity?.age ?? 'N/A'} years",
                    ),
                    _DetailRow("Gender", profile.identity?.gender ?? 'N/A'),
                    _DetailRow(
                      "Date of Birth",
                      profile.identity?.dob != null
                          ? profile.identity!.dob.toString().split(" ").first
                          : 'N/A',
                    ),
                  ],
                ),

                // 🎓 EDUCATION
                _DetailSection(
                  title: "Education",
                  actionChip: AppChip(
                    label: "Edit",
                    icon: Icons.edit,
                    onTap: () => AutoRouter.of(context).push(
                      UserEducationFormRoute(
                        mode: FormMode.edit,
                        existingEducationProfile: profile.education,
                      ),
                    ),
                  ),

                  children: [
                    _DetailRow(
                      "Course",
                      profile.education?.education?.course ?? "N/A",
                    ),
                    _DetailRow(
                      "College",
                      profile.education?.education?.college ?? "N/A",
                    ),
                    _DetailRow(
                      "Passing Year",
                      profile.education?.education?.passingYear?.toString() ??
                          "N/A",
                    ),
                    _DetailRow(
                      "Percentage",
                      profile.education?.education?.percentage?.toString() ??
                          "N/A",
                    ),

                    // show extra qualification in chip  style
                  ],
                ),

                // dettail sectionfor  additional qualification
                if (profile
                        .education
                        ?.extraQualification
                        ?.qualifications
                        .isNotEmpty ??
                    false)
                  _DetailSection(
                    title: "Additional Qualifications",
                    actionChip: AppChip(
                      label: "Edit",
                      icon: Icons.edit,
                      onTap: () => AutoRouter.of(context).push(
                        UserEducationFormRoute(
                          mode: FormMode.edit,
                          existingEducationProfile: profile.education,
                        ),
                      ),
                    ),
                    children: [
                      Wrap(
                        spacing: 10.0,
                        runSpacing: 4.0,
                        children: profile
                            .education!
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
                  actionChip: AppChip(
                    label: "Edit",
                    icon: Icons.edit,
                    onTap: () => AutoRouter.of(context).push(
                      UserEmploymentFormRoute(
                        mode: FormMode.edit,
                        existingEmploymentProfile: profile.employment,
                      ),
                    ),
                  ),
                  children: [
                    _DetailRow("Company", profile.employment?.company ?? "N/A"),
                    _DetailRow(
                      "Income",
                      profile.employment?.annualIncome?.toString() ?? "N/A",
                    ),
                    _DetailRow(
                      "Job Type",
                      profile.employment?.jobType ?? "N/A",
                    ),
                    _DetailRow(
                      "Designation",
                      profile.employment?.designation ?? "N/A",
                    ),
                  ],
                ),

                // 🏠 ADDRESS
                _DetailSection(
                  title: "Address",
                  actionChip: AppChip(
                    label: "Edit",
                    onTap: () => AutoRouter.of(context).push(
                      UserAddressFormRoute(
                        mode: FormMode.edit,
                        existingAddressProfile: profile.address,
                      ),
                    ),
                    icon: Icons.edit,
                  ),

                  children: [
                    _DetailRow("City", profile.address?.city ?? "N/A"),
                    _DetailRow("State", profile.address?.state ?? "N/A"),
                  ],
                ),

                // 👪 FAMILY
                _DetailSection(
                  title: "Family Details",
                  actionChip: AppChip(
                    label: "Edit",
                    onTap: () => AutoRouter.of(context).push(
                      UserFamilyFormRoute(
                        mode: FormMode.edit,
                        existingFamilyProfile: profile.family,
                      ),
                    ),

                    icon: Icons.edit,
                  ),

                  children: [
                    _DetailRow("Father", profile.family?.fatherName ?? "N/A"),
                    _DetailRow("Mother", profile.family?.motherName ?? "N/A"),
                    _DetailRow(
                      "Family Type",
                      profile.family?.familyType ?? "N/A",
                    ),
                  ],
                ),

                //  physical details
                _DetailSection(
                  title: "Physical Details",
                  actionChip: AppChip(
                    label: "Edit",
                    onTap: () => AutoRouter.of(context).push(
                      UserPhysicalFormRoute(
                        mode: FormMode.edit,
                        existingPhysicalProfile: profile.physical,
                      ),
                    ),
                    icon: Icons.edit,
                  ),
                  children: [
                    _DetailRow("Height", profile.physical?.height ?? "N/A"),
                    _DetailRow(
                      "Weight",
                      profile.physical?.weight?.toString() ?? "N/A",
                    ),
                    _DetailRow(
                      "Body Type",
                      profile.physical?.bodyType ?? "N/A",
                    ),

                    _DetailRow(
                      "Complexion",
                      profile.physical?.complexion ?? "N/A",
                    ),

                    _DetailRow(
                      "Disability",
                      profile.physical!.physicallyChallenged ? "Yes" : "No ",
                    ),
                  ],
                ),

                // 🌟 RELIGIOUS & ASTROLOGICAL
                _DetailSection(
                  title: "Religious & Astrological",

                  actionChip: AppChip(
                    label: "Edit",
                    icon: Icons.edit,
                    onTap: () => AutoRouter.of(context).push(
                      UserCultureFormRoute(
                        mode: FormMode.edit,
                        existingCulturalProfile: profile.cultural,
                      ),
                    ),
                  ),

                  children: [
                    _DetailRow("Religion", profile.cultural?.religion ?? "N/A"),
                    _DetailRow("Caste", profile.cultural?.caste ?? "N/A"),
                    _DetailRow(
                      "Sub-caste",
                      profile.cultural?.subCaste ?? "N/A",
                    ),

                    _DetailRow(
                      "Languages",
                      profile.cultural?.languages.join(", ") ?? "N/A",
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

class _DetailRowWithAction extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DetailRowWithAction({
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

class _ProfileHeroCard extends StatelessWidget {
  final MetrimonyProfileViewModel profile;
  const _ProfileHeroCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => AutoRouter.of(
        context,
      ).push(MyProfileDetailRoute(user: profile.user!)),

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.canvasColor,
          borderRadius: BorderRadius.circular(26),
          // gradient: LinearGradient(
          //   colors: [theme.primaryColor.withOpacity(0.12), Colors.white],
          // ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => showPhotoDialogBox(
                    photoUrl: profile.images.primaryImageUrl!,
                    context: context,
                  ),

                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.primaryColor.withOpacity(0.15),
                    backgroundImage:
                        (profile.images.primaryImageUrl?.isNotEmpty ?? false)
                        ? NetworkImage(profile.images.primaryImageUrl!)
                        : null,
                    child: (profile.images.primaryImageUrl?.isEmpty ?? true)
                        ? Icon(
                            Icons.person,
                            size: 48,
                            color: theme.primaryColor,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.user?.fullName ?? "N/A",
                        style: TextStyle(
                          fontSize: 30,

                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      _buildContactTile(
                        label: profile.user?.phone ?? "N/A",
                        icon: Icons.phone_outlined,

                        color: theme.primaryColor,
                      ),
                      SizedBox(height: 16),
                      _buildContactTile(
                        label: profile.user?.email ?? "N/A",
                        icon: Icons.email_outlined,
                        color: theme.primaryColor,
                      ),

                      SizedBox(height: 10),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            Wrap(
              runSpacing: 10,
              spacing: 10,

              children: [
                AppChip(
                  label: profile.identity?.gender ?? "N/A",
                  icon: Icons.person_outline,
                ),

                AppChip(
                  label: "${profile.identity?.age ?? 'N/A'} yrs",
                  icon: Icons.cake_outlined,
                ),

                AppChip(
                  label: profile.employment?.designation ?? "N/A",
                  icon: Icons.work_outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _buildContactTile({
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

  final AppChip actionChip;

  const _DetailSection({
    required this.title,
    required this.children,
    required this.actionChip,
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

              actionChip,

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
