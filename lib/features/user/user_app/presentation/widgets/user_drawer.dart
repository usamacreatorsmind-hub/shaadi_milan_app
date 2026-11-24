import 'package:cached_network_image/cached_network_image.dart';
import 'package:in_app_review/in_app_review.dart';
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
import '../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../../app/router/app_router.dart';
import '../../../../auth/domain/states/agent_state.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../../translitration/models/bilingual_value.dart';
import '../../data/repositories_impl/agent_repository_impl.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import '../../domain/states/metrimony_profile_view_model.dart';
import '../screens/user_profile_screen.dart';
import '../screens/user_home_screen.dart';
import '../utils/profile_action_gate.dart';

class UserDrawer extends ConsumerWidget {
  final String userId;
  const UserDrawer({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileScreenProvider(userId));
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: Colors.grey[100],
      child: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stackTrace) =>
            Center(child: Text(AppLabels.error(context, err.toString()))),
        data: (profile) {
          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 20,
                          bottom: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.primaryColor,
                              theme.primaryColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: _ProfileHeader(profile: profile),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // 🔹 COMPLETE PROFILE / PREMIUM CARD
                          if (!profile.user.isProfileCreated)
                            _DrawerCompleteProfileCard()
                          else
                            Consumer(
                              builder: (context, ref, child) {
                                final paymentState = ref.watch(
                                  paymentNotifierProvider(userId),
                                );
                                if (paymentState.status == PayStatus.loading) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (paymentState.status == PayStatus.success) {
                                  return _DrawerPremiumActiveCard(
                                    user: profile.user,
                                  );
                                }
                                return _DrawerUpgradePremiumCard(
                                  profile: profile,
                                );
                              },
                            ),

                          _DrawerSettingsTile(
                            icon: Icons.workspace_premium_outlined,
                            title: "Premium Membership",
                            onTap: () {
                              Navigator.pop(context);
                              AutoRouter.of(
                                context,
                              ).push(UserPremiumPlansRoute());
                            },
                          ),
                          _SectionTitle(
                            title: AppLabels.generalSection(context),
                          ),
                          _DrawerSettingsTile(
                            icon: Icons.person_search_outlined,
                            title: profile.user.isProfileCreated
                                ? AppLabels.myProfile(context)
                                : AppLabels.completeProfileButton(context),
                            onTap: () {
                              Navigator.pop(context);
                              if (!profile.user.isProfileCreated) {
                                AutoRouter.of(
                                  context,
                                ).push(const MatrimonyFormFlowRoute());
                              } else {
                                AutoRouter.of(
                                  context,
                                ).push(MyProfileRoute(uid: userId));
                              }
                            },
                          ),
                          _DrawerSettingsTile(
                            icon: Icons.tune_rounded,
                            title: "Partner Preferences",
                            onTap: () {
                              Navigator.pop(context);
                              showGeneralDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierLabel: 'Preferences',
                                transitionDuration: const Duration(
                                  milliseconds: 400,
                                ),
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const FilterRightSheet(),
                                transitionBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return SlideTransition(
                                        position: Tween(
                                          begin: const Offset(1, 0),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      );
                                    },
                              );
                            },
                          ),
                          _DrawerSettingsTile(
                            icon: Icons.support_agent_outlined,
                            title: AppLabels.agentDetails(context),
                            onTap: () {
                              Navigator.pop(context);
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
                                  SnackBar(
                                    content: Text(
                                      AppLabels.noAgentAssigned(context),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          _DrawerSettingsTile(
                            icon: Icons.verified_user_outlined,
                            title: AppLabels.userStatus(context),
                            onTap: () {
                              Navigator.pop(context);
                              AutoRouter.of(context).push(UserStatusRoute());
                            },
                          ),
                          _DrawerSettingsTile(
                            icon: Icons.contact_support_outlined,
                            title: AppLabels.support(context),
                            onTap: () {
                              Navigator.pop(context);
                              AutoRouter.of(
                                context,
                              ).push(const ContactUsRoute());
                            },
                          ),
                          _DrawerSettingsTile(
                            icon: Icons.support_agent_outlined,
                            title: AppLabels.supportTickets(context),
                            onTap: () {
                              Navigator.pop(context);
                              AutoRouter.of(
                                context,
                              ).push(SupportTicketsRoute(userId: userId));
                            },
                          ),

                          _SectionTitle(
                            title: AppLabels.accountSettings(context),
                          ),
                          _DrawerSettingsTile(
                            icon: Icons.lock_outline,
                            title: AppLabels.changePassword(context),
                            onTap: () {
                              Navigator.pop(context);
                              AutoRouter.of(
                                context,
                              ).push(ChangePasswordRoute());
                            },
                          ),
                          _DrawerSettingsTile(
                            icon: Icons.payment_outlined,
                            title: AppLabels.paymentHistory(context),
                            onTap: () {
                              Navigator.pop(context);
                              AutoRouter.of(
                                context,
                              ).push(UserPaymentOrderHistoryRoute());
                            },
                          ),
                          _DrawerSettingsTile(
                            icon: Icons.family_restroom_outlined,
                            title: AppLabels.postMarriagePayment(context),
                            onTap: () {
                              Navigator.pop(context);
                              AutoRouter.of(context).push(
                                UserAfterMarriagePaymentRoute(userId: userId),
                              );
                            },
                          ),
                          _DrawerSettingsTile(
                            icon: Icons.notifications_outlined,
                            title: AppLabels.notifications(context),
                            trailing: Consumer(
                              builder: (context, ref, _) {
                                final count = ref.watch(
                                  unreadNotificationsCountProvider,
                                );
                                if (count <= 0)
                                  return const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Colors.grey,
                                  );
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    count > 99 ? '99+' : count.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              AutoRouter.of(
                                context,
                              ).push(const UserNotificationRoute());
                            },
                          ),
                          _DrawerSettingsTile(
                            icon: Icons.language,
                            title: AppLabels.language(context),
                            onTap: () {
                              Navigator.pop(context);
                              _showLanguageDialog(context);
                            },
                          ),

                          _SectionTitle(title: AppLabels.legalAndInfo(context)),
                          _DrawerSettingsTile(
                            icon: Icons.info_outline,
                            title: AppLabels.aboutUs(context),
                            onTap: () {
                              Navigator.pop(context);
                              AutoRouter.of(context).push(const AboutUsRoute());
                            },
                          ),
                          _DrawerSettingsTile(
                            icon: Icons.privacy_tip_outlined,
                            title: AppLabels.privacyPolicy(context),
                            onTap: () {
                              Navigator.pop(context);
                              AppConstants.openUrl(
                                AppConstants.privacyPolicyUrl,
                              );
                            },
                          ),
                          _DrawerSettingsTile(
                            icon: Icons.description_outlined,
                            title: AppLabels.termsAndConditions(context),
                            onTap: () {
                              Navigator.pop(context);
                              AppConstants.openUrl(
                                AppConstants.termsAndConditionsUrl,
                              );
                            },
                          ),
                          _DrawerSettingsTile(
                            icon: Icons.security_outlined,
                            title: "Child Safety Standards",
                            onTap: () {
                              Navigator.pop(context);
                              AppConstants.openUrl(
                                AppConstants.childSafetyStandardsUrl,
                              );
                            },
                          ),
                          _DrawerSettingsTile(
                            icon: Icons.share_outlined,
                            title: AppLabels.shareApp(context),
                            onTap: () async {
                              const String packageName = "com.shaadimilan.app";
                              const String playStoreLink =
                                  "https://play.google.com/store/apps/details?id=$packageName";
                              await Share.share(
                                'Check out ${AppConstants.appName}! Find your perfect match here: $playStoreLink',
                                subject:
                                    'Download ${AppConstants.appNameRaw} App',
                              );
                            },
                          ),
                          _DrawerSettingsTile(
                            icon: Icons.star_rate_outlined,
                            title: AppLabels.rateUs(context),
                            onTap: () async {
                              final InAppReview inAppReview =
                                  InAppReview.instance;
                              if (await inAppReview.isAvailable()) {
                                inAppReview.openStoreListing(
                                  appStoreId: 'YOUR_IOS_APP_ID_HERE',
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Consumer(
                  builder: (context, ref, child) {
                    return OutlinedButton.icon(
                      icon: const Icon(Icons.logout, size: 18),
                      label: Text(
                        AppLabels.logout(context),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                                child: Text(
                                  AppLabels.logout(context),
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          final authRepo = ref.read(authRepositoryProvider);
                          await authRepo.signOut();
                          if (context.mounted) {
                            AutoRouter.of(
                              context,
                            ).replaceAll([const RoleSelectionRoute()]);
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLabels.selectLanguage(context)),
          content: Consumer(
            builder: (context, ref, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: AppTranslation.supportedTranslations.map((
                  translation,
                ) {
                  return ListTile(
                    title: Text(translation.nativeName),
                    subtitle: Text(translation.name),
                    onTap: () {
                      final translationService = ref.read(
                        appTranslationServiceProvider,
                      );
                      final localeNotifier = ref.read(localeProvider.notifier);

                      translationService.setLanguageCode(
                        translation.languageCode,
                      );
                      localeNotifier.state = Locale(translation.languageCode);

                      if (context.mounted) Navigator.pop(context);
                    },
                  );
                }).toList(),
              );
            },
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final MetrimonyProfileViewModel profile;
  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final hasImage = profile.userProfile.profileImageUrl.isNotEmpty;
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white24,
          backgroundImage: hasImage
              ? CachedNetworkImageProvider(profile.userProfile.profileImageUrl)
              : null,
          child: !hasImage
              ? Text(
                  profile.userProfile.fullName.en.isNotEmpty
                      ? profile.userProfile.fullName.en[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 12),
        BilingualParser(
          value: profile.user.fullName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          profile.user.email?.toLowerCase() ?? "",
          style: const TextStyle(fontSize: 12, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DrawerSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _DrawerSettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.primaryColor, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
      onTap: onTap,
      dense: true,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DrawerPremiumActiveCard extends StatelessWidget {
  final dynamic user;
  const _DrawerPremiumActiveCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        AutoRouter.of(context).push(UserPaymentSuccessRoute(user: user));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.verified_user_rounded,
              color: Colors.green,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLabels.premiumActive(context),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    AppLabels.premiumMemberMessage(context),
                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.green),
          ],
        ),
      ),
    );
  }
}

class _DrawerUpgradePremiumCard extends StatelessWidget {
  final MetrimonyProfileViewModel profile;
  const _DrawerUpgradePremiumCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (!ProfileActionGate.ensureProfileComplete(
          context,
          isProfileCreated: profile.user.isProfileCreated,
        )) {
          return;
        }
        if (profile.user.agentId.isEmpty) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            backgroundColor: theme.canvasColor,
            builder: (BuildContext context) => const AgentFormWidget(),
          );
        } else {
          AutoRouter.of(
            context,
          ).push(UserPaymentRoute(userId: profile.userProfile.uid));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLabels.upgradeToPremium(context),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    AppLabels.premiumUpgradeBenefits(context),
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _DrawerCompleteProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        AutoRouter.of(context).push(const MatrimonyFormFlowRoute());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [theme.primaryColor, Colors.orange.shade700],
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.edit_note_rounded, color: Colors.white, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLabels.completeProfileTitle(context),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    AppLabels.completeProfileButton(context),
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
