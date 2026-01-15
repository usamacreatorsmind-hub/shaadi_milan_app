import 'package:arvika_marriage_bureau/features/user/user_app/presentation/controllers/user_status_controller.dart';
import 'package:flutter/rendering.dart';

import '../../../../auth/presentation/providers/auth_providers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    // 🔹 Listen for Auth State Changes (Logout)
    ref.listen(authStateProvider, (previous, next) {
      next.whenData((data) {
        if (data == null) {
          // User logged out, redirect to Onboarding
          context.router.replaceAll([const OnboardingRoute()]);
        }
      });
    });

    return AutoTabsRouter(
      routes: [
        const UserHomeRoute(),
        UserWishListRoute(userId: uid),

        ReviewRoute(),
        UserProfileRoute(userId: uid),
      ],
      transitionBuilder: (context, child, animation) =>
          FadeTransition(opacity: animation, child: child),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          extendBody: true,
          body: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction == ScrollDirection.reverse) {
                if (_isVisible) setState(() => _isVisible = false);
              } else if (notification.direction == ScrollDirection.forward) {
                if (!_isVisible) setState(() => _isVisible = true);
              }
              return true;
            },
            child: child,
          ),
          bottomNavigationBar: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isVisible ? 100 : 0,
            child: Wrap(
              children: [
                CustomBottomNavBar(
                  currentIndex: tabsRouter.activeIndex,
                  onTap: (index) {
                    _handleTabTap(
                      context: context,
                      ref: ref,
                      tabsRouter: tabsRouter,
                      index: index,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;

  const BottomNavItem({required this.icon, required this.label});
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<BottomNavItem> items = [
    BottomNavItem(icon: Icons.home_outlined, label: 'Home'),
    BottomNavItem(icon: Icons.favorite_outline, label: 'WishList'),
    BottomNavItem(icon: Icons.person_outline, label: 'Reviews'),
    BottomNavItem(icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,

          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final bool isSelected = index == currentIndex;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.red.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[index].icon,
                      size: 16,
                      color: isSelected ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[index].label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.red : Colors.grey,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

void _handleTabTap({
  required BuildContext context,
  required WidgetRef ref,
  required TabsRouter tabsRouter,
  required int index,
}) {
  final userStatus = ref.read(userStatusControllerProvider);

  /// Tabs that REQUIRE subscription
  const restrictedTabs = {3};

  // Always allow Home tab
  if (!restrictedTabs.contains(index)) {
    tabsRouter.setActiveIndex(index);
    return;
  }

  // Allow if subscribed
  if (userStatus.userStatus.isPaymentDone) {
    tabsRouter.setActiveIndex(index);
    return;
  }

  // ❌ BLOCK TAB SWITCH
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Please subscribe to access this feature')),
  );

  // Redirect to payment
  final authState = ref.read(authStateProvider);
  final userId = authState.value?.fold((_) => null, (u) => u.uid);

  if (userId != null) {
    context.router.push(UserPaymentRoute(userId: userId));
  }
}
