import 'package:arvika_marriage_bureau/core/notification/notification_service.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/data/firestore/payment_api._firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../core/themes/app_theme.dart';
import 'providers/global_providers.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);
    // load all data here

    ref.watch(paymentApiFirestoreProvider);

    // final themeMode = ref.watch(themeProvider);
    return Sizer(
      builder: (context, orientation, deviceType) => MaterialApp.router(
        theme: AppTheme.lightTheme,
        // darkTheme: AppTheme.darkTheme,
        // themeMode: themeMode,
        title: 'Arvika Marriage Bureau',
        routerConfig: appRouter.config(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
