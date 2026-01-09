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
        AutoRoute(page: UserHomeRoute.page),
        AutoRoute(page: AgentDashboardRoute.page),
        AutoRoute(page: AgentEntityRoute.page),
      ],
    ),
    AutoRoute(
      page: AgentContactRoute.page,
      guards: [AuthGuard(ref), AgentGuard(ref)],
    ),
    AutoRoute(
      page: AgentHomeRoute.page,
      guards: [AuthGuard(ref), AgentGuard(ref)],
    ),
  ];
}
