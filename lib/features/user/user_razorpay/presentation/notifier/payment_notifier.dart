import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/providers.dart';
import '../../domain/states/payment.dart';

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
  StreamSubscription? _subscription;

  PaymentNotifier(this._paymentRepository, this._uid)
    : super(const PaymentState(status: PayStatus.loading)) {
    _watchUserPayment();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Watch payment data in real-time from Firestore
  void _watchUserPayment() {
    _subscription = _paymentRepository
        .watchUserPayment(_uid)
        .listen(
          (payment) {
            if (payment != null) {
              state = state.copyWith(
                status: _mapPaymentStatus(payment.status),
                payment: payment,
              );
            } else {
              state = state.copyWith(status: PayStatus.idle);
            }
          },
          onError: (e) {
            // Handle permission denied (document doesn't exist) as idle
            if (e is FirebaseException && e.code == 'permission-denied' ||
                e.toString().contains('permission-denied') ||
                e.toString().contains('PERMISSION_DENIED')) {
              state = state.copyWith(status: PayStatus.idle);
            } else {
              state = state.copyWith(status: PayStatus.failure);
            }
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
      if (!mounted) return;
      if (payment != null) {
        state = state.copyWith(
          status: _mapPaymentStatus(payment.status),
          payment: payment,
        );
      } else {
        state = state.copyWith(status: PayStatus.idle);
      }
    } catch (e) {
      if (!mounted) return;
      if (e is FirebaseException && e.code == 'permission-denied' ||
          e.toString().contains('permission-denied') ||
          e.toString().contains('PERMISSION_DENIED')) {
        state = state.copyWith(status: PayStatus.idle);
      } else {
        state = state.copyWith(status: PayStatus.failure);
      }
    }
  }
}
