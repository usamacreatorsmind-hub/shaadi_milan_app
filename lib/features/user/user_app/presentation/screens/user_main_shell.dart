import 'package:shadi_milan/core/constants/app_labels.dart';
import 'package:shadi_milan/features/user/user_app/presentation/widgets/user_drawer.dart';
import 'package:shadi_milan/features/user/user_razorpay/presentation/notifier/payment_notifier.dart';
import 'package:shadi_milan/features/user/user_razorpay/domain/states/payment.dart';

import '../../../../../app/providers/global_providers.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/router/app_router.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import '../controllers/home_controller.dart';
import '../utils/profile_action_gate.dart';

@RoutePage()
class UserMainShellScreen extends ConsumerStatefulWidget {
  const UserMainShellScreen({super.key});

  @override
  ConsumerState<UserMainShellScreen> createState() => _UserMainShellState();
}

class _UserMainShellState extends ConsumerState<UserMainShellScreen> {
  String get currentUid {
    final authUser = ref.watch(authStateProvider).value?.fold((agent) => agent.uid, (user) => user.uid);
    if (authUser != null && authUser.isNotEmpty) return authUser;
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final uid = currentUid;

    ref.listen(authStateProvider, (previous, next) {
      next.whenData((data) {
        if (data == null) {
          context.router.replaceAll([const RoleSelectionRoute()]);
        }
      });
    });

    return AutoTabsRouter(
      routes: [
        UserHomeRoute(),
        UserWishListRoute(userId: uid),
        UserChatRoute(),
        const UserPremiumPlansRoute(),
      ],
      transitionBuilder: (context, child, animation) => FadeTransition(opacity: animation, child: child),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        final paymentState = ref.watch(paymentNotifierProvider(uid));
        final currentUser = ref.watch(currentUserProvider).valueOrNull ??
            ref.watch(authStateProvider).valueOrNull?.fold((_) => null, (u) => u);
        final isProfileCreated = currentUser?.isProfileCreated ?? false;

        return Scaffold(
          drawer: tabsRouter.activeIndex == 3 ? null : UserDrawer(userId: uid),
          appBar: tabsRouter.activeIndex == 3
              ? null
              : AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  title: Text(
                    tabsRouter.activeIndex == 0
                        ? "Matches"
                        : tabsRouter.activeIndex == 1
                        ? AppLabels.wishlistTitle(context)
                        : tabsRouter.activeIndex == 2
                        ? AppLabels.navChat(context)
                        : "Premium Plans",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18),
                  ),
                  centerTitle: true,
                  iconTheme: const IconThemeData(color: Colors.black87),
                  leading: Builder(
                    builder: (context) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
                  ),
                  actions: [
                    if (tabsRouter.activeIndex == 0) ...[
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        tooltip: "Refresh Matches",
                        onPressed: () {
                          ref.read(homeControllerProvider.notifier).refreshAndShuffle();
                          HapticFeedback.lightImpact();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none_outlined),
                        onPressed: () => context.router.push(const UserNotificationRoute()),
                      ),
                    ],
                  ],
                ),
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: tabsRouter.activeIndex,
            onTap: (index) {
              if (paymentState.status == PayStatus.loading) return;

              // If already on Matches (index 0) and tapped again -> refresh & shuffle
              if (index == 0 && tabsRouter.activeIndex == 0) {
                ref.read(homeControllerProvider.notifier).refreshAndShuffle();
                HapticFeedback.lightImpact();
                return;
              }

              // Chat tab (index 2): enforce 2-step rule (Complete Profile -> Premium)
              if (index == 2) {
                final allowed = ProfileActionGate.ensureCanContact(
                  context,
                  isProfileCreated: isProfileCreated,
                  isPremium: paymentState.status == PayStatus.success,
                );
                if (!allowed) {
                  HapticFeedback.heavyImpact();
                  return;
                }
              }

              HapticFeedback.lightImpact();
              tabsRouter.setActiveIndex(index);
            },
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.local_fire_department_outlined),
                activeIcon: const Icon(Icons.local_fire_department),
                label: AppLabels.navHome(context),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.all_inbox_outlined),
                activeIcon: const Icon(Icons.all_inbox),
                label: AppLabels.navWishlist(context),
              ),
              BottomNavigationBarItem(
                icon: Consumer(
                  builder: (context, ref, child) {
                    final unreadCountAsync = ref.watch(totalUnreadMessagesProvider);
                    return unreadCountAsync.when(
                      data: (count) => count > 0
                          ? Badge(label: Text(count.toString()), child: const Icon(Icons.chat_bubble_outline))
                          : const Icon(Icons.chat_bubble_outline),
                      loading: () => const Icon(Icons.chat_bubble_outline),
                      error: (_, __) => const Icon(Icons.chat_bubble_outline),
                    );
                  },
                ),
                activeIcon: Consumer(
                  builder: (context, ref, child) {
                    final unreadCountAsync = ref.watch(totalUnreadMessagesProvider);
                    return unreadCountAsync.when(
                      data: (count) => count > 0
                          ? Badge(label: Text(count.toString()), child: const Icon(Icons.chat_bubble))
                          : const Icon(Icons.chat_bubble),
                      loading: () => const Icon(Icons.chat_bubble),
                      error: (_, __) => const Icon(Icons.chat_bubble),
                    );
                  },
                ),
                label: AppLabels.navChat(context),
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.workspace_premium_outlined),
                activeIcon: Icon(Icons.workspace_premium),
                label: "Premium",
              ),
            ],
          ),
        );
      },
    );
  }
}
