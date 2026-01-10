import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'agent_guard.dart';
import 'app_router.dart';
import 'auth_guard.dart';

class AgentRouter {
  static List<AutoRoute> routes(Ref ref) => [
    AutoRoute(
      page: AgentMainShellRoute.page,
      guards: [AuthGuard(ref), AgentGuard(ref)],
      children: [
        AutoRoute(page: AgentDashboardRoute.page),

        AutoRoute(page: AgentUserRoute.page),

        AutoRoute(page: AgentRevenueRoute.page),
        AutoRoute(page: AgentActivitiesRoute.page),
      ],
    ),
    AutoRoute(
      page: ViewUserRoute.page,
      guards: [AuthGuard(ref), AgentGuard(ref)],
    ),

    AutoRoute(
      page: AgentContactRoute.page,
      guards: [AuthGuard(ref), AgentGuard(ref)],
    ),
    AutoRoute(
      page: AgentHomeRoute.page,
      guards: [AuthGuard(ref), AgentGuard(ref)],
    ),

    AutoRoute(
      page: ViewPaymentDetailRoute.page,
      guards: [AuthGuard(ref), AgentGuard(ref)],
    ),
    AutoRoute(
      page: MetrimonyProfileRoute.page,
      guards: [AuthGuard(ref), AgentGuard(ref)],
    ),
  ];
}
