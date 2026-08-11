import 'package:shadi_milan/core/constants/app_constants.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';
import 'package:shadi_milan/features/user/user_razorpay/presentation/notifier/payment_notifier.dart';
import 'package:shadi_milan/features/user/user_razorpay/domain/states/payment.dart';

import '../../../../auth/presentation/providers/auth_providers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/router/app_router.dart';

@RoutePage()
class UserMainShellScreen extends ConsumerStatefulWidget {
  const UserMainShellScreen({super.key});

  @override
  ConsumerState<UserMainShellScreen> createState() => _UserMainShellState();
}

class _UserMainShellState extends ConsumerState<UserMainShellScreen> {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) {
      next.whenData((data) {
        if (data == null) {
          context.router.replaceAll([const OnboardingRoute()]);
        }
      });
    });

    return AutoTabsRouter(
      routes: [
        UserHomeRoute(),
        UserWishListRoute(userId: uid),
        UserChatRoute(),
        UserProfileRoute(userId: uid),
      ],
      transitionBuilder: (context, child, animation) =>
          FadeTransition(opacity: animation, child: child),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        final paymentState = ref.watch(paymentNotifierProvider(uid));
        // final isPaid = paymentState.status == PayStatus.success;

        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: tabsRouter.activeIndex,
            onTap: (index) {
              if (paymentState.status == PayStatus.loading) return;
              //
              // if (!isPaid) {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(
              //       content: Text(AppConstants.pleaseSubscribe(context)),
              //       backgroundColor: Colors.red,
              //     ),
              //   );
              //   context.router.push(UserPaymentRoute(userId: uid));
              //   return;
              // }

              HapticFeedback.lightImpact();
              tabsRouter.setActiveIndex(index);
            },
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: AppLabels.navHome(context),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.favorite_outline),
                activeIcon: const Icon(Icons.favorite),
                label: AppLabels.navWishlist(context),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.chat_bubble_outline),
                activeIcon: const Icon(Icons.chat_bubble),
                label:  AppLabels.navChat(context),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: AppLabels.navProfile(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
