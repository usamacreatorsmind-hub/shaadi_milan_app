import 'package:arvika_marriage_bureau/core/app_version_config/remote_config_service.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/data/firestore/payment_api._firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import 'router/app_router.dart';
import '../core/themes/app_theme.dart';
import 'providers/global_providers.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appRouter = ref.watch(appRouterProvider);

    ref.watch(paymentApiFirestoreProvider);

    return Sizer(
      builder: (context, orientation, deviceType) => MaterialApp.router(
        theme: AppTheme.lightTheme,
        title: 'Arvika Marriage Bureau',
        routerConfig: appRouter.config(),
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return _GlobalUpdateChecker(appRouter: appRouter, child: child!);
        },
      ),
    );
  }
}

/// Wrapper to perform version check once the MaterialApp is initialized
class _GlobalUpdateChecker extends StatefulWidget {
  final AppRouter appRouter;
  final Widget child;
  const _GlobalUpdateChecker({required this.appRouter, required this.child});

  @override
  State<_GlobalUpdateChecker> createState() => _GlobalUpdateCheckerState();
}

class _GlobalUpdateCheckerState extends State<_GlobalUpdateChecker> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final navigatorContext = widget.appRouter.navigatorKey.currentContext;
      if (navigatorContext != null) {
        RemoteConfigService.instance.checkForUpdate(navigatorContext);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
