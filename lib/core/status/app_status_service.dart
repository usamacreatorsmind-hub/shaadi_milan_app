import 'package:arvika_marriage_bureau/core/status/app_status_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_status.dart';
import 'app_status_provider.dart';

/// Service class to manage app status across the application
class AppStatusService {
  final WidgetRef ref;

  AppStatusService(this.ref);

  /// Get current app status
  AppStatusData get currentStatus {
    return ref.read(appStatusProvider);
  }

  /// Get app status notifier
  AppStatusNotifier get _notifier {
    return ref.read(appStatusProvider.notifier);
  }

  /// Set a custom status
  void setStatus(AppStatus status, {String? message, dynamic data}) {
    _notifier.setStatus(status, message: message, data: data);
  }

  /// Set loading state
  void setLoading({String? message}) {
    _notifier.setLoading(message: message);
  }

  /// Set success state
  void setSuccess({String? message, dynamic data}) {
    _notifier.setSuccess(message: message, data: data);
  }

  /// Set error state
  void setError(dynamic error, {String? customMessage}) {
    _notifier.setError(error, customMessage: customMessage);
  }

  /// Handle authentication process
  Future<void> handleAuthentication(
    Future<dynamic> Function() authFuture, {
    String? successMessage,
  }) async {
    try {
      _notifier.setAuthenticating();
      final result = await authFuture();
      _notifier.setAuthenticated(user: result);
    } catch (e) {
      _notifier.setAuthenticationFailed(reason: e.toString());
      rethrow;
    }
  }

  /// Handle logout
  void handleLogout() {
    _notifier.setUnauthenticated();
  }

  /// Handle data synchronization
  Future<void> handleSync(
    Future<dynamic> Function() syncFuture, {
    String? syncingMessage,
  }) async {
    try {
      _notifier.setSyncing(message: syncingMessage);
      final result = await syncFuture();
      _notifier.setSyncCompleted();
    } catch (e) {
      _notifier.setSyncFailed(message: e.toString());
      rethrow;
    }
  }

  /// Handle network errors
  void handleNetworkError({String? message}) {
    _notifier.setNetworkError(message: message);
  }

  /// Handle session expiration
  void handleSessionExpired() {
    _notifier.setSessionExpired();
  }

  /// Reset to initial state
  void reset() {
    _notifier.reset();
  }

  /// Check if loading
  bool get isLoading => _notifier.isLoading;

  /// Check if syncing
  bool get isSyncing => _notifier.isSyncing;

  /// Check if authenticated
  bool get isAuthenticated => _notifier.isAuthenticated;

  /// Check if error
  bool get isError => _notifier.isError;

  /// Check if network error
  bool get isNetworkError => _notifier.isNetworkError;

  /// Check if session expired
  bool get isSessionExpired => _notifier.isSessionExpired;
}
