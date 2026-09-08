
import 'package:shadi_milan/core/constants/app_labels.dart';
import 'package:shadi_milan/features/user/user_razorpay/data/firestore/payment_api._firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../core/themes/app_theme.dart';
import '../features/l10n/app_localizations.dart';
import '../features/l10n/app_translation_service.dart';
import 'providers/global_providers.dart';
import 'router/app_router.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();

    /// Initialize router once
    _appRouter = ref.read(appRouterProvider);

    /// Lazy initialize payment API after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentApiFirestoreProvider);

      /// Delay remote config slightly to avoid startup freeze
      Future.delayed(const Duration(seconds: 1), () async {
        if (!mounted) return;

        final navigatorContext = _appRouter.navigatorKey.currentContext;

        // if (navigatorContext != null) {
        //   try {
        //     await RemoteConfigService.instance.checkForUpdate(navigatorContext);
        //     await RemoteConfigService.instance.checkForMaintenanceMode(
        //       navigatorContext,
        //     );
        //   } catch (e) {
        //     debugPrint('RemoteConfig Error: $e');
        //   }
        // }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLabels.appName(context),
          locale: locale,

          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          /// THEME
          theme: AppTheme.lightTheme,

          /// ROUTER
          routerConfig: _appRouter.config(),

          /// PERFORMANCE
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child ?? const SizedBox(),
            );
          },
        );
      },
    );
  }
}
