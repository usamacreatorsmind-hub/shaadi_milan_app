import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/custom/custom_widgets/animated_app_bar.dart';
import '../../../../../app/router/app_router.dart';
import '../../../../../core/constants/app_labels.dart';
import '../../domain/states/support_ticket.dart';
import '../controllers/support_notifier.dart';

@RoutePage()
class SupportTicketsScreen extends ConsumerWidget {
  final String userId;

  const SupportTicketsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(userSupportTicketsStreamProvider(userId));
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              ModernGradientAppBar(
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),

                title: AppLabels.supportTickets(context),
                subtitle: AppLabels.viewManageTickets(context),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: ticketsAsync.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => SliverFillRemaining(
                    child: Center(
                      child: Text(AppLabels.error(context, error.toString())),
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
                            SupportTicketDetailRoute(
                              ticketId: tickets[index].id,
                            ),
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

          /// ✅ Fully Custom Positioned Button
          Positioned(
            bottom:
                size.height *
                0.12, // 👈 Change this to control vertical position

            right:
                size.width *
                0.05, // 👈 Change this to control horizontal position
            child: FloatingActionButton.extended(
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () => context.router.push(SupportTicketFormRoute()),
              icon: const Icon(Icons.add),
              label: Text(AppLabels.newTicket(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicket ticket;
  final VoidCallback onTap;

  const _TicketCard({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
                  _formatDate(context, ticket.createdAt),
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

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return AppLabels.today(context);
    if (diff.inDays == 1) return AppLabels.yesterday(context);
    if (diff.inDays < 7) return AppLabels.daysAgo(context, diff.inDays);
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
    String label;

    switch (priority) {
      case TicketPriority.low:
        color = Colors.green;
        label = AppLabels.low(context);
        break;
      case TicketPriority.medium:
        color = Colors.blue;
        label = AppLabels.medium(context);
        break;
      case TicketPriority.high:
        color = Colors.orange;
        label = AppLabels.high(context);
        break;
      case TicketPriority.urgent:
        color = Colors.red;
        label = AppLabels.urgent(context);
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
        label,
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
          Text(
            AppLabels.noSupportTickets(context),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppLabels.createTicketHelp(context),
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
