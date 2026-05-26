import 'package:arvika_marriage_bureau/features/user/user_razorpay/presentation/notifier/payment_notifier.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/states/payment.dart';

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
        SupportTicketsRoute(userId: uid),
        UserProfileRoute(userId: uid),
      ],
      transitionBuilder: (context, child, animation) =>
          FadeTransition(opacity: animation, child: child),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        final paymentState = ref.watch(paymentNotifierProvider(uid));
        final isPaid = paymentState.status == PayStatus.success;

        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: tabsRouter.activeIndex,
            onTap: (index) {
              if (paymentState.status == PayStatus.loading) return;

              if (!isPaid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please subscribe to access this feature'),
                    backgroundColor: Colors.red,
                  ),
                );
                context.router.push(UserPaymentRoute(userId: uid));
                return;
              }

              HapticFeedback.lightImpact();
              tabsRouter.setActiveIndex(index);
            },
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline),
                activeIcon: Icon(Icons.favorite),
                label: 'WishList',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.support_agent_outlined),
                activeIcon: Icon(Icons.support_agent),
                label: 'Support',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
