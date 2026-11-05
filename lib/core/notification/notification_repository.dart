import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository(this._firestore);

  /// Stream of notifications for a user or agent
  Stream<List<NotificationModel>> watchNotifications(String collection, String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _firestore
        .collection(collection)
        .doc(uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Mark a notification as read
  Future<void> markAsRead(String collection, String uid, String notificationId) async {
    await _firestore
        .collection(collection)
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Delete a notification
  Future<void> deleteNotification(String collection, String uid, String notificationId) async {
    await _firestore
        .collection(collection)
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  /// Clear all notifications
  Future<void> clearAllNotifications(String collection, String uid) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection(collection)
        .doc(uid)
        .collection('notifications')
        .get();

    for (final doc in notifications.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
