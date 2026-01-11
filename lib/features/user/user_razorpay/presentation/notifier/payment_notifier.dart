import '../../domain/providers/providers.dart';
import '../../domain/states/payment.dart';
import 'package:flutter_riverpod/legacy.dart';

// Provider family that takes uid as parameter
final paymentNotifierProvider =
    StateNotifierProvider.family<PaymentNotifier, PaymentState, String>((
      ref,
      uid,
    ) {
      final paymentRepository = ref.read(paymentRepositoryProvider);
      return PaymentNotifier(paymentRepository, uid);
    });

class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentRepository _paymentRepository;
  final String _uid;

  PaymentNotifier(this._paymentRepository, this._uid)
    : super(const PaymentState()) {
    fetchUserPayment();
  }

  Future<void> fetchUserPayment() async {
    state = state.copyWith(status: PayStatus.loading);
    try {
      final payment = await _paymentRepository.getUserPayment(_uid);
      if (payment != null) {
        state = state.copyWith(status: PayStatus.success, payment: payment);
      } else {
        state = state.copyWith(
          status: PayStatus.idle,
          message: "No payment found",
        );
      }
    } catch (e) {
      state = state.copyWith(status: PayStatus.failure, message: e.toString());
    }
  }
}
