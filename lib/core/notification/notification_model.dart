import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification types based on Cloud Functions implementation
enum NotificationType {
  userRegistered,
  paymentInitiated,
  wishlistSent,
  wishlistReceived,
  agentWishlistCreated,
  unknown,
}

/// Notification model for handling push notifications and local storage
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final Map<String, dynamic> data;
  final bool isRead;
  final String? imageUrl;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    required this.data,
    this.isRead = false,
    this.imageUrl,
  });

  /// Create from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: _parseNotificationType(json['type'] as String?),
      data: json['data'] as Map<String, dynamic>,
      isRead: json['isRead'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'data': data,
      'isRead': isRead,
      'imageUrl': imageUrl,
    };
  }

  /// Create from Firebase RemoteMessage data (used in notification service)
  factory NotificationModel.fromRemoteMessage(
    String messageId,
    Map<String, dynamic> notificationData,
    Map<String, dynamic> dataPayload,
  ) {
    return NotificationModel(
      id: messageId,
      title: notificationData['title'] ?? 'New Notification',
      body: notificationData['body'] ?? '',
      timestamp: DateTime.now(),
      type: _parseNotificationType(dataPayload['type']),
      data: dataPayload,
      imageUrl: notificationData['image'],
    );
  }

  /// Create from Firestore document (if storing notifications)
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] as String,
      body: data['body'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: _parseNotificationType(data['type'] as String?),
      data: data['data'] as Map<String, dynamic>,
      isRead: data['isRead'] as bool? ?? false,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.name,
      'data': data,
      'isRead': isRead,
      'imageUrl': imageUrl,
    };
  }

  /// Mark as read
  NotificationModel markAsRead() {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      type: type,
      data: data,
      isRead: true,
      imageUrl: imageUrl,
    );
  }

  /// Get screen route from data
  String? get screenRoute => data['screen'] as String?;

  /// Get target user ID if applicable
  String? get targetUserId => data['userId'] as String?;

  /// Get target agent ID if applicable
  String? get targetAgentId => data['agentId'] as String?;

  /// Get payment ID if applicable
  String? get paymentId => data['paymentId'] as String?;

  /// Get wishlist ID if applicable
  String? get wishlistId => data['wishlistId'] as String?;
}

/// Parse notification type from string
NotificationType _parseNotificationType(String? type) {
  switch (type) {
    case 'USER_REGISTERED':
    case 'userRegistered':
      return NotificationType.userRegistered;
    case 'PAYMENT_INITIATED':
    case 'paymentInitiated':
      return NotificationType.paymentInitiated;
    case 'WISHLIST_SENT':
    case 'wishlistSent':
      return NotificationType.wishlistSent;
    case 'WISHLIST_RECEIVED':
    case 'wishlistReceived':
      return NotificationType.wishlistReceived;
    case 'AGENT_WISHLIST_CREATED':
    case 'agentWishlistCreated':
      return NotificationType.agentWishlistCreated;
    default:
      return NotificationType.unknown;
  }
}

/// Extension for notification type display
extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.userRegistered:
        return 'New User';
      case NotificationType.paymentInitiated:
        return 'Payment';
      case NotificationType.wishlistSent:
        return 'Interest Sent';
      case NotificationType.wishlistReceived:
        return 'Interest Received';
      case NotificationType.agentWishlistCreated:
        return 'Client Activity';
      case NotificationType.unknown:
        return 'Notification';
    }
  }

  String get iconName {
    switch (this) {
      case NotificationType.userRegistered:
        return 'person_add';
      case NotificationType.paymentInitiated:
        return 'payment';
      case NotificationType.wishlistSent:
      case NotificationType.wishlistReceived:
        return 'favorite';
      case NotificationType.agentWishlistCreated:
        return 'business';
      case NotificationType.unknown:
        return 'notifications';
    }
  }
}