import 'package:shadi_milan/app/custom/custom_widgets/chip_and_action_chip.dart';
import 'package:shadi_milan/app/custom/custom_widgets/widgets.dart';
import 'package:shadi_milan/features/agent/agent_app/presentation/notifier/support_ticket_notifier.dart';
import 'package:shadi_milan/features/user/user_app/domain/states/support_ticket.dart';
import 'package:shadi_milan/features/widgets/marquee.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

@RoutePage()
class AgentSupportScreen extends ConsumerStatefulWidget {
  final String agentId;

  const AgentSupportScreen({super.key, required this.agentId});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AgentSupportScreenState();
}

class _AgentSupportScreenState extends ConsumerState<AgentSupportScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(agentSupportTicketsNotifierProvider.notifier).stream;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allSupportTicketAsync = ref.watch(agentGetAllSupportTicketsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Support Tickets')),
      body: allSupportTicketAsync.when(
        data: (tickets) {
          if (tickets.isEmpty) {
            return const Center(child: Text('No support tickets found.'));
          }
          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(ticket.userName),
                  subtitle: Marquee(ticket.subject, style: TextStyle()),

                  trailing: SupportTicketStatusChip(status: ticket.status),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            AgentSupportTicketDetailScreen(ticketId: ticket.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class SupportTicketStatusChip extends StatelessWidget {
  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Color chipColor;
    Color textColor;
    String label;

    switch (status) {
      case TicketStatus.pending:
        chipColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = 'Open';
        break;

      case TicketStatus.closed:
        chipColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        label = 'Closed';
        break;
      case TicketStatus.resolved:
        chipColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        label = 'Resolved';
        break;
      case TicketStatus.rejected:
        chipColor = Colors.purple.shade100;
        textColor = Colors.purple.shade800;
        label = 'Rejected';
        break;
    }

    return Chip(
      label: Text(label, style: TextStyle(color: textColor, fontSize: 12)),
      backgroundColor: chipColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
    );
  }

  const SupportTicketStatusChip({super.key, required this.status});
}

class AgentSupportTicketDetailScreen extends ConsumerWidget {
  final String ticketId;
  const AgentSupportTicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketAsync = ref.watch(agentSupportTicketStreamProvider(ticketId));

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

                _buildInfoRow('User Name', ticket.userName),
                _buildInfoRow('User Email', ticket.userEmail),
                _buildInfoRow('User ID', ticket.userId),
                _buildInfoRow('Staff Id', ticket.agentId),

                _buildInfoRow('Priority', ticket.priority.displayName),
                _buildInfoRow('Status', ticket.status.displayName),

                const Divider(),
                // ActionChip(
                //   label: const Text('Change Status'),
                //   onPressed: () {
                //     showModalBottomSheet(
                //       context: context,
                //       builder: (context) => _StatusChangeSheet(ticket: ticket),
                //     );
                //   },
                // ),
                const SizedBox(height: 8),
                AppChip(
                  label: 'Add Admin Response',
                  icon: Icons.admin_panel_settings_outlined,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => _AdminResponseSheet(ticket: ticket),
                    );
                  },
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

class _StatusChangeSheet extends ConsumerStatefulWidget {
  final SupportTicket ticket;
  const _StatusChangeSheet({required this.ticket});

  @override
  ConsumerState<_StatusChangeSheet> createState() => _StatusChangeSheetState();
}

class _StatusChangeSheetState extends ConsumerState<_StatusChangeSheet> {
  late TicketStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.ticket.status;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Change Ticket Status',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...TicketStatus.values.map((status) {
            return RadioListTile<TicketStatus>(
              title: Text(status.displayName),
              value: status,
              groupValue: _selectedStatus,
              onChanged: (TicketStatus? value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
            );
          }).toList(),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await ref
                    .read(agentSupportTicketNotifierProvider.notifier)
                    .updateTicketStatus(
                      ticketId: widget.ticket.id,
                      status: _selectedStatus,
                      adminResponse: widget.ticket.adminResponse ?? '',
                    );

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Update Status'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminResponseSheet extends ConsumerStatefulWidget {
  final SupportTicket ticket;
  const _AdminResponseSheet({required this.ticket});

  @override
  ConsumerState<_AdminResponseSheet> createState() =>
      _AdminResponseSheetState();
}

class _AdminResponseSheetState extends ConsumerState<_AdminResponseSheet> {
  late final TextEditingController _responseController;
  late final GlobalKey<FormState> _formKey;
  late TicketStatus _status;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _responseController = TextEditingController(
      text: widget.ticket.adminResponse ?? '',
    );
    _status = widget.ticket.status;
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text(
                'Add Admin Response',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _responseController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Enter admin response here...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Admin response cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<TicketStatus>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Change Status',
                        border: OutlineInputBorder(),
                      ),
                      items: TicketStatus.values
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() => _status = newValue);
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),

                  onPressed: _isSaving
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;

                          setState(() => _isSaving = true);

                          await ref
                              .read(agentSupportTicketNotifierProvider.notifier)
                              .updateTicketStatus(
                                adminResponse: _responseController.text.trim(),
                                status: _status,
                                ticketId: widget.ticket.id,
                              );

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                  child: _isSaving
                      ? const CircularProgressIndicator()
                      : const Text('Save Response'),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
