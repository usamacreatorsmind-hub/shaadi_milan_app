import '../../../../auth/domain/states/user_state.dart';
import '../../domain/states/payment.dart';
import '../notifier/payment_notifier.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

@RoutePage()
class UserPaymentSuccessScreen extends ConsumerStatefulWidget {
  final UserEntity user;

  const UserPaymentSuccessScreen({super.key, required this.user});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserPaymentSuccessScreenState();
}

class _UserPaymentSuccessScreenState
    extends ConsumerState<UserPaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(paymentNotifierProvider(widget.user.uid).notifier)
          .fetchUserPayment();
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentNotifierProvider(widget.user.uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Status')),
      body: _buildBody(paymentState),
    );
  }

  Widget _buildBody(PaymentState state) {
    if (state.status == PayStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == PayStatus.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Error fetching payment: ${state.status}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(paymentNotifierProvider(widget.user.uid).notifier)
                    .fetchUserPayment();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // change after publishing on playstore
    if (state.status == PayStatus.idle && state.payment != null) {
      final payment = state.payment!;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Thank you for your payment. Your transaction was successful.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Payment ID',
                    payment.razorpayPaymentId ?? 'N/A',
                  ),
                  const Divider(height: 24),
                  _buildDetailRow('Order ID', payment.razorpayOrderId),
                  const Divider(height: 24),
                  _buildDetailRow('Amount', '₹${payment.amount}'),
                  const Divider(height: 24),
                  _buildDetailRow('Status', payment.status),
                  const Divider(height: 24),
                  _buildDetailRow(
                    'Date',
                    DateFormat(
                      'dd MMM yyyy, hh:mm a',
                    ).format(payment.createdAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  context.router.popUntilRoot();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      );
    }

    return const Center(child: Text('No payment details found.'));
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
