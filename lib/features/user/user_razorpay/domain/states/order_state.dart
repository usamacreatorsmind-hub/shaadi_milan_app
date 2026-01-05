class OrderModel {
  final String orderId;
  final String userId;

  final double amount;
  final String status; // PENDING | SUCCESS | FAILED
  final String gateway; // razorpay | cashfree

  final String? gatewayOrderId;
  final String? paymentId;

  final bool isSubscription;

  final DateTime createdAt;
  final DateTime? paidAt;

  const OrderModel({
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.status,
    required this.gateway,
    this.gatewayOrderId,
    this.paymentId,
    this.isSubscription = false,
    required this.createdAt,
    this.paidAt,
  });

  // ---------------- COPY WITH ----------------
  OrderModel copyWith({String? status, String? paymentId, DateTime? paidAt}) {
    return OrderModel(
      orderId: orderId,
      userId: userId,
      amount: amount,
      status: status ?? this.status,
      gateway: gateway,
      gatewayOrderId: gatewayOrderId,
      paymentId: paymentId ?? this.paymentId,
      isSubscription: isSubscription,
      createdAt: createdAt,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  // ---------------- FIRESTORE ----------------
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'amount': amount,
      'status': status,
      'gateway': gateway,
      'gatewayOrderId': gatewayOrderId,
      'paymentId': paymentId,
      'isSubscription': isSubscription,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'],
      userId: map['userId'],
      amount: (map['amount'] as num).toDouble(),
      status: map['status'],
      gateway: map['gateway'],
      gatewayOrderId: map['gatewayOrderId'],
      paymentId: map['paymentId'],
      isSubscription: map['isSubscription'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      paidAt: map['paidAt'] != null ? DateTime.parse(map['paidAt']) : null,
    );
  }
}

class OrderState {
  final OrderModel? order;
  final bool isLoading;
  final String? error;

  const OrderState({this.order, this.isLoading = false, this.error});

  OrderState copyWith({OrderModel? order, bool? isLoading, String? error}) {
    return OrderState(
      order: order ?? this.order,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  static const initial = OrderState(order: null, isLoading: false, error: null);
}
