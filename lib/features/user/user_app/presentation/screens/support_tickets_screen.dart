import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../../app/router/app_router.dart';
import '../../../../../app/custom/custom_widgets/animated_app_bar.dart';
import '../../domain/states/support_ticket.dart';
import '../controllers/support_notifier.dart';

@RoutePage()
class SupportTicketsScreen extends ConsumerWidget {
  final String userId;

  const SupportTicketsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(userSupportTicketsStreamProvider(userId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const ModernGradientAppBar(
            title: 'Support Tickets',
            subtitle: 'View and manage your tickets',
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: ticketsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                    ],
                  ),
                ),
              ),
              data: (tickets) {
                if (tickets.isEmpty) {
                  return const SliverFillRemaining(child: _EmptyState());
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _TicketCard(
                      ticket: tickets[index],
                      onTap: () => context.router.push(
                        SupportTicketDetailRoute(ticketId: tickets[index].id),
                      ),
                    ),
                    childCount: tickets.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => context.router.push(const SupportTicketFormRoute()),
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicket ticket;
  final VoidCallback onTap;

  const _TicketCard({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: _StatusIcon(status: ticket.status),
        title: Text(
          ticket.subject,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              ticket.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _PriorityBadge(priority: ticket.priority),
                const SizedBox(width: 8),
                if (ticket.category != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ticket.category!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  _formatDate(ticket.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusIcon extends StatelessWidget {
  final TicketStatus status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case TicketStatus.pending:
        color = Colors.blue;
        icon = Icons.info_outline;
        break;
      case TicketStatus.pending:
        color = Colors.orange;
        icon = Icons.pending_outlined;
        break;
      case TicketStatus.resolved:
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case TicketStatus.closed:
        color = Colors.grey;
        icon = Icons.cancel_outlined;
        break;
      case TicketStatus.rejected:
        color = Colors.red;
        icon = Icons.do_not_disturb_on_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TicketPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (priority) {
      case TicketPriority.low:
        color = Colors.green;
        break;
      case TicketPriority.medium:
        color = Colors.blue;
        break;
      case TicketPriority.high:
        color = Colors.orange;
        break;
      case TicketPriority.urgent:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No Support Tickets',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a ticket to get help from our support team',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
