import 'package:arvika_marriage_bureau/app/app.dart';
import 'package:arvika_marriage_bureau/app/custom/custom_widgets/chip_and_action_chip.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/data/datasources/firebase/user_firestore_ds.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/matrimony_repository_impl.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/user_state.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final matrimonyProfileProvider =
    FutureProvider.family<MatrimonyProfile, String>((ref, uid) async {
      var profile = await ref
          .read(matrimonyRepositoryProvider)
          .getMatrimonyProfile(uid);

      if (profile.user == null) {
        try {
          final userDS = ref.read(userFirestoreDSProvider);
          final userData = await userDS.fetchUser(uid);
          profile = profile.copyWith(user: AppUser.fromMap(userData));
        } catch (_) {}
      }

      return profile;
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

                // build Image card that dispaly all images of user
                _DetailSection(
                  title: "Photos",
                  actionChip: AppChip(
                    label: "Edit",
                    icon: Icons.edit,
                    onTap: () {},
                  ),
                  children: [
                    profile.images != null &&
                            profile.images!.secondaryImageUrls.isNotEmpty
                        ? SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  profile.images!.secondaryImageUrls.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      profile.images!.secondaryImageUrls[index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
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
                    _DetailRow(
                      "Qualification",
                      profile.education?.highestQualification ?? "N/A",
                    ),
                    _DetailRow(
                      "Occupation",
                      profile.education?.occupation ?? "N/A",
                    ),
                    _DetailRow("Company", profile.employment?.company ?? "N/A"),
                    _DetailRow(
                      "Income",
                      profile.employment?.annualIncome?.toString() ?? "N/A",
                    ),
                  ],
                ),

                // 🌿 LIFESTYLE
                _DetailSection(
                  title: "Lifestyle",
                  actionChip: AppChip(
                    label: "Edit",
                    icon: Icons.edit,
                    onTap: () {},
                  ),

                  children: [
                    _DetailRow("Diet", profile.lifestyle?.diet ?? "N/A"),
                    _DetailRow("Smoking", profile.lifestyle?.smoke ?? "N/A"),
                    _DetailRow("Drinking", profile.lifestyle?.drink ?? "N/A"),
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
                    _DetailRow("Country", profile.address?.country ?? "N/A"),
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

                // 💖 PARTNER PREFERENCES
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
  final MatrimonyProfile profile;
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
                (profile.images?.primaryImageUrl?.isNotEmpty ?? false)
                ? NetworkImage(profile.images!.primaryImageUrl)
                : null,
            child: (profile.images?.primaryImageUrl?.isEmpty ?? true)
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
                Text(
                  "${profile.identity?.age ?? 'N/A'} yrs • ${profile.education?.occupation ?? "N/A"}",
                  style: TextStyle(color: Colors.grey[700]),
                ),
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
