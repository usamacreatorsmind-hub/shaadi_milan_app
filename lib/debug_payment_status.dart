import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/user/user_app/presentation/controllers/user_status_controller.dart';

/// Add this widget to your home screen to debug the payment status
class DebugPaymentStatus extends ConsumerWidget {
  const DebugPaymentStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStatus = ref.watch(userStatusControllerProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.yellow.shade100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🐛 DEBUG: Payment Status',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text('isPaymentDone: ${userStatus.userStatus.isPaymentDone}'),
          Text('isLoading: ${userStatus.isLoading}'),
          Text('uid: ${userStatus.userStatus.uid}'),
          Text('error: ${userStatus.error ?? "none"}'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final controller = ref.read(userStatusControllerProvider.notifier);
              await controller.getUserStatus();
            },
            child: const Text('Refresh Status'),
          ),
        ],
      ),
    );
  }
}
