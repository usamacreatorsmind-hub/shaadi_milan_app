import '../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../features/user/user_razorpay/domain/states/payment.dart';
import '../../../features/user/user_razorpay/presentation/notifier/payment_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

import '../../router/app_router.dart';
import '../../../features/auth/domain/states/user_state.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:riverpod/src/framework.dart';

class UserDrawer extends ConsumerWidget {
  final AsyncValue<UserEntity?> userAsync;

  const UserDrawer({super.key, required this.userAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Drawer(
      child: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text("Something went wrong")),
        data: (user) {
          if (user == null) {
            return const Center(child: Text("No user data"));
          }

          final paymentState = ref.watch(paymentNotifierProvider(user.uid));
          final isPaid = paymentState.status == PayStatus.success;
          final isLoading = paymentState.status == PayStatus.loading;

          void requirePayment() {
            context.maybePop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please subscribe to access this feature'),
                backgroundColor: Colors.red,
              ),
            );
            context.pushRoute(UserPaymentRoute(userId: user.uid));
          }

          void guardedTap(VoidCallback action) {
            if (isLoading) return;
            if (isPaid) {
              requirePayment();
              return;
            }
            action();
          }

          return Column(
            children: [
              DrawerHeader1(user: user),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const _SectionTitle(title: "Main"),

                    DrawerItem(
                      icon: Icons.dashboard_outlined,
                      title: "Dashboard",
                      onTap: () => guardedTap(() {
                        context.maybePop();
                        context.pushRoute(UserMainShellRoute());
                      }),
                    ),

                    DrawerItem(
                      icon: Icons.person_outline,
                      title: "My Profile",
                      onTap: () => guardedTap(() {
                        context.maybePop();
                        context.pushRoute(MyProfileDetailRoute(user: user));
                      }),
                    ),

                    DrawerItem(
                      icon: Icons.favorite_border,
                      title: "Wishlist",
                      onTap: () => guardedTap(() {
                        context.maybePop();
                        context.pushRoute(UserWishListRoute(userId: user.uid));
                      }),
                    ),

                    DrawerItem(
                      icon: Icons.notifications_outlined,
                      title: "Notifications",
                      trailing: _NotificationBadge(count: 3),
                      onTap: () => guardedTap(() {
                        context.maybePop();
                        context.pushRoute(const UserNotificationRoute());
                      }),
                    ),

                    DrawerItem(
                      icon: Icons.settings_outlined,
                      title: "Settings",
                      onTap: () => guardedTap(() {
                        context.maybePop();
                      }),
                    ),

                    const _SectionTitle(title: "Legal & Info"),

                    DrawerItem(
                      icon: Icons.description_outlined,
                      title: "Terms & Conditions",
                      onTap: () {
                        context.maybePop();
                        context.pushRoute(const TermsAndConditionsRoute());
                      },
                    ),

                    DrawerItem(
                      icon: Icons.privacy_tip_outlined,
                      title: "Privacy Policy",
                      onTap: () {
                        context.maybePop();
                        context.pushRoute(const PrivacyPolicyRoute());
                      },
                    ),

                    DrawerItem(
                      icon: Icons.info_outline,
                      title: "About Us",
                      onTap: () {
                        context.maybePop();
                        context.pushRoute(const AboutUsRoute());
                      },
                    ),

                    const _SectionTitle(title: "Support"),

                    DrawerItem(
                      icon: Icons.support_agent,
                      title: 'Support Tickets',
                      onTap: () => guardedTap(() {
                        context.maybePop();
                        context.router.push(
                          SupportTicketsRoute(userId: user.uid),
                        );
                      }),
                    ),

                    DrawerItem(
                      icon: Icons.help_outline,
                      title: "Help & Support",
                      onTap: () {
                        context.maybePop();
                        context.pushRoute(const ContactUsRoute());
                      },
                    ),

                    DrawerItem(
                      icon: Icons.share_outlined,
                      title: "Share App",
                      onTap: () async {
                        // 1. Close the drawer first
                        context.maybePop();

                        // 2. Define your app's Play Store link
                        const String packageName =
                            "com.your.package.name"; // Replace with your package name
                        const String playStoreLink =
                            "https://play.google.com/store/apps/details?id=$packageName";

                        // 3. Trigger the native share sheet
                        await Share.share(
                          'Check out Metrimony! Find your perfect match here: $playStoreLink',
                          subject:
                              'Download Metrimony App', // Subject is used for Email sharing
                        );
                      },
                    ),
                    DrawerItem(
                      icon: Icons.star_rate_outlined,
                      title: "Rate Us",
                      onTap: () async {
                        final InAppReview inAppReview = InAppReview.instance;

                        // Check if the store is reachable on this device
                        if (await inAppReview.isAvailable()) {
                          // openStoreListing opens the specific app page.
                          // appStoreId is ONLY required for iOS (found in App Store Connect).
                          inAppReview.openStoreListing(
                            appStoreId: 'YOUR_IOS_APP_ID_HERE',
                          );
                        }

                        // ignore: use_build_context_synchronously
                        context.maybePop();
                      },
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),

              _LogoutButton(ref: ref),
            ],
          );
        },
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing,
      onTap: onTap,
      horizontalTitleGap: 12,
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

class _NotificationBadge extends StatelessWidget {
  final int count;

  const _NotificationBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class DrawerHeader1 extends StatelessWidget {
  final UserEntity user;

  const DrawerHeader1({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = user.profileImageUrl.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white,
            backgroundImage: hasImage
                ? NetworkImage(user.profileImageUrl)
                : null,
            child: !hasImage
                ? Text(
                    user.fullName[0].toUpperCase(),
                    style: TextStyle(fontSize: 28, color: theme.primaryColor),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            user.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final WidgetRef ref;

  const _LogoutButton({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.logout, size: 20),
          label: const Text("Logout", style: TextStyle(fontSize: 16)),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
            side: BorderSide(color: Theme.of(context).colorScheme.error),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            ref.read(authControllerProvider.notifier).signOut();
            context.router.replace( UserLoginRoute());
          },
        ),
      ),
    );
  }
}
