import 'package:arvika_marriage_bureau/core/themes/theme_notifier.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/data/datasources/firebase/agent_firestore_ds.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/agent_repository_impl.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/user_repo_impl.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/agent_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/widgets/agent_bottom_sheet.dart';

import '../../../../../app/router/app_router.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/states/metrimony_state.dart';
import '../../domain/states/user_state.dart';
import '../../domain/states/metrimony_profile_view_model.dart';
import 'package:arvika_marriage_bureau/features/user/user_auth/presentation/providers/auth_providers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileScreenProvider =
    FutureProvider.family<MetrimonyProfileViewModel, String>((
      ref,
      userId,
    ) async {
      final repository = ref.watch(matrimonyRepositoryProvider);
      final matrimonyProfile = await repository.getMatrimonyProfile(userId);

      final userRepo = ref.watch(userRepositoryProvider);
      final user = await userRepo.fetchUser(userId);

      // fetch agentprofile
      AgentProfile? agent;
      if (matrimonyProfile.agentId.isNotEmpty) {
        final agentRepo = ref.watch(agentRepositoryProvider);
        agent = await agentRepo.fetchAgent(matrimonyProfile.agentId);
      }

      return MetrimonyProfileViewModel(
        metrimonyProfile: matrimonyProfile,
        userProfile: user,
        agentProfile: agent,
      );
    });

@RoutePage()
class UserProfileScreen extends ConsumerWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileScreenProvider(userId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stackTrace) {
          debugPrint(stackTrace.toString());

          return Center(child: Text('Error: $err'));
        },
        data: (profile) {
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
                _PremiumCard(appUser: profile.user),

                // 🔹 GENERAL SECTION
                _SectionTitle(title: "General"),
                _SettingsTile(
                  icon: Icons.person_search_outlined,
                  title: "My Profile",
                  onTap: () {
                    AutoRouter.of(context).push(MyProfileRoute(uid: userId));
                  },
                ),
                _SettingsTile(
                  icon: Icons.support_agent_outlined,
                  title: "Agent Details",
                  onTap: () {
                    if (profile.agentProfile != null) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            AgentBottomSheet(agent: profile.agentProfile!),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("No agent assigned yet.")),
                      );
                    }
                  },
                ),

                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: "Change Password",
                  onTap: () {
                    // navigate to change password screen
                    AutoRouter.of(context).push(const ChangePasswordRoute());
                  },
                ),

                // payment route
                _SettingsTile(
                  icon: Icons.payment_outlined,
                  title: "Payment History",
                  onTap: () {
                    AutoRouter.of(context).push(const PaymentHistoryRoute());
                  },
                ),
                // user status
                _SettingsTile(
                  icon: Icons.verified_user_outlined,
                  title: "User Status",
                  onTap: () {
                    // navigate to user status screen
                    AutoRouter.of(context).push(const UserStatusRoute());
                  },
                ),

                // this is for user data access can be implemented in future
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: "Privacy Settings",
                  onTap: () {},
                ),
                // Terms & Conditions
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: "Terms & Conditions",
                  onTap: () {
                    AutoRouter.of(
                      context,
                    ).push(const TermsAndConditionsRoute());
                  },
                ),
                // Privacy Policy
                _SettingsTile(
                  icon: Icons.policy_outlined,
                  title: "Privacy Policy",
                  onTap: () {
                    AutoRouter.of(context).push(const PrivacyPolicyRoute());
                  },
                ),

                // help and support
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: "About Us",
                  onTap: () {
                    AutoRouter.of(context).push(const AboutUsRoute());
                  },
                ),

                // Contact Support
                // stting tile
                _SettingsTile(
                  icon: Icons.contact_support_outlined,
                  title: "Contact Support",
                  onTap: () {
                    AutoRouter.of(context).push(const ContactUsRoute());
                  },
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
                // 🔹 APP PREFERENCES SECTION
                _SectionTitle(title: "App Preferences"),
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
                // _SettingsTile(
                //   icon: Icons.dark_mode_outlined,
                //   title: "Dark Mode",
                //   trailing: Switch(
                //     value: ref.watch(themeProvider) == ThemeMode.dark,
                //     onChanged: (value) {
                //       ref
                //           .read(themeProvider.notifier)
                //           .setTheme(value ? ThemeMode.dark : ThemeMode.light);

                //       // print selected theme
                //       print('Selected theme: ${value ? 'Dark' : 'Light'}');
                //     },
                //   ),
                // ),

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
  final MetrimonyProfileViewModel profile;

  const _ProfileHeaderCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      child: Center(
        child: Column(
          children: [
            // 👤 Avatar
            CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.30,
              backgroundColor: theme.primaryColor.withOpacity(0.15),
              backgroundImage:
                  (profile.images.primaryImageUrl?.isNotEmpty ?? false)
                  ? NetworkImage(profile.images.primaryImageUrl!)
                  : null,
              child: (profile.images.primaryImageUrl?.isEmpty ?? true)
                  ? Icon(Icons.person, size: 50, color: theme.primaryColor)
                  : null,
            ),

            // 📝 Name (unchanged data)
            Text(
              profile.user?.fullName ?? 'N/A',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 40,

                color: Theme.of(context).primaryColor,

                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final AppUser? appUser;
  const _PremiumCard({this.appUser});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        if (appUser != null) {
          AutoRouter.of(context).push(UserPaymentRoute(appUser: appUser!));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User data not available.")),
          );
        }
      },
      child: Container(
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
            const Expanded(
              child: Text(
                "Upgrade Account to Premium",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
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
