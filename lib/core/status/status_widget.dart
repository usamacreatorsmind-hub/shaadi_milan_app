import 'package:flutter/material.dart';
import 'app_status.dart';

/// Widget to display status messages to users
class StatusMessageWidget extends StatelessWidget {
  final AppStatusData statusData;
  final Duration duration;
  final VoidCallback? onDismiss;

  const StatusMessageWidget({
    Key? key,
    required this.statusData,
    this.duration = const Duration(seconds: 3),
    this.onDismiss,
  }) : super(key: key);

  /// Get color based on status
  Color _getStatusColor(AppStatus status) {
    switch (status) {
      case AppStatus.loading:
      case AppStatus.syncing:
      case AppStatus.authenticating:
      case AppStatus.updating:
        return Colors.blue;
      case AppStatus.loaded:
      case AppStatus.authenticated:
      case AppStatus.syncCompleted:
      case AppStatus.updateCompleted:
        return Colors.green;
      case AppStatus.error:
      case AppStatus.authenticationFailed:
      case AppStatus.syncFailed:
      case AppStatus.networkError:
      case AppStatus.sessionExpired:
      case AppStatus.maintenance:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get icon based on status
  IconData _getStatusIcon(AppStatus status) {
    switch (status) {
      case AppStatus.loading:
      case AppStatus.syncing:
      case AppStatus.authenticating:
      case AppStatus.updating:
        return Icons.hourglass_bottom;
      case AppStatus.loaded:
      case AppStatus.authenticated:
      case AppStatus.syncCompleted:
      case AppStatus.updateCompleted:
        return Icons.check_circle;
      case AppStatus.error:
      case AppStatus.authenticationFailed:
      case AppStatus.syncFailed:
      case AppStatus.sessionExpired:
        return Icons.error;
      case AppStatus.networkError:
        return Icons.wifi_off;
      case AppStatus.maintenance:
        return Icons.build;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (statusData.message == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getStatusColor(statusData.status).withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(statusData.status),
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  statusData.status.toString().split('.').last.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusData.message ?? 'No message',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

/// Snackbar-style overlay for status notifications
void showStatusSnackbar(
  BuildContext context,
  AppStatusData statusData, {
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: StatusMessageWidget(
        statusData: statusData,
        duration: duration,
      ),
      duration: duration,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}
