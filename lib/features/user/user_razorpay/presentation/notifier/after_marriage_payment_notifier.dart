import 'package:arvika_marriage_bureau/features/auth/domain/states/user_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/providers/providers.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/repository/payment_repository.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/states/payment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class AfterMarriagePaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentRepository _paymentRepository;
  final String _userId;

  AfterMarriagePaymentNotifier(this._paymentRepository, this._userId)
    : super(PaymentState.initial());

  Future<void> fetchUserPayment() async {
    state = state.copyWith(status: PayStatus.loading);
    try {
      final payment = await _paymentRepository.fetchUserPostMarriagePayment(
        _userId,
      );
      if (payment != null) {
        state = state.copyWith(payment: payment, status: PayStatus.success);
      } else {
        state = state.copyWith(payment: null, status: PayStatus.idle);
      }
    } catch (e) {
      state = state.copyWith(status: PayStatus.failure);
    }
  }
}

final afterMarriagePaymentNotifierProvider =
    StateNotifierProvider.family<
      AfterMarriagePaymentNotifier,
      PaymentState,
      String
    >((ref, userId) {
      final paymentRepository = ref.read(paymentRepositoryProvider);
      return AfterMarriagePaymentNotifier(paymentRepository, userId);
    });
