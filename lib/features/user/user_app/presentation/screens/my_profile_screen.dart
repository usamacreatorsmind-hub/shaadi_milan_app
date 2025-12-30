import 'package:arvika_marriage_bureau/features/user/user_app/data/datasources/firebase/agent_firestore_ds.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/user_repo_impl.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/agent_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_profile_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../app/app.dart';
import '../../../../../app/custom/custom_widgets/chip_and_action_chip.dart';
import '../../../../../app/custom/shimmer.dart';
import '../../data/datasources/firebase/user_firestore_ds.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/states/metrimony_state.dart';
import '../../domain/states/user_state.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final matrimonyProfileProvider =
    FutureProvider.family<MetrimonyProfileViewModel, String>((ref, uid) async {
      final matrimonyProfile = await ref
          .read(matrimonyRepositoryProvider)
          .getMatrimonyProfile(uid);

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(matrimonyProfile.userId)
          .get();
      final user = userDoc.exists ? AppUser.fromMap(userDoc.data()!) : null;

      AgentProfile? agent;
      if (matrimonyProfile.agentId.isNotEmpty) {
        agent = await ref
            .read(agentFirestoreDsProvider)
            .fetchAgentProfilebyAgentId(matrimonyProfile.agentId);
      }

      if (user == null) {
        throw Exception("User profile not found");
      }

      return MetrimonyProfileViewModel(
        metrimonyProfile: matrimonyProfile,
        userProfile: user,
        agentProfile: agent,
      );
    });

@RoutePage()
class MyProfileScreen extends ConsumerWidget {
  final String uid;
  const MyProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(matrimonyProfileProvider(uid));

    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (profile) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                const SizedBox(height: 46),

                // 👤 TOP CARD
                _ProfileHeroCard(profile: profile),

                const SizedBox(height: 24),

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
                const SizedBox(height: 24),

                // build Image card that display all images of user
                _DetailSection(
                  title: "Photos",
                  actionChip: AppChip(
                    label: "Edit",
                    icon: Icons.edit,
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
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      profile.images.secondaryImageUrls[index],
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
                                );
                              },
                            ),
                          )
                        : const Text("No additional photos available."),
                  ],
                ),

                const SizedBox(height: 24),

                // 📋 BASIC INFO
                _DetailSection(
                  title: "Basic Information",

                  actionChip: AppChip(label: "Edit", icon: Icons.edit),

                  children: [
                    _DetailRow(
                      "Aadhar",
                      profile.identity?.aadhar.toString() ?? 'N/A',
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

                // 🎓 EDUCATION & CAREER
                _DetailSection(
                  title: "Education & Career",
                  actionChip: AppChip(
                    label: "Edit",
                    icon: Icons.edit,
                    onTap: () {},
                  ),

                  children: [
                    _DetailRow("Company", profile.employment?.company ?? "N/A"),
                    _DetailRow(
                      "Income",
                      profile.employment?.annualIncome?.toString() ?? "N/A",
                    ),
                  ],
                ),
 

                // 🏠 ADDRESS
                _DetailSection(
                  title: "Address",
                  actionChip: AppChip(
                    label: "Edit",
                    onTap: () {},
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
                    onTap: () {},

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
                // 🌟 RELIGIOUS & ASTROLOGICAL
                _DetailSection(
                  title: "Religious & Astrological",

                  actionChip: AppChip(
                    label: "Edit",
                    icon: Icons.edit,
                    onTap: () {},
                  ),

                  children: [
                    _DetailRow("Religion", profile.cultural?.religion ?? "N/A"),
                    _DetailRow("Caste", profile.cultural?.caste ?? "N/A"),
                    _DetailRow(
                      "Sub-caste",
                      profile.cultural?.subCaste ?? "N/A",
                    ),
                  ],
                ),

                // 🕵️ AGENT DETAILS
                if (profile.agent != null) ...[
                  const SizedBox(height: 24),
                  _DetailSection(
                    title: "Agent Details",
                    actionChip: AppChip(
                      label: "Contact",
                      icon: Icons.call,
                      onTap: () {},
                    ),
                    children: [
                      _DetailRow("Name", profile.agent!.agentName),
                      _DetailRow("Mobile", profile.agent!.agentMobile),
                      _DetailRow("Email", profile.agent!.email),
                      _DetailRow("Agent ID", profile.agent!.agentId),
                    ],
                  ),
                ],

                // � PARTNER PREFERENCES
                const SizedBox(height: 24),
              ],
            ),
          );
        },
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [theme.primaryColor.withOpacity(0.12), Colors.white],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: theme.primaryColor.withOpacity(0.15),
            backgroundImage:
                (profile.images.primaryImageUrl?.isNotEmpty ?? false)
                ? NetworkImage(profile.images.primaryImageUrl!)
                : null,
            child: (profile.images.primaryImageUrl?.isEmpty ?? true)
                ? Icon(Icons.person, size: 48, color: theme.primaryColor)
                : null,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.user?.fullName ?? "N/A",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                // Text(
                //   "${profile.identity?.age ?? 'N/A'} yrs • ${profile.education?. ?? "N/A"}",
                //   style: TextStyle(color: Colors.grey[700]),
                // ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "${profile.address?.city ?? "N/A"}, ${profile.address?.state ?? "N/A"}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
