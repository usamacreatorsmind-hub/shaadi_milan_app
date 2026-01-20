import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/foundation.dart';

class InAppMessagingService {
  static final FirebaseInAppMessaging _fiam = FirebaseInAppMessaging.instance;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Initialize the service
  static Future<void> init() async {
    debugPrint("🔔 In-App Messaging Service Initialized");
    await _logInstallationId();
  }

  /// Log the Installation ID for testing purposes
  static Future<void> _logInstallationId() async {
    try {
      final String id = await FirebaseInstallations.instance.getId();
      debugPrint("🆔 Firebase Installation ID (FIAM): $id");
    } catch (e) {
      debugPrint("❌ Error getting Installation ID: $e");
    }
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

  /// Set a user property.
  /// This allows you to target campaigns based on user attributes.
  static Future<void> setUserProperty(String name, String? value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      debugPrint("🔔 FIAM User Property (via Analytics) Set: $name = $value");
    } catch (e) {
      debugPrint("❌ FIAM User Property Error: $e");
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
