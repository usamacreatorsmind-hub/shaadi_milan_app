import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arvika_marriage_bureau/core/status/status.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Example: Feature Notifier with integrated status management
///
/// This shows how to use the centralized status system in your feature notifiers

class ExampleFeatureNotifier extends StateNotifier<AsyncValue<String>> {
  ExampleFeatureNotifier(this.ref) : super(const AsyncValue.loading());

  final Ref ref;

  /// Example 1: Fetch data with status management
  Future<void> fetchExampleData() async {
    final statusService = AppStatusService(ref as WidgetRef);

    try {
      statusService.setLoading(message: 'Fetching example data...');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final data = 'Example Data Loaded';

      statusService.setSuccess(message: 'Data loaded successfully', data: data);
      state = AsyncValue.data(data);
    } catch (e) {
      statusService.setError(e, customMessage: 'Failed to fetch data');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Example 2: Authenticate user
  Future<void> authenticateUser(String email, String password) async {
    final statusService = AppStatusService(ref as WidgetRef);

    try {
      await statusService.handleAuthentication(() async {
        // Simulate authentication
        await Future.delayed(const Duration(seconds: 2));
        if (email.isEmpty) throw Exception('Email required');
        return {'email': email, 'token': 'abc123'};
      }, successMessage: 'Authentication successful');
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Example 3: Sync data with server
  Future<void> syncData() async {
    final statusService = AppStatusService(ref as WidgetRef);

    try {
      await statusService.handleSync(() async {
        // Simulate server sync
        await Future.delayed(const Duration(seconds: 3));
        return 'Sync completed';
      }, syncingMessage: 'Syncing with server...');
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Example 4: Network error handling
  Future<void> handleNetworkOperation() async {
    final statusService = AppStatusService(ref as WidgetRef);

    try {
      statusService.setLoading();
      // Simulate network operation
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      if (e is SocketException) {
        statusService.handleNetworkError(
          message: 'Please check your internet connection',
        );
      } else {
        statusService.setError(e);
      }
    }
  }

  /// Example 5: Session handling
  void handleSessionExpired() {
    final statusService = AppStatusService(ref as WidgetRef);
    statusService.handleSessionExpired();
    // Then redirect to login screen
  }
}

// Provider for the example feature
final exampleFeatureProvider =
    StateNotifierProvider<ExampleFeatureNotifier, AsyncValue<String>>((ref) {
      return ExampleFeatureNotifier(ref);
    });

// Import this in your feature Dart or widget:
//
// import 'package:arvika_marriage_bureau/core/status/status.dart';
// import 'example_feature_with_status.dart';
//
// Then use in Widget:
//
// class ExampleWidget extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final data = ref.watch(exampleFeatureProvider);
//     final isLoading = ref.watch(isLoadingProvider);
//     final hasError = ref.watch(hasErrorProvider);
//
//     return Column(
//       children: [
//         if (isLoading)
//           const CircularProgressIndicator()
//         else if (hasError)
//           ElevatedButton(
//             onPressed: () {
//               ref.read(exampleFeatureProvider.notifier).fetchExampleData();
//             },
//             child: const Text('Retry'),
//           )
//         else
//           Text('Data: ${data.value}'),
//       ],
//     );
//   }
// }

// For import SocketException
