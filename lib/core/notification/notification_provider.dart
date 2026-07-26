import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers/global_providers.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import 'notification_model.dart';
import 'notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return NotificationRepository(firestore);
});

final userNotificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  final repository = ref.watch(notificationRepositoryProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);

      return user.fold(
        (agent) => repository.watchNotifications('agents', agent.uid),
        (user) => repository.watchNotifications('users', user.uid),
      );
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(userNotificationsProvider);
  return notificationsAsync.when(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
