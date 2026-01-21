import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/features/agent/agent_app/presentation/screens/agen_profile.screen.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../notifier/user_nofier.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class ViewWishListUserScreen extends ConsumerStatefulWidget {
  final String userId;

  const ViewWishListUserScreen({super.key, required this.userId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ViewUserScreenState();
}

class _ViewUserScreenState extends ConsumerState<ViewWishListUserScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(agentUserNotifierProvider.notifier).fetchUserById(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(agentUserNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'User Not Found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    // Header Section with Avatar
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                      child: Column(
                        children: [
                          // Positioned(child: child),
                          // Avatar
                          Hero(
                            tag: 'user-avatar-${user.uid}',
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                image: user.profileImageUrl.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          user.profileImageUrl,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                              ),
                              child: Center(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Name
                          Text(
                            user.fullName,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          // Email
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onPrimary.withOpacity(
                                0.9,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Profile Status Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatusItem(
                                icon: Icons.check_circle,
                                label: 'Profile Status',
                                value: user.isProfileCreated
                                    ? 'Created'
                                    : 'Pending',
                                color: user.isProfileCreated
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              Container(
                                width: 1,
                                height: 50,
                                color: Colors.grey[300],
                              ),
                              _StatusItem(
                                icon: Icons.favorite,
                                label: 'Profile',
                                value: user.isProfileCreated ? 'Active' : 'Pending',
                                color: Colors.pink,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Contact Information
                    _SectionCard(
                      title: 'Contact Information',
                      icon: Icons.contact_mail,
                      children: [
                        _DetailRow(
                          icon: Icons.phone,
                          label: 'Phone',
                          value: user.phone.isNotEmpty
                              ? user.phone
                              : 'Not provided',
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.email,
                          label: 'Email',
                          value: user.email,
                        ),
                      ],
                    ),

                    // Account Information
                    _SectionCard(
                      title: 'Account Information',
                      icon: Icons.account_box,
                      children: [
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.verified_user,
                          label: 'Role',
                          value: user.role.isNotEmpty ? user.role : 'User',
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.category,
                          label: 'User Type',
                          value: user.userType.isNotEmpty
                              ? user.userType
                              : 'Not specified',
                        ),
                      ],
                    ),

                    // Matrimony Information
                    _SectionCard(
                      title: 'Matrimony Information',
                      icon: Icons.favorite_border,
                      children: [
                        _DetailRow(
                          icon: Icons.fingerprint,
                          label: 'Matrimony ID',
                          value: user.metrimonyId.isNotEmpty
                              ? user.metrimonyId
                              : 'Not assigned',
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.person_pin,
                          label: 'Profile ID',
                          value: user.profileId.isNotEmpty
                              ? user.profileId
                              : 'Not assigned',
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.supervisor_account,
                          label: 'Agent ID',
                          value: user.agentId.isNotEmpty
                              ? user.agentId
                              : 'Not assigned',
                        ),
                      ],
                    ),

                    // Activity Information
                    _SectionCard(
                      title: 'Activity',
                      icon: Icons.history,
                      children: [
                        _DetailRow(
                          icon: Icons.calendar_today,
                          label: 'Created At',
                          value: _formatDateTime(user.createdAt),
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.access_time,
                          label: 'Last Seen',
                          value: _formatDateTime(user.lastSeen),
                        ),
                      ],
                    ),

                    // Payment Information

                    // Wishlists Section
                    // if (user.wishlists.isNotEmpty)
                    //   _SectionCard(
                    //     title: 'Wishlists',
                    //     icon: Icons.list,
                    //     children: [
                    //       ...user.wishlists.asMap().entries.map((entry) {
                    //         final index = entry.key;
                    //         final wishlistId = entry.value;

                    //         return Padding(
                    //           padding: EdgeInsets.only(
                    //             bottom: index < user.wishlists.length - 1
                    //                 ? 12
                    //                 : 0,
                    //           ),
                    //           child: Row(
                    //             children: [
                    //               Container(
                    //                 width: 32,
                    //                 height: 32,
                    //                 decoration: BoxDecoration(
                    //                   color: theme.primaryColor.withOpacity(
                    //                     0.1,
                    //                   ),
                    //                   borderRadius: BorderRadius.circular(8),
                    //                 ),
                    //                 child: Center(
                    //                   child: Text(
                    //                     '${index + 1}',
                    //                     style: TextStyle(
                    //                       fontWeight: FontWeight.bold,
                    //                       color: theme.primaryColor,
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //               const SizedBox(width: 12),
                    //               Expanded(
                    //                 child: _WishlistUserTile(
                    //                   profileId: wishlistId.profileId,

                    //                   currentUserAgentId: user.agentId,
                    //                   status: wishlistId.status,
                    //                   updatedAt: wishlistId.updatedAt,
                    //                   formatDateTime: _formatDateTime,
                    //                   onTap: () {
                    //                     context.router.push(
                    //                       ViewUserRoute(
                    //                         userId: wishlistId.profileId,
                    //                       ),
                    //                     );
                    //                   },
                    //                 ),
                    //               ),

                    //               // _DetailRow(
                    //               //   icon: Icons.person_add,
                    //               //   label: 'Wishlist Item ${index + 1}',
                    //               //   value: wishlistId.profileId,
                    //               // ),
                    //             ],
                    //           ),
                    //         );
                    //       }),
                    //     ],
                    //   ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Handle call action
                            launchUrl(Uri.parse('tel:${user.phone}'));

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Contacting ${user.fullName}...'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            launchUrl(Uri.parse('mailto:${user.email}'));

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Mailing ${user.fullName}...'),

                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.post_add),
                          label: const Text('Mail'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) {
          debugPrint(stackTrace.toString());
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  'Error Loading User',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(agentUserNotifierProvider.notifier)
                        .fetchUserById(widget.userId);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        },
        loading: () {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading User...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    if (dateTime.millisecondsSinceEpoch == 0) {
      return 'Not available';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// ==========================================
// Status Item Widget
// ==========================================
class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatusItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ==========================================
// Section Card Widget
// ==========================================
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: theme.primaryColor, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// Detail Row Widget
// ==========================================
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// Wishlist User Tile Widget
// ==========================================
class _WishlistUserTile extends ConsumerWidget {
  final String profileId;
  final String status;
  final DateTime updatedAt;
  final String currentUserAgentId;

  final String Function(DateTime) formatDateTime;
  final VoidCallback onTap;

  const _WishlistUserTile({
    required this.profileId,

    required this.currentUserAgentId,
    required this.status,
    required this.updatedAt,
    required this.formatDateTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(wishlistUserProvider(profileId));
    var isSameAgent = false;

    return GestureDetector(
      onTap: onTap,
      child: userAsync.when(
        data: (user) {
          if (user == null) {
            return _buildPlaceholder('User not found');
          }

          isSameAgent = currentUserAgentId == user.agentId;

          return Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 245, 236, 236),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info Row
                Row(
                  children: [
                    // Profile Image
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
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName.isNotEmpty
                                ? user.fullName
                                : 'No Name',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.phone.isNotEmpty ? user.phone : 'No phone',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    status,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: _getStatusColor(status),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatDateTime(updatedAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
                // Agent Contact Button
                if (user.agentId.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final isSameAgent =
                              currentUserAgentId == user.agentId;

                          if (isSameAgent) {
                            _showSameAgentDialog(context);
                          } else {
                            if (user.agentId.isNotEmpty) {
                              showAgentDialog(context, ref, user.agentId);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Agent ID not available for this user.',
                                  ),
                                ),
                              );
                            }
                          }
                        },

                        icon: Icon(
                          isSameAgent
                              ? Icons.check_circle_outline
                              : Icons.person,
                        ),

                        label: Text(
                          isSameAgent ? 'Same Agent' : 'Contact Agent',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isSameAgent
                              ? Colors.green
                              : Colors.blue,
                          side: BorderSide(
                            color: isSameAgent ? Colors.green : Colors.blue,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        error: (_, _) => _buildPlaceholder('Error loading user'),
      ),
    );
  }

  Widget _buildPlaceholder(String message) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person_off, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Text(message, style: TextStyle(color: Colors.grey[600])),
      ],
    );
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

  void _showSameAgentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Same Agent'),
        content: const Text(
          'This user is registered under the same agent. No need to contact another agent for the matrimony process.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showAgentDialog(BuildContext context, WidgetRef ref, String agentId) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _AgentDialog(agentId: agentId),
    );
  }

  Widget _buildAgentInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                Text(
                  value.isNotEmpty ? value : 'Not available',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentDialog extends ConsumerWidget {
  final String agentId;

  const _AgentDialog({required this.agentId});
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(agent) {
    if (agent.isApproved) {
      return const Chip(
        label: Text('Approved'),
        backgroundColor: Colors.greenAccent,
      );
    }
    if (agent.isRejected) {
      return const Chip(
        label: Text('Rejected'),
        backgroundColor: Colors.redAccent,
      );
    }
    return const Chip(
      label: Text('Pending'),
      backgroundColor: Colors.orangeAccent,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentAsync = ref.watch(agentProvider(agentId));

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      title: agentAsync.when(
        data: (agent) => Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.blue.withOpacity(0.1),
              backgroundImage: agent.profileImageUrl.isNotEmpty
                  ? NetworkImage(agent.profileImageUrl)
                  : null,
              child: agent.profileImageUrl.isEmpty
                  ? const Icon(Icons.support_agent, color: Colors.blue)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                agent.agentName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        loading: () => const Text('Agent Details'),
        error: (_, __) => const Text('Agent Details'),
      ),
      content: agentAsync.when(
        loading: () => const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const SizedBox(
          height: 120,
          child: Center(child: Text('Failed to load agent info')),
        ),
        data: (agent) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildInfoRow(Icons.badge, 'Agent ID', agent.agentId),
              _buildInfoRow(Icons.phone, 'Phone', agent.agentMobile),
              const Divider(),
              _buildInfoRow(Icons.email, 'Email', agent.agentEmail),
              const Divider(),
              _buildInfoRow(
                Icons.location_on,
                'Location',
                '${agent.agentCity}, ${agent.agentState}',
              ),
              const Divider(),
              _buildStatusChip(agent),
            ],
          ),
        ),
      ),
      actions: agentAsync.when(
        data: (agent) => [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (agent.agentMobile.isNotEmpty) ...[
            TextButton.icon(
              onPressed: () {
                final number = agent.agentMobile.replaceAll(
                  RegExp(r'[^0-9]'),
                  '',
                );
                final url =
                    'https://wa.me/$number?text=Hi, I am contacting you regarding a matrimony profile.';
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.message, size: 18),
              label: const Text('WhatsApp'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                launchUrl(
                  Uri.parse('tel:${agent.agentMobile}'),
                  mode: LaunchMode.externalApplication,
                );
              },
              icon: const Icon(Icons.phone, size: 18),
              label: const Text('Call'),
            ),
          ],
        ],
        loading: () => [],
        error: (_, __) => [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
