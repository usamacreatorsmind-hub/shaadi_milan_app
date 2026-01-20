import 'app_router.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AgentGuard extends AutoRouteGuard {
  final Ref ref;

  AgentGuard(this.ref);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final authState = ref.read(authStateProvider);
    final eitherUser = authState.value;

    if (eitherUser != null && eitherUser.isLeft()) {
      resolver.next(true);
    } else {
      // If not logged in, send to agent login.
      router.replaceAll([AgentLoginRoute()]);
    }
  }
}
