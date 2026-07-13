import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import 'app_router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../core/app_version_config/remote_config_service.dart';
import '../custom/custom_widgets/app_logo.dart';

@RoutePage()
class AuthWrapperScreen extends ConsumerStatefulWidget {
  const AuthWrapperScreen({super.key});

  @override
  ConsumerState<AuthWrapperScreen> createState() => _AuthWrapperScreenState();
}

class _AuthWrapperScreenState extends ConsumerState<AuthWrapperScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _timerFinished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    _init();
  }

  Future<void> _init() async {
    // Wait for splash duration and check remote config
    await Future.wait([
      Future.delayed(const Duration(seconds: 1)),
      _checkRemoteConfig(),
    ]);
    if (mounted) {
      setState(() {
        _timerFinished = true;
      });
      _checkNavigation();
    }
  }

  Future<void> _checkRemoteConfig() async {
    try {
      await RemoteConfigService.instance.checkForUpdate(context);
    } catch (e) {
      debugPrint('RemoteConfig update check failed: $e');
    }
  }

  void _checkNavigation() {
    if (!_timerFinished) return;

    final authState = ref.read(authStateProvider);
    authState.whenData((value) {
      if (!mounted) return;
      if (value == null) {
        context.router.replaceAll([const OnboardingRoute()]);
      } else {
        value.fold(
          (agent) => context.router.replaceAll([
            AgentMainShellRoute(agentId: agent.uid),
          ]),
          (user) {
            if (!user.isProfileCreated) {
              context.router.replaceAll([const MatrimonyFormFlowRoute()]);
              return;
            }
            context.router.replaceAll([UserMainShellRoute()]);
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Try navigation whenever authState changes, as long as timer finished
    ref.listen(authStateProvider, (previous, next) {
      if (next.hasValue) {
        _checkNavigation();
      }
    });

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, theme.primaryColor.withOpacity(0.05)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: const AppLogo(size: 180),
              ),
            ),
            const SizedBox(height: 30),
            FadeTransition(
              opacity: _opacityAnimation,
              child: Column(
                children: [
                  Text(
                    AppConstants.appName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppConstants.splashTagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: 40,
              child: LinearProgressIndicator(
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                color: theme.primaryColor,
                minHeight: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
