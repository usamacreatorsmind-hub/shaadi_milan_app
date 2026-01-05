import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../data/api/payment_api.dart';
import '../data/api/razorpay_service.dart';
import '../domain/states/payment_state.dart';

final paymentApiProvider = Provider<PaymentApi>((ref) => PaymentApi());

// We use autoDispose to ensure the notifier (and the Razorpay instance inside it)
// is disposed when the user leaves the payment screen.
final paymentProvider =
    StateNotifierProvider.autoDispose<PaymentNotifier, PaymentState>(
      (ref) => PaymentNotifier(
        ref.watch(paymentApiProvider),
        RazorpayService(), // Create a fresh service instance for this session
      ),
    );

class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentApi _api;
  final RazorpayService _razorpayService;

  PaymentNotifier(this._api, this._razorpayService)
    : super(const PaymentState());

  void init() {
    _razorpayService.init(
      onSuccess: _onSuccess,
      onError: _onError,
      onWallet: _onWallet,
    );
  }

  // This will be called automatically if the provider is autoDispose
  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  /// ONE-TIME PAYMENT
  Future<void> startOneTimePayment({
    required double amount,
    required String uid,
    required String email,
    required String fullName,
    required String phone,
  }) async {
    try {
      state = state.copyWith(status: PaymentStatus.loading);

      // Razorpay expects amount in paisa (multiply by 100)
      final amountInPaisa = (amount * 100).toInt();

      final data = await _api.createOrder(
        amount: amount, // API might expect INR or Paisa, check your backend.

        uid: uid,
        email: email,
        fullName: fullName,
        phone: phone,
      );

      _razorpayService.open({
        "key": data['key'], // rzp_test_...
        "amount": amountInPaisa, // ✅ Converted to paisa
        "name": "Arvika Marriage Bureau",

        "image":
            "https://firebasestorage.googleapis.com/v0/b/fir-app-e3a53.firebasestorage.app/o/company_files%2Flogo.png?alt=media&token=1d77300b-fa4d-4f0c-a4cb-c1772ae54b38", // Company logo
        // ✅ MUST be Razorpay order id
        "order_id": data['razorpayOrderId'],

        "prefill": {"contact": phone, "email": email},
        "notes": {"user_id": uid, "user_name": fullName},
      });
    } catch (e) {
      state = state.copyWith(
        status: PaymentStatus.failure,
        message: e.toString(),
      );
    }
  }

  /// CALLBACKS
  void _onSuccess(PaymentSuccessResponse response) {
    // Update state to success so UI can react.
    // Backend verification should happen via Webhook as per your architecture.
    state = state.copyWith(
      status: PaymentStatus.success,
      message: "Payment Successful",
      razorpayPaymentId: response.paymentId,
      razorpayOrderId: response.orderId,
      signature: response.signature,
    );
  }

  void _onError(PaymentFailureResponse response) {
    state = state.copyWith(
      status: PaymentStatus.failure,
      message: response.message ?? "Payment Failed",
    );
  }

  void _onWallet(ExternalWalletResponse response) {}
}
