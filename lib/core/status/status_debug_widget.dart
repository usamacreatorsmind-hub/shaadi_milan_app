import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_status_provider.dart';

/// Debug widget showing current app status
/// Use this during development to monitor status changes
class StatusDebugPanel extends ConsumerWidget {
  final bool expanded;

  const StatusDebugPanel({
    Key? key,
    this.expanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusData = ref.watch(appStatusProvider);

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🔧 Status Debug',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ref.read(appStatusProvider.notifier).reset();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'RESET',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 12),
          _StatusField('Status', statusData.status.toString().split('.').last),
          _StatusField('Message', statusData.message ?? '(none)'),
          _StatusField('Data', statusData.data?.toString() ?? '(none)'),
          _StatusField(
            'Time',
            statusData.timestamp.toString().split('.').first,
          ),
          if (expanded) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            const Text(
              'Flags:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                _StatusFlag('Loading', ref.watch(isLoadingProvider)),
                _StatusFlag('Syncing', ref.watch(isSyncingProvider)),
                _StatusFlag('Auth', ref.watch(isAuthenticatedProvider)),
                _StatusFlag('Error', ref.watch(hasErrorProvider)),
                _StatusFlag('NetErr', ref.watch(isNetworkErrorProvider)),
                _StatusFlag('SessExp', ref.watch(isSessionExpiredProvider)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusField extends StatelessWidget {
  final String label;
  final String value;

  const _StatusField(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFlag extends StatelessWidget {
  final String label;
  final bool value;

  const _StatusFlag(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: value ? Colors.green.shade200 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: value ? Colors.green.shade900 : Colors.grey.shade600,
        ),
      ),
    );
  }
}

/// Floating debug button (development only)
class StatusDebugButton extends ConsumerStatefulWidget {
  final Widget child;

  const StatusDebugButton({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<StatusDebugButton> createState() => _StatusDebugButtonState();
}

class _StatusDebugButtonState extends ConsumerState<StatusDebugButton> {
  bool _showDebug = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showDebug)
          Positioned(
            bottom: 80,
            right: 16,
            left: 16,
            child: StatusDebugPanel(expanded: true),
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.purple,
            onPressed: () {
              setState(() => _showDebug = !_showDebug);
            },
            child: Icon(_showDebug ? Icons.close : Icons.bug_report),
          ),
        ),
      ],
    );
  }
}
