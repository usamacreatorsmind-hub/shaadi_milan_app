import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/image_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/controllers/app_user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../user_auth/presentation/providers/auth_providers.dart';

import '../../../../../app/router/app_router.dart';
import '../../../user_auth/presentation/controllers/auth_controller.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import '../../data/repositories_impl/userstatus_repository.dart';
import '../../domain/states/user_status_state.dart';
import '../controllers/metrimony_profile_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class UserBiodataCheckScreen extends ConsumerStatefulWidget {
  const UserBiodataCheckScreen({super.key, required bool isAgreed});

  @override
  ConsumerState<UserBiodataCheckScreen> createState() =>
      _UserDetailsCheckScreenState();
}

class _UserDetailsCheckScreenState
    extends ConsumerState<UserBiodataCheckScreen> {
  @override
  void initState() {
    super.initState();
    // fetch user

    final currentUser = ref.read(authStateProvider).value;
    if (currentUser != null) {
      ref.read(appUserControllerProvider(currentUser.uid).notifier).addListener(
        (state) {
          state.whenData((user) {
            if (user != null) {
              ref.read(metrimonyControllerProvider.notifier).saveUser(user);
            }
          });
        },
      );
    }
  }

  bool isAgreed = false; // ✅ CORRECT PLACE

  @override
  Widget build(BuildContext context) {
    final authController = ref.read(authControllerProvider);
    final metrimonyState = ref.watch(metrimonyControllerProvider);
    final metrimonyProfile = metrimonyState.metrimony;

    if (metrimonyState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Profile Summary'),
        centerTitle: true,
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionCard(
              icon: Icons.person,
              title: 'User',
              content: metrimonyProfile.user.toString(),
            ),
            _sectionCard(
              icon: Icons.supervised_user_circle,
              title: 'Agent',
              content: metrimonyProfile.agent.toString(),
            ),

            _sectionCard(
              icon: Icons.person,
              title: 'Identity',
              content: metrimonyProfile.identity.toString(),
            ),
            _sectionCard(
              icon: Icons.accessibility_new,
              title: 'Physical',
              content: metrimonyProfile.physical.toString(),
            ),
            _sectionCard(
              icon: Icons.temple_hindu,
              title: 'Cultural',
              content: metrimonyProfile.cultural.toString(),
            ),
            _sectionCard(
              icon: Icons.favorite,
              title: 'Lifestyle',
              content: metrimonyProfile.lifestyle.toString(),
            ),
            _sectionCard(
              icon: Icons.school,
              title: 'Education',
              content: metrimonyProfile.education.toString(),
            ),
            _sectionCard(
              icon: Icons.work,
              title: 'Employment',
              content: metrimonyProfile.employment.toString(),
            ),
            _sectionCard(
              icon: Icons.family_restroom,
              title: 'Family',
              content: metrimonyProfile.family.toString(),
            ),
            _sectionCard(
              icon: Icons.location_on,
              title: 'Address',
              content: metrimonyProfile.address.toString(),
            ),

            _ImageCard(
              icon: Icons.image,
              title: 'Profile Images',
              primaryImageUrl: metrimonyProfile.images?.primaryImageUrl,
              secondaryImageUrls:
                  metrimonyProfile.images?.secondaryImageUrls ?? [],
            ),

            const SizedBox(height: 24),

            // ✅ AGREEMENT
            Row(
              children: [
                Checkbox(
                  value: isAgreed,
                  onChanged: (value) {
                    setState(() {
                      isAgreed = value ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Text(
                    'I agree that all the information provided above is correct.',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ✅ SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isAgreed
                    ? () async {
                        final userId = ref.read(authStateProvider).value?.uid;

                        if (userId != null) {
                          await ref
                              .read(matrimonyRepositoryProvider)
                              .createMatrimonyProfile(
                                userId,
                                metrimonyProfile.toMap(),
                              );

                          // ✅ Update User Status to 'Profile Created'
                          await ref
                              .read(userStatusRepositoryProvider)
                              .updateUserStatus(userId, UserStatus.all(userId));

                          if (context.mounted) {
                            context.router.replaceAll([const UserHomeRoute()]);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User not authenticated'),
                            ),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Submit Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------
  // SECTION CARD
  // ----------------------------
  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(content, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  _imageCard({
    required IconData icon,
    required String title,
    required String imageUrl,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Center(
              child: Image.network(
                imageUrl,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? primaryImageUrl;
  final List<String> secondaryImageUrls;

  const _ImageCard({
    required this.icon,
    required this.title,
    this.primaryImageUrl,
    this.secondaryImageUrls = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            if (primaryImageUrl != null)
              Center(
                child: Image.network(
                  primaryImageUrl!,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 100),
                ),
              ),
            if (secondaryImageUrls.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Gallery Images:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: secondaryImageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Image.network(
                        secondaryImageUrls[index],
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 50),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

extension on User? {
  void signOut() {}
}
