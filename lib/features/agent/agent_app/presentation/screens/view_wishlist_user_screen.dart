import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/features/agent/agent_app/presentation/screens/agen_profile.screen.dart';
import 'package:shadi_milan/features/auth/domain/states/agent_state.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/l10n_helper.dart';
import '../notifier/user_nofier.dart';

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
        title: Text(context.l10n.userDetails),
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
                    context.l10n.userNotFound,
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
                              child: const Center(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        
                        
                      
                      
                         BilingualParser(
                    value:  user.fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                        
                         
                          const SizedBox(height: 8),
                          // Email
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onPrimary.withValues(
                                alpha: 0.9,
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
                                label: context.l10n.profileStatus,
                                value: user.isProfileCreated
                                    ? context.l10n.created
                                    : context.l10n.notCreated,
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
                                label: context.l10n.profile,
                                value: user.isProfileCreated
                                    ? context.l10n.active
                                    : context.l10n.notCreated,
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
                      title: context.l10n.contactInformation,
                      icon: Icons.contact_mail,
                      children: [
                        _DetailRow(
                          icon: Icons.phone,
                          label: context.l10n.phone,
                          value: user.phone.isNotEmpty
                              ? user.phone
                              : context.l10n.notProvided,
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.email,
                          label: context.l10n.email,
                          value: user.email,
                        ),
                      ],
                    ),

                    // Account Information
                    _SectionCard(
                      title: context.l10n.accountInformation,
                      icon: Icons.account_box,
                      children: [
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.verified_user,
                          label: context.l10n.role,
                          value: user.role.isNotEmpty
                              ? user.role
                              : context.l10n.userRole,
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.category,
                          label: 'User Type',
                          value: user.userType.isNotEmpty
                              ? user.userType
                              : context.l10n.notSpecified,
                        ),
                      ],
                    ),

                    // Matrimony Information
                    _SectionCard(
                      title: context.l10n.matrimonyInformation,
                      icon: Icons.favorite_border,
                      children: [
                        _DetailRow(
                          icon: Icons.fingerprint,
                          label: 'Matrimony ID',
                          value: user.metrimonyId.isNotEmpty
                              ? user.metrimonyId
                              : context.l10n.notAssigned,
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.person_pin,
                          label: 'Profile ID',
                          value: user.profileId.isNotEmpty
                              ? user.profileId
                              : context.l10n.notAssigned,
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.supervisor_account,
                          label: context.l10n.staffId,
                          value: user.agentId.isNotEmpty
                              ? user.agentId
                              : context.l10n.notAssigned,
                        ),
                      ],
                    ),

                    // Activity Information
                    _SectionCard(
                      title: context.l10n.activity,
                      icon: Icons.history,
                      children: [
                        _DetailRow(
                          icon: Icons.calendar_today,
                          label: context.l10n.createdAt,
                          value: _formatDateTime(user.createdAt, context),
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.access_time,
                          label: context.l10n.lastSeen,
                          value: _formatDateTime(user.lastSeen, context),
                        ),
                      ],
                    ),
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
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            launchUrl(Uri.parse('tel:${user.phone}'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.l10n.contactingUser(user.fullName.en),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone),
                          label: Text(context.l10n.call),
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
                                content: Text(
                                  context.l10n.mailingUser(user.fullName.en),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.post_add),
                          label: Text(context.l10n.mail),
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
                  context.l10n.errorLoadingUser,
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
                  label: Text(context.l10n.retry),
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
                  context.l10n.loadingUser,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime, BuildContext context) {
    if (dateTime.millisecondsSinceEpoch == 0) {
      return context.l10n.notAvailable;
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

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

class _WishlistUserTile extends ConsumerWidget {
  final String profileId;
  final String status;
  final DateTime updatedAt;
  final String currentUserAgentId;
  final String Function(DateTime, BuildContext) formatDateTime;
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
            return _buildPlaceholder(context.l10n.userNotFound);
          }
          isSameAgent = currentUserAgentId == user.agentId;

          return Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 245, 236, 236),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
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
                Row(
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

                          
                          BilingualParser(
                          
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ), value:    user.fullName,
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
                                user.phone.isNotEmpty
                                    ? user.phone
                                    : context.l10n.noPhone,
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
                                  _getLocalizedStatus(status, context),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: _getStatusColor(status),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatDateTime(updatedAt, context),
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
                if (user.agentId.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (currentUserAgentId == user.agentId) {
                            _showSameAgentDialog(context);
                          } else {
                            showAgentDialog(context, ref, user.agentId);
                          }
                        },
                        icon: Icon(
                          isSameAgent
                              ? Icons.check_circle_outline
                              : Icons.person,
                        ),
                        label: Text(
                          isSameAgent
                              ? context.l10n.sameAgent
                              : context.l10n.contactAgent,
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
        error: (_, _) => _buildPlaceholder(context.l10n.errorLoadingUser),
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

  String _getLocalizedStatus(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'pending':
        return context.l10n.pending;
      case 'contacted':
        return context.l10n.statusContacted;
      case 'interested':
        return context.l10n.statusInterested;
      case 'notinterested':
        return context.l10n.statusNotInterested;
      case 'closed':
        return context.l10n.closed;
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

  void _showSameAgentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: Text(context.l10n.sameAgent),
        content: Text(context.l10n.sameAgentMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.ok),
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
}

class _AgentDialog extends ConsumerWidget {
  final String agentId;

  const _AgentDialog({required this.agentId});

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
        loading: () => Text(context.l10n.agentDetails),
        error: (error, stackTrace) => Text(context.l10n.agentDetails),
      ),
      content: agentAsync.when(
        loading: () => const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stackTrace) => SizedBox(
          height: 120,
          child: Center(child: Text(context.l10n.failedToLoadAgentInfo)),
        ),
        data: (agent) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                Icons.phone,
                context.l10n.phone,
                agent.agentMobile,
                context,
              ),
              const Divider(),
              _buildInfoRow(
                Icons.email,
                context.l10n.email,
                agent.agentEmail,
                context,
              ),
              const Divider(),
              _buildInfoRow(
                Icons.location_on,
                context.l10n.location,
                '${agent.agentCity}, ${agent.agentState}',
                context,
              ),
              const Divider(),
              _buildStatusChip(agent, context),
            ],
          ),
        ),
      ),
      actions: agentAsync.when(
        data: (agent) => [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          if (agent.agentMobile.isNotEmpty) ...[
            TextButton.icon(
              onPressed: () {
                final number = agent.agentMobile.replaceAll(
                  RegExp(r'[^0-9]'),
                  '',
                );
                final url =
                    'https://wa.me/$number?text=${Uri.encodeComponent(context.l10n.whatsappContactMessage)}';
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.message, size: 18),
              label: Text(context.l10n.whatsapp),
            ),
            ElevatedButton.icon(
              onPressed: () {
                launchUrl(
                  Uri.parse('tel:${agent.agentMobile}'),
                  mode: LaunchMode.externalApplication,
                );
              },
              icon: const Icon(Icons.phone, size: 18),
              label: Text(context.l10n.call),
            ),
          ],
        ],
        loading: () => [],
        error: (error, stackTrace) => [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    BuildContext context,
  ) {
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
                value.isNotEmpty ? value : context.l10n.notAvailable,
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

  Widget _buildStatusChip(AgentEntity agent, BuildContext context) {
    if (agent.isApproved) {
      return Chip(
        label: Text(context.l10n.approved),
        backgroundColor: Colors.greenAccent,
      );
    }
    if (agent.isRejected) {
      return Chip(
        label: Text(context.l10n.rejected),
        backgroundColor: Colors.redAccent,
      );
    }
    return Chip(
      label: Text(context.l10n.pending),
      backgroundColor: Colors.orangeAccent,
    );
  }
}
