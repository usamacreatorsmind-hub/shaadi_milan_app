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

          // 🔹 User flow - Add small delay to ensure Firestore sync
          if (!mounted || _hasNavigated) return;

          // Wait a moment to allow server to sync isProfileCreated flag
          await Future.delayed(const Duration(milliseconds: 500));

          if (!mounted || _hasNavigated) return;
          _hasNavigated = true;

          debugPrint('🔄 Checking profile creation status...');
          debugPrint('👤 User ID: ${user.uid}');

          debugPrint(
            '📊 User profile status: isProfileCreated=${user.isProfileCreated}',
          );

          //  print all user data
          debugPrint('🗂️ Full user data: $user');

          if (user.isProfileCreated) {
            debugPrint('✅ Profile created - Navigating to main shell');
            router.replaceAll([const UserMainShellRoute()]);
          } else {
            debugPrint('📝 Profile not created - Navigating to form flow');
            router.replaceAll([const MatrimonyFormFlowRoute()]);
          }
        },
        loading: () {
          debugPrint('⏳ Auth state loading...');
        },
        error: (e, st) {
          debugPrint('❌ Auth error: $e\n$st');
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
