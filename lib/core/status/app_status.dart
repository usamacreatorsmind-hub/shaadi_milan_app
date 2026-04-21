/// Enum representing different application states
enum AppStatus {
  /// Initial state when app starts
  initial,

  /// User is being authenticated
  authenticating,

  /// User is authenticated successfully
  authenticated,

  /// User authentication failed
  authenticationFailed,

  /// User is logged out
  unauthenticated,

  /// App is loading data
  loading,

  /// Data loaded successfully
  loaded,

  /// Error occurred during any operation
  error,

  /// Network connection is unavailable
  networkError,

  /// App is synchronizing with server
  syncing,

  /// Sync completed successfully
  syncCompleted,

  /// Sync failed
  syncFailed,

  /// User session expired
  sessionExpired,

  /// App is updating
  updating,

  /// Update completed
  updateCompleted,

  /// Maintenance mode
  maintenance,
}

/// Class to hold app status with additional metadata
class AppStatusData {
  final AppStatus status;
  final String? message; // Error or status message
  final dynamic data; // Additional data for the status
  final DateTime timestamp;

  AppStatusData({
    required this.status,
    this.message,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create a copy of this with modified fields
  AppStatusData copyWith({
    AppStatus? status,
    String? message,
    dynamic data,
    DateTime? timestamp,
  }) {
    return AppStatusData(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() =>
      'AppStatusData(status: $status, message: $message, data: $data, timestamp: $timestamp)';
}
