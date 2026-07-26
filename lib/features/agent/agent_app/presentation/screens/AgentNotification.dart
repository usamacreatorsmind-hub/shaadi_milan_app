import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/notification/notification_model.dart';
import '../../../../../core/notification/notification_provider.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';

@RoutePage()
class AgentnotificationScreen extends ConsumerWidget {
  const AgentnotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
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
            return const Center(child: Text('No new notifications'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _AgentNotificationTile(notification: notification, onTap: () => _handleNotificationTap(context, ref, notification));
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, WidgetRef ref, NotificationModel notification) {
    final authState = ref.read(authStateProvider);
    authState.whenData((user) {
      if (user != null) {
        final collection = user.fold((_) => 'agents', (_) => 'users');
        final uid = user.fold((a) => a.uid, (u) => u.uid);
        ref.read(notificationRepositoryProvider).markAsRead(collection, uid, notification.id);
      }
    });

    if (notification.screenRoute != null) {
      // Basic navigation or log
      debugPrint("Navigating to: ${notification.screenRoute}");
    }
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all notifications?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final authState = ref.read(authStateProvider);
              authState.whenData((user) {
                if (user != null) {
                  final collection = user.fold((_) => 'agents', (_) => 'users');
                  final uid = user.fold((a) => a.uid, (u) => u.uid);
                  ref.read(notificationRepositoryProvider).clearAllNotifications(collection, uid);
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

class _AgentNotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _AgentNotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: notification.isRead ? 0 : 2,
      color: notification.isRead ? Colors.grey.shade50 : Colors.white,
      child: ListTile(
        onTap: onTap,
        title: Text(notification.title, style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            Text(DateFormat('dd MMM, hh:mm a').format(notification.timestamp), style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        trailing: !notification.isRead ? const CircleAvatar(radius: 4, backgroundColor: Colors.blue) : null,
      ),
    );
  }
}
