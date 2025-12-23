import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/matrimony_repository_impl.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_auth/presentation/providers/auth_providers.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final matrimonyProfileProvider =
    FutureProvider.family<MatrimonyProfile, String>((ref, userId) {
      final repository = ref.watch(matrimonyRepositoryProvider);
      return repository.getMatrimonyProfile(userId);
    });

@RoutePage()
class UserProfileScreen extends ConsumerWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(matrimonyProfileProvider(userId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (profile) {
          if (profile.identity == null) {
            return const Center(child: Text('User identity not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // 🔹 TITLE
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  child: Text(
                    "My Profile",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),

                // 🔹 PROFILE HEADER
                _ProfileHeaderCard(profile: profile),

                // 🔹 PREMIUM CARD
                _PremiumCard(),

                // 🔹 GENERAL SECTION
                _SectionTitle(title: "General"),

                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: "Change Password",
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: "Privacy Settings",
                  onTap: () {},
                ),

                // help and support
                _SettingsTile(
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: "About Us",
                  onTap: () {},
                ),

                // 🔹 ACCOUNT SETTINGS SECTION
                _SectionTitle(title: "Account Settings"),
                _SettingsTile(
                  icon: Icons.person_outline,
                  title: "Edit Profile",
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.photo_library_outlined,
                  title: "Manage Photos",
                  onTap: () {},
                ),

                // 🔹 NOTIFICATIONS SECTION
                _SectionTitle(title: "Notifications"),
                _SettingsTile(
                  icon: Icons.notifications_active_outlined,
                  title: "Push Notifications",
                  trailing: Switch(value: true, onChanged: (v) {}),
                ),
                _SettingsTile(
                  icon: Icons.email_outlined,
                  title: "Email Notifications",
                  trailing: Switch(value: false, onChanged: (v) {}),
                ),

                // 🔹 LOGOUT
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton(
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all(
                        Theme.of(context).primaryColor,
                      ),
                      side: WidgetStateProperty.all(
                        BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 14),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    onPressed: () {
                      //LOGOUT HERE

                      ref.read(authRepositoryProvider).signOut();

                      AutoRouter.of(context).replace(const LoginRoute());

                      print("Logout button pressed");
                    },
                    child: const Text("Logout"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final MatrimonyProfile profile;

  const _ProfileHeaderCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        AutoRouter.of(context).push(MyProfileRoute(uid: profile.user!.uid));
      },

      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [theme.primaryColor.withOpacity(0.08), Colors.white],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👤 Avatar + Verified badge
              Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.primaryColor.withOpacity(0.15),
                    backgroundImage:
                        (profile.images?.primaryImageUrl?.isNotEmpty ?? false)
                        ? NetworkImage(profile.images!.primaryImageUrl)
                        : null,
                    child: (profile.images?.primaryImageUrl?.isEmpty ?? true)
                        ? Icon(
                            Icons.person,
                            size: 40,
                            color: theme.primaryColor,
                          )
                        : null,
                  ),
                ],
              ),

              const SizedBox(width: 18),

              // 📝 Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Name
                    Text(
                      profile.user?.fullName ?? 'N/A',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 🔹 Verified + Edit (SAME ROW ✅)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: profile.user?.isVerified == true
                                  ? theme.primaryColor
                                  : Colors.red,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                profile.user?.isVerified == true
                                    ? Icons.verified
                                    : Icons.cancel,
                                size: 16,
                                color: profile.user?.isVerified == true
                                    ? theme.primaryColor
                                    : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                profile.user?.isVerified == true
                                    ? "Verified"
                                    : "Not Verified",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: profile.user?.isVerified == true
                                      ? theme.primaryColor
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: profile.user?.isVerified == true
                                  ? theme.primaryColor
                                  : Colors.red,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                size: 16,
                                color: profile.user?.isVerified == true
                                    ? theme.primaryColor
                                    : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Edit Profile",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: profile.user?.isVerified == true
                                      ? theme.primaryColor
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // 🔹 Age & Occupation
                    Text(
                      '${profile.identity?.age ?? 'N/A'} yrs • ${profile.education?.occupation ?? 'N/A'}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),

                    const SizedBox(height: 8),

                    // 📍 Location
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
                            '${profile.address?.city ?? 'N/A'}, ${profile.address?.state ?? 'N/A'}',
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
        ),
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.primaryColor.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 30,
            color: theme.primaryColor,
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => AutoRouter.of(context).push(const UserPaymentRoute()),

            child: const Expanded(
              child: Text(
                "Upgrade Account to Premium",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
