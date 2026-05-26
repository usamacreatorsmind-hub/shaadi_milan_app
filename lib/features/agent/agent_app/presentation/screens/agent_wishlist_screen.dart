import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../app/router/app_router.dart';
import '../../../../auth/domain/states/user_state.dart';
import '../notifier/user_nofier.dart';
import '../notifier/wishlist_notifier.dart';
import 'agen_profile.screen.dart';

@RoutePage()
class AgentWishlistScreen extends ConsumerStatefulWidget {
  final String agentId;

  const AgentWishlistScreen({super.key, required this.agentId});

  @override
  ConsumerState<AgentWishlistScreen> createState() => _AgentWishlistScreenState();
}

class _AgentWishlistScreenState extends ConsumerState<AgentWishlistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  WishlistStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load wishlists for agent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(agentWishlistNotifierProvider.notifier).loadWishlists(widget.agentId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wishlistState = ref.watch(agentWishlistNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist Management'),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Status Filter
              _buildStatusFilter(theme),
              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.arrow_upward),
                    text: "My Users' Wishlists",
                  ),
                  Tab(
                    icon: Icon(Icons.arrow_downward),
                    text: "Leads for My Users",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: wishlistState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : wishlistState.error != null
              ? _buildErrorState(wishlistState.error!)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Wishlists where user is sender
                    _buildWishlistList(
                      wishlists: _filterBySender(wishlistState.filteredWishlists),
                      isMyUsersSender: true,
                    ),
                    // Tab 2: Wishlists where user is receiver (leads)
                    _buildWishlistList(
                      wishlists: _filterByReceiver(wishlistState.filteredWishlists),
                      isMyUsersSender: false,
                    ),
                  ],
                ),
    );
  }

  List<WishlistEntity> _filterBySender(List<WishlistEntity> wishlists) {
    return wishlists;
  }

  List<WishlistEntity> _filterByReceiver(List<WishlistEntity> wishlists) {
    return wishlists;
  }

  Widget _buildStatusFilter(ThemeData theme) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(null, "All", theme),
          ...WishlistStatus.values.map(
            (status) => _buildFilterChip(status, _getStatusLabel(status), theme),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(WishlistStatus? status, String label, ThemeData theme) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color.fromARGB(179, 15, 3, 3),
          fontSize: 12,
        ),
        backgroundColor: Colors.white24,
        selectedColor: _getStatusColor(status),
        checkmarkColor: Colors.white,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = selected ? status : null;
          });
          ref.read(agentWishlistNotifierProvider.notifier).setStatusFilter(_selectedStatus);
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Error: $error', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(agentWishlistNotifierProvider.notifier).loadWishlists(widget.agentId);
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistList({
    required List<WishlistEntity> wishlists,
    required bool isMyUsersSender,
  }) {
    if (wishlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isMyUsersSender ? Icons.favorite_border : Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isMyUsersSender
                  ? "No wishlists from your users"
                  : "No leads for your users",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(agentWishlistNotifierProvider.notifier).loadWishlists(widget.agentId);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: wishlists.length,
        itemBuilder: (context, index) {
          final wishlist = wishlists[index];
          return _AgentWishlistCard(
            wishlist: wishlist,
            agentId: widget.agentId,
            isMyUsersSender: isMyUsersSender,
            onStatusUpdate: (newStatus) async {
              await ref.read(agentWishlistNotifierProvider.notifier).updateStatus(
                    wishlistId: wishlist.id,
                    status: newStatus,
                    updatedBy: widget.agentId,
                  );
            },
          );
        },
      ),
    );
  }

  String _getStatusLabel(WishlistStatus status) {
    switch (status) {
      case WishlistStatus.pending:
        return "Pending";
      case WishlistStatus.contacted:
        return "Contacted";
      case WishlistStatus.interested:
        return "Interested";
      case WishlistStatus.notInterested:
        return "Not Interested";
      case WishlistStatus.closed:
        return "Closed";
    }
  }

  Color _getStatusColor(WishlistStatus? status) {
    if (status == null) return Colors.blue;
    switch (status) {
      case WishlistStatus.pending:
        return Colors.orange;
      case WishlistStatus.contacted:
        return Colors.blue;
      case WishlistStatus.interested:
        return Colors.green;
      case WishlistStatus.notInterested:
        return Colors.red;
      case WishlistStatus.closed:
        return Colors.grey;
    }
  }
}

/// ==========================================
/// Agent Wishlist Card Widget
/// ==========================================
class _AgentWishlistCard extends ConsumerWidget {
  final WishlistEntity wishlist;
  final String agentId;
  final bool isMyUsersSender;
  final Future<void> Function(String status) onStatusUpdate;

  const _AgentWishlistCard({
    required this.wishlist,
    required this.agentId,
    required this.isMyUsersSender,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine which user to show based on perspective
    final myUserId = isMyUsersSender ? wishlist.senderId : wishlist.receiverId;
    final otherUserId = isMyUsersSender ? wishlist.receiverId : wishlist.senderId;
    final otherAgentId = isMyUsersSender ? wishlist.receiverAgent : wishlist.senderAgent;

    final myUserAsync = ref.watch(wishlistUserProvider(myUserId));
    final otherUserAsync = ref.watch(wishlistUserProvider(otherUserId));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status badge
            Row(
              children: [
                Icon(
                  isMyUsersSender ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isMyUsersSender ? Colors.blue : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isMyUsersSender ? "Outgoing Interest" : "Incoming Lead",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isMyUsersSender ? Colors.blue : Colors.green,
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(wishlist.status),
              ],
            ),
            const Divider(height: 16),

            // My User Section
            _buildUserSection(
              context,
              ref,
              label: "Your User",
              userAsync: myUserAsync,
              userId: myUserId,
              showActions: true,
            ),

            const SizedBox(height: 8),
            Center(
              child: Icon(
                isMyUsersSender ? Icons.favorite : Icons.arrow_downward,
                color: Colors.pink,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),

            // Other User Section
            _buildUserSection(
              context,
              ref,
              label: isMyUsersSender ? "Interested In" : "Interested By",
              userAsync: otherUserAsync,
              userId: otherUserId,
              showActions: false,
              otherAgentId: otherAgentId,
            ),

            const Divider(height: 16),

            // Action Row
            Row(
              children: [
                Text(
                  'Updated: ${_formatDateTime(wishlist.updatedAt)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showStatusUpdateDialog(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Update Status'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required AsyncValue<UserEntity?> userAsync,
    required String userId,
    required bool showActions,
    String? otherAgentId,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        userAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => Text('Error loading user: $userId'),
          data: (user) {
            if (user == null) {
              return Text('User not found: $userId');
            }
            return Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: user.profileImageUrl.isNotEmpty
                      ? NetworkImage(user.profileImageUrl)
                      : null,
                  child: user.profileImageUrl.isEmpty
                      ? Icon(Icons.person, color: Colors.grey[600])
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName.isNotEmpty ? user.fullName : 'N/A',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        user.phone.isNotEmpty ? user.phone : 'No phone',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (showActions) ...[
                  IconButton(
                    icon: const Icon(Icons.phone, color: Colors.green),
                    onPressed: () => launchUrl(Uri.parse('tel:${user.phone}')),
                    tooltip: 'Call',
                  ),
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.blue),
                    onPressed: () {
                      context.router.push(ViewUserRoute(userId: userId));
                    },
                    tooltip: 'View Details',
                  ),
                ] else if (otherAgentId != null && otherAgentId.isNotEmpty) ...[
                  OutlinedButton.icon(
                    onPressed: () => _showAgentDialog(context, ref, otherAgentId),
                    icon: const Icon(Icons.support_agent, size: 16),
                    label: const Text('Contact Agent'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status).withValues(alpha: 0.5)),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: WishlistStatus.values.map((status) {
            final isSelected = wishlist.status == status.name;
            return ListTile(
              leading: Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status.name),
              ),
              title: Text(_getStatusLabel(status.name)),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              selected: isSelected,
              onTap: () async {
                Navigator.pop(context);
                try {
                  await onStatusUpdate(status.name);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Status updated to ${_getStatusLabel(status.name)}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update status: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAgentDialog(BuildContext context, WidgetRef ref, String otherAgentId) {
    showDialog(
      context: context,
      builder: (_) => _AgentContactDialog(agentId: otherAgentId),
    );
  }

  IconData _getStatusIcon(WishlistStatus status) {
    switch (status) {
      case WishlistStatus.pending:
        return Icons.hourglass_empty;
      case WishlistStatus.contacted:
        return Icons.phone;
      case WishlistStatus.interested:
        return Icons.thumb_up;
      case WishlistStatus.notInterested:
        return Icons.thumb_down;
      case WishlistStatus.closed:
        return Icons.check_circle;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'contacted':
        return 'Contacted';
      case 'interested':
        return 'Interested';
      case 'notinterested':
        return 'Not Interested';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'contacted':
        return Colors.blue;
      case 'interested':
        return Colors.green;
      case 'notinterested':
        return Colors.red;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    if (dateTime.millisecondsSinceEpoch == 0) return 'N/A';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

/// ==========================================
/// Agent Contact Dialog
/// ==========================================
class _AgentContactDialog extends ConsumerWidget {
  final String agentId;

  const _AgentContactDialog({required this.agentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentAsync = ref.watch(agentProvider(agentId));

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Contact Agent'),
      content: agentAsync.when(
        loading: () => const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => const Text('Failed to load agent info'),
        data: (agent) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              backgroundImage: agent.profileImageUrl.isNotEmpty
                  ? NetworkImage(agent.profileImageUrl)
                  : null,
              child: agent.profileImageUrl.isEmpty
                  ? const Icon(Icons.support_agent, size: 40, color: Colors.blue)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              agent.agentName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, agent.agentMobile),
            _buildInfoRow(Icons.email, agent.agentEmail),
            _buildInfoRow(Icons.location_on, '${agent.agentCity}, ${agent.agentState}'),
          ],
        ),
      ),
      actions: agentAsync.when(
        loading: () => [],
        error: (_, _) => [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
        data: (agent) => [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (agent.agentMobile.isNotEmpty) ...[
            TextButton.icon(
              onPressed: () {
                final number = agent.agentMobile.replaceAll(RegExp(r'[^0-9]'), '');
                final url = 'https://wa.me/$number?text=Hi, I am contacting you regarding a matrimony profile.';
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.message, size: 18),
              label: const Text('WhatsApp'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                launchUrl(Uri.parse('tel:${agent.agentMobile}'));
              },
              icon: const Icon(Icons.phone, size: 18),
              label: const Text('Call'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
