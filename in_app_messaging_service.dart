import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/foundation.dart';

class InAppMessagingService {
  static final FirebaseInAppMessaging _fiam = FirebaseInAppMessaging.instance;

  /// Initialize the service
  static Future<void> init() async {
    debugPrint("🔔 In-App Messaging Service Initialized");
  }

  /// Trigger a specific event programmatically.
  /// This allows you to show campaigns based on internal app logic
  /// rather than just standard Analytics events.
  static void triggerEvent(String eventName) {
    try {
      _fiam.triggerEvent(eventName);
      debugPrint("🔔 FIAM Event Triggered: $eventName");
    } catch (e) {
      debugPrint("❌ FIAM Event Error: $e");
    }
  }

  /// Suppress messages temporarily.
  /// Useful for critical flows like payments or onboarding where
  /// popups should not interrupt the user.
  static Future<void> setSuppressed(bool suppressed) async {
    try {
      await _fiam.setMessagesSuppressed(suppressed);
      debugPrint("🔔 FIAM Suppressed: $suppressed");
    } catch (e) {
      debugPrint("❌ FIAM Suppression Error: $e");
    }
  }
}
