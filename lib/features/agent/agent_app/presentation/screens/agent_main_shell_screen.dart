import 'package:flutter/rendering.dart';

import '../../../../auth/presentation/providers/auth_providers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/router/app_router.dart';

@RoutePage()
class AgentMainShellScreen extends ConsumerStatefulWidget {
  final String agentId;
  const AgentMainShellScreen({required this.agentId, super.key});

  @override
  ConsumerState<AgentMainShellScreen> createState() => _AgentMainShellState();
}

class _AgentMainShellState extends ConsumerState<AgentMainShellScreen> {
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
        AgentDashboardRoute(agentId: widget.agentId),
        AgentUserRoute(agentId: widget.agentId),
        AgentRevenueRoute(agentId: widget.agentId),
        AgentEntityRoute(uid: widget.agentId),
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
                  onTap: tabsRouter.setActiveIndex,
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
    BottomNavItem(
      icon: Icons.analytics_outlined,
      label: 'Dashboard', // Stats & Overview
    ),
    BottomNavItem(
      icon: Icons.groups_3_outlined,
      label: 'Clients', // Their own data/profiles
    ),
    BottomNavItem(
      icon: Icons.payments_outlined,
      label: 'Revenue', // Earnings & Commissions
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      label: 'My Profile', // Tasks, Meetings, & Follow-ups
    ),
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
                      size: 24,
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
