import 'dart:io';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shadi_milan/app/router/app_router.dart';
import 'package:shadi_milan/core/constants/app_constants.dart';
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
        // icon: AppConstants.notificationIcon,
        displayOnBackground: true,

        badge: 10,

        displayOnForeground: true,

        id: Random().nextInt(100000),
        channelKey: AppConstants.fcmChannelKey,
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
    String channelKey = AppConstants.basicChannelKey,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random().nextInt(100000),

        // icon: AppConstants.notificationIcon,
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
        channelKey: AppConstants.scheduledChannelKey,
        notificationLayout: NotificationLayout.Default,

        // icon: AppConstants.notificationIcon,
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

  /// Central navigation handler
  static void _handleNavigation(Map<String, dynamic> data) {
    if (data.isEmpty) return;

    debugPrint("Handle navigation data: $data");

    // Optional external callback
    onNotificationTap?.call(data);

    if (_appRouter == null) {
      debugPrint("Router not available in NotificationService");
      return;
    }

    final screen = data['screen'] as String?;
    final type = data['type'] as String?;

    // Extract IDs from notification data
    final userId = data['userId'] as String? ?? data['id'] as String?;
    final agentId = data['agentId'] as String?;
    final profileId = data['profileId'] as String?;
    final ticketId = data['ticketId'] as String?;
    final senderId = data['senderId'] as String?;

    debugPrint(
      "Navigation: screen=$screen, type=$type, userId=$userId, agentId=$agentId",
    );

    switch (screen) {
      // ============ AGENT SCREENS ============

      // View user details (for agent)
      case 'view_user':
      case 'agent_user_view':
        if (userId != null) {
          debugPrint("Navigating to ViewUserScreen: userId=$userId");
          _appRouter!.push(ViewUserRoute(userId: userId));
        }
        break;

      // Agent users list
      case 'agent_users_screen':
        if (agentId != null) {
          debugPrint("Navigating to AgentUserScreen: agentId=$agentId");
          _appRouter!.push(AgentUserRoute(agentId: agentId));
        }
        break;

      // Agent wishlist screen
      case 'agent_wishlist':
        if (agentId != null) {
          debugPrint("Navigating to AgentWishlistScreen: agentId=$agentId");
          _appRouter!.push(AgentWishlistRoute(agentId: agentId));
        }
        break;

      // View wishlist user details (for agent)
      case 'view_wishlist_user':
      case 'agent_wishlist_details':
        if (userId != null) {
          debugPrint("Navigating to ViewWishListUserScreen: userId=$userId");
          _appRouter!.push(ViewWishListUserRoute(userId: userId));
        } else if (senderId != null) {
          debugPrint(
            "Navigating to ViewWishListUserScreen: senderId=$senderId",
          );
          _appRouter!.push(ViewWishListUserRoute(userId: senderId));
        }
        break;

      // View payment details (for agent)
      case 'view_payment_detail':
        if (userId != null && agentId != null) {
          debugPrint(
            "Navigating to ViewPaymentDetailScreen: userId=$userId, agentId=$agentId",
          );
          _appRouter!.push(
            ViewPaymentDetailRoute(userId: userId, agentId: agentId),
          );
        }
        break;

      // View matrimony profile (for agent)
      case 'metrimony_profile':
        if (profileId != null) {
          debugPrint(
            "Navigating to MetrimonyProfileScreen: profileId=$profileId",
          );
          _appRouter!.push(MetrimonyProfileRoute(userId: profileId));
        }
        break;

      // Agent support screen
      case 'agent_support':
        if (agentId != null) {
          debugPrint("Navigating to AgentSupportScreen: agentId=$agentId");
          _appRouter!.push(AgentSupportRoute(agentId: agentId));
        }
        break;

      // Agent notifications screen
      case 'agent_notification':
        debugPrint("Navigating to AgentNotificationScreen");
        _appRouter!.push(const AgentnotificationRoute());
        break;

      // ============ USER SCREENS ============

      // User wishlist screen
      case 'user_wishlist':
      case 'wishlist_details':
        if (userId != null) {
          debugPrint("Navigating to UserWishListScreen: userId=$userId");
          _appRouter!.push(UserWishListRoute(userId: userId));
        }
        break;

      // User notification screen
      case 'user_notification':
        debugPrint("Navigating to UserNotificationScreen");
        _appRouter!.push(const UserNotificationRoute());
        break;

      // User profile screen
      case 'user_profile':
        if (userId != null) {
          debugPrint("Navigating to UserProfileScreen: userId=$userId");
          _appRouter!.push(UserProfileRoute(userId: userId));
        }
        break;

      // User home screen
      case 'user_home':
        debugPrint("Navigating to UserHomeScreen");
        _appRouter!.push(const UserHomeRoute());
        break;

      // Support tickets screen
      case 'support_tickets':
        if (userId != null) {
          debugPrint("Navigating to SupportTicketsScreen: userId=$userId");
          _appRouter!.push(SupportTicketsRoute(userId: userId));
        }
        break;

      // Support ticket detail
      case 'support_ticket_detail':
        if (ticketId != null) {
          debugPrint(
            "Navigating to SupportTicketDetailScreen: ticketId=$ticketId",
          );
          _appRouter!.push(SupportTicketDetailRoute(ticketId: ticketId));
        }
        break;

      // User detail screen (view another user's profile)
      case 'user_detail':
        if (userId != null) {
          debugPrint("Navigating to UserDetailScreen: uid=$userId");
          _appRouter!.push(UserDetailRoute(uid: userId));
        }
        break;

      // Payment screen
      case 'user_payment':
        if (userId != null) {
          debugPrint("Navigating to UserPaymentScreen: userId=$userId");
          _appRouter!.push(UserPaymentRoute(userId: userId));
        }
        break;

      default:
        debugPrint("Unknown screen: $screen, type: $type");
        // Fallback: try to navigate based on type
        _handleNavigationByType(type, data);
    }
  }

  /// Fallback navigation handler based on notification type
  static void _handleNavigationByType(String? type, Map<String, dynamic> data) {
    if (type == null || _appRouter == null) return;

    final userId = data['userId'] as String?;
    final agentId = data['agentId'] as String?;

    switch (type) {
      case 'USER_REGISTERED':
      case 'PROFILE_COMPLETED':
      case 'MATRIMONY_PROFILE_CREATED':
        if (userId != null) {
          _appRouter!.push(ViewUserRoute(userId: userId));
        }
        break;

      case 'PAYMENT_INITIATED':
        if (userId != null && agentId != null) {
          _appRouter!.push(
            ViewPaymentDetailRoute(userId: userId, agentId: agentId),
          );
        }
        break;

      case 'WISHLIST_SENT':
      case 'WISHLIST_RECEIVED':
      case 'WISHLIST_STATUS_UPDATED':
        if (userId != null) {
          _appRouter!.push(UserWishListRoute(userId: userId));
        }
        break;

      case 'AGENT_WISHLIST_CREATED':
      case 'AGENT_WISHLIST_STATUS_UPDATED':
        if (agentId != null) {
          _appRouter!.push(AgentWishlistRoute(agentId: agentId));
        }
        break;

      case 'SUPPORT_TICKET_CREATED':
        if (agentId != null) {
          _appRouter!.push(AgentSupportRoute(agentId: agentId));
        }
        break;

      default:
        debugPrint("Unknown notification type: $type");
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
