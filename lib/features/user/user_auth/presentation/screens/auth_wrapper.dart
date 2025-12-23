import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/userstatus_repository.dart';

import '../../../user_app/domain/states/user_state.dart';

import '../../../../../app/router/app_router.dart';
import '../providers/auth_providers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class AuthWrapperScreen extends ConsumerStatefulWidget {
  const AuthWrapperScreen({super.key});

  @override
  ConsumerState<AuthWrapperScreen> createState() => _AuthWrapperScreenState();
}

class _AuthWrapperScreenState extends ConsumerState<AuthWrapperScreen> {
  late final ProviderSubscription _authSub;

  @override
  void initState() {
    super.initState();

    _authSub = ref.listenManual<AsyncValue<AppUser?>>(authStateProvider, (
      _,
      authState,
    ) async {
      final router = context.router;

      authState.when(
        data: (user) async {
          if (!mounted) return;

          if (user == null) {
            router.replaceAll([const OnboardingRoute()]);
            return;
          }

          if (user.role == 'agent') {
            router.replaceAll([AgentDashboardRoute(uid: user.uid)]);
            return;
          }

          // ✅ USER FLOW (WAIT FOR FIRESTORE STREAM)
          try {
            final status = await ref
                .read(userStatusRepositoryProvider)
                .watchUserStatus(user.uid)
                .first;

            if (!mounted) return;

            if (status.isProfileCreated) {
              debugPrint('User profile created: ${status.isProfileCreated}');
              debugPrint(status.toString());
              router.replaceAll([const UserMainShellRoute()]);
            } else {
              debugPrint('User profile created: ${status.isProfileCreated}');
              router.replaceAll([const MatrimonyFormFlowRoute()]);
            }
          } catch (e) {
            debugPrint("Error fetching user status: $e");
          }
        },
        loading: () {},
        error: (_, __) {},
      );
    });
  }

  @override
  void dispose() {
    _authSub.close(); // 🔴 VERY IMPORTANT
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
