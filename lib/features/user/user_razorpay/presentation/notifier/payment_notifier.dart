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
    : super(const PaymentState(status: PayStatus.loading)) {
    _watchUserPayment();
  }

  /// Watch payment data in real-time from Firestore
  void _watchUserPayment() {
    _paymentRepository
        .watchUserPayment(_uid)
        .listen(
          (payment) {
            if (payment != null) {
              state = state.copyWith(
                status: _mapPaymentStatus(payment.status),
                payment: payment,
              );
            } else {
              state = state.copyWith(
                status: PayStatus.idle,
                message: "No payment found",
              );
            }
          },
          onError: (e) {
            state = state.copyWith(
              status: PayStatus.failure,
              message: e.toString(),
            );
          },
        );
  }

  /// Map server payment status to PayStatus enum
  PayStatus _mapPaymentStatus(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return PayStatus.success;
      case 'FAILED':
        return PayStatus.failure;
      case 'PENDING':
        return PayStatus.processing;
      default:
        return PayStatus.idle;
    }
  }

  /// Fetch payment data once (useful for manual refresh)
  Future<void> fetchUserPayment() async {
    state = state.copyWith(status: PayStatus.loading);
    try {
      final payment = await _paymentRepository.getUserPayment(_uid);
      if (payment != null) {
        state = state.copyWith(
          status: _mapPaymentStatus(payment.status),
          payment: payment,
        );
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
