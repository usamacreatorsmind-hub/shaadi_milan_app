import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/constants/app_labels.dart';
import '../../../../../../core/notification/notification_model.dart';
import '../../../../../../core/notification/notification_provider.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';

@RoutePage()
class UserNotificationScreen extends ConsumerWidget {
  const UserNotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLabels.notifications(context)),
        actions: [
          notificationsAsync.when(
            data: (notifications) => notifications.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_all),
                    onPressed: () {
                      _showClearAllDialog(context, ref);
                    },
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationTile(
                notification: notification,
                onTap: () {
                  _handleNotificationTap(context, ref, notification);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _handleNotificationTap(
      BuildContext context, WidgetRef ref, NotificationModel notification) {
    // Mark as read
    final authState = ref.read(authStateProvider);
    authState.whenData((user) {
      if (user != null) {
        final collection = user.fold((_) => 'agents', (_) => 'users');
        final uid = user.fold((a) => a.uid, (u) => u.uid);
        ref
            .read(notificationRepositoryProvider)
            .markAsRead(collection, uid, notification.id);
      }
    });

    // Handle navigation based on type or screen route
    if (notification.screenRoute != null) {
      // You can use a central navigation handler or AutoRouter here
      debugPrint("Navigating to: ${notification.screenRoute}");
    }
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final authState = ref.read(authStateProvider);
              authState.whenData((user) {
                if (user != null) {
                  final collection = user.fold((_) => 'agents', (_) => 'users');
                  final uid = user.fold((a) => a.uid, (u) => u.uid);
                  ref
                      .read(notificationRepositoryProvider)
                      .clearAllNotifications(collection, uid);
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _getIcon(notification.type);
    final iconColor = _getIconColor(notification.type);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: notification.isRead ? 0 : 2,
      color: notification.isRead ? Colors.grey.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: notification.isRead
            ? BorderSide(color: Colors.grey.shade200)
            : BorderSide.none,
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(iconData, color: iconColor, size: 20),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.body,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM, hh:mm a').format(notification.timestamp),
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.userRegistered:
        return Icons.person_add;
      case NotificationType.paymentInitiated:
        return Icons.payment;
      case NotificationType.wishlistSent:
        return Icons.favorite;
      case NotificationType.wishlistReceived:
        return Icons.favorite;
      case NotificationType.agentWishlistCreated:
        return Icons.business;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.userRegistered:
        return Colors.blue;
      case NotificationType.paymentInitiated:
        return Colors.green;
      case NotificationType.wishlistSent:
      case NotificationType.wishlistReceived:
        return Colors.red;
      case NotificationType.agentWishlistCreated:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
