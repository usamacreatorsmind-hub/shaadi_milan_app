import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ModernGradientAppBar(
            title: AppLabels.supportTickets(context),
            subtitle: AppLabels.viewManageTickets(context),
            centerTitle: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: ticketsAsync.when(
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (error, stack) => SliverFillRemaining(child: Center(child: Text(AppLabels.error(context, error.toString())))),
              data: (tickets) {
                if (tickets.isEmpty) {
                  return const SliverFillRemaining(child: _EmptyState());
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _TicketCard(
                      ticket: tickets[index],
                      onTap: () => context.router.push(SupportTicketDetailRoute(ticketId: tickets[index].id)),
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
        elevation: 4,
        onPressed: () => context.router.push(SupportTicketFormRoute()),
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: Text(
          AppLabels.newTicket(context),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusBadge(status: ticket.status),
                    _PriorityBadge(priority: ticket.priority),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  ticket.subject,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(
                  ticket.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14, height: 1.3),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (ticket.category != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ticket.category!,
                          style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(context, ticket.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_rounded, size: 18, color: Theme.of(context).primaryColor),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return AppLabels.today(context);
    if (diff.inDays == 1) return AppLabels.yesterday(context);
    if (diff.inDays < 7) return AppLabels.daysAgo(context, diff.inDays);
    return DateFormat('dd MMM yyyy').format(date);
  }
}

class _StatusBadge extends StatelessWidget {
  final TicketStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case TicketStatus.pending:
        color = Colors.orange;
        label = "PENDING";
        break;
      case TicketStatus.resolved:
        color = Colors.green;
        label = "RESOLVED";
        break;
      case TicketStatus.closed:
        color = Colors.grey;
        label = "CLOSED";
        break;
      case TicketStatus.rejected:
        color = Colors.red;
        label = "REJECTED";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.05), shape: BoxShape.circle),
              child: Icon(Icons.support_agent_rounded, size: 80, color: Theme.of(context).primaryColor.withOpacity(0.2)),
            ),
            const SizedBox(height: 24),
            Text(
              AppLabels.noSupportTickets(context),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppLabels.createTicketHelp(context),
              style: TextStyle(color: Colors.grey[600], fontSize: 15, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
