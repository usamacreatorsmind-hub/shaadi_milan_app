import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_status.dart';

/// StateNotifier for managing centralized app status
class AppStatusNotifier extends StateNotifier<AppStatusData> {
  AppStatusNotifier() : super(AppStatusData(status: AppStatus.initial));

  /// Update status with a new status
  void setStatus(AppStatus status, {String? message, dynamic data}) {
    state = AppStatusData(
      status: status,
      message: message,
      data: data,
      timestamp: DateTime.now(),
    );
  }

  /// Set loading state
  void setLoading({String? message}) {
    setStatus(AppStatus.loading, message: message ?? 'Loading...');
  }

  /// Set success state
  void setSuccess({String? message, dynamic data}) {
    setStatus(AppStatus.loaded, message: message, data: data);
  }

  /// Set error state
  void setError(dynamic error, {String? customMessage}) {
    final errorMessage = customMessage ?? error.toString();
    setStatus(AppStatus.error, message: errorMessage, data: error);
  }

  /// Set authenticating state
  void setAuthenticating() {
    setStatus(AppStatus.authenticating, message: 'Authenticating...');
  }

  /// Set authenticated state
  void setAuthenticated({dynamic user}) {
    setStatus(
      AppStatus.authenticated,
      message: 'User authenticated',
      data: user,
    );
  }

  /// Set unauthenticated state
  void setUnauthenticated() {
    setStatus(AppStatus.unauthenticated, message: 'User logged out');
  }

  /// Set authentication failed state
  void setAuthenticationFailed({String? reason}) {
    setStatus(
      AppStatus.authenticationFailed,
      message: reason ?? 'Authentication failed',
    );
  }

  /// Set network error state
  void setNetworkError({String? message}) {
    setStatus(
      AppStatus.networkError,
      message: message ?? 'No internet connection',
    );
  }

  /// Set session expired state
  void setSessionExpired() {
    setStatus(
      AppStatus.sessionExpired,
      message: 'Session expired. Please login again.',
    );
  }

  /// Set syncing state
  void setSyncing({String? message}) {
    setStatus(AppStatus.syncing, message: message ?? 'Syncing data...');
  }

  /// Set sync completed state
  void setSyncCompleted({String? message}) {
    setStatus(AppStatus.syncCompleted, message: message ?? 'Sync completed');
  }

  /// Set sync failed state
  void setSyncFailed({String? message}) {
    setStatus(AppStatus.syncFailed, message: message ?? 'Sync failed');
  }

  /// Set maintenance state
  void setMaintenance({String? message}) {
    setStatus(
      AppStatus.maintenance,
      message: message ?? 'App is under maintenance',
    );
  }

  /// Reset to initial state
  void reset() {
    state = AppStatusData(status: AppStatus.initial);
  }

  /// Check if current status is loading
  bool get isLoading => state.status == AppStatus.loading;

  /// Check if current status is syncing
  bool get isSyncing => state.status == AppStatus.syncing;

  /// Check if current status is authenticated
  bool get isAuthenticated => state.status == AppStatus.authenticated;

  /// Check if current status is an error
  bool get isError => state.status == AppStatus.error;

  /// Check if current status indicates no network
  bool get isNetworkError => state.status == AppStatus.networkError;

  /// Check if session is expired
  bool get isSessionExpired => state.status == AppStatus.sessionExpired;
}
