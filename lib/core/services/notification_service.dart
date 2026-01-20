import 'dart:io';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static AppRouter? _appRouter;

  /// Callback for handling notification taps (set from app)
  static void Function(Map<String, dynamic> data)? onNotificationTap;

  /// Initialize the notification service
  /// Call ONCE after Firebase.initializeApp()
  static Future<void> init() async {
    await _requestPermission();
    await _getToken();
    await getInstallationId();
    _setupTokenRefreshListener();
    _foregroundListener();
    _onNotificationClick();
    await _terminatedState();
  }

  /// 🧭 Set the router for navigation from notifications
  static void setRouter(AppRouter router) {
    _appRouter = router;
  }

  /// 🔔 Request notification permission
  static Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint("🔔 Permission status: ${settings.authorizationStatus}");
  }

  /// 🔥 Get FCM token
  static Future<String?> _getToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint("🔥 FCM Token: $token");
      return token;
    } catch (e) {
      debugPrint("❌ Error getting token: $e");
      return null;
    }
  }

  /// 🆔 Get Firebase Installation ID (FID)
  static Future<String?> getInstallationId() async {
    try {
      final String id = await FirebaseInstallations.instance.getId();
      debugPrint("🆔 Firebase Installation ID: $id");
      return id;
    } catch (e) {
      debugPrint("❌ Error getting Installation ID: $e");
      return null;
    }
  }

  /// Public token getter
  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// 🔄 Token refresh listener
  static void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint("🔄 Token refreshed: $newToken");
      // Update token in Firestore if user is logged in
      await _updateRefreshedToken(newToken);
    });
  }

  /// Update refreshed token in Firestore
  static Future<void> _updateRefreshedToken(String newToken) async {
    try {
      // Check agents collection first
      final agentsQuery = await FirebaseFirestore.instance
          .collection('agents')
          .where('fcmToken', isNotEqualTo: newToken)
          .limit(1)
          .get();

      for (final doc in agentsQuery.docs) {
        final oldToken = doc.data()['fcmToken'];
        if (oldToken != null && oldToken != newToken) {
          await doc.reference.update({
            'fcmToken': newToken,
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          });
          debugPrint("✅ Agent token updated: ${doc.id}");
          return;
        }
      }

      // Check users collection
      final usersQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('fcmToken', isNotEqualTo: newToken)
          .limit(1)
          .get();

      for (final doc in usersQuery.docs) {
        final oldToken = doc.data()['fcmToken'];
        if (oldToken != null && oldToken != newToken) {
          await doc.reference.update({
            'fcmToken': newToken,
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          });
          debugPrint("✅ User token updated: ${doc.id}");
          return;
        }
      }
    } catch (e) {
      debugPrint("❌ Error updating refreshed token: $e");
    }
  }

  /// 💾 Save token to Firestore
  static Future<void> saveAdminTokenToFirestore(String userId) async {
    try {
      final token = await getToken();
      if (token != null && userId.isNotEmpty) {
        await FirebaseFirestore.instance.collection('agents').doc(userId).set({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          'platform': Platform.operatingSystem,
        }, SetOptions(merge: true));
        debugPrint("✅ Token saved for Agent: $userId");
      }
    } catch (e) {
      debugPrint("❌ Save token error for agent: $e");
    }
  }

  /// 💾 Save token to Firestore
  static Future<void> saveUserTokenToFirestore(String userId) async {
    try {
      final token = await getToken();
      if (token != null && userId.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          'platform': Platform.operatingSystem,
        }, SetOptions(merge: true));
        debugPrint("✅ Token saved for user: $userId");
      }
    } catch (e) {
      debugPrint("❌ Save token error for user: $e");
    }
  }

  /// ❌ Remove token on logout
  static Future<void> removeTokenFromFirestore(String userId) async {
    try {
      if (userId.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {
            'fcmToken': FieldValue.delete(),
            'fcmTokenUpdatedAt': FieldValue.delete(),
          },
        );
        debugPrint("🗑 Token removed for user: $userId");
      }
    } catch (e) {
      debugPrint("❌ Remove token error: $e");
    }
  }

  /// 🟢 FOREGROUND messages
  /// Shows local notification using Awesome Notifications
  static void _foregroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("🟢 Foreground Message: ${message.data}");

      // Show local notification using Awesome Notifications
      _showLocalNotification(message);
    });
  }

  /// Show local notification using Awesome Notifications
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        // icon: 'resource://drawable/ic_notification',
        displayOnBackground: true,

        badge: 10,

        displayOnForeground: true,

        id: Random().nextInt(100000),
        channelKey: 'fcm_channel',
        title: notification?.title ?? data['title'] ?? 'New Notification',
        body: notification?.body ?? data['body'] ?? '',
        largeIcon: notification?.android?.imageUrl ?? data['image'],
        bigPicture: notification?.android?.imageUrl ?? data['image'],

        payload: data.map((k, v) => MapEntry(k, v.toString())),
        notificationLayout:
            (notification?.android?.imageUrl != null || data['image'] != null)
            ? NotificationLayout.BigPicture
            : NotificationLayout.Default,
      ),
    );
  }

  /// Create a local notification manually
  static Future<void> showNotification({
    required String title,
    required String body,
    Map<String, String>? payload,
    String channelKey = 'basic_channel',
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random().nextInt(100000),

        // icon: 'resource://drawable/ic_notification',
        channelKey: channelKey,
        title: title,
        body: body,
        payload: payload,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  /// Schedule a notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, String>? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'scheduled_channel',
        notificationLayout: NotificationLayout.Default,

        // icon: 'resource://drawable/ic_notification',
        wakeUpScreen: true,

        title: title,
        body: body,
        payload: payload,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledTime),
    );
  }

  /// Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  /// Set up Awesome Notifications listeners
  static void setNotificationListeners({
    required Future<void> Function(ReceivedAction) onActionReceived,
  }) {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceived,
    );
  }

  /// 🟡 BACKGROUND → notification tap
  static void _onNotificationClick() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("🟡 Notification Clicked: ${message.data}");
      _handleNavigation(message.data);
    });
  }

  /// 🔴 TERMINATED → app opened via notification
  static Future<void> _terminatedState() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      debugPrint("🔴 Terminated launch: ${message.data}");
      Future.delayed(const Duration(milliseconds: 400), () {
        _handleNavigation(message.data);
      });
    }
  }

  /// 🧭 Central navigation handler
  static void _handleNavigation(Map<String, dynamic> data) {
    if (data.isEmpty) return;

    debugPrint("➡️ Handle navigation data: $data");
    onNotificationTap?.call(data);

    if (_appRouter == null) {
      debugPrint("Router not available in NotificationService for navigation.");
      return;
    }

    final screen = data['screen'] as String?;
    final agentId = data['agentId'] as String?;
    final userId = data['id'] as String?;

    if (screen == 'agent_users_screen' && agentId != null) {
      debugPrint("Navigating to AgentUserScreen for agent ID: $agentId");
      _appRouter!.push(AgentUserRoute(agentId: agentId));
    } else if (screen == 'agent_user_view' && userId != null) {
      // This is an example for another route, keeping existing logic pattern.
      debugPrint("Navigating to AgentUserView for user ID: $userId");
      // _appRouter!.push(ViewUserRoute(userId: userId));
    }
  }

  /// 📡 Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint("📡 Subscribed to $topic");
    } catch (e) {
      debugPrint("❌ Topic subscribe error: $e");
    }
  }

  /// 🚫 Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint("📡 Unsubscribed from $topic");
    } catch (e) {
      debugPrint("❌ Topic unsubscribe error: $e");
    }
  }
}
