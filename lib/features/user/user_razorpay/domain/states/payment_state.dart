enum PaymentStatus {
  idle,
  loading,
  processing, // 👈 waiting for webhook
  success,
  failure,
}

class PaymentState {
  final PaymentStatus status;
  final String? message;
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? signature;

  const PaymentState({
    this.status = PaymentStatus.idle,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.signature,
    this.message,
  });

  PaymentState copyWith({
    PaymentStatus? status,
    String? message,
    String? razorpayPaymentId,
    String? razorpayOrderId,
    String? signature,
  }) {
    return PaymentState(
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      signature: signature ?? this.signature,

      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
