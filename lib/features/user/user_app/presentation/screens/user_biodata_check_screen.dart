import 'package:arvika_marriage_bureau/app/custom/custom_widgets/chip_and_action_chip.dart';
import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/image_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/controllers/metrimony_profile_controller.dart';
import 'package:arvika_marriage_bureau/features/user/user_auth/presentation/providers/auth_providers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.value;

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Verify Your Profile'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _warningCard(),
          const SizedBox(height: 16),

          _expandableSection('User Details', Icons.person, [
            _tile('Full Name', profile.user?.fullName ?? currentUser?.fullName),
            _tile('Email', profile.user?.email ?? currentUser?.email),
            _tile('Phone Number', profile.user?.phone ?? currentUser?.phone),
            _tile(
              'Verification',
              profile.user?.isVerified ?? currentUser?.isVerified,
            ),
          ]),

          _expandableSection('Identity', Icons.badge, [
            _tile('Gender', profile.identity?.gender),
            _tile('Aadhar', profile.identity?.aadhar),

            // intl package for data
            _tile(
              'Date of Birth',
              DateFormat('dd-MM-yyyy').format(profile.identity!.dob),
            ),
            _tile('Age', profile.identity?.age),
          ]),

          _expandableSection('Physical', Icons.accessibility_new, [
            _tile('Height', profile.physical?.height),
            _tile('Weight', profile.physical?.weight),
            _tile('Complexion', profile.physical?.complexion),
            _tile('Body Type', profile.physical?.bodyType),
          ]),

          _expandableSection('Cultural', Icons.temple_hindu, [
            _tile('Religion', profile.cultural?.religion),
            _tile('Caste', profile.cultural?.caste),
            _tile('Sub Caste', profile.cultural?.subCaste),
            _tile('Gothra', profile.cultural?.gothra),
            _tile('Mother Tongue', profile.cultural?.motherTongue),
            _tile('Languages Known', profile.cultural?.languages?.join(', ')),
          ]),

          _expandableSection('Lifestyle', Icons.favorite, [
            _tile('Diet', profile.lifestyle?.diet),
            _tile('Smoking', profile.lifestyle?.smoke),
            _tile('Drinking', profile.lifestyle?.drink),
          ]),

          _expandableSection('Education', Icons.school, [
            _tile(
              'Highest Qualification',
              profile.education?.highestQualification,
            ),
            _tile('College', profile.education?.college),
            _tile('Degree', profile.education?.degree),
            _tile('Occupation', profile.education?.occupation),
            _tile('Job Type', profile.employment?.jobType),
          ]),

          _expandableSection('Employment', Icons.work, [
            _tile('Company', profile.employment?.company),
            _tile('Role', profile.employment?.designation),
            _tile('Annual Income', profile.employment?.annualIncome),
          ]),

          _expandableSection('Family', Icons.family_restroom, [
            _tile('Father Name', profile.family?.fatherName),
            _tile('Mother Name', profile.family?.motherName),
            _tile('Brothers', profile.family?.numberOfBrothers),
            _tile('Sisters', profile.family?.numberOfSisters),
            _tile('Family Type', profile.family?.familyType),
          ]),

          _expandableSection('Address', Icons.location_on, [
            _tile('Address Line 1', profile.address?.addressLine1),
            _tile('Address Line 2', profile.address?.addressLine2),
            _tile('City', profile.address?.city),
            _tile('State', profile.address?.state),
            _tile('Pincode', profile.address?.pincode),
            _tile('Country', profile.address?.country),
          ]),

          _imageSection(profile.images),

          const SizedBox(height: 20),

          CheckboxListTile(
            value: isAgreed,
            onChanged: (v) => setState(() => isAgreed = v ?? false),
            title: const Text(
              'I confirm that all details above are correct',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Once submitted, profile cannot be edited.',
              style: TextStyle(color: Colors.red),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: isAgreed ? _confirmSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,

              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'FINAL SUBMIT (Cannot be Undone)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ================= COMMON TILE =================
  Widget _tile(String label, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SECTION =================
  Widget _expandableSection(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

        leading: Icon(icon, color: Theme.of(context).primaryColor),
        trailing: const Icon(Icons.arrow_drop_down),

        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: children,
      ),
    );
  }

  // ================= WARNING =================
  Widget _warningCard() {
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Please verify carefully.\nOnce submitted, profile cannot be edited.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= IMAGES =================
  Widget _imageSection(ProfileImages? images) {
    if (images == null) return const SizedBox();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Images',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (images.primaryImageUrl != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    images.primaryImageUrl!,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            if (images.secondaryImageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.secondaryImageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      images.secondaryImageUrls[i],
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSubmit() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not found')));
      return;
    }
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Final Confirmation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text(
                'Are you absolutely sure?\n\n'
                'Once submitted, your profile details cannot be edited or changed.',
                style: TextStyle(height: 1.4),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                // 🔹 REVIEW AGAIN
                AppActionChip(
                  label: "Review Again",
                  onTap: isLoading ? null : () => Navigator.pop(dialogContext),
                ),

                // 🔴 FINAL SUBMIT
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          setDialogState(() => isLoading = true);

                          try {
                            // 🔥 FINAL SUBMIT API CALL
                            await ref
                                .read(metrimonyControllerProvider.notifier)
                                .submitProfile(ref, user.uid);

                            if (context.mounted) {
                              Navigator.pop(dialogContext);
                              context.router.replaceAll([
                                const UserMainShellRoute(),
                              ]);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'FINAL SUBMIT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
