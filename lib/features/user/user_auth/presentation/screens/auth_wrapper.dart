import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/user_repo_impl.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/router/app_router.dart';
import '../../../user_app/domain/states/user_state.dart';
import '../providers/auth_providers.dart';

@RoutePage()
class AuthWrapperScreen extends ConsumerStatefulWidget {
  const AuthWrapperScreen({super.key});

  @override
  ConsumerState<AuthWrapperScreen> createState() => _AuthWrapperScreenState();
}

class _AuthWrapperScreenState extends ConsumerState<AuthWrapperScreen> {
  late final ProviderSubscription _authSub;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _authSub = ref.listenManual<AsyncValue<AppUser?>>(authStateProvider, (
      _,
      authState,
    ) async {
      if (_hasNavigated) return;

      final router = context.router;

      authState.when(
        data: (user) async {
          if (!mounted || _hasNavigated) return;

          // 🔹 Not logged in
          if (user == null) {
            _hasNavigated = true;
            router.replaceAll([const OnboardingRoute()]);
            return;
          }

          // 🔹 Agent flow
          if (user.role == 'agent') {
            _hasNavigated = true;
            router.replaceAll([AgentDashboardRoute(uid: user.uid)]);
            return;
          }

          // 🔹 User flow
          try {
            final status = await ref
                .read(userRepositoryProvider)
                .fetchUserStatus(user.uid);
            print("this is status");
            print(status);

            if (!mounted || _hasNavigated) return;

            _hasNavigated = true;

            if (status.isProfileCreated) {
              debugPrint('✅ Profile created');
              router.replaceAll([const UserMainShellRoute()]);
            } else {
              debugPrint('📝 Profile not created');
              router.replaceAll([const MatrimonyFormFlowRoute()]);
            }
          } catch (e, st) {
            print("this is error");
            print(st);
            print(e.toString());
            debugPrint('❌ Status fetch failed: $e');
            debugPrintStack(stackTrace: st);

            if (!mounted || _hasNavigated) return;

            // Fallback: If status fetch fails (e.g. missing fields in Firestore),
            // assume profile is incomplete and navigate to form flow.
            _hasNavigated = true;
            router.replaceAll([const MatrimonyFormFlowRoute()]);
          }
        },
        loading: () {},
        error: (e, _) {
          debugPrint('Auth error: $e');
        },
      );
    });
  }

  @override
  void dispose() {
    _authSub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
