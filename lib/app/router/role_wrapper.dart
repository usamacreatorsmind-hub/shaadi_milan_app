import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/features/auth/domain/states/agent_state.dart';
import 'package:arvika_marriage_bureau/features/auth/domain/states/user_state.dart';
import 'package:arvika_marriage_bureau/features/auth/presentation/providers/auth_providers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimal Unified Auth Wrapper
/// Handles: auth check, role routing, profile check for users
///
/// Flow:
/// 1. Check authentication (null → Onboarding)
/// 2. Route by role (agent → dashboard, user → check profile)
/// 3. Route user by profile (complete → shell, incomplete → form)
@RoutePage()
class AuthWrapperScreen extends ConsumerStatefulWidget {
  const AuthWrapperScreen({super.key});

  @override
  ConsumerState<AuthWrapperScreen> createState() => _AuthWrapperScreenState();
}

class _AuthWrapperScreenState extends ConsumerState<AuthWrapperScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasNavigated) return;

      // Default to onboarding after timeout if auth doesn't resolve
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted || _hasNavigated) return;
        _hasNavigated = true;
        context.router.replaceAll([const OnboardingRoute()]);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AsyncValue<Either<AgentEntity, UserEntity>?>>(
      authStateProvider,
      (previous, next) {
        if (_hasNavigated) return;

        next.when(
          data: (eitherUser) {
            if (!mounted || _hasNavigated) return;

            // User not logged in
            if (eitherUser == null) {
              _hasNavigated = true;
              context.router.replaceAll([const OnboardingRoute()]);
              return;
            }

            // User logged in - route by role
            _hasNavigated = true;
            eitherUser.fold(
              (agent) {
                // Agent
                context.router.replaceAll([
                  AgentMainShellRoute(agentId: agent.uid),
                ]);
              },
              (user) {
                // User - check profile
                if (user.isProfileCreated) {
                  context.router.replaceAll([const UserMainShellRoute()]);
                } else {
                  context.router.replaceAll([const MatrimonyFormFlowRoute()]);
                }
              },
            );
          },
          loading: () {
            debugPrint('Auth state loading...');
          },
          error: (e, st) {
            debugPrint('Auth error: $e');
            if (!mounted || _hasNavigated) return;
            _hasNavigated = true;
            context.router.replaceAll([const OnboardingRoute()]);
          },
        );
      },
    );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              authState.when(
                data: (_) => 'Authenticating...',
                loading: () => 'Loading auth state...',
                error: (e, st) => 'Auth error, redirecting...',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
