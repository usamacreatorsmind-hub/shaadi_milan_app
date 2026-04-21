import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_status.dart';
import 'app_status_notifier.dart';

/// Provider for centralized app status management
final appStatusProvider =
    StateNotifierProvider<AppStatusNotifier, AppStatusData>((ref) {
  return AppStatusNotifier();
});

/// Provider to select the current app status (enum only)
final appStatusValueProvider = Provider<AppStatus>((ref) {
  return ref.watch(appStatusProvider).status;
});

/// Provider to select the status message
final appStatusMessageProvider = Provider<String?>((ref) {
  return ref.watch(appStatusProvider).message;
});

/// Provider to select the status data
final appStatusDataProvider = Provider<dynamic>((ref) {
  return ref.watch(appStatusProvider).data;
});

/// Provider to check if the app is loading
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(appStatusProvider).status == AppStatus.loading;
});

/// Provider to check if the app is syncing
final isSyncingProvider = Provider<bool>((ref) {
  return ref.watch(appStatusProvider).status == AppStatus.syncing;
});

/// Provider to check if the user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(appStatusProvider).status == AppStatus.authenticated;
});

/// Provider to check if there's an error
final hasErrorProvider = Provider<bool>((ref) {
  return ref.watch(appStatusProvider).status == AppStatus.error;
});

/// Provider to check network connectivity status
final isNetworkErrorProvider = Provider<bool>((ref) {
  return ref.watch(appStatusProvider).status == AppStatus.networkError;
});

/// Provider to check if session is expired
final isSessionExpiredProvider = Provider<bool>((ref) {
  return ref.watch(appStatusProvider).status == AppStatus.sessionExpired;
});

/// Provider for full status data
final appStatusFullProvider = Provider<AppStatusData>((ref) {
  return ref.watch(appStatusProvider);
});
