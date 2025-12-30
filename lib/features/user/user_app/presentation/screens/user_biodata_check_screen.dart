import 'package:arvika_marriage_bureau/data_core/metrimony_profiles_data.dart';

import '../../../../../app/custom/custom_widgets/chip_and_action_chip.dart';
import '../../../../../app/router/app_router.dart';
import '../../domain/states/image_state.dart';
import '../controllers/metrimony_profile_controller.dart';
import '../../../user_auth/presentation/providers/auth_providers.dart';
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

          _section('User Details', Icons.person, [
            _infoRow('Full Name', currentUser?.fullName),
            _infoRow('Email', currentUser?.email),
            _infoRow('Phone', currentUser?.phone),
            _infoRow(
              'Verification',
              (currentUser?.isVerified) == true ? 'Verified' : 'Not Verified',
            ),
          ]),

          _section('Identity', Icons.badge, [
            _infoRow('Gender', profile.identity.gender),
            _infoRow(
              'Date of Birth',
              profile.identity.dob != null
                  ? DateFormat('dd MMM yyyy').format(profile.identity.dob)
                  : null,
            ),
            _infoRow(
              'Age',
              profile.identity.age != null
                  ? '${profile.identity.age} Years'
                  : null,
            ),
            _infoRow('Aadhar', profile.identity.aadhar),
          ]),

          _section('Physical', Icons.accessibility_new, [
            _infoRow('Height', profile.physical.height),
            _infoRow('Weight', profile.physical.weight),
            _infoRow('Complexion', profile.physical.complexion),
            _infoRow('Body Type', profile.physical.bodyType),
          ]),

          _section('Cultural', Icons.temple_hindu, [
            _infoRow('Religion', profile.cultural.religion),
            _infoRow('Caste', profile.cultural.caste),
            _infoRow('Sub Caste', profile.cultural.subCaste), 
            _infoRow('Mother Tongue', profile.cultural.motherTongue),
            _chipWrap('Languages Known', profile.cultural.languages),
          ]),

        
          _section('Education', Icons.school, [
            
            _infoRow(
              'Graduation College',
              profile.education.education?.college,
            ),
            _infoRow('Degree', profile.education.education?.degree),
            _infoRow('Graduation %', profile.education.education?.percentage),
            _infoRow('Passing Year', profile.education.education?.passingYear),
          ]),

          _section('Employment', Icons.work, [
            _infoRow('Company', profile.employment.company),
            _infoRow('Role', profile.employment.designation),
            _infoRow('Annual Income', profile.employment.annualIncome),
          ]),

          _section('Family', Icons.family_restroom, [
            _infoRow('Father Name', profile.family.fatherName),
            _infoRow('Mother Name', profile.family.motherName),
            _infoRow('Brothers', profile.family.numberOfBrothers),
            _infoRow('Sisters', profile.family.numberOfSisters),
            _infoRow('Family Type', profile.family.familyType),
          ]),

          _section('Address', Icons.location_on, [
            _infoRow('Address', profile.address.addressLine1),
            _infoRow('Post', profile.address.post),
            _infoRow('City', profile.address.city),
            _infoRow('State', profile.address.state),
            _infoRow('Pincode', profile.address.pincode),
          ]),

          _imageSection(profile.images),

          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: isAgreed,
            onChanged: (v) => setState(() => isAgreed = v ?? false),
            title: const Text(
              'I confirm all details are correct',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Once submitted, profile cannot be edited',
              style: TextStyle(color: Colors.redAccent),
            ),
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
              'FINAL SUBMIT',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values
                .map(
                  (e) => Chip(
                    label: Text(e),
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.08),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _warningCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Please verify carefully.\nOnce submitted, profile cannot be edited.',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageSection(ProfileImages? images) {
    if (images == null) return const SizedBox();

    return _section('Profile Images', Icons.photo, [
      if (images.primaryImageUrl != null)
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            images.primaryImageUrl!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      if (images.secondaryImageUrls.isNotEmpty) ...[
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.secondaryImageUrls.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                images.secondaryImageUrls[i],
                width: 90,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    ]);
  }

  // ================= SUBMIT =================

  Future<void> _confirmSubmit() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    await ref
        .read(metrimonyControllerProvider.notifier)
        .submitProfile(uid: user.uid, agentId: user.agentId);

    if (context.mounted) {
      context.router.replaceAll([const UserMainShellRoute()]);
    }
  }
}
