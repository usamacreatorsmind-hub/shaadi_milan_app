import '../../../../auth/domain/states/agent_state.dart';
import '../../data/repositories_impl/agent_repository_impl.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import '../controllers/user_status_controller.dart';
import '../../widgets/agent_bottom_sheet.dart';

import '../../../../../app/router/app_router.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/states/metrimony_profile_view_model.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileScreenProvider =
    StreamProvider.family<MetrimonyProfileViewModel, String>((ref, userId) {
      final repository = ref.watch(matrimonyRepositoryProvider);
      final userRepo = ref.watch(userRepositoryProvider);
      final agentRepo = ref.watch(agentRepositoryProvider);

      return repository.watchMatrimonyProfile(userId).asyncMap((
        matrimonyProfile,
      ) async {
        final user = await userRepo.fetchUser(userId);

        // fetch AgentEntity
        AgentEntity? agent;
        if (matrimonyProfile.agentId.isNotEmpty) {
          agent = await agentRepo.fetchAgent(matrimonyProfile.agentId);
        }

        return MetrimonyProfileViewModel(
          metrimonyProfile: matrimonyProfile,
          userProfile: user,
          agentEntity: agent,
        );
      });
    });

@RoutePage()
class UserProfileScreen extends ConsumerWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
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
          return CustomScrollView(
            slivers: [
              // SliverAppBar(
              //   backgroundColor: Colors.grey[100],
              //   expandedHeight: 120,
              //   floating: false,
              //   pinned: true,
              //   flexibleSpace: FlexibleSpaceBar(
              //     titlePadding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 10,
              //     ),
              //     centerTitle: false,
              //     title: Text(
              //       "My Profile",
              //       style: TextStyle(
              //         fontSize: 24,
              //         fontWeight: FontWeight.bold,
              //         color: theme.primaryColor,
              //       ),
              //     ),
              //   ),
              // ),
              SliverAppBar(
                backgroundColor: Colors.grey[100],
                expandedHeight: 120,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  centerTitle: false,
                  title: Text(
                    "My Profile",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _ProfileHeaderCard(profile: profile)),

              SliverPadding(
                padding: const EdgeInsets.only(bottom: 1),

                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // 🔹 TITLE

                        // 🔹 PREMIUM CARD

                        //  check for payments collection if status is success then show premium card
                        Consumer(
                          builder: (context, ref, child) {
                            final userStatusState = ref.watch(
                              userStatusControllerProvider,
                            );
                            if (userStatusState.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (userStatusState.userStatus.subscriptionActive) {
                              return GestureDetector(
                                onTap: () => AutoRouter.of(context).push(
                                  UserPaymentSuccessRoute(user: profile.user),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Custom Icon Container
                                      Container(
                                        height: 45,
                                        width: 45,
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade500,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.verified_user_rounded,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Premium Active",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.green.shade800,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.1,
                                              ),
                                            ),
                                            const Text(
                                              "You are a Premium Member!",
                                              style: TextStyle(
                                                fontSize: 17,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14,
                                        color: Colors.green.shade300,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return _PremiumCard(profile: profile);
                          },
                        ),

                        // 🔹 GENERAL SECTION
                        _SectionTitle(title: "General"),
                        _SettingsTile(
                          icon: Icons.person_search_outlined,
                          title: "My Profile",
                          onTap: () {
                            AutoRouter.of(
                              context,
                            ).push(MyProfileRoute(uid: userId));
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.support_agent_outlined,
                          title: "Agent Details",
                          onTap: () {
                            if (profile.agentEntity != null) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => AgentBottomSheet(
                                  agent: profile.agentEntity!,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("No agent assigned yet."),
                                ),
                              );
                            }
                          },
                        ),

                        // user status
                        _SettingsTile(
                          icon: Icons.verified_user_outlined,
                          title: "User Status",
                          onTap: () {
                            // navigate to user status screen
                            AutoRouter.of(
                              context,
                            ).push(const UserStatusRoute());
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
                          icon: Icons.lock_outline,
                          title: "Change Password",
                          onTap: () {
                            // navigate to change password screen
                            AutoRouter.of(
                              context,
                            ).push(const ChangePasswordRoute());
                          },
                        ),

                        // payment route
                        _SettingsTile(
                          icon: Icons.payment_outlined,
                          title: "Payment History",
                          onTap: () {
                            AutoRouter.of(
                              context,
                            ).push(const UserPaymentOrderHistoryRoute());
                          },
                        ),

                        // Privacy Policy
                        _SettingsTile(
                          icon: Icons.policy_outlined,
                          title: "Privacy Policy",
                          onTap: () {
                            AutoRouter.of(
                              context,
                            ).push(const PrivacyPolicyRoute());
                          },
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
                        // help and support
                        _SettingsTile(
                          icon: Icons.info_outline,
                          title: "About Us",
                          onTap: () {
                            AutoRouter.of(context).push(const AboutUsRoute());
                          },
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
                                BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
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

                              ref.watch(authRepositoryProvider).signOut();

                              AutoRouter.of(
                                context,
                              ).replace(const UserLoginRoute());

                              print("Logout button pressed");
                            },
                            child: const Text("Logout"),
                          ),
                        ),

                        SizedBox(height: 100),
                      ],
                    );
                  }, childCount: 1),
                ),
              ),
            ],
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
              radius: MediaQuery.of(context).size.width * 0.15,
              backgroundColor: theme.primaryColor.withOpacity(0.15),
              backgroundImage:
                  (profile.user.profileImageUrl.isNotEmpty ?? false)
                  ? NetworkImage(profile.images.primaryImageUrl)
                  : null,
              child: (profile.user.profileImageUrl.isNotEmpty ?? true)
                  ? Icon(Icons.person, size: 50, color: theme.primaryColor)
                  : null,
            ),

            // 📝 Name (unchanged data)
            Text(
              profile.user.fullName ?? 'N/A',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 30,

                color: Theme.of(context).primaryColor,

                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              profile.user.email ?? 'N/A',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final MetrimonyProfileViewModel? profile;
  const _PremiumCard({this.profile});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        if (profile != null) {
          AutoRouter.of(
            context,
          ).push(UserPaymentRoute(metrimonyProfileViewModel: profile!));
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
              size: 50,
              color: theme.primaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Upgrade to Premium",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Get unlimited access to all features and connect with more matches.",
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.primaryColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.primaryColor.withOpacity(0.6),
            ),
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
