import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/features/auth/presentation/providers/auth_providers.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/controllers/user_status_controller.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/user_profile_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserSubscriptionGuard extends AutoRouteGuard {
  final Ref ref;

  UserSubscriptionGuard(this.ref);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    debugPrint('🔒 UserSubscriptionGuard fired');

    final authState = ref.read(authStateProvider);
    final userStatusState = ref.read(userStatusControllerProvider);

    final userId = authState.value?.fold((agent) => null, (user) => user.uid);

    if (userId == null) {
      resolver.redirect(const UserLoginRoute());
      return;
    }

    if (userStatusState.isLoading) {
      // // 🔥 WAIT screen instead of blocking router
      // resolver.redirect(const SplashRoute());
      // return;
    }

    if (userStatusState.error != null) {
      resolver.redirect(const UserLoginRoute());
      return;
    }

    if (userStatusState.userStatus.isPaymentDone) {
      resolver.next(true);
      return;
    }

    resolver.redirect(UserPaymentRoute(userId: userId));
  }
}
