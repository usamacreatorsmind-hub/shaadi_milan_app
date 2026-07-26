// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenshot_blocker/flutter_screenshot_blocker.dart';

// import 'core/notification/notification_service.dart';
// import 'app/app.dart';
// import 'core/env/app_env.dart';
// import 'core/env/app_env_config.dart';
// import 'core/notification/in_app_messaging_service.dart';
// import 'firebase_options.dart';

// // Background handler - must be a top-level function
// @pragma('vm:entry-point')
// Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   await AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
//       channelKey: 'fcm_channel',
//       title: message.notification?.title ?? 'New Notification',
//       body: message.notification?.body ?? '',
//       icon: 'resource://drawable/ic_notification', // ✅ REQUIRED
//       notificationLayout: NotificationLayout.Default,
//     ),
//   );
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   AppEnvConfig.init(environment: AppEnvironment.prod);

//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   // Must be registered before runApp
//   FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

//   runApp(const ProviderScope(child: App()));

//   // Defer non-critical init so the first frame renders immediately
//   await AwesomeNotifications()
//       .initialize('resource://drawable/ic_notification', [
//         NotificationChannel(
//           channelKey: 'basic_channel',
//           channelName: 'Basic Notifications',
//           channelDescription: 'General notifications',
//           importance: NotificationImportance.High,
//           channelShowBadge: true,
//         ),
//         NotificationChannel(
//           channelKey: 'scheduled_channel',
//           channelName: 'Scheduled Notifications',
//           channelDescription: 'Scheduled reminders',
//           importance: NotificationImportance.High,
//           channelShowBadge: true,
//         ),
//         NotificationChannel(
//           channelKey: 'fcm_channel',
//           channelName: 'FCM Notifications',
//           channelDescription: 'Firebase Cloud Messaging',
//           importance: NotificationImportance.Max,
//           playSound: true,
//           enableVibration: true,
//           channelShowBadge: true,
//         ),
//       ], debug: false);

//   final isAllowed = await AwesomeNotifications().isNotificationAllowed();
//   if (!isAllowed) {
//     await AwesomeNotifications().requestPermissionToSendNotifications();
//   }

//   await Future.wait([
//     NotificationService.init(),
//     InAppMessagingService.init(),
//     FlutterScreenshotBlocker.enableScreenshotBlocking(),
//   ]);
// }
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenshot_blocker/flutter_screenshot_blocker.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'features/l10n/app_translation_service.dart';

import 'app/app.dart';
import 'core/env/app_env.dart';
import 'core/env/app_env_config.dart';
import 'core/notification/in_app_messaging_service.dart';
import 'core/notification/notification_service.dart';
import 'firebase_options.dart';
import 'core/constants/app_constants.dart';

/// Background FCM handler
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await AwesomeNotifications().initialize(AppConstants.notificationIcon, [
    NotificationChannel(
      channelKey: AppConstants.fcmChannelKey,
      channelName: AppConstants.fcmChannelName,
      channelDescription: AppConstants.fcmChannelDescription,
      importance: NotificationImportance.Max,
      playSound: true,
      enableVibration: true,
      channelShowBadge: true,
    ),
  ], debug: false);

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      channelKey: AppConstants.fcmChannelKey,
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      notificationLayout: NotificationLayout.Default,
      icon: AppConstants.notificationIcon,
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// SHARED PREFERENCES
  final sharedPreferences = await SharedPreferences.getInstance();

  /// ENV
  AppEnvConfig.init(environment: AppEnvironment.prod);

  /// FIREBASE
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// FCM BACKGROUND HANDLER
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  /// AWESOME NOTIFICATIONS
  await AwesomeNotifications().initialize(AppConstants.notificationIcon, [
    NotificationChannel(
      channelKey: AppConstants.basicChannelKey,
      channelName: AppConstants.basicChannelName,
      channelDescription: AppConstants.basicChannelDescription,
      importance: NotificationImportance.High,
      channelShowBadge: true,
    ),
    NotificationChannel(
      channelKey: AppConstants.scheduledChannelKey,
      channelName: AppConstants.scheduledChannelName,
      channelDescription: AppConstants.scheduledChannelDescription,
      importance: NotificationImportance.High,
      channelShowBadge: true,
    ),
    NotificationChannel(
      channelKey: AppConstants.fcmChannelKey,
      channelName: AppConstants.fcmChannelName,
      channelDescription: AppConstants.fcmChannelDescription,
      importance: NotificationImportance.Max,
      playSound: true,
      enableVibration: true,
      channelShowBadge: true,
    ),
  ], debug: false);

  /// NON-BLOCKING INITIALIZATION
  Future.microtask(() async {
    try {
      // Request notification permission after runApp so Flutter context exists
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }

      await Future.wait([NotificationService.init(), InAppMessagingService.init(), FlutterScreenshotBlocker.enableScreenshotBlocking()]);
    } catch (e, s) {
      debugPrint('Initialization Error: $e');
      debugPrintStack(stackTrace: s);
    }
  });

  /// GLOBAL ERROR HANDLER
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.exceptionAsString());
  };

  runApp(SafeArea(
      top: false,
      child: ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)], child: App())));
}
