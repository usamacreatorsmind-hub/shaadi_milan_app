import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';
import 'package:shadi_milan/features/l10n/app_translation_service.dart';
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
    // Wait for max 1.5s splash duration and non-blocking remote config check
    try {
      await Future.wait([
        Future.delayed(const Duration(milliseconds: 1500)),
        _checkRemoteConfig(),
      ]).timeout(const Duration(seconds: 3));
    } catch (_) {}

    if (mounted) {
      setState(() {
        _timerFinished = true;
      });
      _checkNavigation();
    }
  }

  Future<void> _checkRemoteConfig() async {
    try {
      await RemoteConfigService.instance.checkForUpdate(context).timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('RemoteConfig update check failed: $e');
    }
  }

  Future<void> _checkNavigation() async {
    if (!_timerFinished) return;

    final authState = ref.read(authStateProvider);

    if (authState.isLoading) return; // Will be navigated by ref.listen when auth state resolves

    if (authState.hasError) {
      if (mounted) {
        context.router.replaceAll([UserLoginRoute()]);
      }
      return;
    }

    final value = authState.valueOrNull;
    if (!mounted) return;

    if (value == null) {
      final prefs = ref.read(sharedPreferencesProvider);
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

      if (!hasSeenOnboarding) {
        context.router.replaceAll([const OnboardingRoute()]);
      } else {
        context.router.replaceAll([const RoleSelectionRoute()]);
      }
    } else {
      await value.fold(
        (agent) async {
          context.router.replaceAll([
            AgentMainShellRoute(agentId: agent.uid),
          ]);
        },
        (user) async {
          bool profileCreated = user.isProfileCreated;
          if (!profileCreated) {
            try {
              // 1. Direct doc check by user.uid
              var matrimonyDoc = await FirebaseFirestore.instance
                  .collection('metrimony_profiles')
                  .doc(user.uid)
                  .get();

              if (matrimonyDoc.exists) {
                profileCreated = true;
              } else {
                // 2. Query by userId field
                var queryByUserId = await FirebaseFirestore.instance
                    .collection('metrimony_profiles')
                    .where('userId', isEqualTo: user.uid)
                    .limit(1)
                    .get();

                if (queryByUserId.docs.isNotEmpty) {
                  profileCreated = true;
                } else if (user.phone.isNotEmpty) {
                  // 3. Query by phone
                  final cleanPhone = user.phone.replaceAll(RegExp(r'\D'), '');
                  final last10 = cleanPhone.length >= 10 ? cleanPhone.substring(cleanPhone.length - 10) : cleanPhone;
                  if (last10.isNotEmpty) {
                    var queryByPhone = await FirebaseFirestore.instance
                        .collection('metrimony_profiles')
                        .where('phone', isEqualTo: last10)
                        .limit(1)
                        .get();

                    if (queryByPhone.docs.isEmpty) {
                      queryByPhone = await FirebaseFirestore.instance
                          .collection('metrimony_profiles')
                          .where('phone', isEqualTo: user.phone)
                          .limit(1)
                          .get();
                    }

                    if (queryByPhone.docs.isNotEmpty) {
                      profileCreated = true;
                    }
                  }
                }
              }

              if (!mounted) return;

              if (profileCreated) {
                // Self-heal users doc in background
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .set({
                      'isProfileCreated': true,
                      'userStatus': {'isProfileCreated': true},
                    }, SetOptions(merge: true));
              }
            } catch (e) {
              debugPrint('Error checking profile existence: $e');
            }
          }

          if (!profileCreated) {
            context.router.replaceAll([const MatrimonyFormFlowRoute()]);
            return;
          }
          context.router.replaceAll([UserMainShellRoute()]);
        },
      );
    }
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
                    AppLabels.appName (context),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLabels.splashTagline(context),
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
