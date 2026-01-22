import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../data/api/payment_api.dart';
import '../../data/api/razorpay_service.dart';
import '../../domain/states/payment.dart';

final paymentApiProvider = Provider<PaymentApi>((ref) => PaymentApi());

// We use autoDispose to ensure the notifier (and the Razorpay instance inside it)
// is disposed when the user leaves the payment screen.
final paymentProvider =
    StateNotifierProvider.autoDispose<PaymentApiNotifier, PaymentState>(
      (ref) => PaymentApiNotifier(
        ref.watch(paymentApiProvider),
        RazorpayService(), // Create a fresh service instance for this session
      ),
    );

class PaymentApiNotifier extends StateNotifier<PaymentState> {
  final PaymentApi _api;
  final RazorpayService _razorpayService;

  PaymentApiNotifier(this._api, this._razorpayService)
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
  Future<void> startPayment({
    required double amount,
    required String uid,
    required String email,
    required String fullName,
    required String phone,
    required String agentId,
    required String region,
    required String paymentType,
    required String district,
    required String gender,
  }) async {
    try {
      state = state.copyWith(status: PayStatus.loading);
      debugPrint("Printing all data here");
      debugPrint("Amount: $amount");
      debugPrint("UID: $uid");
      debugPrint("Email: $email");
      debugPrint("FullName: $fullName");
      debugPrint("Phone: $phone");
      debugPrint("AgentId: $agentId");
      debugPrint("PaymentType: $paymentType");
      debugPrint("Region: $region");
      debugPrint("District: $district");
      debugPrint("Gender: $gender");

      // Razorpay expects amount in paisa (multiply by 100)
      final amountInPaisa = (amount * 100).toInt();

      final data = await _api.createOrder(
        amount: amount, // API might expect INR or Paisa, check your backend.
        agentId: agentId,
        uid: uid,
        paymentType: paymentType,
        email: email,
        fullName: fullName,
        phone: phone,
        region: region,
        district: district,
        gender: gender,
      );

      // print response
      debugPrint("API Response: $data");

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
      state = state.copyWith(status: PayStatus.failure);
    }
  }

  /// CALLBACKS
  void _onSuccess(PaymentSuccessResponse response) {
    // Update state to success so UI can react.
    // Backend verification should happen via Webhook as per your architecture.
    state = state.copyWith(
      status: PayStatus.success,

      razorpayPaymentId: response.paymentId,
      razorpayOrderId: response.orderId,
      signature: response.signature,
    );
  }

  void _onError(PaymentFailureResponse response) {
    state = state.copyWith(status: PayStatus.failure);
  }

  void _onWallet(ExternalWalletResponse response) {}
}
