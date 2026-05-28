import 'app_router.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import 'package:auto_route/auto_route.dart';
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
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    authState.when(
      data: (eitherUser) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _hasNavigated) return;
          _hasNavigated = true;

          if (eitherUser == null) {
            context.router.replaceAll([const OnboardingRoute()]);
            return;
          }

          eitherUser.fold(
            (agent) {
              context.router.replaceAll([
                AgentMainShellRoute(agentId: agent.uid),
              ]);
            },
            (user) {
              if (user.isProfileCreated) {
                context.router.replaceAll([UserMainShellRoute()]);
              } else {
                context.router.replaceAll([MatrimonyFormFlowRoute()]);
              }
            },
          );
        });
      },
      loading: () {},
      error: (e, st) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _hasNavigated) return;
          _hasNavigated = true;
          context.router.replaceAll([const OnboardingRoute()]);
        });
      },
    );

    return const LoadingWidget();
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      body: Column(
        children: [
          // a beatifull loader
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png', // Replace with your actual logo path
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  'Loading...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
