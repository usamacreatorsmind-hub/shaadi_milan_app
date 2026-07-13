import 'package:shadi_milan/core/constants/app_constants.dart';
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
        AgentDashboardRoute(agentId: widget.agentId),
        AgentUserRoute(agentId: widget.agentId),
        AgentRevenueRoute(agentId: widget.agentId),
        AgentWishlistRoute(agentId: widget.agentId),
        AgentEntityRoute(uid: widget.agentId),
      ],
      transitionBuilder: (context, child, animation) =>
          FadeTransition(opacity: animation, child: child),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: tabsRouter.activeIndex,
            onTap: tabsRouter.setActiveIndex,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined),
                activeIcon: Icon(Icons.analytics),
                label: AppConstants.navDashboard,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.groups_3_outlined),
                activeIcon: Icon(Icons.groups_3),
                label: AppConstants.navClients,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.payments_outlined),
                activeIcon: Icon(Icons.payments),
                label: AppConstants.navRevenue,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline),
                activeIcon: Icon(Icons.favorite),
                label: AppConstants.navWishlist,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: AppConstants.myProfile,
              ),
            ],
          ),
        );
      },
    );
  }
}
