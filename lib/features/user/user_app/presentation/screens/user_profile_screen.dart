import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shadi_milan/core/constants/app_constants.dart';
import 'package:shadi_milan/features/l10n/app_translation_service.dart';
import 'package:shadi_milan/core/notification/notification_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/features/user/user_app/widgets/agent_bottom_sheet.dart';
import 'package:shadi_milan/features/user/user_razorpay/domain/states/payment.dart';
import 'package:shadi_milan/features/user/user_razorpay/presentation/notifier/payment_notifier.dart';

import '../../../../../../core/constants/app_labels.dart';
import '../../../../../app/custom/custom_widgets/animated_app_bar.dart';
import '../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../../app/router/app_router.dart';
import '../../../../auth/domain/states/agent_state.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../../translitration/models/bilingual_value.dart';
import '../../data/repositories_impl/agent_repository_impl.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import '../../domain/states/metrimony_profile_view_model.dart';
import '../controllers/metrimony_profile_controller.dart';
import 'user_home_screen.dart';

final userProfileScreenProvider = StreamProvider.family<MetrimonyProfileViewModel, String>((ref, userId) {
  final repository = ref.watch(matrimonyRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  final agentRepo = ref.watch(agentRepositoryProvider);

  return repository.watchMatrimonyProfile(userId).asyncMap((matrimonyProfile) async {
    final user = await userRepo.fetchUser(userId);

    // fetch AgentEntity
    AgentEntity? agent;
    if (user.agentId.isNotEmpty) {
      try {
        agent = await agentRepo.fetchAgent(user.agentId);
      } catch (e) {
        debugPrint('Error fetching agent with ID: ${user.agentId}, Error: $e');
        agent = null;
      }
    } else {
      debugPrint('Staff Id is empty for user: $userId');
    }

    return MetrimonyProfileViewModel(metrimonyProfile: matrimonyProfile, userProfile: user, agentEntity: agent);
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

    final currentUserAsync = ref.watch(currentUserProvider);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stackTrace) {
          debugPrint(stackTrace.toString());

          return Center(child: Text(AppLabels.error(context, err.toString())));
        },
        data: (profile) {
          return CustomScrollView(
            slivers: [
              ModernGradientAppBar(title: AppLabels.myProfile(context), subtitle: AppLabels.manageAccount(context), centerTitle: true),

              SliverToBoxAdapter(child: _ProfileHeaderCard(profile: profile)),

              SliverPadding(
                padding: const EdgeInsets.only(bottom: 1),

                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // 🔹 PREMIUM CARD

                        //  check for payments collection if status is success then show premium card
                        Consumer(
                          builder: (context, ref, child) {
                            final paymentState = ref.watch(paymentNotifierProvider(userId));
                            if (paymentState.status == PayStatus.loading) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            // change after publishing on playstore
                            if (paymentState.status == PayStatus.idle) {
                              return GestureDetector(
                                onTap: () => AutoRouter.of(context).push(UserPaymentSuccessRoute(user: profile.user)),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.green.shade200, width: 1.5),
                                  ),
                                  child: Row(
                                    children: [
                                      // Custom Icon Container
                                      Container(
                                        height: 45,
                                        width: 45,
                                        decoration: BoxDecoration(color: Colors.green.shade500, borderRadius: BorderRadius.circular(12)),
                                        child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 26),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLabels.premiumActive(context),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.green.shade800,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.1,
                                              ),
                                            ),
                                            Text(
                                              AppLabels.premiumMemberMessage(context),
                                              style: const TextStyle(fontSize: 17, color: Colors.black87, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward_ios, size: 14, color: Colors.green.shade300),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return _PremiumCard(profile: profile);
                          },
                        ),

                        // 🔹 GENERAL SECTION
                        _SectionTitle(title: AppLabels.generalSection(context)),
                        _SettingsTile(
                          icon: Icons.person_search_outlined,
                          title: AppLabels.myProfile(context),
                          onTap: () {
                            AutoRouter.of(context).push(MyProfileRoute(uid: userId));
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.tune_rounded,
                          title: "Partner Preferences",
                          onTap: () {
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: 'Preferences',
                              transitionDuration: const Duration(milliseconds: 400),
                              pageBuilder: (context, animation, secondaryAnimation) => const FilterRightSheet(),
                              transitionBuilder: (context, animation, secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
                                  child: child,
                                );
                              },
                            );
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.support_agent_outlined,
                          title: AppLabels.agentDetails(context),
                          onTap: () {
                            if (profile.agentEntity != null) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => AgentBottomSheet(agent: profile.agentEntity!),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLabels.noAgentAssigned(context))));
                            }
                          },
                        ),

                        // user status
                        _SettingsTile(
                          icon: Icons.verified_user_outlined,
                          title: AppLabels.userStatus(context),
                          onTap: () {
                            // navigate to user status screen
                            AutoRouter.of(context).push(UserStatusRoute());
                          },
                        ),

                        // Contact Support
                        _SettingsTile(
                          icon: Icons.contact_support_outlined,
                          title: AppLabels.support(context),
                          onTap: () {
                            AutoRouter.of(context).push(const ContactUsRoute());
                          },
                        ),

                        // Support Tickets
                        _SettingsTile(
                          icon: Icons.support_agent_outlined,
                          title: AppLabels.supportTickets(context),
                          onTap: () {
                            AutoRouter.of(context).push(SupportTicketsRoute(userId: userId));
                          },
                        ),

                        // 🔹 ACCOUNT SETTINGS SECTION
                        _SectionTitle(title: AppLabels.accountSettings(context)),

                        _SettingsTile(
                          icon: Icons.lock_outline,
                          title: AppLabels.changePassword(context),
                          onTap: () {
                            // navigate to change password screen
                            AutoRouter.of(context).push(ChangePasswordRoute());
                          },
                        ),

                        // payment route
                        _SettingsTile(
                          icon: Icons.payment_outlined,
                          title: AppLabels.paymentHistory(context),
                          onTap: () {
                            AutoRouter.of(context).push(UserPaymentOrderHistoryRoute());
                          },
                        ),

                        _SettingsTile(
                          icon: Icons.family_restroom_outlined,
                          title: AppLabels.postMarriagePayment(context),
                          onTap: () {
                            AutoRouter.of(context).push(UserAfterMarriagePaymentRoute(userId: userId));
                          },
                        ),

                        _SettingsTile(
                          icon: Icons.notifications_outlined,
                          title: AppLabels.notifications(context),
                          trailing: Consumer(
                            builder: (context, ref, _) {
                              final count = ref.watch(unreadNotificationsCountProvider);
                              if (count <= 0) return const Icon(Icons.arrow_forward_ios, size: 16);
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                child: Text(
                                  count > 99 ? '99+' : count.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                          onTap: () {
                            AutoRouter.of(context).push(const UserNotificationRoute());
                          },
                        ),

                        _SettingsTile(
                          icon: Icons.language,
                          title: AppLabels.language(context),
                          onTap: () => _showLanguageDialog(context, ref),
                        ),

                        // 🔹 LEGAL & INFO SECTION
                        _SectionTitle(title: AppLabels.legalAndInfo(context)),

                        _SettingsTile(
                          icon: Icons.info_outline,
                          title: AppLabels.aboutUs(context),
                          onTap: () {
                            AutoRouter.of(context).push(const AboutUsRoute());
                          },
                        ),

                        _SettingsTile(
                          icon: Icons.privacy_tip_outlined,
                          title: AppLabels.privacyPolicy(context),
                          onTap: () => AppConstants.openUrl(AppConstants.privacyPolicyUrl),
                        ),

                        _SettingsTile(
                          icon: Icons.description_outlined,
                          title: AppLabels.termsAndConditions(context),
                          onTap: () => AppConstants.openUrl(AppConstants.termsAndConditionsUrl),
                        ),

                        _SettingsTile(
                          icon: Icons.security_outlined,
                          title: "Child Safety Standards",
                          onTap: () => AppConstants.openUrl(AppConstants.childSafetyStandardsUrl),
                        ),

                        _SettingsTile(
                          icon: Icons.share_outlined,
                          title: AppLabels.shareApp(context),
                          onTap: () async {
                            const String packageName = "com.shaadimilan.app";
                            const String playStoreLink = "https://play.google.com/store/apps/details?id=$packageName";
                            await Share.share(
                              'Check out ${AppConstants.appName}! Find your perfect match here: $playStoreLink',
                              subject: 'Download ${AppConstants.appNameRaw} App',
                            );
                          },
                        ),

                        _SettingsTile(
                          icon: Icons.star_rate_outlined,
                          title: AppLabels.rateUs(context),
                          onTap: () async {
                            final InAppReview inAppReview = InAppReview.instance;
                            if (await inAppReview.isAvailable()) {
                              inAppReview.openStoreListing(appStoreId: 'YOUR_IOS_APP_ID_HERE');
                            }
                          },
                        ),

                        const SizedBox(height: 10),
                      ],
                    );
                  }, childCount: 1),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout, size: 20),
                    label: Text(AppLabels.logout(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade200, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      backgroundColor: Colors.red.shade50.withOpacity(0.5),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(AppLabels.logout(context)),
                          content: Text(AppLabels.logoutConfirm(context)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(AppLabels.cancel(context)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(AppLabels.logout(context), style: const TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref.read(authRepositoryProvider).signOut();
                        if (context.mounted) {
                          AutoRouter.of(context).replaceAll([const RoleSelectionRoute()]);
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

void _showLanguageDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(AppLabels.selectLanguage(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppTranslation.supportedTranslations.map((translation) {
            return ListTile(
              title: Text(translation.nativeName),
              subtitle: Text(translation.name),
              onTap: () {
                ref.read(appTranslationServiceProvider).setLanguageCode(translation.languageCode);
                ref.read(localeProvider.notifier).state = Locale(translation.languageCode);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      );
    },
  );
}

class _ProfileHeaderCard extends StatelessWidget {
  final MetrimonyProfileViewModel profile;

  const _ProfileHeaderCard({required this.profile});

  bool get hasImage => profile.userProfile.profileImageUrl.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        backgroundImage: hasImage ? CachedNetworkImageProvider(profile.userProfile.profileImageUrl) : null,
                        child: !hasImage
                            ? Text(
                                profile.userProfile.fullName.en.isNotEmpty ? profile.userProfile.fullName.en[0].toUpperCase() : '?',
                                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: primaryColor),
                              )
                            : null,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BilingualParser(
                  value: profile.user.fullName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // 🆔 Matrimony ID with Copy & Edit Action
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: profile.metrimonyProfile.metrimonyId));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ID Copied to Clipboard")));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              profile.metrimonyProfile.metrimonyId,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.copy_rounded, size: 16, color: Colors.grey.shade600),
                          ],
                        ),
                      ),
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        return GestureDetector(
                          onTap: () => _showEditIdDialog(context, ref, profile.userProfile.uid, profile.metrimonyProfile.metrimonyId),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: const BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30)),
                              border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
                            ),
                            child: Icon(Icons.edit_rounded, size: 16, color: theme.primaryColor),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 🗓 Subscription Info Card
                Consumer(
                  builder: (context, ref, _) {
                    final paymentState = ref.watch(paymentNotifierProvider(profile.userProfile.uid));
                    final isPremium = paymentState.status == PayStatus.success;

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: isPremium ? const Color(0xFFF1F4FF) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isPremium ? Colors.blue.withOpacity(0.2) : Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 15, color: Colors.black87),
                                children: [
                                  TextSpan(
                                    text: "Account - ",
                                    style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                  ),
                                  TextSpan(
                                    text: isPremium ? "Platinum Plus" : "Free Member",
                                    style: TextStyle(color: isPremium ? Colors.blue.shade800 : Colors.black87, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isPremium && paymentState.payment != null) ...[
                            Container(
                              width: 1,
                              height: 20,
                              color: Colors.grey.shade300,
                              margin: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            Text(
                              "till ${DateFormat('d MMM, yyyy').format(paymentState.payment!.createdAt.add(const Duration(days: 365)))}",
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.03),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(context, AppLabels.profile(context), "85%"),
                _buildVerticalDivider(),
                _buildStatColumn(context, AppLabels.profileStatus(context), AppLabels.active(context)),
                _buildVerticalDivider(),
                _buildStatColumn(context, AppLabels.trustScore(context), "4.8"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 24, width: 1, color: Colors.grey[300]);
  }

  void _showEditIdDialog(BuildContext context, WidgetRef ref, String uid, String currentId) {
    final controller = TextEditingController(text: currentId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Matrimony ID"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "New Matrimony ID", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final newId = controller.text.trim();
              if (newId.isNotEmpty) {
                try {
                  await ref.read(metrimonyControllerProvider.notifier).updateMetrimonyId(uid, newId);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ID Updated Successfully")));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating ID: $e")));
                  }
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
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
          // if Staff Id not present
          if (profile!.user.agentId.isEmpty) {
            // create a model bottom sheet  to take user id or  show contact details if he does not know
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
              backgroundColor: theme.canvasColor,
              builder: (BuildContext context) {
                return const AgentFormWidget();
              },
            );
            return;
          }
          AutoRouter.of(context).push(UserPaymentRoute(userId: profile!.userProfile.uid));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          ),
          boxShadow: [BoxShadow(color: theme.primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.workspace_premium, size: 30, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLabels.upgradeToPremium(context),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(AppLabels.premiumUpgradeBenefits(context), style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// creat a state provider for tab
final agentSetupProvider = StateProvider<int>((ref) => 1);

final agentDetailProvider = StateProvider<int>((ref) => 0);

class AgentFormWidget extends ConsumerStatefulWidget {
  const AgentFormWidget({super.key});

  @override
  ConsumerState<AgentFormWidget> createState() => _AgentFormWidgetState();
}

class _AgentFormWidgetState extends ConsumerState<AgentFormWidget> {
  final TextEditingController _agentIdController = TextEditingController();
  AgentEntity? _fetchedAgent;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _agentIdController.dispose();
    super.dispose();
  }

  Future<void> _fetchAgent() async {
    final agentId = _agentIdController.text.trim();
    if (agentId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _fetchedAgent = null;
    });

    try {
      final agent = await ref.read(agentRepositoryProvider).fetchAgentEntitybyAgentId(agentId);

      if (mounted) {
        setState(() {
          _fetchedAgent = agent;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AppLabels.agentNotFound(context);
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(agentSetupProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: AppLabels.agentSetup(context)),
            const SizedBox(height: 12),

            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: _ActionTab(
                    icon: Icons.person_add_alt_1_outlined,
                    title: AppLabels.enterStaffId(context),
                    isSelected: selectedTab == 1,
                    onTap: () {
                      ref.read(agentSetupProvider.notifier).state = 1;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionTab(
                    icon: Icons.contact_phone_outlined,
                    title: AppLabels.support(context),
                    isSelected: selectedTab == 2,

                    onTap: () {
                      ref.read(agentSetupProvider.notifier).state = 2;
                    },
                  ),
                ),

                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 24),

            if (selectedTab == 1) _buildAgentForm() else _buildContactAndSupportForm(),
          ],
        ),
      ),
    );
  }

  void _assignAgent({required String agentId}) {
    if (agentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLabels.pleaseEnterStaffId(context))));
      return;
    }

    ref.read(userRepositoryProvider).updateAgentId(ref.read(authRepositoryProvider).currentUser!.uid, agentId);

    /// update state
    ref.invalidate(userProfileScreenProvider(ref.read(authRepositoryProvider).currentUser!.uid));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLabels.agentAssignedSuccessfully(context, agentId))));

    _agentIdController.clear();
    Navigator.pop(context);
  }

  Container _buildAgentForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLabels.agentSetupDescription(context),
            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _agentIdController,
            decoration: InputDecoration(
              labelText: AppLabels.staffId(context),
              hintText: AppLabels.staffIdHint(context),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.person_outline),
              suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _fetchAgent),
            ),
            onSubmitted: (_) => _fetchAgent(),
          ),
          const SizedBox(height: 20),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Text(_errorMessage!, style: const TextStyle(color: Colors.red))
          else if (_fetchedAgent != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50,

                    backgroundImage: _fetchedAgent!.profileImageUrl.isNotEmpty
                        ? CachedNetworkImageProvider(_fetchedAgent!.profileImageUrl)
                        : null,

                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                  ),
                  const SizedBox(width: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLabels.agentDetailsHeader(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("${AppLabels.fullName(context)}: ${_fetchedAgent!.agentName}", maxLines: 2, overflow: TextOverflow.ellipsis),
                      Text(maxLines: 2, overflow: TextOverflow.ellipsis, "${AppLabels.phone(context)}: ${_fetchedAgent!.agentMobile}"),
                      Text(maxLines: 2, overflow: TextOverflow.ellipsis, "${AppLabels.email(context)}: ${_fetchedAgent!.agentEmail}"),
                      Text(maxLines: 2, overflow: TextOverflow.ellipsis, "${AppLabels.staffId(context)}: ${_fetchedAgent!.agentId}"),
                      Text(maxLines: 2, overflow: TextOverflow.ellipsis, "${AppLabels.address(context)}: ${_fetchedAgent!.agentAddress}"),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _fetchedAgent != null ? () => _assignAgent(agentId: _fetchedAgent!.uid) : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLabels.assignAgent(context), style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Container _buildContactAndSupportForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            AppLabels.noStaffIdSupport(context),
            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            child: Column(
              children: [
                AppTextField(
                  prefixIcon: Icons.person,

                  iconColor: Theme.of(context).primaryColor,
                  label: AppLabels.fullName(context),
                  hint: AppLabels.fullNameHint(context),
                  obscureText: false,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  prefixIcon: Icons.email,

                  iconColor: Theme.of(context).primaryColor,
                  label: AppLabels.emailAddress(context),
                  hint: AppLabels.emailHint(context),
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  prefixIcon: Icons.phone,
                  iconColor: Theme.of(context).primaryColor,
                  label: AppLabels.phone(context),
                  hint: AppLabels.phoneHint(context),
                  obscureText: false,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  prefixIcon: Icons.message,
                  iconColor: Theme.of(context).primaryColor,
                  label: AppLabels.message(context),
                  hint: AppLabels.enterMessageHint(context),
                  obscureText: false,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLabels.supportRequestSubmitted(context))));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(AppLabels.submitRequest(context), style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;

  final VoidCallback onTap;

  const _ActionTab({required this.icon, required this.title, this.isSelected = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withOpacity(0.1) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? theme.primaryColor : theme.dividerColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? theme.primaryColor : Colors.grey),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? theme.primaryColor : null),
              ),
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
      padding: const EdgeInsets.fromLTRB(20, 24, 16, 12),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.2, height: 1.5),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.title, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: theme.primaryColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
