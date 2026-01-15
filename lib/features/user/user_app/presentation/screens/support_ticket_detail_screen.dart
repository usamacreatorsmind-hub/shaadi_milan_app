import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/states/support_ticket.dart';
import '../controllers/support_notifier.dart';

@RoutePage()
class SupportTicketDetailScreen extends ConsumerWidget {
  final String ticketId;
  const SupportTicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketAsync = ref.watch(supportTicketStreamProvider(ticketId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Details')),
      body: ticketAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (ticket) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(context, ticket),
              const SizedBox(height: 24),
              _buildInfoCard(context, 'Ticket Information', [
                _buildInfoRow('Subject', ticket.subject),
                _buildInfoRow('Category', ticket.category ?? 'N/A'),
                _buildInfoRow(
                  'Created At',
                  DateFormat.yMMMd().add_jm().format(ticket.createdAt),
                ),
                if (ticket.updatedAt != null)
                  _buildInfoRow(
                    'Last Updated',
                    DateFormat.yMMMd().add_jm().format(ticket.updatedAt!),
                  ),
              ]),
              const SizedBox(height: 16),
              _buildInfoCard(context, 'Description', [
                Text(ticket.description, style: const TextStyle(height: 1.5)),
              ]),
              const SizedBox(height: 16),
              if (ticket.adminResponse != null)
                _buildInfoCard(
                  context,
                  'Admin Response',
                  [
                    Text(
                      ticket.adminResponse!,
                      style: const TextStyle(
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  cardColor: theme.primaryColor.withOpacity(0.05),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SupportTicket ticket) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Ticket #${ticket.id.substring(0, 6)}',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusChip(
                  'Status',
                  ticket.status.displayName,
                  _getStatusColor(ticket.status),
                ),
                _buildStatusChip(
                  'Priority',
                  ticket.priority.displayName,
                  _getPriorityColor(ticket.priority),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Chip(
          label: Text(value, style: TextStyle(color: color)),
          backgroundColor: color.withOpacity(0.1),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    List<Widget> children, {
    Color? cardColor,
  }) {
    return Card(
      color: cardColor,
      elevation: cardColor != null ? 0 : 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      // get updated
      case TicketStatus.pending:
        return Colors.green;
      case TicketStatus.resolved:
        return Colors.orange;

      case TicketStatus.closed:
        return Colors.red;
      case TicketStatus.rejected:
        return Colors.red;
    }
  }

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return Colors.green;
      case TicketPriority.medium:
        return Colors.blue;
      case TicketPriority.high:
        return Colors.orange;
      case TicketPriority.urgent:
        return Colors.red;
    }
  }
}
