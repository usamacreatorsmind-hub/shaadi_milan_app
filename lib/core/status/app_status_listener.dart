import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/core/constants/app_constants.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';
import 'app_status.dart';
import 'app_status_provider.dart';

/// Consumer widget that displays status messages
class AppStatusListener extends ConsumerWidget {
  final Widget child;
  final void Function(AppStatusData status)? onStatusChanged;
  final bool showSnackbar;

  const AppStatusListener({
    Key? key,
    required this.child,
    this.onStatusChanged,
    this.showSnackbar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusData = ref.watch(appStatusProvider);

    // Listen for status changes
    ref.listen(appStatusProvider, (previous, next) {
      onStatusChanged?.call(next);

      if (showSnackbar && next.message != null) {
        _showStatusFeedback(context, next);
      }
    });

    return child;
  }

  void _showStatusFeedback(BuildContext context, AppStatusData statusData) {
    final color = _getColor(statusData.status);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getIcon(statusData.status),
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(statusData.message ?? AppLabels.statusUpdated(context)),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Color _getColor(AppStatus status) {
    switch (status) {
      case AppStatus.error:
      case AppStatus.authenticationFailed:
      case AppStatus.syncFailed:
      case AppStatus.networkError:
      case AppStatus.sessionExpired:
        return Colors.red;
      case AppStatus.loaded:
      case AppStatus.authenticated:
      case AppStatus.syncCompleted:
        return Colors.green;
      case AppStatus.loading:
      case AppStatus.syncing:
      case AppStatus.authenticating:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon(AppStatus status) {
    switch (status) {
      case AppStatus.loading:
      case AppStatus.syncing:
        return Icons.hourglass_bottom;
      case AppStatus.loaded:
      case AppStatus.authenticated:
        return Icons.check_circle;
      case AppStatus.error:
      case AppStatus.networkError:
        return Icons.error;
      default:
        return Icons.info;
    }
  }
}
