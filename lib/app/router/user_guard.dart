import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/features/auth/presentation/providers/auth_providers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserGuard extends AutoRouteGuard {
  final Ref ref;

  UserGuard(this.ref);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final authState = ref.read(authStateProvider);
    final eitherUser = authState.value;

    if (eitherUser != null && eitherUser.isRight()) {
      resolver.next(true);
    } else {
      // If not logged in, send to user login.
      router.replaceAll([UserLoginRoute()]);
    }
  }
}
