import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../notifier/user_nofier.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class ViewUserScreen extends ConsumerStatefulWidget {
  final String userId;
  final String agentId;

  const ViewUserScreen({
    super.key,
    required this.agentId,
    required this.userId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ViewUserScreenState();
}

class _ViewUserScreenState extends ConsumerState<ViewUserScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(agentUserNotifierProvider.notifier).fetchUserById(widget.userId);
      ref
          .read(userPaymentNotifierProvider.notifier)
          .getUserPayment(agentId: widget.agentId, userId: widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(agentUserNotifierProvider);
    final paymentAsync = ref.watch(userPaymentNotifierProvider);
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
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              image: user.profileImageUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(user.profileImageUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Center(),
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
                                label: 'Wishlists',
                                value: user.wishlists.length.toString(),
                                color: Colors.pink,
                              ),
                              Container(
                                width: 1,
                                height: 50,
                                color: Colors.grey[300],
                              ),
                              _StatusItem(
                                icon: Icons.payment,
                                label: 'Payment',
                                value: paymentAsync.value?.status == 'SUCCESS'
                                    ? 'Paid'
                                    : 'Pending',
                                color: paymentAsync.value?.status == 'SUCCESS'
                                    ? Colors.green
                                    : Colors.orange,
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
                        _DetailRow(
                          icon: Icons.badge,
                          label: 'User ID',
                          value: user.uid,
                        ),
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
                    paymentAsync.when(
                      data: (payment) {
                        if (payment == null) {
                          return _SectionCard(
                            title: 'Payment Information',
                            icon: Icons.payment,
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.receipt_long_outlined,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No payment record found',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return _SectionCard(
                          title: 'Payment Information',
                          icon: Icons.payment,
                          children: [
                            _DetailRow(
                              icon: Icons.receipt,
                              label: 'Order ID',
                              value: payment.orderId,
                            ),
                            const Divider(height: 24),
                            _DetailRow(
                              icon: Icons.confirmation_number,
                              label: 'Razorpay Order ID',
                              value: payment.razorpayOrderId,
                            ),
                            const Divider(height: 24),
                            _DetailRow(
                              icon: Icons.payment,
                              label: 'Payment ID',
                              value: payment.razorpayPaymentId.isNotEmpty
                                  ? payment.razorpayPaymentId
                                  : 'Not available',
                            ),
                            const Divider(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.currency_rupee,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Amount',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${(payment.amount).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Payment Status',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: payment.status == 'SUCCESS'
                                              ? Colors.green.withValues(
                                                  alpha: 0.1,
                                                )
                                              : payment.status == 'FAILED'
                                              ? Colors.red.withValues(
                                                  alpha: 0.1,
                                                )
                                              : Colors.orange.withValues(
                                                  alpha: 0.1,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          payment.status,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: payment.status == 'SUCCESS'
                                                ? Colors.green
                                                : payment.status == 'FAILED'
                                                ? Colors.red
                                                : Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _DetailRow(
                              icon: Icons.account_balance_wallet,
                              label: 'Payment Gateway',
                              value: payment.gateway.toUpperCase(),
                            ),
                            if (payment.region != null &&
                                payment.region!.isNotEmpty) ...[
                              const Divider(height: 24),
                              _DetailRow(
                                icon: Icons.location_on,
                                label: 'Region',
                                value: payment.region!,
                              ),
                            ],
                            if (payment.district != null &&
                                payment.district!.isNotEmpty) ...[
                              const Divider(height: 24),
                              _DetailRow(
                                icon: Icons.place,
                                label: 'District',
                                value: payment.district!,
                              ),
                            ],
                            const Divider(height: 24),
                            _DetailRow(
                              icon: Icons.calendar_today,
                              label: 'Payment Date',
                              value: _formatDateTime(payment.createdAt),
                            ),
                            if (payment.updatedAt != null) ...[
                              const Divider(height: 24),
                              _DetailRow(
                                icon: Icons.update,
                                label: 'Last Updated',
                                value: _formatDateTime(payment.updatedAt!),
                              ),
                            ],
                          ],
                        );
                      },
                      error: (error, stackTrace) {
                        print("this is error");
                        print(stackTrace);
                        return _SectionCard(
                          title: 'Payment Information',
                          icon: Icons.payment,
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.red[400],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Error loading payment',
                                      style: TextStyle(
                                        color: Colors.red[600],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () {
                        return _SectionCard(
                          title: 'Payment Information',
                          icon: Icons.payment,
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                ),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                    theme.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    // Wishlists Section
                    if (user.wishlists.isNotEmpty)
                      _SectionCard(
                        title: 'Wishlists',
                        icon: Icons.list,
                        children: [
                          ...user.wishlists.asMap().entries.map((entry) {
                            final index = entry.key;
                            final wishlistId = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < user.wishlists.length - 1
                                    ? 12
                                    : 0,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      wishlistId,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),

                    const SizedBox(height: 16),
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
