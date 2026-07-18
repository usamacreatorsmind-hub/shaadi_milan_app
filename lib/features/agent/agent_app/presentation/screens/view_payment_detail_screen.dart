import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/features/user/user_razorpay/domain/states/payment.dart';

import '../../../../l10n/l10n_helper.dart';
import '../notifier/user_nofier.dart';

@RoutePage()
class ViewPaymentDetailScreen extends ConsumerStatefulWidget {
  final String userId;
  final String agentId;

  const ViewPaymentDetailScreen({
    super.key,
    required this.userId,
    required this.agentId,
  });
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewPaymentDetailScreenState();
}

class _ViewPaymentDetailScreenState
    extends ConsumerState<ViewPaymentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(userPaymentNotifierProvider.notifier)
          .getUserPayment(agentId: widget.agentId, userId: widget.userId);
      // Fetch after marriage payments for this user
      ref
          .read(afterMarriagePaymentsForUserNotifierProvider.notifier)
          .getAfterMarriagePaymentForUser(userId: widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userPaymentState = ref.watch(userPaymentNotifierProvider);
    final afterMarriagePaymentState = ref.watch(
      afterMarriagePaymentsForUserNotifierProvider,
    );
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.paymentDetails),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: userPaymentState.when(
        data: (payment) {
          if (payment == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.noPaymentFound,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.noPaymentsYetMessage,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: payment.status == 'SUCCESS'
                            ? [Colors.green[400]!, Colors.green[600]!]
                            : payment.status == 'FAILED'
                            ? [Colors.red[400]!, Colors.red[600]!]
                            : [Colors.orange[400]!, Colors.orange[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          payment.status == 'SUCCESS'
                              ? Icons.check_circle
                              : payment.status == 'FAILED'
                              ? Icons.cancel
                              : Icons.pending,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          payment.status,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${(payment.amount).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Payment Details
                _DetailCard(
                  title: context.l10n.paymentInformation,
                  icon: Icons.payment,
                  children: [
                    _DetailItem(
                      label: context.l10n.status,
                      value: payment.status,
                      icon: Icons.info_outline,
                    ),
                    const Divider(height: 24),
                    _DetailItem(
                      label: context.l10n.paymentId,
                      value: payment.razorpayPaymentId.isNotEmpty
                          ? payment.razorpayPaymentId
                          : context.l10n.notAvailable,
                      icon: Icons.fingerprint,
                    ),
                    const Divider(height: 24),
                    _DetailItem(
                      label: context.l10n.orderId,
                      value: payment.orderId,
                      icon: Icons.receipt,
                    ),
                    const Divider(height: 24),
                    _DetailItem(
                      label: context.l10n.razorpayOrderId,
                      value: payment.razorpayOrderId,
                      icon: Icons.confirmation_number,
                    ),
                    const Divider(height: 24),
                    _DetailItem(
                      label: context.l10n.paymentGateway,
                      value: payment.gateway.toUpperCase(),
                      icon: Icons.account_balance_wallet,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Customer Information
                _DetailCard(
                  title: context.l10n.clientInformation,
                  icon: Icons.person,
                  children: [
                    _DetailItem(
                      label: context.l10n.fullName,
                      value: payment.fullName,
                      icon: Icons.person_outline,
                    ),
                    const Divider(height: 24),
                    _DetailItem(
                      label: context.l10n.email,
                      value: payment.email,
                      icon: Icons.email,
                    ),
                    const Divider(height: 24),
                    _DetailItem(
                      label: context.l10n.phone,
                      value: payment.phone,
                      icon: Icons.phone,
                    ),

                    const Divider(height: 24),
                    _DetailItem(
                      label: context.l10n.gender,
                      value: payment.gender!,
                      icon: Icons.people,
                    ),
                    const Divider(height: 24),
                    _DetailItem(
                      label: context.l10n.religion,
                      value: payment.religion,
                      icon: Icons.people,
                    ),
                    const Divider(height: 24),
                    _DetailItem(
                      label: context.l10n.caste,
                      value: payment.caste,
                      icon: Icons.people,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Location Information (if available)
                if ((payment.region != null && payment.region!.isNotEmpty) ||
                    (payment.district != null && payment.district!.isNotEmpty))
                  _DetailCard(
                    title: context.l10n.location,
                    icon: Icons.location_on,
                    children: [
                      if (payment.region != null && payment.region!.isNotEmpty)
                        _DetailItem(
                          label: context.l10n.region,
                          value: payment.region!,
                          icon: Icons.map,
                        ),
                      if (payment.region.isNotEmpty &&
                          payment.district.isNotEmpty)
                        const Divider(height: 24),
                      if (payment.district.isNotEmpty)
                        _DetailItem(
                          label: context.l10n.district,
                          value: payment.district,
                          icon: Icons.place,
                        ),
                    ],
                  ),
                if ((payment.region != null && payment.region!.isNotEmpty) ||
                    (payment.district != null && payment.district!.isNotEmpty))
                  const SizedBox(height: 16),

                // Timestamps
                _DetailCard(
                  title: context.l10n.timeline,
                  icon: Icons.history,
                  children: [
                    _DetailItem(
                      label: context.l10n.createdAt,
                      value: _formatDateTime(payment.createdAt, context),
                      icon: Icons.calendar_today,
                    ),
                    if (payment.updatedAt != null) ...[
                      const Divider(height: 24),
                      _DetailItem(
                        label: context.l10n.lastUpdated,
                        value: _formatDateTime(payment.updatedAt!, context),
                        icon: Icons.update,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                // After Marriage Payments Section
                _buildAfterMarriagePaymentsSection(
                  afterMarriagePaymentState,
                  theme,
                ),
              ],
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(theme.primaryColor),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                context.l10n.errorLoadingPayment,
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
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime, BuildContext context) {
    if (dateTime.millisecondsSinceEpoch == 0) {
      return context.l10n.notAvailable;
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildAfterMarriagePaymentsSection(
    AsyncValue<Payment?> afterMarriagePaymentState,
    ThemeData theme,
  ) {
    final context = this.context;
    return afterMarriagePaymentState.when(
      data: (payment) {
        if (payment == null) {
          return _DetailCard(
            title: context.l10n.afterMarriagePayment,
            icon: Icons.favorite,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.sentiment_dissatisfied_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.noAfterMarriagePaymentFound,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return _DetailCard(
          title: context.l10n.afterMarriagePayment,
          icon: Icons.favorite,
          children: [_buildAfterMarriagePaymentCard(payment, theme)],
        );
      },
      loading: () => _DetailCard(
        title: context.l10n.afterMarriagePayment,
        icon: Icons.favorite,
        children: const [
          Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),

      error: (error, stack) => _DetailCard(
        title: context.l10n.afterMarriagePayment,
        icon: Icons.favorite,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.errorLoadingAfterMarriagePayment,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAfterMarriagePaymentCard(Payment payment, ThemeData theme) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Status Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              gradient: LinearGradient(
                colors: payment.status == 'SUCCESS'
                    ? [Colors.green[400]!, Colors.green[600]!]
                    : payment.status == 'FAILED'
                    ? [Colors.red[400]!, Colors.red[600]!]
                    : [Colors.orange[400]!, Colors.orange[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      payment.status == 'SUCCESS'
                          ? Icons.check_circle
                          : payment.status == 'FAILED'
                          ? Icons.cancel
                          : Icons.pending,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      payment.status,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${(payment.amount).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Payment Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _DetailItem(
                  label: context.l10n.paymentId,
                  value: payment.razorpayPaymentId.isNotEmpty
                      ? payment.razorpayPaymentId
                      : context.l10n.notAvailable,
                  icon: Icons.fingerprint,
                ),
                const Divider(height: 24),
                _DetailItem(
                  label: context.l10n.orderId,
                  value: payment.orderId.isNotEmpty
                      ? payment.orderId
                      : context.l10n.notAvailableShort,
                  icon: Icons.receipt,
                ),
                const Divider(height: 24),
                _DetailItem(
                  label: context.l10n.paymentType,
                  value: payment.paymentType.isNotEmpty
                      ? payment.paymentType
                      : context.l10n.afterMarriage,
                  icon: Icons.category,
                ),
                const Divider(height: 24),
                _DetailItem(
                  label: context.l10n.createdAt,
                  value: _formatDateTime(payment.createdAt, context),
                  icon: Icons.calendar_today,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
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
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
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
