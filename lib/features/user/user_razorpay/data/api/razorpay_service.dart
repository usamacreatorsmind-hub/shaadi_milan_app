import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  Razorpay? _razorpay;

  void init({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    required Function(ExternalWalletResponse) onWallet,
  }) {
    _razorpay?.clear(); // Clear existing instance if any
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, onWallet);
  }

  void open(Map<String, dynamic> options) {
    _razorpay?.open(options);
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }
}
