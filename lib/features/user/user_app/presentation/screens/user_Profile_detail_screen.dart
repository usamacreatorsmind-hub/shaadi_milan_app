import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/matrimony_repository_impl.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_state.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final matrimonyProfileProvider =
    FutureProvider.family<MatrimonyProfile, String>((ref, uid) {
      return ref.read(matrimonyRepositoryProvider).getMatrimonyProfile(uid);
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
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile.identity == null) {
            return const Center(child: Text('Profile incomplete'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // 🔹 HEADER
                _MyProfileHeader(profile: profile),

                const SizedBox(height: 16),

                // 🔹 PROFILE COMPLETION
                _ProfileCompletion(progress: 0.75),

                const SizedBox(height: 16),

                // 🔹 QUICK ACTIONS
                _QuickActions(),

                const SizedBox(height: 24),

                // 🔹 SECTIONS
                _SectionTitle('Personal Information'),
                _InfoTile('Age', '${profile.identity!.age} years'),
                _InfoTile('Gender', profile.identity!.gender),
                _InfoTile(
                  'Location',
                  '${profile.address?.city ?? 'N/A'}, ${profile.address?.state ?? 'N/A'}',
                ),

                const SizedBox(height: 16),

                _SectionTitle('Education & Career'),
                _InfoTile(
                  'Qualification',
                  profile.education?.highestQualification ?? 'N/A',
                ),
                _InfoTile('Occupation', profile.education?.occupation ?? 'N/A'),
                _InfoTile('Company', profile.employment?.company ?? 'N/A'),

                const SizedBox(height: 16),

                _SectionTitle('Lifestyle'),
                _InfoTile('Diet', profile.lifestyle?.diet ?? 'N/A'),
                _InfoTile('Smoking', profile.lifestyle?.smoke ?? 'N/A'),
                _InfoTile('Drinking', profile.lifestyle?.drink ?? 'N/A'),

                const SizedBox(height: 24),

                // 🔹 SETTINGS
                _SectionTitle('Account'),
                _SettingsTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Manage Photos',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Privacy Settings',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  color: Colors.red,
                  onTap: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// HEADER
////////////////////////////////////////////////////////////

class _MyProfileHeader extends StatelessWidget {
  final MatrimonyProfile profile;
  const _MyProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.canvasColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: theme.primaryColor.withOpacity(0.12),
            backgroundImage:
                (profile.images?.primaryImageUrl?.isNotEmpty ?? false)
                ? NetworkImage(profile.images!.primaryImageUrl)
                : null,
            child: (profile.images?.primaryImageUrl?.isEmpty ?? true)
                ? Icon(Icons.person, size: 42, color: theme.primaryColor)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        profile.user?.fullName ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (profile.user?.isVerified == true)
                      const Icon(Icons.verified, color: Colors.green, size: 20),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${profile.identity?.age ?? 'N/A'} yrs • ${profile.education?.occupation ?? 'N/A'}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Profile'),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// PROFILE COMPLETION
////////////////////////////////////////////////////////////

class _ProfileCompletion extends StatelessWidget {
  final double progress;
  const _ProfileCompletion({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Completion',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// QUICK ACTIONS
////////////////////////////////////////////////////////////

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _ActionCard(
              icon: Icons.photo_camera,
              label: 'Photos',
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionCard(
              icon: Icons.description_outlined,
              label: 'Bio',
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// REUSABLES
////////////////////////////////////////////////////////////

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
