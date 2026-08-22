import '../../../../../app/router/app_router.dart';
import '../../../../auth/domain/states/user_state.dart';
import '../../domain/states/payment.dart';
import '../notifier/payment_notifier.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/constants/app_labels.dart';

@RoutePage()
class UserPaymentSuccessScreen extends ConsumerStatefulWidget {
  final UserEntity user;

  const UserPaymentSuccessScreen({super.key, required this.user});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserPaymentSuccessScreenState();
}

class _UserPaymentSuccessScreenState extends ConsumerState<UserPaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentNotifierProvider(widget.user.uid).notifier).fetchUserPayment();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paymentState = ref.watch(paymentNotifierProvider(widget.user.uid));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLabels.premiumMembership(context), style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _buildBody(paymentState, theme),
    );
  }

  Widget _buildBody(PaymentState state, ThemeData theme) {
    if (state.status == PayStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == PayStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: 80),
              const SizedBox(height: 24),
              Text('Something went wrong', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'We couldn\'t fetch your payment details. Please try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => ref.read(paymentNotifierProvider(widget.user.uid).notifier).fetchUserPayment(),
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.status == PayStatus.success && state.payment != null) {
      final payment = state.payment!;
      return SingleChildScrollView(
        child: Column(
          children: [
            // Top Success Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [theme.primaryColor.withValues(alpha: 0.05), Colors.white],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                    child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLabels.premiumActive(context),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLabels.premiumMemberMessage(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
                  ),
                ],
              ),
            ),

            // Benefits Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your Exclusive Benefits",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitItem(
                    Icons.chat_bubble_rounded,
                    "Unlimited Direct Chat",
                    "Connect with anyone instantly without restrictions.",
                  ),
                  _buildBenefitItem(Icons.visibility_rounded, "Advanced Filters", "Find your perfect match with detailed preferences."),
                  _buildBenefitItem(Icons.bolt_rounded, "Profile Boost", "Appear 3x more often in searches for higher visibility."),
                  _buildBenefitItem(Icons.star_rounded, "Priority Support", "Dedicated support team to help you on your journey."),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Transaction Details Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Transaction Details",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow('Transaction ID', payment.razorpayPaymentId.isEmpty ? "N/A" : payment.razorpayPaymentId),
                    _buildDetailRow('Order ID', payment.razorpayOrderId),
                    _buildDetailRow('Amount Paid', '₹${payment.amount}', isBold: true),
                    _buildDetailRow('Status', payment.status.toUpperCase(), valueColor: Colors.green),
                    _buildDetailRow('Date & Time', DateFormat('dd MMM yyyy, hh:mm a').format(payment.createdAt)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Back Home Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.router.popUntilRoot(),
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                  child: const Text('Back to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.workspace_premium_outlined, size: 80, color: theme.primaryColor.withValues(alpha: 0.2)),
          const SizedBox(height: 24),
          const Text('No Active Membership', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Upgrade today to unlock all features.', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: () => context.router.push(UserPremiumPlansRoute()), child: const Text('View Plans')),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.red, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, color: valueColor ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
