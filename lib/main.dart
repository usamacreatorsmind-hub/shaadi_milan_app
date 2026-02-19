import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upgrader/upgrader.dart';

import 'core/notification/notification_service.dart';
import 'app/app.dart';
import 'core/env/app_env.dart';
import 'core/env/app_env_config.dart';
import 'core/notification/in_app_messaging_service.dart';
import 'firebase_options.dart';

// Background handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      channelKey: 'fcm_channel',
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      icon: 'resource://drawable/ic_notification', // ✅ REQUIRED
      notificationLayout: NotificationLayout.Default,
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppEnvConfig.init(environment: AppEnvironment.prod);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await AwesomeNotifications().initialize(
    'resource://drawable/ic_notification', // ✅ REQUIRED
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'General notifications',
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
      NotificationChannel(
        channelKey: 'scheduled_channel',
        channelName: 'Scheduled Notifications',
        channelDescription: 'Scheduled reminders',
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
      NotificationChannel(
        channelKey: 'fcm_channel',
        channelName: 'FCM Notifications',
        channelDescription: 'Firebase Cloud Messaging',
        importance: NotificationImportance.Max,
        playSound: true,
        enableVibration: true,
        channelShowBadge: true,
      ),
    ],
    debug: true,
  );

  // Permission request
  final isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  await NotificationService.init();
  await InAppMessagingService.init();

  runApp(UpgradeAlert(child: const ProviderScope(child: App())));
}
